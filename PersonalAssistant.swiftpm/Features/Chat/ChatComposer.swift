// Features/Chat/ChatComposer.swift
// Message composer with text field, send, mic and attachment triggers.
// Per V3 §Features/Chat/ChatComposer.swift blueprint.

import SwiftUI

struct ChatComposer: View {
    @Binding var text: String
    let isStreaming: Bool
    let onSend: () -> Void
    let onCancel: () -> Void
    let onVoiceTap: () -> Void
    let onAttachmentTap: () -> Void

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Button(action: onAttachmentTap) {
                Image(systemName: "paperclip")
                    .font(.system(size: 20))
                    .foregroundStyle(.secondary)
                    .frame(minWidth: AppTheme.minimumTapTarget, minHeight: AppTheme.minimumTapTarget)
            }
            .accessibilityLabel("Attach file or photo")

            TextField("Ask anything…", text: $text, axis: .vertical)
                .lineLimit(1...5)
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, 8)
                .background(SwiftUI.Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))

            if isStreaming {
                Button(action: onCancel) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.red)
                        .frame(minWidth: AppTheme.minimumTapTarget, minHeight: AppTheme.minimumTapTarget)
                }
                .accessibilityLabel("Stop generating response")
            } else if text.trimmingCharacters(in: .whitespaces).isEmpty {
                Button(action: onVoiceTap) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(SwiftUI.Color.accentColor)
                        .frame(minWidth: AppTheme.minimumTapTarget, minHeight: AppTheme.minimumTapTarget)
                }
                .accessibilityLabel("Start voice input")
            } else {
                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(SwiftUI.Color.accentColor)
                        .frame(minWidth: AppTheme.minimumTapTarget, minHeight: AppTheme.minimumTapTarget)
                }
                .accessibilityLabel("Send message")
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.xs)
    }
}
