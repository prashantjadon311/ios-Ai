// AI/Context/ContextBuilder.swift
// Algorithm B04: Trusted ordered bounded context assembly.
// System prompt -> Verified memories -> History -> Active query.

import Foundation

actor ContextBuilder {
    private let tokenBudgetEstimator: TokenBudgetEstimator

    init(tokenBudgetEstimator: TokenBudgetEstimator = TokenBudgetEstimator()) {
        self.tokenBudgetEstimator = tokenBudgetEstimator
    }

    func buildContext(
        systemPrompt: String,
        memories: [MemoryItem],
        history: [MessageRecord],
        userQuery: String,
        maxTokens: Int = 4096,
        ownerID: UserID
    ) -> ContextPacket {
        var messages: [ContextMessage] = []
        var sourceIDs: [UUID] = []
        var selectedMemoryRevisions: [UUID] = []
        var usedTokens = 0

        // 1. System Prompt (Highest trust)
        let sysMsg = ContextMessage(
            role: .system,
            parts: [.text(systemPrompt)],
            source: .systemPolicy,
            sensitivity: .personal
        )
        messages.append(sysMsg)
        usedTokens += tokenBudgetEstimator.estimateTokens(for: systemPrompt)

        // 2. Verified Active Memories for this owner
        let activeMemories = memories.filter { $0.ownerID == ownerID && $0.isActive() }
        if !activeMemories.isEmpty {
            let memorySummary = activeMemories.map { "- \($0.content)" }.joined(separator: "\n")
            let memMsg = ContextMessage(
                role: .system,
                parts: [.text("Verified memories about user:\n" + memorySummary)],
                source: .retrievedMemory,
                sensitivity: .personal
            )
            messages.append(memMsg)
            usedTokens += tokenBudgetEstimator.estimateTokens(for: memorySummary)
            for mem in activeMemories {
                selectedMemoryRevisions.append(mem.id.rawValue)
            }
        }

        // 3. Conversation History (Chronological, budgeted)
        for record in history where record.ownerID == ownerID {
            let text = record.parts.compactMap { part -> String? in
                if case .text(let t) = part { return t }
                return nil
            }.joined(separator: " ")
            let tokens = tokenBudgetEstimator.estimateTokens(for: text)
            if usedTokens + tokens > maxTokens - 500 {
                break
            }
            messages.append(ContextMessage(
                role: record.role,
                parts: record.parts,
                source: record.source,
                sensitivity: record.sensitivity
            ))
            sourceIDs.append(record.id.rawValue)
            usedTokens += tokens
        }

        // 4. Active User Query
        if !userQuery.isEmpty {
            let queryMsg = ContextMessage(
                role: .user,
                parts: [.text(userQuery)],
                source: .userTyped,
                sensitivity: .personal
            )
            messages.append(queryMsg)
            usedTokens += tokenBudgetEstimator.estimateTokens(for: userQuery)
        }

        return ContextPacket(
            messages: messages,
            estimatedInputTokens: usedTokens,
            sourceIDs: sourceIDs,
            selectedMemoryRevisions: selectedMemoryRevisions
        )
    }
}
