// DesignSystem/ToastAndBanner.swift
// Non-intrusive floating toasts and status banners.
// Per V3 §DesignSystem/ToastAndBanner.swift blueprint.

import SwiftUI

struct ToastBanner: View {
    let message: String
    var systemImage: String? = "info.circle"
    var isError: Bool = false

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            if let icon = systemImage {
                Image(systemName: icon)
                    .foregroundStyle(isError ? Color.red : Color.accentColor)
            }
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.primary)
            Spacer()
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
        .shadow(radius: 4)
        .padding(.horizontal, AppTheme.Spacing.md)
    }
}
