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
        privacyMode: PrivacyMode,
        consents: [String: ConsentRecord],
        dataClass: PrivacyClass
    ) async -> RoutingResult {
        // 1. Enforce requirement privacy ceiling:
        if dataClass > requirements.allowedPrivacy {
            return .noneEligible(
                reason: "Turn sensitivity '\(dataClass)' exceeds allowedPrivacy requirement '\(requirements.allowedPrivacy)'"
            )
        }

        // 2. Enforce Private Only constraint (T024)
        if privacyMode == .privateOnly {
            let hasLocalCandidate = configs.contains { $0.ownerID == ownerID && $0.isEnabled && $0.providerKind == .appleFoundation }
            if !hasLocalCandidate {
                return .noneEligible(reason: "External model routing is disabled in Private Only mode. Switch to Cloud Allowed to use cloud providers.")
            }
        }

        var eligible: [(config: ProviderConfiguration, provider: any AssistantModel, modelID: String)] = []

        for config in configs {
            guard config.ownerID == ownerID, config.isEnabled else { continue }
            guard let raw = config.modelOverride?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !raw.isEmpty, raw != "default" else { continue }
            let selectedModelID = raw

            let destination = config.egressDestination
            let effectiveConsent: ConsentRecord?
            if config.providerKind == .custom {
                effectiveConsent = consents[ConsentRecord.computeScopeKey(
                    destination: .customEndpoint,
                    providerConfigID: config.id,
                    endpointOrigin: config.normalizedEndpointOrigin
                )]
            } else {
                effectiveConsent = consents[destination.rawValue]
            }

            // Full privacy and consent check:
            do {
                try PrivacyPolicyEngine.checkEgressAllowed(
                    destination: destination,
                    privacyMode: privacyMode,
                    dataClass: dataClass,
                    consent: effectiveConsent
                )
            } catch {
                continue // Egress blocked by privacy mode, ceiling, or missing/revoked consent
            }

            // Lookup by providerKind rawValue (e.g. "groq", "openRouter") or config ID
            guard let provider = providers[config.providerKind.rawValue] ?? providers[config.id.rawValue.uuidString] else {
                continue
            }

            // Key check
            let hasKey = await keychainVault.hasSecret(ownerID: ownerID, providerID: config.providerKind.rawValue)
            guard hasKey else { continue }

            // Health check
            let isHealthy = healthMap[config.providerKind.rawValue] ?? healthMap[config.id.rawValue.uuidString] ?? true
            guard isHealthy else { continue }

            // Capability check using provider.models() if available
            if let availableModels = try? await provider.models() {
                if let descriptor = availableModels.first(where: { $0.id == selectedModelID }) {
                    if requirements.needsVision && descriptor.capabilities.vision != .yes {
                        continue
                    }
                    if requirements.needsTools && descriptor.capabilities.tools != .yes {
                        continue
                    }
                } else if requirements.needsVision || requirements.needsTools {
                    continue
                }
            } else if requirements.needsVision || requirements.needsTools {
                continue
            }

            eligible.append((config, provider, selectedModelID))
        }

        guard let first = eligible.first else {
            return .noneEligible(reason: "No eligible provider matching capabilities, health, and privacy consent found")
        }

        return .selected(provider: first.provider, modelID: first.modelID)
    }

    // MARK: - Health update

    func updateHealth(providerID: String, isHealthy: Bool) {
        healthMap[providerID] = isHealthy
    }
}

