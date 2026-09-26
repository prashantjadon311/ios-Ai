// Features/Configuration/ProviderDetailView.swift
import SwiftUI

struct ProviderDetailView: View {
    let providerName: String
    let providerID: String

    @Environment(AppContainer.self) private var container
    @Environment(AppSession.self) private var session
    @State private var apiKey: String = ""
    @State private var statusMessage: String?

    var body: some View {
        Form {
            Section("API Credentials") {
                SecureField("API Key", text: $apiKey)
                Button("Save to Keychain") {
                    guard let owner = session.currentProfile else { return }
                    Task {
                        try? await container.keychainVault.setSecret(
                            ownerID: owner.id,
                            providerID: providerID,
                            value: apiKey
                        )
                        statusMessage = "Key saved securely."
                    }
                }
                .buttonStyle(.borderedProminent)
            }

            if let msg = statusMessage {
                Section {
                    Text(msg)
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
        }
        .navigationTitle(providerName)
    }
}
