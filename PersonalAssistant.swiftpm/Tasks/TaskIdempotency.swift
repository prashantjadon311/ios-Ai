// Tasks/TaskIdempotency.swift
// Prevents duplicate executions of the same task run occurrence.
// Per V3 §Tasks/TaskIdempotency.swift blueprint.

import Foundation

actor TaskIdempotencyLedger {
    private var executedKeys: Set<String> = []

    func claimExecution(occurrenceKey: String) -> Bool {
        if executedKeys.contains(occurrenceKey) {
            return false
        }
        executedKeys.insert(occurrenceKey)
        return true
    }

    func releaseExecution(occurrenceKey: String) {
        executedKeys.remove(occurrenceKey)
    }
}
