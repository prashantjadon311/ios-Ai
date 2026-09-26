// Features/Configuration/ProviderDetailView.swift
// Configures BYOK credentials in KeychainVault and persists enabled ProviderConfiguration.

import SwiftUI

struct ProviderDetailView: View {
    let providerName: String
    let providerID: String

    @Environment(AppContainer.self) private var container
    @Environment(AppSession.self) private var session
    @State private var apiKey: String = ""
    @State private var statusMessage: String?
    @State private var isError: Bool = false
    @State private var isEnabled: Bool = true
    @State private var isSaving: Bool = false

    var body: some View {
        Form {
            Section("API Credentials") {
                SecureField("API Key", text: $apiKey)
                    .accessibilityLabel("API Key input")

                Toggle("Enable Provider", isOn: $isEnabled)
                    .accessibilityLabel("Enable this provider")

                Button(action: saveKey) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save to Keychain")
                    }
                }
                .disabled(apiKey.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                .buttonStyle(.borderedProminent)
            } footer: {
                Text("API keys are stored securely in your local device Keychain and transmitted directly to \(providerName) exclusively as an Authorization header during AI turns.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let msg = statusMessage {
                Section {
                    Text(msg)
                        .font(.caption)
                        .foregroundStyle(isError ? .red : .green)
                }
            }
        }
        .navigationTitle(providerName)
        .task {
            await loadExisting()
        }
    }

    private func loadExisting() async {
        guard let owner = session.currentProfile else { return }
        let hasKey = await container.keychainVault.hasSecret(ownerID: owner.id, providerID: providerID)
        if hasKey {
            statusMessage = "Key is currently configured in Keychain."
            isError = false
        }
    }

    private func saveKey() {
        guard let owner = session.currentProfile else { return }
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespaces)
        guard !trimmedKey.isEmpty else { return }

        isSaving = true
        statusMessage = nil
        isError = false

        Task {
            defer { isSaving = false }
            do {
                try await container.keychainVault.setSecret(
                    ownerID: owner.id,
                    providerID: providerID,
                    value: trimmedKey
                )
                // Create or update ProviderConfiguration
                let kind = ProviderKind(rawValue: providerID) ?? .custom
                let existingConfigs = (try? await container.configurationRepository.providerConfigs(ownerID: owner.id)) ?? []
                let existing = existingConfigs.first { $0.providerKind == kind }
                let configID = existing?.id ?? ProviderConfigID()

                let config = ProviderConfiguration(
                    id: configID,
                    ownerID: owner.id,
                    providerKind: kind,
                    displayName: providerName,
                    keychainKey: "\(owner.id.rawValue.uuidString).\(providerID)",
                    isEnabled: isEnabled
                )
                guard let token = session.sessionToken else {
                    throw AppError.notAuthenticated
                }
                try await container.configurationRepository.saveProviderConfig(config, session: token)
                statusMessage = "Key and provider configuration saved successfully."
                isError = false
                apiKey = ""
            } catch {
                statusMessage = "Failed to save: \(error.localizedDescription)"
                isError = true
            }
        }
    }
}
