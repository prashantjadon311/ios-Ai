// Features/Settings/PrivacySettingsView.swift

import SwiftUI

struct PrivacySettingsView: View {
    @Environment(AppSession.self) private var session
    @State private var privacyMode: PrivacyMode = .cloudAllowed

    var body: some View {
        Form {
            Section("Data Privacy Mode") {
                Picker("Mode", selection: Binding(
                    get: { privacyMode },
                    set: { newMode in
                        privacyMode = newMode
                        Task {
                            try? await session.updatePrivacyMode(newMode)
                        }
                    }
                )) {
                    Text("Cloud Allowed").tag(PrivacyMode.cloudAllowed)
                    Text("Private Only").tag(PrivacyMode.privateOnly)
                }
                .pickerStyle(.inline)

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
