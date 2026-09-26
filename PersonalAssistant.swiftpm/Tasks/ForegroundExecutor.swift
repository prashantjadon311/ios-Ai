// Tasks/ForegroundExecutor.swift
// Bounded foreground execution with strict cancellation checks.
// Per V3 §Tasks/ForegroundExecutor.swift blueprint.

import Foundation

struct ForegroundExecutor: Sendable {
    static func executeWithTimeout<T: Sendable>(
        timeoutSeconds: TimeInterval,
        operation: @Sendable @escaping () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            group.addTask {
                try await Task.sleep(for: .seconds(timeoutSeconds))
                throw AppError.interrupted(reason: "Operation timed out")
            }
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
}
