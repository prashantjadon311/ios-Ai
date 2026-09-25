// App/ApplicationCommandBus.swift
// Shared typed entry points for UI and voice — prevents duplicate side effects.
// Per V3 §App/ApplicationCommandBus.swift.

import Foundation
import Observation

/// Typed command — one entry point for domain actions from both UI and voice.
enum AppCommand: Sendable {
    case sendMessage(conversationID: ConversationID, text: String, traceID: TraceID)
    case cancelStreaming(traceID: TraceID)
    case createTask(ownerID: UserID, title: String, description: String)
    case openConversation(ConversationID)
    case switchAssistant(AssistantID)
    case lockApp
}

@MainActor
@Observable
final class ApplicationCommandBus {

    private(set) var lastCommandTrace: TraceID?
    private(set) var isProcessing: Bool = false

    private let session: AppSession
    private let router: AppRouter

    // Replay guard: track recently processed trace IDs
    private var processedTraceIDs: Set<UUID> = []

    init(session: AppSession, router: AppRouter) {
        self.session = session
        self.router = router
    }

    /// Dispatch a typed command. Guards against replay of the same traceID.
    func dispatch(_ command: AppCommand) {
        switch command {
        case .openConversation(let id):
            router.openChat(conversationID: id)
        case .switchAssistant(let id):
            Task {
                if let profile = session.assistantProfiles.first(where: { $0.id == id }) {
                    try? await session.setActiveAssistant(profile)
                }
            }
        case .lockApp:
            session.lock()
        case .sendMessage(_, _, let trace):
            guard !processedTraceIDs.contains(trace.rawValue) else { return }
            processedTraceIDs.insert(trace.rawValue)
            lastCommandTrace = trace
        case .cancelStreaming:
            break
        case .createTask:
            router.openTaskEditor(taskID: nil)
        }
    }
}
