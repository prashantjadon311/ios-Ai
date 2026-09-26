// DesignSystem/DateAndRelativeTime.swift
// Localized date, time, and relative timestamp display helpers.
// Per V3 §DesignSystem/DateAndRelativeTime.swift blueprint.

import SwiftUI

struct RelativeTimeText: View {
    let date: Date

    var body: some View {
        Text(date, style: .relative)
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}

enum DateFormattingHelpers {
    static func mediumDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .shortened)
    }

    static func shortTime(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }

    static func relativeOrDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today at " + shortTime(date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday at " + shortTime(date)
        } else {
            return mediumDate(date)
        }
    }
}
