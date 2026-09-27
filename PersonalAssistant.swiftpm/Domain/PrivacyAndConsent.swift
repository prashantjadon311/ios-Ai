// Domain/PrivacyAndConsent.swift
// Data egress destination, privacy policy, consent records.
// Per V3 A10: one central destination-aware data egress decision with per-channel consent.

import Foundation

// MARK: - Privacy mode

/// Global privacy mode controls what data may leave the device.
enum PrivacyMode: String, Codable, Sendable, Hashable, CaseIterable {
    /// Private-only: NO external content transfer. Local features only.
    case privateOnly
    /// Cloud allowed: external AI/STT may be used for permitted data classes.
    case cloudAllowed

    /// When private-only, ALL external data transfer is blocked (not just AI chat).
    var allowsExternalTransfer: Bool {
        self == .cloudAllowed
    }
}

// MARK: - Data egress destination

/// Named destinations for data egress decisions (A10 one-central-decision rule).
enum DataEgressDestination: String, Codable, Sendable, Hashable, CaseIterable {
    case groqAPI
    case openRouterAPI
    case customEndpoint
    case appleFoundationModel  // COND
    case managedGateway        // NEXT
    case appleSTT              // COND — requires separate consent
    case externalURL           // user-initiated browser open
    case system                // local OS APIs only
    case openAIAPI
    case geminiAPI
    case nvidiaAPI
}

// MARK: - Consent record

/// Tracks explicit per-channel opt-in consent (A10 per-channel consent).
struct ConsentRecord: Codable, Sendable, Hashable {
    let destination: DataEgressDestination
    var providerConfigID: ProviderConfigID?
    var endpointOrigin: String? // Normalized HTTPS origin: "https://host:port"
    let maximumDataClass: PrivacyClass
    var isGranted: Bool
    var grantedAt: Date?
    var revokedAt: Date?

    var scopeKey: String {
        ConsentRecord.computeScopeKey(
            destination: destination,
            providerConfigID: providerConfigID,
            endpointOrigin: endpointOrigin
        )
    }

    static func computeScopeKey(
        destination: DataEgressDestination,
        providerConfigID: ProviderConfigID? = nil,
        endpointOrigin: String? = nil
    ) -> String {
        var key = destination.rawValue
        if let configID = providerConfigID {
            key += ":\(configID.rawValue.uuidString)"
        }
        if let origin = endpointOrigin {
            key += ":\(origin)"
        }
        return key
    }

    init(
        destination: DataEgressDestination,
        providerConfigID: ProviderConfigID? = nil,
        endpointOrigin: String? = nil,
        maximumDataClass: PrivacyClass,
        isGranted: Bool = false,
        grantedAt: Date? = nil,
        revokedAt: Date? = nil
    ) {
        self.destination = destination
        self.providerConfigID = providerConfigID
        self.endpointOrigin = endpointOrigin
        self.maximumDataClass = maximumDataClass
        self.isGranted = isGranted
        self.grantedAt = grantedAt
        self.revokedAt = revokedAt
    }
}

// MARK: - App preference

/// V3 §Stable business entities — AppPreference.
struct AppPreference: Codable, Sendable, Hashable {
    let ownerID: UserID
    var privacyMode: PrivacyMode
    var consents: [String: ConsentRecord] // Keyed by stable scopeKey
    var activeAssistantID: AssistantID?
    var appearanceMode: AppearanceMode
    var localeIdentifier: String?
    var reduceMotion: Bool   // mirror of system preference, cached
    var largeText: Bool      // mirror of system preference, cached
    var updatedAt: Date

    init(ownerID: UserID, activeAssistantID: AssistantID? = nil) {
        self.ownerID = ownerID
        self.privacyMode = .privateOnly // Fail-closed: ZERO external transfer until explicit user opt-in
        self.consents = [:]
        self.activeAssistantID = activeAssistantID
        self.appearanceMode = .system
        self.localeIdentifier = nil
        self.reduceMotion = false
        self.largeText = false
        self.updatedAt = Date()
    }

    func consent(
        for destination: DataEgressDestination,
        providerConfigID: ProviderConfigID? = nil,
        endpointOrigin: String? = nil
    ) -> ConsentRecord? {
        let key = ConsentRecord.computeScopeKey(
            destination: destination,
            providerConfigID: providerConfigID,
            endpointOrigin: endpointOrigin
        )
        return consents[key]
    }

    mutating func grantConsent(
        destination: DataEgressDestination,
        maximumDataClass: PrivacyClass,
        providerConfigID: ProviderConfigID? = nil,
        endpointOrigin: String? = nil,
        at date: Date = Date()
    ) {
        let record = ConsentRecord(
            destination: destination,
            providerConfigID: providerConfigID,
            endpointOrigin: endpointOrigin,
            maximumDataClass: maximumDataClass,
            isGranted: true,
            grantedAt: date,
            revokedAt: nil
        )
        consents[record.scopeKey] = record
        updatedAt = date
    }

    mutating func revokeConsent(
        destination: DataEgressDestination,
        providerConfigID: ProviderConfigID? = nil,
        endpointOrigin: String? = nil,
        at date: Date = Date()
    ) {
        let key = ConsentRecord.computeScopeKey(
            destination: destination,
            providerConfigID: providerConfigID,
            endpointOrigin: endpointOrigin
        )
        if var existing = consents[key] {
            existing.isGranted = false
            existing.revokedAt = date
            consents[key] = existing
            updatedAt = date
        }
    }
}

// MARK: - Appearance

enum AppearanceMode: String, Codable, Sendable, Hashable, CaseIterable {
    case system
    case light
    case dark
}

// MARK: - Permission status

/// Typed OS permission states (never assume granted without actual OS query).
enum PermissionStatus: Sendable {
    case notDetermined
    case granted
    case denied
    case restricted
    case unavailable(reason: String)
}
