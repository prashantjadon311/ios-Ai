// Features/Tasks/TaskApprovalStrip.swift
import SwiftUI

struct TaskApprovalStrip: View {
    let taskTitle: String
    let onApprove: () -> Void

    var body: some View {
        HStack {
            Text("Approval needed: \(taskTitle)")
                .font(.caption)
            Spacer()
            Button("Review", action: onApprove)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        }
        .padding(8)
        .background(Color.orange.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
    }
}
