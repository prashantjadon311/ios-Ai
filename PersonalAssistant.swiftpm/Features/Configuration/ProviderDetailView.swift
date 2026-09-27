// Features/Configuration/ProviderDetailView.swift
// Configures BYOK credentials in KeychainVault and persists enabled ProviderConfiguration.
// Includes truthful capability reporting, consumer subscription disclaimers, and model selection.
// Per V3 §Features/Configuration and P08 requirements.

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
    @State private var selectedModel: String = ""
    @State private var availableModels: [ModelDescriptor] = []
    @State private var customBaseURLString: String = ""

    private var isAppleOnDevice: Bool {
        providerID == "appleFoundationModels" || providerID == "appleFoundation"
    }

    private var providerKind: ProviderKind {
        ProviderKind(rawValue: providerID) ?? .custom
    }

    var body: some View {
        Form {
            if isAppleOnDevice {
                Section("On-Device Engine Status") {
                    HStack {
                        Image(systemName: "cpu")
                            .foregroundStyle(.purple)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Apple Intelligence (On-Device)")
                                .font(.headline)
                            Text("Apple Foundation Models run strictly locally on device and never transmit data to cloud servers.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack {
                        Text("Eligibility")
                        Spacer()
                        #if arch(arm64) && !targetEnvironment(simulator)
                        Label("Supported", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        #else
                        Label("Unavailable on this Device", systemImage: "xmark.circle.fill")
                            .foregroundStyle(.orange)
                        #endif
                    }

                    Text("Apple Intelligence requires physical Apple Silicon (A17 Pro, M1 or later) running iOS 18.1+ with Apple Intelligence turned on in System Settings.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } else {
                Section {
                    SecureField("API Key", text: $apiKey)
                        .accessibilityLabel("API Key input")
                        .autocorrectionDisabled()
                        #if !os(macOS)
                        .textInputAutocapitalization(.never)
                        #endif

                    Toggle("Enable Provider", isOn: $isEnabled)
                        .accessibilityLabel("Enable this provider")

                    if providerKind == .custom {
                        TextField("Base URL (e.g. https://api.example.com/v1)", text: $customBaseURLString)
                            .accessibilityLabel("Custom endpoint base URL")
                            .autocorrectionDisabled()
                            #if !os(macOS)
                            .textInputAutocapitalization(.never)
                            #endif
                    }

                    Button(action: saveKey) {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save to Keychain")
                        }
                    }
                    .disabled(apiKey.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                    .buttonStyle(.borderedProminent)
                } header: {
                    Text("API Credentials")
                } footer: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("API keys are stored securely in your local device Keychain and transmitted directly to \(providerName) exclusively as an Authorization header during AI turns.")
                        if providerKind == .openAI {
                            Text("⚠️ Note: ChatGPT Plus is a consumer web subscription and does NOT provide API access. A developer API key from platform.openai.com is required.")
                                .foregroundStyle(.secondary)
                        } else if providerKind == .gemini {
                            Text("⚠️ Note: Google One / Gemini Advanced is a consumer subscription and does NOT provide API access. A developer API key from aistudio.google.com is required.")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .font(.footnote)
                }
            }

            if !availableModels.isEmpty {
                Section("Model Selection") {
                    Picker("Default Model", selection: $selectedModel) {
                        ForEach(availableModels) { model in
                            VStack(alignment: .leading) {
                                Text(model.displayName)
                                Text(model.id)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .tag(model.id)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
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
            await loadModels()
        }
    }

    private func loadExisting() async {
        guard let owner = session.currentProfile else { return }
        let hasKey = await container.keychainVault.hasSecret(ownerID: owner.id, providerID: providerID)
        if hasKey {
            statusMessage = "Key is currently configured in Keychain."
            isError = false
        }
        let configs = (try? await container.configurationRepository.providerConfigs(ownerID: owner.id)) ?? []
        if let config = configs.first(where: { $0.providerKind == providerKind }) {
            isEnabled = config.isEnabled
            if let override = config.modelOverride, !override.isEmpty {
                selectedModel = override
            }
            if let base = config.baseURL {
                customBaseURLString = base.absoluteString
            }
        }
    }

    private func loadModels() async {
        let cached = await container.modelCatalogClient.cachedModels(providerID: providerID)
        if let cached, !cached.isEmpty {
            availableModels = cached
        } else {
            let defaults = ModelCatalogClient.defaultFallbackCatalog()[providerID] ?? []
            availableModels = defaults
        }
        if selectedModel.isEmpty, let first = availableModels.first {
            selectedModel = first.id
        }
    }

    private func saveKey() {
        guard let owner = session.currentProfile else { return }
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else { return }

        // Enforce honest API key validation rejecting consumer subscriptions (P08)
        let validation = ProviderAPIKeyValidator.validate(key: trimmedKey, for: providerKind)
        switch validation {
        case .failure(let err):
            statusMessage = err.localizedDescription
            isError = true
            return
        case .success(let validatedKey):
            isSaving = true
            statusMessage = nil
            isError = false

            Task {
                defer { isSaving = false }
                do {
                    try await container.keychainVault.setSecret(
                        ownerID: owner.id,
                        providerID: providerID,
                        value: validatedKey
                    )

                    let kind = providerKind
                    let existingConfigs = (try? await container.configurationRepository.providerConfigs(ownerID: owner.id)) ?? []
                    let existing = existingConfigs.first { $0.providerKind == kind }
                    let configID = existing?.id ?? ProviderConfigID()

                    let baseURL = customBaseURLString.isEmpty ? nil : URL(string: customBaseURLString)

                    let config = ProviderConfiguration(
                        id: configID,
                        ownerID: owner.id,
                        providerKind: kind,
                        displayName: providerName,
                        baseURL: baseURL,
                        keychainKey: "\(owner.id.rawValue.uuidString).\(providerID)",
                        isEnabled: isEnabled,
                        modelOverride: selectedModel.isEmpty ? nil : selectedModel
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
}
