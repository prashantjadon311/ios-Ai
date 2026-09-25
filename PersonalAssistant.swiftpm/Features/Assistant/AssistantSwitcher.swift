// Features/Assistant/AssistantSwitcher.swift
// Lets user select between Maya and Saar assistants.

import SwiftUI

struct AssistantSwitcher: View {
    @Environment(AppSession.self) private var session
    @Environment(AppRouter.self) private var router

    var body: some View {
        NavigationStack {
            List(session.assistantProfiles, id: \.id) { profile in
                Button {
                    Task {
                        try? await session.setActiveAssistant(profile)
                        router.dismissSheet()
                    }
                } label: {
                    HStack {
                        Circle()
                            .fill(Color(profile.avatarRole.themeColor))
                            .frame(width: 44, height: 44)
                            .overlay {
                                Text(String(profile.displayName.prefix(1)))
                                    .font(.headline.bold())
                                    .foregroundStyle(.white)
                            }
                        VStack(alignment: .leading) {
                            Text(profile.displayName)
                                .font(.headline)
                            Text(profile.avatarRole.rawValue.capitalized)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if session.activeAssistant?.id == profile.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.accent)
                        }
                    }
                    .padding(.vertical, AppTheme.Spacing.xs)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Select \(profile.displayName)")
            }
            .navigationTitle("Choose Assistant")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { router.dismissSheet() }
                }
            }
        }
    }
}
