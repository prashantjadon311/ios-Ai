// Tasks/LocalIntentParser.swift
// Deterministic offline parser for touch/text/voice task and reminder commands.
// Per V7 Phase P02/P03 and docs/04 Exact Engineering Contracts Section D.

import Foundation

enum ClarificationReason: String, Codable, Sendable, Hashable {
    case unspecifiedTime
    case ambiguousRelativeDate
    case unspecifiedTimeZone
    case ambiguousCommand
}

enum LocalIntentParseResult: Sendable, Hashable {
    case reminder(title: String, fireDate: Date, timeZone: TimeZone)
    case task(title: String, description: String, schedule: TaskSchedule?)
    case needsClarification(reason: ClarificationReason, prompt: String, suggestedTitle: String?, suggestedDate: Date?)
    case notRecognized
}

struct LocalIntentParser: Sendable {

    /// Parses text into a deterministic action, clarification request, or unrecognized intent.
    /// Injects reference clock, calendar, and timezone for 100% reproducible execution.
    static func parse(
        text: String,
        referenceDate: Date = Date(),
        calendar: Calendar = Calendar(identifier: .gregorian),
        timeZone: TimeZone = TimeZone(identifier: "UTC") ?? TimeZone.current
    ) -> LocalIntentParseResult {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .notRecognized }
        let lower = trimmed.lowercased()

        // 1. Task Creation Detection ("create task ...", "add task ...", "new task ...", "task banao ...")
        if let taskMatch = parseTaskCommand(lower, original: trimmed) {
            return taskMatch
        }

        // 2. Reminder Triggers: English ("remind me", "reminder", "set a reminder") or Hindi/Hinglish ("yaad dilana", "remind karna", "yaad dila do", "reminder lagao")
        let isReminderTrigger = lower.contains("remind") ||
            lower.contains("reminder") ||
            lower.contains("yaad dila") ||
            lower.contains("yaad dilana")

        guard isReminderTrigger else {
            return .notRecognized
        }

        // 3. Ambiguous relative Hindi date words: "kal" (yesterday OR tomorrow), "parson" (day before yesterday OR day after tomorrow)
        // Per contract: ambiguous dates (kal, parson) require clarification, not guessing.
        if containsWord(lower, word: "kal") || containsWord(lower, word: "parson") {
            let extractedTitle = extractTitleFromReminder(original: trimmed)
            return .needsClarification(
                reason: .ambiguousRelativeDate,
                prompt: "In Hindi, relative day references ('kal', 'parson') can be ambiguous. Please clarify if you mean tomorrow or another date, and specify the exact time.",
                suggestedTitle: extractedTitle,
                suggestedDate: nil
            )
        }

        // 4. Time without Day ("remind me at 6 pm" without tomorrow / today specified)
        if (lower.contains(" at ") || lower.contains(" baje")) && !lower.contains("tomorrow") && !lower.contains("today") && !lower.contains("aaj") {
            let extractedTitle = extractTitleFromReminder(original: trimmed)
            return .needsClarification(
                reason: .ambiguousRelativeDate,
                prompt: "Please specify whether the reminder is for today or tomorrow.",
                suggestedTitle: extractedTitle,
                suggestedDate: nil
            )
        }

        // 5. Day without Time ("remind me tomorrow" without a specific time)
        // Per contract: unspecified timezone/time must return editable clarification, not guess.
        if lower.contains("tomorrow") && !hasTimeSpecification(lower) {
            let extractedTitle = extractTitleFromReminder(original: trimmed)
            return .needsClarification(
                reason: .unspecifiedTime,
                prompt: "Please specify the time you would like to be reminded tomorrow.",
                suggestedTitle: extractedTitle,
                suggestedDate: nil
            )
        }

        // 6. Deterministic "tomorrow at <time>" extraction
        if lower.contains("tomorrow") {
            if let (hour, minute) = parseTime(from: lower) {
                var cal = calendar
                cal.timeZone = timeZone

                guard let nextDay = cal.date(byAdding: .day, value: 1, to: referenceDate) else {
                    return .needsClarification(
                        reason: .ambiguousCommand,
                        prompt: "Could not calculate the reminder date. Please enter the date and time manually.",
                        suggestedTitle: nil,
                        suggestedDate: nil
                    )
                }

                var components = cal.dateComponents([.year, .month, .day], from: nextDay)
                components.hour = hour
                components.minute = minute
                components.second = 0

                guard let fireDate = cal.date(from: components) else {
                    return .needsClarification(
                        reason: .ambiguousCommand,
                        prompt: "Could not resolve the reminder time. Please specify a valid time.",
                        suggestedTitle: nil,
                        suggestedDate: nil
                    )
                }

                let title = extractTitleFromReminder(original: trimmed)
                return .reminder(title: title, fireDate: fireDate, timeZone: timeZone)
            }
        }

