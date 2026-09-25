// App/FeatureGate.swift
// Presents only genuinely supported features; combines capability + release flag + consent.
// Per V3 §App/FeatureGate.swift.

import Foundation

/// Combines OS/device capability, release scope, and user consent into a single decision.
struct FeatureGate: Sendable {

    let capability: FeatureDecision
    let isInScope: Bool       // V1 = true, COND = capability-gated, NEXT = false
    let hasConsent: Bool      // user has explicitly consented (where required)

    /// Whether the feature is available to the user right now.
    var isEnabled: Bool {
        isInScope && capability.isAvailable && hasConsent
    }

    /// Human-readable reason if disabled.
    var disabledReason: String? {
        if !isInScope { return "Not available in this version" }
        if !capability.isAvailable { return capability.reason }
        if !hasConsent { return "Permission or consent required" }
        return nil
    }
}

// MARK: - Feature gate registry

@MainActor
struct FeatureGateRegistry {
    let capabilityCenter: CapabilityCenter

    func gate(for feature: AppFeature, consentGranted: Bool = true) -> FeatureGate {
        let decision = capabilityCenter.isAvailable(feature: feature)
        return FeatureGate(
            capability: decision,
            isInScope: isV1Scope(feature),
            hasConsent: consentGranted
        )
    }

    private func isV1Scope(_ feature: AppFeature) -> Bool {
        switch feature {
        case .voiceInput: return true        // V1 (tap-to-talk)
        case .localNotifications: return true // V1 (task reminders)
        case .appleFoundationModels: return false // COND — not in V1 shipping path
        case .networkFeatures: return true   // V1 (BYOK providers)
        }
    }
}
