// AI/Context/TokenBudget.swift
// Conservative token budgeting using UTF8/3 byte estimation and advisory budget tracking.
// Per V3 §AI/Context/TokenBudget.swift blueprint, T025, S007.

import Foundation

struct TokenBudgetEstimator: Sendable {
    static let advisoryNotice: String = "Advisory estimate only. This local limit helps manage usage but is not an upstream provider billing cap."

    static func estimateTokens(for text: String) -> Int {
        let bytes = text.utf8.count
        return max(1, (bytes + 2) / 3)
    }

    static func fitsInBudget(messages: [ContextMessage], maxTokens: Int = 4096) -> Bool {
        var total = 0
        for msg in messages {
            for part in msg.parts {
                if case .text(let t) = part {
                    total += estimateTokens(for: t)
                }
            }
        }
        return total <= maxTokens
    }

    static func estimatedCost(
        inputTokens: Int,
        outputTokens: Int,
        inputRatePerMillion: Decimal = 0.50,
        outputRatePerMillion: Decimal = 1.50
    ) -> Decimal {
        let inCost = (Decimal(inputTokens) / 1_000_000) * inputRatePerMillion
        let outCost = (Decimal(outputTokens) / 1_000_000) * outputRatePerMillion
        return inCost + outCost
    }

    static func isAdvisoryBudgetExceeded(
        currentAccumulatedCost: Decimal,
        advisoryCap: Decimal
    ) -> Bool {
        return currentAccumulatedCost >= advisoryCap
    }
}
