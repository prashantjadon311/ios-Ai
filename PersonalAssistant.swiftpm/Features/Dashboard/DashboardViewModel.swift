// Features/Dashboard/DashboardViewModel.swift
// Dashboard view model — active assistant summary, quick actions, today's tasks, pending approvals.

import Foundation
import Observation

@MainActor
@Observable
final class DashboardViewModel {
    private(set) var recentConversations: [Conversation] = []
    private(set) var todayTasks: [TaskDefinition] = []
    private(set) var isLoading: Bool = false
    private(set) var error: AppError?

    private let session: AppSession
    private let router: AppRouter
    private let conversationRepository: ConversationRepository
    private let taskRepository: TaskRepository

    init(
        session: AppSession,
        router: AppRouter,
        conversationRepository: ConversationRepository,
        taskRepository: TaskRepository
    ) {
        self.session = session
        self.router = router
        self.conversationRepository = conversationRepository
        self.taskRepository = taskRepository
    }

    // MARK: - Load

    func load() async {
        guard let owner = session.currentProfile else { return }
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            let convs = try await conversationRepository.conversations(owner: owner.id)
            recentConversations = Array(convs.prefix(5))
            todayTasks = try await taskRepository.taskDefinitions(ownerID: owner.id)
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }
    }

    // MARK: - Actions (per V3 §UI screens and expected event handlers)

    func onAsk(text: String) async {
        guard let owner = session.currentProfile,
              let assistant = session.activeAssistant else { return }
        do {
            let conv = try await conversationRepository.createConversation(
                owner: owner.id,
                assistantID: assistant.id
            )
            router.openChat(conversationID: conv.id)
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }
    }

    func onVoice() {
        // Opens chat with voice active — VoiceCoordinator.begin() called in ChatView
        router.openNewConversation()
    }

    func onSwitchAssistant() {
        router.openAssistantSelector()
    }

    func onTaskCard(_ task: TaskDefinition) {
        router.navigate(to: .tasks)
    }

    func onOpenConversation(_ conv: Conversation) {
        router.openChat(conversationID: conv.id)
    }
}
