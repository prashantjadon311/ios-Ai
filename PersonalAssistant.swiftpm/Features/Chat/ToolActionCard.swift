// Features/Chat/ToolActionCard.swift
import SwiftUI

struct ToolActionCard: View {
    let toolName: String
    let statusText: String

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "wrench.and.screwdriver")
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading) {
                Text(toolName)
                    .font(.caption.bold())
                Text(statusText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
    }
}
