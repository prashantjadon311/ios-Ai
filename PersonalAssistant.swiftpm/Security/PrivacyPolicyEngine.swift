// Security/PrivacyPolicyEngine.swift
// Enforces privacy policy rules and data egress boundaries.
// Per V3 §Security/PrivacyPolicyEngine.swift blueprint.

import Foundation

struct PrivacyPolicyEngine: Sendable {
    static func checkEgressAllowed(
        route: String,
        privacyMode: PrivacyMode,
        dataClass: PrivacyClass
    ) throws {
        if privacyMode == .privateOnly {
            throw AppError.privacyDenied(route: route, requiredClass: dataClass)
        }
        if privacyMode == .cloudAllowed && dataClass == .secret {
            throw AppError.privacyDenied(route: route, requiredClass: .secret)
        }
    }
}
