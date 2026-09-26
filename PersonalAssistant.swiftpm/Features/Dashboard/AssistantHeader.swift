// Features/Dashboard/AssistantHeader.swift
import SwiftUI

struct AssistantHeader: View {
    let name: String
    let identity: AvatarIdentity

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            AvatarView(state: .idle, identity: identity, size: 60)
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(name)
                    .font(.title2.bold())
            }
            Spacer()
        }
    }
}
