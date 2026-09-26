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

        let interval = max(1, recurrence.interval)
        let tentativeTarget: Date?

        switch recurrence.frequency {
        case .daily:
            tentativeTarget = cal.date(byAdding: .day, value: interval, to: current)

        case .weekly:
            if let daysOfWeek = recurrence.daysOfWeek, !daysOfWeek.isEmpty {
                var found: Date? = nil
                for dayOffset in 1...7 {
                    if let candidate = cal.date(byAdding: .day, value: dayOffset, to: current) {
                        let candidateWeekday = cal.component(.weekday, from: candidate)
                        if daysOfWeek.contains(candidateWeekday) {
                            if cal.isDate(candidate, equalTo: current, toGranularity: .weekOfYear) {
                                found = candidate
                                break
                            } else if interval == 1 {
                                found = candidate
                                break
                            }
                        }
                    }
                }
                if found == nil {
                    if let nextWeek = cal.date(byAdding: .weekOfYear, value: interval, to: current),
                       let weekInterval = cal.dateInterval(of: .weekOfYear, for: nextWeek) {
                        for dayOffset in 0..<7 {
                            if let candidate = cal.date(byAdding: .day, value: dayOffset, to: weekInterval.start) {
                                let candidateWeekday = cal.component(.weekday, from: candidate)
                                if daysOfWeek.contains(candidateWeekday) {
                                    found = candidate
                                    break
                                }
                            }
                        }
                    }
                }
                tentativeTarget = found
            } else {
                tentativeTarget = cal.date(byAdding: .day, value: 7 * interval, to: current)
            }

        case .monthly:
            if let dayOfMonth = recurrence.dayOfMonth {
                if let nextMonth = cal.date(byAdding: .month, value: interval, to: current) {
                    var targetComps = cal.dateComponents([.year, .month], from: nextMonth)
                    let range = cal.range(of: .day, in: .month, for: nextMonth)
                    let maxDay = range?.count ?? 30
                    targetComps.day = min(dayOfMonth, maxDay)
                    tentativeTarget = cal.date(from: targetComps)
                } else {
                    tentativeTarget = nil
                }
            } else {
                tentativeTarget = cal.date(byAdding: .month, value: interval, to: current)
            }

        case .yearly:
            tentativeTarget = cal.date(byAdding: .year, value: interval, to: current)
        }

        guard let tentativeTarget else {
            return nil
        }

        // Lock to the intended local wall-clock hour and minute
        var targetComponents = cal.dateComponents([.year, .month, .day], from: tentativeTarget)
        targetComponents.hour = originalHour
        targetComponents.minute = originalMinute
        targetComponents.second = 0

        let resultDate: Date?
        // Handle DST spring-forward (gap) and fall-back (overlap)
        if let exactDate = cal.date(from: targetComponents) {
            // Verify if Calendar preserved wall-clock hour or if it was nonexistent
            let computedHour = cal.component(.hour, from: exactDate)
            if computedHour != originalHour {
                // Nonexistent time during spring-forward: select next valid date
                resultDate = cal.nextDate(
                    after: tentativeTarget,
                    matching: DateComponents(minute: originalMinute),
                    matchingPolicy: .nextTime,
                    repeatedTimePolicy: .first,
                    direction: .forward
                )
            } else {
                resultDate = exactDate
            }
        } else {
            // Nonexistent time: compute next valid time matching target minute
            resultDate = cal.nextDate(
                after: tentativeTarget,
                matching: DateComponents(minute: originalMinute),
                matchingPolicy: .nextTime,
                repeatedTimePolicy: .first,
                direction: .forward
            )
        }

        if let resultDate {
            if case .until(let limit) = recurrence.endCondition, resultDate > limit {
                return nil
            }
            if case .afterCount(let count) = recurrence.endCondition, count <= 0 {
                return nil
            }
        }
        return resultDate
    }
}
