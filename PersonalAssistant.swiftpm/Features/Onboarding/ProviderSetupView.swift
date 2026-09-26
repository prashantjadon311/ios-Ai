// Features/Onboarding/ProviderSetupView.swift
import SwiftUI

struct ProviderSetupView: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Text("Bring Your Own Key")
                .font(.title2.bold())
            Text("Add an API key in Configuration to enable AI chat.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
