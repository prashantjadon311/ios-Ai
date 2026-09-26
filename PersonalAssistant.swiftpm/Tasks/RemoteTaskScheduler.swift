// Tasks/RemoteTaskScheduler.swift
// Protocol contract for future autonomous remote task scheduling.
// Per V3 §Tasks/RemoteTaskScheduler.swift blueprint.

import Foundation

protocol RemoteTaskSchedulerProtocol: Sendable {
    func registerRemoteSchedule(taskID: TaskID, cronExpression: String) async throws
    func cancelRemoteSchedule(taskID: TaskID) async throws
}

final class RemoteTaskSchedulerStub: RemoteTaskSchedulerProtocol {
    func registerRemoteSchedule(taskID: TaskID, cronExpression: String) async throws {
        // V1 local-only release: remote scheduler is a contract interface only
    }

    func cancelRemoteSchedule(taskID: TaskID) async throws {
        // V1 local-only release
    }
}
