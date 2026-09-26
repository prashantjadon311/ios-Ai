// Features/Dashboard/AttentionSummary.swift
import SwiftUI

struct AttentionSummary: View {
    let pendingCount: Int

    var body: some View {
        if pendingCount > 0 {
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(Color.orange)
                Text("\(pendingCount) item(s) need your review")
                    .font(.subheadline.bold())
                Spacer()
            }
            .padding()
            .background(Color.orange.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
        }
    }
}
