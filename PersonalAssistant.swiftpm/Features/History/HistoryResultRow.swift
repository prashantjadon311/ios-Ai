// Features/History/HistoryResultRow.swift
import SwiftUI

struct HistoryResultRow: View {
    let title: String
    let subtitle: String
    let date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(date, style: .relative)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}
