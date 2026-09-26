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
        switch (from, to) {
        case (.queued, .running): return true
        case (.queued, .cancelled): return true
        case (.running, .succeeded): return true
        case (.running, .failed): return true
        case (.running, .cancelled): return true
        case (.running, .ambiguous): return true
        case (.ambiguous, .succeeded): return true
        case (.ambiguous, .failed): return true
        case (.ambiguous, .cancelled): return true
        default: return false
        }
    }

    static func validateTransition(from: TaskRunStatus, to: TaskRunStatus) throws {
        guard canTransition(from: from, to: to) else {
            throw TaskTransitionError.invalidTransition(from: from, to: to)
        }
    }
}
