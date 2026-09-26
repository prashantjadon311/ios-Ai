// Tasks/TaskPlanner.swift
// Decomposes high-level goals into atomic verifiable descriptions.
// Per V3 §Tasks/TaskPlanner.swift blueprint.

import Foundation

struct TaskPlanner: Sendable {
    static func planDescriptions(for goal: String) -> [String] {
        let trimmed = goal.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        return [
            "Analyze goal: " + trimmed,
            "Execute approved primary action",
            "Verify outcome and persist receipt"
        ]
    }
}
