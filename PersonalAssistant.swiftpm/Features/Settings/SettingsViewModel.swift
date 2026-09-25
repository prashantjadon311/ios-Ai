// Features/Settings/SettingsViewModel.swift

import Foundation
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    private(set) var providerConfigs: [ProviderConfiguration] = []
    private(set) var isLoading = false
    private(set) var error: AppError?
    var showDeleteConfirmation = false

    private let session: AppSession
    private let configurationRepository: ConfigurationRepository
    private let keychainVault: KeychainVault
    private let capabilityCenter: CapabilityCenter

    init(
        session: AppSession,
        configurationRepository: ConfigurationRepository,
        keychainVault: KeychainVault,
        capabilityCenter: CapabilityCenter
    ) {
        self.session = session
        self.configurationRepository = configurationRepository
        self.keychainVault = keychainVault
        self.capabilityCenter = capabilityCenter
    }

    func load() async {
        guard let owner = session.currentProfile else { return }
        isLoading = true; error = nil
        defer { isLoading = false }
        do {
            providerConfigs = try await configurationRepository.providerConfigs(ownerID: owner.id)
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }
    }

    var currentPrivacyMode: PrivacyMode {
        session.preferences?.privacyMode ?? .cloudAllowed
    }

    var currentAppearance: AppearanceMode {
        session.preferences?.appearanceMode ?? .system
    }

    func onLock() {
        session.lock()
    }
}
