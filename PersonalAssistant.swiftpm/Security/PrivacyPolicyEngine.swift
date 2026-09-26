// Security/PrivacyPolicyEngine.swift
// Enforces privacy policy rules and data egress boundaries.
// Per V3 §Security/PrivacyPolicyEngine.swift blueprint.

import Foundation

struct PrivacyPolicyEngine: Sendable {
    static func checkEgressAllowed(privacyMode: PrivacyMode, dataClass: PrivacyClass) throws {
        if privacyMode == .privateOnly {
            throw AppError.privacyDenied(reason: "External data transfer is strictly blocked in Private Only mode")
        }
        if privacyMode == .standard && dataClass == .secret {
            throw AppError.privacyDenied(reason: "Secrets cannot be transmitted to external models")
        }
    }
}
