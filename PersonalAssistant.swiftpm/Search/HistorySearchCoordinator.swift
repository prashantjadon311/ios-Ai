// Search/HistorySearchCoordinator.swift
// Multi-scope search coordinator isolating conversation and memory items by owner.
// Per V3 §Search/HistorySearchCoordinator.swift blueprint.

import Foundation

actor HistorySearchCoordinator {
    private let textIndex: LocalTextIndex
    private let conversationRepo: ConversationRepository

    init(conversationRepo: ConversationRepository, textIndex: LocalTextIndex = LocalTextIndex()) {
        self.conversationRepo = conversationRepo
        self.textIndex = textIndex
    }

    func search(query: String, ownerID: UserID) async throws -> [Conversation] {
        let convs = try await conversationRepo.conversations(owner: ownerID)
        let queryLower = query.lowercased()
        return convs.filter { $0.title.lowercased().contains(queryLower) }
    }
}
