// Tasks/TaskEngineActor.swift
// Core actor coordinating task scheduling, progress tracking, and execution runs.
// Per V3 §Tasks/TaskEngineActor.swift blueprint, S006.

import Foundation

actor TaskEngineActor {
    private let taskRepository: TaskRepository
    private let reminderScheduler: LocalReminderScheduler
    private var activeTasks: [TaskID: Task<Void, Never>] = [:]

    init(taskRepository: TaskRepository, reminderScheduler: LocalReminderScheduler = LocalReminderScheduler()) {
        self.taskRepository = taskRepository
        self.reminderScheduler = reminderScheduler
    }

    func cancelTask(taskID: TaskID) async {
        activeTasks[taskID]?.cancel()
        activeTasks.removeValue(forKey: taskID)
        await reminderScheduler.cancelReminder(taskID: taskID)
    }

    func cancelAllRunningTasks() async {
        for (_, runningTask) in activeTasks {
            runningTask.cancel()
        }
        activeTasks.removeAll()
    }

    func scheduleTask(task: TaskDefinition) async throws {
        if let schedule = task.schedule {
            try await reminderScheduler.scheduleReminder(
                taskID: task.id,
                title: task.title,
                fireDate: schedule.fireDate
            )
        }
    }
}
