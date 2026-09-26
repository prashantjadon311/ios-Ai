// Features/Onboarding/LocalProfileSetup.swift
import SwiftUI

struct LocalProfileSetup: View {
    @Binding var displayName: String

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Text("What should we call you?")
                .font(.headline)
            TextField("Your Name", text: $displayName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
        }
    }
}
