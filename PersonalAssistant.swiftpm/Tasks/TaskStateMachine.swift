// Tasks/TaskStateMachine.swift
// Exhaustive state transitions and lifecycle validation for task runs.
// Per V3 §Tasks/TaskStateMachine.swift blueprint.

import Foundation

enum TaskTransitionError: Error, Sendable {
    case invalidTransition(from: TaskRunStatus, to: TaskRunStatus)
    case taskAlreadyTerminal(TaskRunStatus)
}

struct TaskStateMachine: Sendable {
    static func canTransition(from: TaskRunStatus, to: TaskRunStatus) -> Bool {
        from.canTransition(to: to)
    }

    static func validateTransition(from: TaskRunStatus, to: TaskRunStatus) throws {
        guard canTransition(from: from, to: to) else {
            throw TaskTransitionError.invalidTransition(from: from, to: to)
        }
    }
}
