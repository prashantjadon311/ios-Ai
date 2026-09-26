// DesignSystem/AssistantStatusChip.swift
// Compact status pill displaying current assistant identity and model.
// Per V3 §DesignSystem/AssistantStatusChip.swift blueprint.

import SwiftUI

struct AssistantStatusChip: View {
    let assistantName: String
    let modelName: String?
    var isStreaming: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isStreaming ? Color.green : Color.secondary)
                .frame(width: 8, height: 8)

            Text(assistantName)
                .font(.caption.weight(.semibold))

            if let model = modelName {
                Text("•")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(model)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color(.secondarySystemBackground))
        .clipShape(Capsule())
    }
}
