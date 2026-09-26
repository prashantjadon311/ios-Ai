// DesignSystem/AccessibleButton.swift
// Button with guaranteed 44pt minimum touch target and accessible states.
// Per V3 §DesignSystem/AccessibleButton.swift blueprint.

import SwiftUI

struct AccessibleButton: View {
    let title: String
    var systemImage: String? = nil
    var role: ButtonRole? = nil
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(role: role) {
            guard !isLoading && !isDisabled else { return }
            action()
        } label: {
            HStack(spacing: AppTheme.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else if let icon = systemImage {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.medium)
            }
            .frame(minWidth: 44, minHeight: 44)
            .padding(.horizontal, AppTheme.Spacing.md)
            .contentShape(Rectangle())
        }
        .disabled(isDisabled || isLoading)
        .accessibilityLabel(Text(title))
    }
}
