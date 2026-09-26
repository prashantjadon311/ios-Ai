// Features/Configuration/PrivacyRoutingView.swift
// Privacy and data egress configuration view.
// Uses canonical PrivacyMode (.cloudAllowed and .privateOnly).
// Persists preferences directly to ConfigurationRepository.

import SwiftUI

struct PrivacyRoutingView: View {
    @Environment(AppContainer.self) private var container
    @Environment(AppSession.self) private var session
    @State private var privacyMode: PrivacyMode = .cloudAllowed
    @State private var currentPrefs: AppPreference?
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section("Privacy Boundary") {
                Picker("Egress Mode", selection: $privacyMode) {
                    Text("Cloud Allowed (BYOK)").tag(PrivacyMode.cloudAllowed)
                    Text("Private Only (Local Only)").tag(PrivacyMode.privateOnly)
                }
                .pickerStyle(.inline)
                .onChange(of: privacyMode) { _, newMode in
                    Task {
                        await save(mode: newMode)
                    }
                }
            }

            Section {
                if privacyMode == .privateOnly {
                    Text("In Private Only mode, all external network requests to cloud AI providers are blocked. Local processing only.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Cloud Allowed mode permits BYOK requests to authorized endpoints using your configured API keys.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            if let error = errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }
        }
        .navigationTitle("Privacy Routing")
        .task {
            await load()
        }
    }

    private func load() async {
        if let prefs = session.preferences {
            privacyMode = prefs.privacyMode
        } else if let owner = session.currentProfile {
            do {
                let prefs = try await container.configurationRepository.preferences(ownerID: owner.id)
                privacyMode = prefs.privacyMode
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func save(mode: PrivacyMode) async {
        errorMessage = nil
        do {
            try await session.updatePrivacyMode(mode)
        } catch {
            errorMessage = error.localizedDescription
            // Revert on failure
            privacyMode = session.preferences?.privacyMode ?? .cloudAllowed
        }
    }
}
