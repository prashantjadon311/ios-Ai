// DesignSystem/ConfirmationSheet.swift
// Reusable confirmation sheet for destructive actions.
// Per V3 §DesignSystem/ConfirmationSheet.swift blueprint.

import SwiftUI

struct ConfirmationSheet: View {
    let title: String
    let message: String
    let confirmTitle: String
    var isDestructive: Bool = true
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: isDestructive ? "exclamationmark.triangle.fill" : "questionmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(isDestructive ? Color.red : Color.accentColor)

            Text(title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: AppTheme.Spacing.sm) {
                Button(role: isDestructive ? .destructive : nil) {
                    onConfirm()
                } label: {
                    Text(confirmTitle)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                .buttonStyle(.borderedProminent)

                Button("Cancel") {
                    onCancel()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
        }
        .padding(AppTheme.Spacing.xl)
    }
}
