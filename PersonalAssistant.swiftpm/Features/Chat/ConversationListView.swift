// Features/Chat/ConversationListView.swift
import SwiftUI

struct ConversationListView: View {
    let conversations: [Conversation]
    let onSelect: (ConversationID) -> Void

    var body: some View {
        List(conversations) { conv in
            Button {
                onSelect(conv.id)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(conv.title)
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                    Text(conv.updatedAt, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
