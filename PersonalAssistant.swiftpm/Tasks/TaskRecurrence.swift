// Tasks/TaskRecurrence.swift
// Algorithm B06: Wall-clock recurrence calculation handling DST shifts.
// Per V3 §B06 and §Tasks/TaskRecurrence.swift blueprint.
// Handles nonexistent local clock times (spring-forward) and repeated times (fall-back).

import Foundation

struct TaskRecurrenceCalculator: Sendable {
    /// Computes the next fire date for a recurring task preserving wall-clock time.
    /// In accordance with B06:
    /// - Nonexistent local clock times (e.g. 02:30 during spring-forward) choose next valid time.
    /// - Repeated local clock times (e.g. 01:30 during fall-back overlap) choose the first instance.
    /// - Never schedules duplicate occurrences.
    static func nextDate(
        after current: Date,
        recurrence: TaskRecurrence,
        targetHour: Int? = nil,
        targetMinute: Int? = nil,
        calendar: Calendar = Calendar.current,
        timeZone: TimeZone = TimeZone.current
    ) -> Date? {
        var cal = calendar
        cal.timeZone = timeZone

        let originalHour = targetHour ?? cal.component(.hour, from: current)
        let originalMinute = targetMinute ?? cal.component(.minute, from: current)

        // Base advancement based on frequency
        var dateComponents = DateComponents()
        switch recurrence.frequency {
        case .daily:
            dateComponents.day = recurrence.interval
        case .weekly:
            dateComponents.day = 7 * recurrence.interval
        case .monthly:
            dateComponents.month = recurrence.interval
        case .yearly:
            dateComponents.year = recurrence.interval
        }

        guard let tentativeTarget = cal.date(byAdding: dateComponents, to: current) else {
            return nil
        }

        // Lock to the intended local wall-clock hour and minute
        var targetComponents = cal.dateComponents([.year, .month, .day], from: tentativeTarget)
        targetComponents.hour = originalHour
        targetComponents.minute = originalMinute
        targetComponents.second = 0

        // Handle DST spring-forward (gap) and fall-back (overlap)
        if let exactDate = cal.date(from: targetComponents) {
            // Verify if Calendar preserved wall-clock hour or if it was nonexistent
            let computedHour = cal.component(.hour, from: exactDate)
            if computedHour != originalHour {
                // Nonexistent time during spring-forward: select next valid date
                return cal.nextDate(
                    after: tentativeTarget,
                    matching: DateComponents(minute: originalMinute),
                    matchingPolicy: .nextTime,
                    repeatedTimePolicy: .first,
                    direction: .forward
                )
            }
            return exactDate
        } else {
            // Nonexistent time: compute next valid time matching target minute
            return cal.nextDate(
                after: tentativeTarget,
                matching: DateComponents(minute: originalMinute),
                matchingPolicy: .nextTime,
                repeatedTimePolicy: .first,
                direction: .forward
            )
        }
    }
}
