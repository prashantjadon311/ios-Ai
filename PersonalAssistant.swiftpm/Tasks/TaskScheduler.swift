// Tasks/TaskScheduler.swift
// Schedules upcoming task occurrences with deterministic occurrence keys.
// Per V3 §Tasks/TaskScheduler.swift blueprint.

import Foundation

struct TaskScheduler: Sendable {
    static func makeOccurrenceKey(taskID: TaskID, scheduledDate: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return "\(taskID.rawValue.uuidString)_\(formatter.string(from: scheduledDate))"
    }

    static func scheduleNextRun(
        for task: TaskDefinition,
        after lastDate: Date = Date()
    ) -> (occurrenceKey: String, scheduledDate: Date)? {
        guard let rule = task.recurrenceRule else { return nil }
        guard let next = TaskRecurrenceCalculator.nextDate(after: lastDate, recurrence: rule) else {
            return nil
        }
        let key = makeOccurrenceKey(taskID: task.id, scheduledDate: next)
        return (key, next)
    }
}
