// Features/Chat/ChatViewModel.swift
// Chat view model — manages one conversation, streaming turns, and message state.
// AI transport is wired in W05/W06; this gate provides UI state management.

import Foundation
import Observation

@MainActor
@Observable
final class ChatViewModel {
    private(set) var messages: [MessageRecord] = []
    private(set) var isStreaming: Bool = false
    private(set) var streamingText: String = ""
    private(set) var error: AppError?
    var composerText: String = ""
    var conversation: Conversation?
    private(set) var activeConversationID: ConversationID?

    private let session: AppSession
    private let conversationRepository: ConversationRepository
    private let keychainVault: KeychainVault
    private let capabilityCenter: CapabilityCenter
    private let orchestrator: AssistantOrchestrator
    private let configurationRepository: ConfigurationRepository

    /// Active streaming task (cancellable).
    private var streamingTask: Task<Void, Never>?

    init(
        conversationID: ConversationID?,
        session: AppSession,
        conversationRepository: ConversationRepository,
        keychainVault: KeychainVault,
        capabilityCenter: CapabilityCenter,
        orchestrator: AssistantOrchestrator,
        configurationRepository: ConfigurationRepository
    ) {
        self.activeConversationID = conversationID
        self.session = session
        self.conversationRepository = conversationRepository
        self.keychainVault = keychainVault
        self.capabilityCenter = capabilityCenter
        self.orchestrator = orchestrator
        self.configurationRepository = configurationRepository
    }

    // MARK: - Load

    func load() async {
        guard let cid = activeConversationID,
              let owner = session.currentProfile else { return }
        do {
            messages = try await conversationRepository.pageMessages(
                owner: owner.id, conversationID: cid, cursor: 0
            )
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }
    }

    private var consumedNonces: Set<UUID> = []

    func submitLaunchOnce(_ intent: ChatLaunchIntent) async {
        guard let text = intent.initialText?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return }
        guard !consumedNonces.contains(intent.launchNonce) else { return }
        consumedNonces.insert(intent.launchNonce)

        composerText = text
        await send()
    }

    // MARK: - Send message

    func send() async {
        let text = composerText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, let owner = session.currentProfile else { return }
        if !capabilityCenter.snapshot.networkAvailable {
            self.error = .unknown(underlying: "Network unavailable. Please check your connection.")
            return
        }
        composerText = ""
        error = nil

        // Ensure conversation exists
        let cid: ConversationID
        if let existing = activeConversationID {
            cid = existing
        } else {
            guard let assistant = session.activeAssistant else { return }
            do {
                let conv = try await conversationRepository.createConversation(
                    owner: owner.id, assistantID: assistant.id
                )
                conversation = conv
                activeConversationID = conv.id
                cid = conv.id
            } catch {
                self.error = .unknown(underlying: error.localizedDescription)
                return
            }
        }

        // Persist user message before sending to provider (V3 §ConversationRepository)
        let sessionToken: SessionToken
        do {
            sessionToken = try session.captureSession()
            let userMsg = try await conversationRepository.appendPendingUserMessage(
                owner: owner.id,
                conversationID: cid,
                parts: [.text(text)],
                session: sessionToken
            )
            messages.append(userMsg)
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
            return
        }

        isStreaming = true
        streamingText = ""

        let traceID = TraceID()
        let contextMessages = messages.map { msg in
            ContextMessage(
                role: msg.role,
                parts: msg.parts.map { part in
                    switch part {
                    case .text(let t): return .text(t)
                    case .attachment(let id): return .attachment(id)
                    case .toolResult(let id, let output): return .toolResult(invocationID: id, summary: output)
                    }
                },
                source: msg.source,
                sensitivity: msg.sensitivity
            )
        }

        let request = AssistantRequest(
            traceID: traceID,
            owner: owner.id,
            conversationID: cid,
            messages: contextMessages,
            requirements: CapabilityRequirements(needsVision: false, needsTools: false),
            responseLimit: 2048,
            allowedTools: [],
            session: sessionToken
        )

        streamingTask = Task {
            await orchestrator.executeTurn(request: request) { [weak self] event in
                guard let self else { return }
                switch event {
                case .started(let tid, let modelID):
                    self.streamingText = ""
                case .textDelta(let delta, _):
                    self.streamingText += delta
                case .toolProposalPending:
                    break
                case .usageUpdate:
                    break
                case .completed(let tid, let reason):
                    if !self.streamingText.isEmpty {
                        if let msgs = try? await self.conversationRepository.pageMessages(
                            owner: owner.id,
                            conversationID: cid,
                            cursor: 0
                        ), !msgs.isEmpty {
                            self.messages = msgs
                        } else {
                            let finalMsg = MessageRecord(
                                id: MessageID(),
                                conversationID: cid,
                                ownerID: owner.id,
                                traceID: traceID,
                                role: .assistant,
                                parts: [.text(self.streamingText)],
                                source: .assistantGenerated,
                                sensitivity: .personal,
                                status: .complete,
                                createdAt: Date(),
                                updatedAt: Date(),
                                sequenceNumber: self.messages.count
                            )
                            self.messages.append(finalMsg)
                        }
                    }
                    self.isStreaming = false
                    self.streamingText = ""
                case .interrupted(let tid, let reason):
                    if !self.streamingText.isEmpty {
                        let finalMsg = MessageRecord(
                            id: MessageID(),
                            conversationID: cid,
                            ownerID: owner.id,
                            traceID: traceID,
                            role: .assistant,
                            parts: [.text(self.streamingText + "\n[Interrupted: \(reason)]")],
                            source: .assistantGenerated,
                            sensitivity: .personal,
                            status: .interrupted,
                            createdAt: Date(),
                            updatedAt: Date(),
                            sequenceNumber: self.messages.count
                        )
                        self.messages.append(finalMsg)
                    }
                    self.isStreaming = false
                    self.streamingText = ""
                case .failed(_, let err):
                    self.error = err
                    self.isStreaming = false
                    self.streamingText = ""
                }
            }
        }
    }

    // MARK: - Cancel streaming

    func cancel() {
        streamingTask?.cancel()
        streamingTask = nil
        isStreaming = false
        streamingText = ""
    }
}
