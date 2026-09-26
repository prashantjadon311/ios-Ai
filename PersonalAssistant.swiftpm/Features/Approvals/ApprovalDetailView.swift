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

            Text(request.humanReadableSummary)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                LabeledContent("Recipient", value: request.recipient)
                LabeledContent("Risk Level", value: request.riskLevel.rawValue.capitalized)
            }
            .font(.caption)
            .padding(.horizontal)

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
