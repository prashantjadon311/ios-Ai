// Tasks/TaskProgress.swift
// Deterministic progress estimation based on completed task steps.
// Per V3 §Tasks/TaskProgress.swift blueprint.

import Foundation

struct TaskProgressEstimator: Sendable {
    static func calculateProgress(steps: [TaskStep]) -> Double {
        guard !steps.isEmpty else { return 0.0 }
        let completed = steps.filter { $0.isCompleted }.count
        return Double(completed) / Double(steps.count)
    }
}
