// Features/Onboarding/PermissionEducationView.swift
import SwiftUI

struct PermissionEducationView: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
                .foregroundStyle(Color.accentColor)
            Text("Your Data Stays on Device")
                .font(.title3.bold())
            Text("Personal Assistant stores conversations, tasks, and memories locally.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
