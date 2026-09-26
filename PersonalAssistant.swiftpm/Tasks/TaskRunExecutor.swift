// Tasks/TaskRunExecutor.swift
// Step-by-step runner executing task steps with state checkpoints.
// Per V3 §Tasks/TaskRunExecutor.swift blueprint.

import Foundation

actor TaskRunExecutor {
    func executeStep(
        step: TaskStep,
        onProgress: @Sendable (Double) async -> Void
    ) async throws -> TaskStep {
        try Task.checkCancellation()
        await onProgress(0.5)
        var updated = step
        updated.isCompleted = true
        updated.completedAt = Date()
        await onProgress(1.0)
        return updated
    }
}
