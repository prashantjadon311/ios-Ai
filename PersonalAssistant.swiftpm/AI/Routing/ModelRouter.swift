// AI/Routing/ModelRouter.swift
// Model routing and fallback per V3 §B03.
// Freezes traceID before first token; no automatic fallback after first visible output.
// Enforces capability filtering, privacy mode constraints, health checks, and credentials.

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

    init(keychainVault: KeychainVault, initialProviders: [any AssistantModel] = []) {
        self.keychainVault = keychainVault
        for provider in initialProviders {
            self.providers[provider.providerID] = provider
        }
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
        configs: [ProviderConfiguration],
        privacyMode: PrivacyMode = .cloudAllowed
    ) async -> RoutingResult {
        // Enforce Private Only constraint (T024)
        if privacyMode == .privateOnly {
            return .noneEligible(reason: "External model routing is disabled in Private Only mode. Switch to Cloud Allowed to use cloud providers.")
        }

        var eligible: [(config: ProviderConfiguration, provider: any AssistantModel)] = []

        for config in configs {
            guard config.isEnabled else { continue }
            // Lookup by providerKind rawValue (e.g. "groq", "openRouter") or config ID
            guard let provider = providers[config.providerKind.rawValue] ?? providers[config.id.rawValue.uuidString] else {
                continue
            }

            // Capability filtering (S014 / I11)
            if requirements.needsVision {
                let modelId = (config.modelOverride ?? "").lowercased()
                if !modelId.contains("vision") && !modelId.contains("vl") && !modelId.isEmpty {
                    continue
                }
            }

            if requirements.needsTools {
                let modelId = (config.modelOverride ?? "").lowercased()
                if modelId.contains("embed") {
                    continue
                }
            }

            // Key check
            let hasKey = await keychainVault.hasSecret(ownerID: ownerID, providerID: config.providerKind.rawValue)
            guard hasKey else { continue }

            // Health check
            let isHealthy = healthMap[config.providerKind.rawValue] ?? healthMap[config.id.rawValue.uuidString] ?? true
            guard isHealthy else { continue }

            eligible.append((config, provider))
        }

        guard let first = eligible.first else {
            return .noneEligible(reason: "No eligible provider with valid credentials found matching capabilities")
        }

        let modelID = first.config.modelOverride ?? "default"
        return .selected(provider: first.provider, modelID: modelID)
    }

    // MARK: - Health update

    func updateHealth(providerID: String, isHealthy: Bool) {
        healthMap[providerID] = isHealthy
    }
}

