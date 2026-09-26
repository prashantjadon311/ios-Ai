// Features/Settings/PrivacySettingsView.swift

import SwiftUI

struct PrivacySettingsView: View {
    @Environment(AppSession.self) private var session
    @State private var privacyMode: PrivacyMode = .cloudAllowed
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section("Data Privacy Mode") {
                Picker("Mode", selection: Binding(
                    get: { privacyMode },
                    set: { newMode in
                        privacyMode = newMode
                        errorMessage = nil
                        Task {
                            do {
                                try await session.updatePrivacyMode(newMode)
                            } catch {
                                errorMessage = error.localizedDescription
                                privacyMode = session.preferences?.privacyMode ?? .cloudAllowed
                            }
                        }
                    }
                )) {
                    Text("Cloud Allowed").tag(PrivacyMode.cloudAllowed)
                    Text("Private Only").tag(PrivacyMode.privateOnly)
                }
                .pickerStyle(.inline)

                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                if privacyMode == .privateOnly {
                    Label("Private Only blocks all external data transfer, not just AI chat.", systemImage: "info.circle")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }

            Section("About") {
                Text("Private Only mode prevents any data from leaving your device, including AI requests, link previews and attachments. Only local features remain available.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Privacy")
        .onAppear {
            privacyMode = session.preferences?.privacyMode ?? .cloudAllowed
        }
    }
}
