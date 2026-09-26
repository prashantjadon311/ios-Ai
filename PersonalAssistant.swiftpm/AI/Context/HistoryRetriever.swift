// AI/Context/HistoryRetriever.swift
// Retrieves owner-scoped historical messages for context assembly.
// Per V3 §AI/Context/HistoryRetriever.swift blueprint.

import Foundation

actor HistoryRetriever {
    private let conversationRepo: ConversationRepository

    init(conversationRepo: ConversationRepository) {
        self.conversationRepo = conversationRepo
    }

    func retrieveRecentMessages(conversationID: ConversationID, ownerID: UserID, limit: Int = 20) async throws -> [MessageRecord] {
        let all = try await conversationRepo.pageMessages(owner: ownerID, conversationID: conversationID, cursor: 0)
        return Array(all.suffix(limit))
    }
}
