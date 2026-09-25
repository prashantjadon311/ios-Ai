// Features/Approvals/ApprovalCenterView.swift
// Approvals screen — shows pending tool approval requests.

import SwiftUI

struct ApprovalCenterView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label("No Pending Approvals", systemImage: "checkmark.seal")
            } description: {
                Text("When an assistant requests to perform an action, it will appear here for your review.")
            }
            .navigationTitle("Approvals")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { router.dismissSheet() }
                }
            }
        }
    }
}
