// AI/Context/MemoryProposalEngine.swift
// Proposes memory items from conversational turns, keeping state .proposed.
// Per V3 §A13 and §AI/Context/MemoryProposalEngine.swift blueprint.

import Foundation

struct MemoryProposalEngine: Sendable {
    static func proposeMemory(from text: String, ownerID: UserID) -> MemoryItem? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > 10 else { return nil }
        return MemoryItem(
            ownerID: ownerID,
            content: trimmed,
            scope: .general,
            verificationState: .proposed
        )
    }
}
