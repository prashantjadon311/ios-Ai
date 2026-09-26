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

        // 1. Budget reservation: System Prompt + Active Query + Margin
        let sysTokens = tokenBudgetEstimator.estimateTokens(for: systemPrompt)
        let queryTokens = tokenBudgetEstimator.estimateTokens(for: userQuery)
        let reservedTokens = sysTokens + queryTokens + 500
        var remainingBudget = max(0, maxTokens - reservedTokens)

        // System message (trusted policy)
        let sysMsg = ContextMessage(
            role: .system,
            parts: [.text(systemPrompt)],
            source: .systemPolicy,
            sensitivity: .personal
        )
        messages.append(sysMsg)
        usedTokens += sysTokens

        // 2. Verified Active Memories for this owner (reference data, not system policy)
        let activeMemories = memories.filter { $0.ownerID == ownerID && $0.isActive() }
        if !activeMemories.isEmpty {
            let memorySummary = activeMemories.map { "- \($0.content)" }.joined(separator: "\n")
            let memTokens = tokenBudgetEstimator.estimateTokens(for: memorySummary)
            if memTokens <= remainingBudget {
                let memMsg = ContextMessage(
                    role: .user,
                    parts: [.text("<retrieved_user_context>\n" + memorySummary + "\n</retrieved_user_context>")],
                    source: .retrievedMemory,
                    sensitivity: .personal
                )
                messages.append(memMsg)
                usedTokens += memTokens
                remainingBudget -= memTokens
                for mem in activeMemories {
                    selectedMemoryRevisions.append(mem.id.rawValue)
                }
            }
        }

        // 3. Conversation History (most recent first, budgeted, chronologically emitted)
        let ownerHistory = history.filter { $0.ownerID == ownerID }
        var includedHistory: [ContextMessage] = []
        for record in ownerHistory.reversed() {
            let text = record.parts.compactMap { part -> String? in
                if case .text(let t) = part { return t }
                return nil
            }.joined(separator: " ")
            let tokens = tokenBudgetEstimator.estimateTokens(for: text)
            if tokens <= remainingBudget {
                includedHistory.append(ContextMessage(
                    role: record.role,
                    parts: record.parts,
                    source: record.source,
                    sensitivity: record.sensitivity
                ))
                sourceIDs.append(record.id.rawValue)
                usedTokens += tokens
                remainingBudget -= tokens
            } else {
                break
            }
        }
        messages.append(contentsOf: includedHistory.reversed())

        // 4. Active User Query
        if !userQuery.isEmpty {
            let queryMsg = ContextMessage(
                role: .user,
                parts: [.text(userQuery)],
                source: .userTyped,
                sensitivity: .personal
            )
            messages.append(queryMsg)
            usedTokens += queryTokens
        }

        return ContextPacket(
            messages: messages,
            estimatedInputTokens: usedTokens,
            sourceIDs: sourceIDs,
            selectedMemoryRevisions: selectedMemoryRevisions
        )
    }
}
