// Tasks/TaskDateQueries.swift
// Timezone-aware due-today and overdue calculations handling DST shifts.
// Per V7 Phase P07 and V7 §§6, 3.4.

import Foundation

struct TaskDateFilter: Sendable {

    /// Checks if a date falls on the calendar day of referenceDate in the given timezone.
    /// Handles DST spring-forward (23-hour day) and fall-back (25-hour day) properly
    /// by using Calendar calendar day boundary queries.
    static func isDueToday(
        date: Date,
        in timeZone: TimeZone,
        relativeTo referenceDate: Date = Date()
    ) -> Bool {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = timeZone
        return cal.isDate(date, inSameDayAs: referenceDate)
    }

    /// Checks if a date is strictly before the beginning of the calendar day of referenceDate in the given timezone.
    static func isOverdue(
        date: Date,
        in timeZone: TimeZone,
        relativeTo referenceDate: Date = Date()
    ) -> Bool {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = timeZone
        let startOfToday = cal.startOfDay(for: referenceDate)
        return date < startOfToday
    }

    /// Filter task definitions due today in the specified timezone.
    static func filterDueToday(
        tasks: [TaskDefinition],
        in timeZone: TimeZone,
        relativeTo referenceDate: Date = Date()
    ) -> [TaskDefinition] {
        tasks.filter { task in
            guard !task.isArchived, let schedule = task.schedule else { return false }
            return isDueToday(date: schedule.fireDate, in: timeZone, relativeTo: referenceDate)
        }
    }

    /// Filter task definitions overdue in the specified timezone.
    /// Tasks marked 100% complete are excluded from overdue.
    static func filterOverdue(
        tasks: [TaskDefinition],
        in timeZone: TimeZone,
        relativeTo referenceDate: Date = Date()
    ) -> [TaskDefinition] {
        tasks.filter { task in
            guard !task.isArchived, let schedule = task.schedule else { return false }
            if (task.completionPercent ?? 0) >= 100 { return false }
            return isOverdue(date: schedule.fireDate, in: timeZone, relativeTo: referenceDate)
        }
    }

    /// Filter reminders due today in the specified timezone.
    static func filterRemindersDueToday(
        reminders: [ReminderDefinition],
        in timeZone: TimeZone,
        relativeTo referenceDate: Date = Date()
    ) -> [ReminderDefinition] {
        reminders.filter { reminder in
            guard !reminder.isArchived, !reminder.isCompleted else { return false }
            return isDueToday(date: reminder.dueDate, in: timeZone, relativeTo: referenceDate)
        }
    }

    /// Filter reminders overdue in the specified timezone.
    static func filterRemindersOverdue(
        reminders: [ReminderDefinition],
        in timeZone: TimeZone,
        relativeTo referenceDate: Date = Date()
    ) -> [ReminderDefinition] {
        reminders.filter { reminder in
            guard !reminder.isArchived, !reminder.isCompleted else { return false }
            return isOverdue(date: reminder.dueDate, in: timeZone, relativeTo: referenceDate)
        }
    }
}
