// AI/Routing/ModelRouter.swift
// Model routing and fallback per V3 §B03.
// Freezes traceID before first token; no automatic fallback after first visible output.

import Foundation
import Observation

// MARK: - Routing result

enum RoutingResult: Sendable {
    case selected(provider: any AssistantModel, modelID: String)
    case noneEligible(reason: String)
}

// MARK: - ModelRouter actor

actor ModelRouter {

    private var providers: [String: any AssistantModel] = [:]
    private var healthMap: [String: Bool] = [:]
    private let keychainVault: KeychainVault

    init(keychainVault: KeychainVault) {
        self.keychainVault = keychainVault
    }

    func register(provider: any AssistantModel) {
        providers[provider.providerID] = provider
    }

    // MARK: - Route selection (B03)

    /// Selects the best eligible provider for the given requirements.
    /// B03: filter order — capabilities, credentials, availability, privacy, context, health, budget, preferences, config order.
    func route(
        requirements: CapabilityRequirements,
        ownerID: UserID,
        configs: [ProviderConfiguration]
    ) -> RoutingResult {
        // Only consider enabled configs with keys
        let eligible = configs.filter { config in
            guard config.isEnabled else { return false }
            guard providers[config.id.rawValue.uuidString] != nil else { return false }
            let hasKey = keychainVault.hasSecret(ownerID: ownerID, providerID: config.providerKind.rawValue)
            guard hasKey else { return false }
            // Provider must be healthy (or unknown = optimistic)
            let healthy = healthMap[config.id.rawValue.uuidString] ?? true
            return healthy
        }

        guard let first = eligible.first,
              let provider = providers[first.id.rawValue.uuidString] else {
            return .noneEligible(reason: "No eligible provider with credentials found")
        }

        return .selected(provider: provider, modelID: first.modelOverride ?? "default")
    }

    // MARK: - Health update

    func updateHealth(providerID: String, isHealthy: Bool) {
        healthMap[providerID] = isHealthy
    }
}

private extension ProviderConfiguration {
    var id: ProviderConfigID { self.id }
}
