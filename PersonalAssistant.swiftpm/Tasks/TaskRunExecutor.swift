// Tasks/TaskRunExecutor.swift
// Step-by-step runner executing task steps with state checkpoints.
// Per V3 §Tasks/TaskRunExecutor.swift blueprint.

import Foundation

actor TaskRunExecutor {
    func executeLocalStep(
        _ step: TaskStepRecord,
        operation: @Sendable (TaskStepRecord) async throws -> Void
    ) async throws -> TaskStepRecord {
        try Task.checkCancellation()
        try await operation(step)
        try Task.checkCancellation()
        var done = step
        done.status = .completed
        done.completedAt = Date()
        return done
    }
}
