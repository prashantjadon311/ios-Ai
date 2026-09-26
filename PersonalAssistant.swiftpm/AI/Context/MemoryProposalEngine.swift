// AI/Context/MemoryProposalEngine.swift
// Generates draft memory proposals from user content.
// Invariant A13/B08: Model-inferred memories are strictly PROPOSED, never auto-verified.

import Foundation

actor MemoryProposalEngine {

    func proposeMemories(
        from text: String,
        ownerID: UserID,
        conversationID: ConversationID? = nil,
        messageID: MessageID? = nil
    ) -> [MemoryItem] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let triggers = ["my name is", "i live in", "i like", "i prefer", "remember that", "my birthday is"]
        let lower = trimmed.lowercased()

        var proposals: [MemoryItem] = []
        for trigger in triggers {
            if lower.contains(trigger) {
                let sourceRef = MemorySourceRef(
                    conversationID: conversationID,
                    messageID: messageID,
                    summarized: false,
                    capturedAt: Date()
                )
                let item = MemoryItem(
                    ownerID: ownerID,
                    content: trimmed,
                    tags: ["user_preference"],
                    verificationState: .proposed,
                    sourceRefs: [sourceRef],
                    revision: 1
                )
                proposals.append(item)
                break
            }
        }
        return proposals
    }
}
