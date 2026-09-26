// Features/Chat/StreamingStatusView.swift
import SwiftUI

struct StreamingStatusView: View {
    let isStreaming: Bool

    var body: some View {
        if isStreaming {
            HStack(spacing: 6) {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Streaming response…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
        }
    }
}
