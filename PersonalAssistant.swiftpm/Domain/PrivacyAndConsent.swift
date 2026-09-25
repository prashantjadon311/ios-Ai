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
}

// MARK: - Consent record

/// Tracks explicit per-channel opt-in consent (A10 per-channel consent).
struct ConsentRecord: Codable, Sendable, Hashable {
    let destination: DataEgressDestination
    let maximumDataClass: PrivacyClass
    var isGranted: Bool
    var grantedAt: Date?
    var revokedAt: Date?

    init(
        destination: DataEgressDestination,
        maximumDataClass: PrivacyClass,
        isGranted: Bool = false
    ) {
        self.destination = destination
        self.maximumDataClass = maximumDataClass
        self.isGranted = isGranted
    }
}

// MARK: - App preference

/// V3 §Stable business entities — AppPreference.
struct AppPreference: Codable, Sendable, Hashable {
    let ownerID: UserID
    var privacyMode: PrivacyMode
    var consents: [DataEgressDestination: ConsentRecord]
    var activeAssistantID: AssistantID?
    var appearanceMode: AppearanceMode
    var localeIdentifier: String?
    var reduceMotion: Bool   // mirror of system preference, cached
    var largeText: Bool      // mirror of system preference, cached
    var updatedAt: Date

    init(ownerID: UserID, activeAssistantID: AssistantID? = nil) {
        self.ownerID = ownerID
        self.privacyMode = .cloudAllowed
        self.consents = [:]
        self.activeAssistantID = activeAssistantID
        self.appearanceMode = .system
        self.localeIdentifier = nil
        self.reduceMotion = false
        self.largeText = false
        self.updatedAt = Date()
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