        // 7. Fallback for unparseable reminder commands
        return .needsClarification(
            reason: .ambiguousCommand,
            prompt: "Could not understand the reminder time or details. Please clarify.",
            suggestedTitle: nil,
            suggestedDate: nil
        )
    }

    // MARK: - Helper Parsers

    private static func parseTaskCommand(_ lower: String, original: String) -> LocalIntentParseResult? {
        let prefixes = ["create task ", "add task ", "new task ", "task: "]
        for prefix in prefixes {
            if lower.hasPrefix(prefix) {
                let startIndex = original.index(original.startIndex, offsetBy: prefix.count)
                let title = String(original[startIndex...]).trimmingCharacters(in: .whitespacesAndNewlines)
                guard !title.isEmpty else { return nil }
                return .task(title: title, description: "", schedule: nil)
            }
        }
        return nil
    }

    private static func containsWord(_ text: String, word: String) -> Bool {
        let tokens = text.components(separatedBy: CharacterSet.alphanumerics.inverted)
        return tokens.contains(word)
    }

    private static func hasTimeSpecification(_ lower: String) -> Bool {
        let patterns = [" at ", "pm", "am", "hours", "o'clock", ":"]
        for p in patterns {
            if lower.contains(p) { return true }
        }
        return false
    }

    /// Extracts (hour24, minute) from a string containing time expressions like:
    /// "at 6 pm", "at 6:30 pm", "at 18:00", "at 9 am", "6pm", "6:30am"
    static func parseTime(from text: String) -> (hour: Int, minute: Int)? {
        let lower = text.lowercased()

        // Match patterns like "at 6:30 pm", "at 6 pm", "6:30pm", "6pm", "18:00"
        let isPM = lower.contains("pm") || lower.contains("shaam") || lower.contains("raat")
        let isAM = lower.contains("am") || lower.contains("subah")

        // Look for digit patterns
        let regexPattern = #"(\d{1,2})(?::(\d{2}))?\s*(am|pm)?"#
        guard let regex = try? NSRegularExpression(pattern: regexPattern, options: .caseInsensitive) else {
            return nil
        }

        let nsString = lower as NSString
        let matches = regex.matches(in: lower, options: [], range: NSRange(location: 0, length: nsString.length))

        for match in matches {
            guard match.numberOfRanges >= 2 else { continue }
            let hourRange = match.range(at: 1)
            guard hourRange.location != NSNotFound else { continue }
            guard let rawHour = Int(nsString.substring(with: hourRange)) else { continue }

            var minute = 0
            if match.numberOfRanges >= 3 {
                let minuteRange = match.range(at: 2)
                if minuteRange.location != NSNotFound {
                    minute = Int(nsString.substring(with: minuteRange)) ?? 0
                }
            }

            var hour = rawHour
            let matchedAMPM: String? = (match.numberOfRanges >= 4 && match.range(at: 3).location != NSNotFound)
                ? nsString.substring(with: match.range(at: 3)).lowercased()
                : nil

            let isPostMeridiem = isPM || (matchedAMPM == "pm")
            let isAnteMeridiem = isAM || (matchedAMPM == "am")

            if isPostMeridiem {
                if hour < 12 { hour += 12 }
            } else if isAnteMeridiem {
                if hour == 12 { hour = 0 }
            }

            if hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59 {
                return (hour, minute)
            }
        }

        return nil
    }

    /// Cleans up extracted title from phrases like "remind me to buy groceries tomorrow at 6 pm"
    private static func extractTitleFromReminder(original: String) -> String {
        var cleaned = original

        let stripPrefixes = [
            "remind me to ", "remind me ", "set a reminder to ", "set reminder to ",
            "create a reminder to ", "create reminder to ", "reminder to ", "reminder "
        ]
        let lower = cleaned.lowercased()
        for prefix in stripPrefixes {
            if lower.hasPrefix(prefix) {
                let idx = cleaned.index(cleaned.startIndex, offsetBy: prefix.count)
                cleaned = String(cleaned[idx...])
                break
            }
        }

        // Remove trailing " tomorrow at ..." or " tomorrow"
        if let tomorrowRange = cleaned.range(of: "tomorrow", options: .caseInsensitive) {
            cleaned = String(cleaned[..<tomorrowRange.lowerBound])
        }

        cleaned = cleaned.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: "-,.")))
        return cleaned.isEmpty ? "Reminder" : cleaned
    }
}
