// Features/Approvals/ApprovalDetailView.swift
import SwiftUI

struct ApprovalDetailView: View {
    let request: ApprovalRequest
    let onApprove: () -> Void
    let onReject: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "exclamationmark.shield")
                .font(.system(size: 64))
                .foregroundStyle(Color.orange)

            Text("Approval Required")
                .font(.title2.bold())

            Text(request.summary)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()

            HStack(spacing: AppTheme.Spacing.md) {
                Button("Reject", role: .destructive, action: onReject)
                    .buttonStyle(.bordered)
                    .frame(minHeight: 44)

                Button("Approve", action: onApprove)
                    .buttonStyle(.borderedProminent)
                    .frame(minHeight: 44)
            }
        }
        .padding()
    }
}
