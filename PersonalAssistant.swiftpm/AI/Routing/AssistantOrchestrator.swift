// AI/Routing/AssistantOrchestrator.swift
// Orchestrates user turn: context building, routing, streaming, persistence, error recovery.
// Per V3 §AI/Routing/AssistantOrchestrator.swift blueprint and Algorithm B03.

import Foundation

actor AssistantOrchestrator {

    private let conversationRepository: ConversationRepository
    private let configurationRepository: ConfigurationRepository
    private let memoryRepository: MemoryRepository
    private let auditRepository: AuditRepository
    private let router: ModelRouter
    private let policyEngine: ToolPolicyEngine

    init(
        conversationRepository: ConversationRepository,
        configurationRepository: ConfigurationRepository,
        memoryRepository: MemoryRepository,
        auditRepository: AuditRepository,
        modelRouter: ModelRouter,
        policyEngine: ToolPolicyEngine = ToolPolicyEngine()
    ) {
        self.conversationRepository = conversationRepository
        self.configurationRepository = configurationRepository
        self.memoryRepository = memoryRepository
        self.auditRepository = auditRepository
        self.router = modelRouter
        self.policyEngine = policyEngine
    }

    // MARK: - Execute turn (B03/B04 pipeline)

    func executeTurn(
        request: AssistantRequest,
        onEvent: @Sendable (TurnUIEvent) async -> Void
    ) async {
        let traceID = request.traceID
        let ownerID = request.owner
        let conversationID = request.conversationID
        let session = request.session

        do {
            let configs = try await configurationRepository.providerConfigs(ownerID: ownerID)

            let prefs: AppPreference
            do {
                prefs = try await configurationRepository.preferences(ownerID: ownerID)
            } catch let appErr as AppError {
                // Fail-closed: Immediately emit failure and abort; 0 provider calls, 0 HTTP requests
                await onEvent(.failed(traceID: traceID, error: appErr))
                return
            } catch {
                await onEvent(.failed(traceID: traceID, error: .storageRecoveryRequired(reason: "Preference load failure: \(error.localizedDescription)")))
                return
            }

            let maxSensitivity: PrivacyClass = request.messages.map(\.sensitivity).max() ?? .publicData

            let routeResult = await router.route(
                requirements: request.requirements,
                ownerID: ownerID,
                configs: configs,
                privacyMode: prefs.privacyMode,
                consents: prefs.consents,
                dataClass: maxSensitivity
            )

            switch routeResult {
            case .noneEligible(let reason):
                await onEvent(.failed(traceID: traceID, error: .noEligibleModel(reason: reason)))
                return

            case .selected(let provider, let modelID):
                await onEvent(.started(traceID: traceID, modelID: modelID))

                let routedRequest = AssistantRequest(
                    traceID: request.traceID,
                    owner: request.owner,
                    conversationID: request.conversationID,
                    messages: request.messages,
                    requirements: request.requirements,
                    responseLimit: request.responseLimit,
                    allowedTools: request.allowedTools,
                    session: request.session,
                    modelOverride: modelID
                )

                var hasEmittedVisibleToken = false

                let coalescer = StreamingDeltaCoalescer(flushThreshold: 128) { delta in
                    _ = try? await conversationRepository.appendAssistantCheckpoint(
                        traceID: traceID,
                        conversationID: conversationID,
                        ownerID: ownerID,
                        deltaText: delta,
                        session: session
                    )
                }

                do {
                    let stream = try await provider.stream(routedRequest)
                    for try await event in stream {
                        switch event {
                        case .started:
                            break

                        case .textDelta(let delta, let seq):
                            hasEmittedVisibleToken = true
                            await onEvent(.textDelta(delta, sequence: seq))
                            try? await coalescer.append(delta: delta)

                        case .toolProposal(let proposal):
                            // Intentional validated action handoff with required approval (Contract P02, Prompt 05)
                            do {
                                let decision = try policyEngine.evaluate(
                                    proposal: proposal,
                                    ownerID: ownerID,
                                    session: session,
                                    privacyMode: prefs.privacyMode
                                )
                                switch decision {
                                case .deny(let reason):
                                    try? await coalescer.flush()
                                    await onEvent(.failed(traceID: traceID, error: .toolExecutionFailed(toolID: proposal.toolID, message: reason)))
                                    return
                                case .ask(let approvalRequest):
                                    await onEvent(.toolProposalPending(approvalRequest))
                                case .permit(let authorized):
                                    let approvalRequest = ApprovalRequest(
                                        id: authorized.approvalID,
                                        invocationID: authorized.invocationID,
                                        toolID: authorized.toolID,
                                        schemaVersion: authorized.schemaVersion,
                                        ownerID: authorized.ownerID,
                                        traceID: authorized.traceID,
                                        payloadHash: authorized.payloadHash,
                                        riskLevel: .low,
                                        humanReadableSummary: "Permitted tool: \(authorized.toolID)",
                                        recipient: "Local",
                                        dataClasses: [.personal],
                                        canonicalArguments: authorized.canonicalArguments,
                                        sessionGeneration: authorized.sessionGeneration,
                                        expiresAt: authorized.expiresAt,
                                        status: .approved
                                    )
                                    await onEvent(.toolProposalPending(approvalRequest))
                                }
                            } catch {
                                try? await coalescer.flush()
                                await onEvent(.failed(traceID: traceID, error: .toolExecutionFailed(toolID: proposal.toolID, message: error.localizedDescription)))
                                return
                            }

                        case .usage(let input, let output, let cost):
                            let usage = UsageEstimate(
                                traceID: traceID,
                                providerID: provider.providerID,
                                modelID: modelID,
                                inputTokens: input,
                                outputTokens: output,
                                estimatedCostUSD: cost,
                                isActual: true,
                                recordedAt: Date()
                            )
                            await onEvent(.usageUpdate(usage))

                        case .completed(let finishReason):
                            try? await coalescer.flush()
                            _ = try? await conversationRepository.finishAssistantMessage(
                                traceID: traceID,
                                ownerID: ownerID,
                                status: .complete,
                                session: session
                            )
                            await onEvent(.completed(traceID: traceID, finishReason: finishReason))
                            return

                        case .failed(let failure):
                            try? await coalescer.flush()
                            if hasEmittedVisibleToken {
                                _ = try? await conversationRepository.finishAssistantMessage(
                                    traceID: traceID,
                                    ownerID: ownerID,
                                    status: .interrupted,
                                    session: session
                                )
                                await onEvent(.interrupted(traceID: traceID, reason: failure.message))
                            } else {
                                await onEvent(.failed(traceID: traceID, error: .providerTransient(providerID: failure.providerID, statusCode: failure.statusCode)))
                            }
                            return
                        }
                    }
                } catch is CancellationError {
                    try? await coalescer.flush()
                    if hasEmittedVisibleToken {
                        _ = try? await conversationRepository.finishAssistantMessage(
                            traceID: traceID,
                            ownerID: ownerID,
                            status: .interrupted,
                            session: session
                        )
                    }
                    await onEvent(.interrupted(traceID: traceID, reason: "Cancelled by user"))
                } catch {
                    try? await coalescer.flush()
                    if hasEmittedVisibleToken {
                        _ = try? await conversationRepository.finishAssistantMessage(
                            traceID: traceID,
                            ownerID: ownerID,
                            status: .interrupted,
                            session: session
                        )
                        await onEvent(.interrupted(traceID: traceID, reason: error.localizedDescription))
                    } else {
                        await onEvent(.failed(traceID: traceID, error: .unknown(underlying: error.localizedDescription)))
                    }
                }
            }
        } catch {
            await onEvent(.failed(traceID: traceID, error: .unknown(underlying: error.localizedDescription)))
        }
    }
}

