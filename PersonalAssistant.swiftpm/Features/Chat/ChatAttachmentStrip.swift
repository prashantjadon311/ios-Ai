// Features/Chat/ChatAttachmentStrip.swift
// Preview strip for pending attachments before message dispatch per V3 §Features/Chat.

import SwiftUI

struct ChatAttachmentStrip: View {
    let attachments: [Attachment]
    let onRemove: (AttachmentID) -> Void

    var body: some View {
        if !attachments.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(attachments) { attachment in
                        HStack(spacing: AppTheme.Spacing.xs) {
                            Image(systemName: "doc.fill")
                                .foregroundStyle(.secondary)
                            Text(attachment.filename)
                                .font(.caption)
                                .lineLimit(1)
                            Button {
                                onRemove(attachment.id)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, 4)
                        .background(SwiftUI.Color(uiColor: .tertiarySystemBackground))
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, 4)
            }
        }
    }
}
