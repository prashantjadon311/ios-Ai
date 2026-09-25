// AI/Routing/AssistantOrchestrator.swift
// Orchestrates user turn: context building, routing, streaming, persistence, error recovery.
// Per V3 §AI/Routing/AssistantOrchestrator.swift blueprint.

import Foundation

actor AssistantOrchestrator {

    private let conversationRepository: ConversationRepository
    private let memoryRepository: MemoryRepository
    private let auditRepository: AuditRepository
    private let router: ModelRouter

    init(
        conversationRepository: ConversationRepository,
        memoryRepository: MemoryRepository,
        auditRepository: AuditRepository,
        modelRouter: ModelRouter
    ) {
        self.conversationRepository = conversationRepository
        self.memoryRepository = memoryRepository
        self.auditRepository = auditRepository
        self.router = modelRouter
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

        // B04: context is already assembled by caller (ChatViewModel)
        // Route selection
        // W05: real routing via ModelRouter; placeholder for now
        await onEvent(.started(traceID: traceID, modelID: "pending-provider"))

        // Streaming placeholder — real provider stream wired in W05/W06
        // This emitter simulates a turn completing for UI gate verification
        await onEvent(.completed(traceID: traceID, finishReason: "stop"))
    }
}
