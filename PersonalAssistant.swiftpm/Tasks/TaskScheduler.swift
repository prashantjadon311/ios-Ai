// Tasks/TaskScheduler.swift
// Schedules upcoming task occurrences with deterministic occurrence keys.
// Per V3 §B06 and §Tasks/TaskScheduler.swift blueprint.
// Eliminates random UUIDs: derives stable occurrence identity from taskID + revision + scheduled UTC instant.

import Foundation
import CryptoKit

struct TaskScheduler: Sendable {

    /// Derives a stable, deterministic UUID for a scheduled occurrence based on task identity, revision, and UTC scheduled instant.
    /// Algorithm B06: Prevents duplicate scheduled runs and ensures idempotency across restarts.
    static func deterministicOccurrenceID(taskID: TaskID, revision: Int, scheduledDate: Date) -> UUID {
        let utcSeconds = Int64(scheduledDate.timeIntervalSince1970)
        let seed = "\(taskID.rawValue.uuidString):\(revision):\(utcSeconds)"
        let digest = SHA256.hash(data: Data(seed.utf8))
        let bytes = Array(digest.prefix(16))
        return UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }

    /// Derives deterministic occurrence key from taskID, revision, and scheduled date.
    static func makeOccurrenceKey(taskID: TaskID, revision: Int, scheduledDate: Date) -> TaskOccurrenceKey {
        let occID = deterministicOccurrenceID(taskID: taskID, revision: revision, scheduledDate: scheduledDate)
        return TaskOccurrenceKey(
            taskID: taskID,
            definitionRevision: revision,
            scheduledOccurrenceID: occID
        )
    }

    /// Legacy / explicit overload supporting direct occurrence UUID.
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

        let timeZone = task.schedule?.timezone ?? TimeZone.current

        var targetHour: Int? = nil
        var targetMinute: Int? = nil
        if let fireDate = task.schedule?.fireDate {
            var cal = Calendar.current
            cal.timeZone = timeZone
            targetHour = cal.component(.hour, from: fireDate)
            targetMinute = cal.component(.minute, from: fireDate)
        }

        guard let next = TaskRecurrenceCalculator.nextDate(
            after: lastDate,
            recurrence: recurrence,
            targetHour: targetHour,
            targetMinute: targetMinute,
            timeZone: timeZone
        ) else {
            return nil
        }

        let key = makeOccurrenceKey(taskID: task.id, revision: task.revision, scheduledDate: next)
        return (key, next)
    }
}
