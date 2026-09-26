// DesignSystem/MarkdownMessageView.swift
// Formatted markdown message bubble rendering.
// Per V3 §DesignSystem/MarkdownMessageView.swift blueprint.

import SwiftUI

struct MarkdownMessageView: View {
    let content: String
    var isUser: Bool = false

    var body: some View {
        Text(LocalizedStringKey(content))
            .font(.body)
            .foregroundStyle(isUser ? Color.white : Color.primary)
            .textSelection(.enabled)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(
                isUser ? Color.accentColor : Color(.secondarySystemBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            .frame(maxWidth: 600, alignment: isUser ? .trailing : .leading)
    }
}
