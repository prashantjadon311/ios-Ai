// Tasks/TaskScheduler.swift
// Schedules upcoming task occurrences with deterministic occurrence keys.
// Per V3 §Tasks/TaskScheduler.swift blueprint.

import Foundation

struct TaskScheduler: Sendable {
    static func makeOccurrenceKey(taskID: TaskID, revision: Int, occurrenceID: UUID = UUID()) -> TaskOccurrenceKey {
        TaskOccurrenceKey(
            taskID: taskID,
            definitionRevision: revision,
            scheduledOccurrenceID: occurrenceID
        )
    }

    static func scheduleNextRun(
        for task: TaskDefinition,
        after lastDate: Date = Date()
    ) -> (occurrenceKey: TaskOccurrenceKey, scheduledDate: Date)? {
        guard let recurrence = task.recurrence else { return nil }
        guard let next = TaskRecurrenceCalculator.nextDate(after: lastDate, recurrence: recurrence) else {
            return nil
        }
        let key = makeOccurrenceKey(taskID: task.id, revision: task.revision)
        return (key, next)
    }
}
