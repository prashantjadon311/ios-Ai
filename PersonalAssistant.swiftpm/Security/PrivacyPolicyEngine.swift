// Security/PrivacyPolicyEngine.swift
// Enforces privacy policy rules and data egress boundaries.
// Per V3 §Security/PrivacyPolicyEngine.swift blueprint.

import Foundation

struct PrivacyPolicyEngine: Sendable {
    static func checkEgressAllowed(
        destination: DataEgressDestination,
        privacyMode: PrivacyMode,
        dataClass: PrivacyClass,
        consent: ConsentRecord?
    ) throws {
        // 1. On-device destinations always permitted
        if destination == .system || destination == .appleFoundationModel {
            return
        }

        // 2. Global privacy mode: Private-only blocks ALL external egress
        guard privacyMode == .cloudAllowed else {
            throw AppError.privacyDenied(route: destination.rawValue, requiredClass: dataClass)
        }

        // 3. Absolute Secret Policy: .secret data is NEVER permitted to leave the device
        guard dataClass < .secret else {
            throw AppError.privacyDenied(route: destination.rawValue, requiredClass: .secret)
        }

        // 4. Explicit Per-Destination Opt-In Consent:
        // Cloud Allowed mode DOES NOT automatically authorize every provider!
        guard let consent = consent, consent.isGranted else {
            throw AppError.privacyDenied(route: destination.rawValue, requiredClass: dataClass)
        }

        // 4b. Destination match check
        guard consent.destination == destination else {
            throw AppError.privacyDenied(route: destination.rawValue, requiredClass: dataClass)
        }

        // 5. Revocation Check
        if let revokedAt = consent.revokedAt, revokedAt <= Date() {
            throw AppError.privacyDenied(route: destination.rawValue, requiredClass: dataClass)
        }

        // 6. Data Classification Ceiling Check
        guard dataClass <= consent.maximumDataClass else {
            throw AppError.privacyDenied(route: destination.rawValue, requiredClass: dataClass)
        }
    }

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
