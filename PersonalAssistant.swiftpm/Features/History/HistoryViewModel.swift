// Features/History/HistoryViewModel.swift

import Foundation
import Observation

@MainActor
@Observable
final class HistoryViewModel {
    private(set) var conversations: [Conversation] = []
    private(set) var searchText: String = ""
    private(set) var isLoading = false
    private(set) var error: AppError?

    private let session: AppSession
    private let conversationRepository: ConversationRepository
    private let router: AppRouter

    init(session: AppSession, conversationRepository: ConversationRepository, router: AppRouter) {
        self.session = session
        self.conversationRepository = conversationRepository
        self.router = router
    }

    var filteredConversations: [Conversation] {
        guard !searchText.isEmpty else { return conversations }
        let q = searchText.lowercased()
        return conversations.filter {
            $0.title.lowercased().contains(q) ||
            ($0.lastMessagePreview?.lowercased().contains(q) ?? false)
        }
    }

    func load() async {
        guard let owner = session.currentProfile else { return }
        isLoading = true; error = nil
        defer { isLoading = false }
        do {
            conversations = try await conversationRepository.conversations(owner: owner.id)
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }
    }

    func onSearch(_ query: String) { searchText = query }

    func onOpenConversation(_ conv: Conversation) {
        router.openChat(conversationID: conv.id)
    }

    func onDelete(_ conv: Conversation) async {
        guard let owner = session.currentProfile else { return }
        do {
            let token = try session.captureSession()
            try await conversationRepository.deleteConversation(
                id: conv.id, owner: owner.id, session: token
            )
            await load()
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }
    }
}
