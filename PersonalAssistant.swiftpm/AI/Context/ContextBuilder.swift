// AI/Context/ContextBuilder.swift
// Algorithm B04: Deterministic trust-ordered context assembly.
// Per V3 §B04 and §AI/Context/ContextBuilder.swift blueprint.

import Foundation

struct ContextBuilder: Sendable {
    static func buildContext(
        systemPrompt: String,
        memories: [MemoryItem],
        history: [MessageRecord],
        userTurn: String
    ) -> [ContextMessage] {
        var result: [ContextMessage] = []

        // 1. Trusted System Policy
        result.append(ContextMessage(
            role: .system,
            parts: [.text(systemPrompt)],
            provenanceHash: nil
        ))

        // 2. Active Memories (Deterministic sort by ID)
        let sortedMemories = memories.sorted { $0.id.rawValue.uuidString < $1.id.rawValue.uuidString }
        if !sortedMemories.isEmpty {
            let memoryText = sortedMemories.map { "- \($0.content)" }.joined(separator: "\n")
            result.append(ContextMessage(
                role: .system,
                parts: [.text("Relevant user preferences and facts:\n" + memoryText)],
                provenanceHash: nil
            ))
        }

        // 3. Conversation History
        for msg in history {
            result.append(ContextMessage(
                role: msg.role,
                parts: msg.parts.map { part in
                    switch part {
                    case .text(let t): return .text(t)
                    case .attachment(let id): return .text("[attachment \(id.rawValue)]")
                    case .toolResult(let id, let out, _): return .text("[tool \(id): \(out)]")
                    }
                },
                provenanceHash: nil
            ))
        }

        // 4. Current User Command
        result.append(ContextMessage(
            role: .user,
            parts: [.text(userTurn)],
            provenanceHash: nil
        ))

        return result
    }
}
