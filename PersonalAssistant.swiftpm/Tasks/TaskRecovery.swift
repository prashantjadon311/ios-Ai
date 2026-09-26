// Tasks/TaskRecovery.swift
// Reconciles interrupted or crashed in-flight tasks upon app launch.
// Per V3 §Tasks/TaskRecovery.swift blueprint.

import Foundation

struct TaskRecoveryWorker: Sendable {
    static func reconcileInFlightRuns(
        runs: [TaskRun]
    ) -> [TaskRun] {
        return runs.map { run in
            if run.status == .running {
                var reconciled = run
                reconciled.status = .ambiguous
                return reconciled
            }
            return run
        }
    }
}
