// Features/Dashboard/QuickActionGrid.swift
import SwiftUI

struct QuickActionGrid: View {
    let onNewChat: () -> Void
    let onVoice: () -> Void
    let onNewTask: () -> Void

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            actionCard(title: "Chat", systemImage: "bubble.left.and.bubble.right", action: onNewChat)
            actionCard(title: "Voice", systemImage: "mic", action: onVoice)
            actionCard(title: "New Task", systemImage: "plus.circle", action: onNewTask)
        }
    }

    private func actionCard(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: systemImage)
                    .font(.title2)
                Text(title)
                    .font(.caption.bold())
            }
            .frame(maxWidth: .infinity, minHeight: 70)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
        }
        .buttonStyle(.plain)
    }
}
