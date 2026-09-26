// Features/Memory/MemorySourceView.swift
import SwiftUI

struct MemorySourceView: View {
    let sourceText: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Memory Source")
                .font(.headline)
            Text(sourceText)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
