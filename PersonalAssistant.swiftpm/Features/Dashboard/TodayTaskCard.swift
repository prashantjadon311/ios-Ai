// Features/Dashboard/TodayTaskCard.swift
import SwiftUI

struct TodayTaskCard: View {
    let task: TaskDefinition

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "checklist")
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.headline)
                if let schedule = task.scheduleTime {
                    Text(DateFormattingHelpers.shortTime(schedule))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
    }
}
