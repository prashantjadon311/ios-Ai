// Features/Assistant/AssistantProfileView.swift
// Displays active and configured assistant profiles (Maya and Saar).
// Uses canonical AssistantProfile (avatarRole, displayName, voiceSettings).

import SwiftUI

struct AssistantProfileView: View {
    @Environment(AppSession.self) private var session
    @State private var showingNameEditor = false

    var body: some View {
        List {
            Section("Active Assistant") {
                if let assistant = session.activeAssistant {
                    HStack {
                        AvatarView(state: .idle, identity: assistant.avatarRole == .saar ? .saar : .maya, size: 50)
                        VStack(alignment: .leading) {
                            Text(assistant.displayName)
                                .font(.headline)
                            Text(assistant.voiceSettings.voiceIdentifier ?? "Default Voice")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("All Profiles") {
                ForEach(session.assistantProfiles, id: \.id) { profile in
                    HStack {
                        Text(profile.displayName)
                        Spacer()
                        if profile.id == session.activeAssistant?.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Task { try? await session.setActiveAssistant(profile) }
                    }
                }
            }
        }
        .navigationTitle("Assistant Profiles")
    }
}
