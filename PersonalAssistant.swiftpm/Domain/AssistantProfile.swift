// Domain/AssistantProfile.swift
// Maya/Saar user-owned name, avatar, locale and voice settings.
// Single responsibility: assistant identity DTO. No SwiftData/SwiftUI imports.

import Foundation

/// V3 §Stable business entities — AssistantProfile.
/// Two independent editable avatar identities (Maya and Saar).
/// A profile switch is NOT an account switch.
struct AssistantProfile: Identifiable, Codable, Sendable, Hashable {
    let id: AssistantID
    let ownerID: UserID
    /// Display name — user-renameable, not the role name.
    var displayName: String
    /// Canonical avatar role (Maya = female, Saar = male). Immutable once created.
    let avatarRole: AvatarRole
    var voiceSettings: VoiceSettings
    var stylePreference: StylePreference
    /// Provider/model overrides per assistant (nil = use app global config).
    var providerOverrideID: ProviderConfigID?
    let createdAt: Date
    var updatedAt: Date

    init(
        id: AssistantID = AssistantID(),
        ownerID: UserID,
        displayName: String,
        avatarRole: AvatarRole,
        voiceSettings: VoiceSettings = VoiceSettings(),
        stylePreference: StylePreference = .balanced,
        providerOverrideID: ProviderConfigID? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.ownerID = ownerID
        self.displayName = displayName
        self.avatarRole = avatarRole
        self.voiceSettings = voiceSettings
        self.stylePreference = stylePreference
        self.providerOverrideID = providerOverrideID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Avatar role

/// The canonical identity for each assistant slot.
/// User may rename but cannot change the underlying avatar role after creation.
enum AvatarRole: String, Codable, Sendable, Hashable, CaseIterable {
    case maya  // Female assistant
    case saar  // Male assistant
}

// MARK: - Voice settings

struct VoiceSettings: Codable, Sendable, Hashable {
    /// Locale identifier e.g. "en-US", "hi-IN". nil = system default.
    var localeIdentifier: String?
    /// System voice identifier (AVSpeechSynthesisVoice.identifier). nil = system default.
    var voiceIdentifier: String?
    /// Rate 0.0–1.0 mapped to AVSpeechUtteranceDefaultSpeechRate range.
    var rate: Float
    /// Pitch multiplier 0.5–2.0.
    var pitchMultiplier: Float
    /// Volume 0.0–1.0.
    var volume: Float
    /// Whether to use cloud STT (requires separate explicit opt-in consent).
    var cloudSTTConsent: Bool

    init(
        localeIdentifier: String? = nil,
        voiceIdentifier: String? = nil,
        rate: Float = 0.5,
        pitchMultiplier: Float = 1.0,
        volume: Float = 1.0,
        cloudSTTConsent: Bool = false
    ) {
        self.localeIdentifier = localeIdentifier
        self.voiceIdentifier = voiceIdentifier
        self.rate = rate.clamped(to: 0.0...1.0)
        self.pitchMultiplier = pitchMultiplier.clamped(to: 0.5...2.0)
        self.volume = volume.clamped(to: 0.0...1.0)
        self.cloudSTTConsent = cloudSTTConsent
    }
}

// MARK: - Style preference

enum StylePreference: String, Codable, Sendable, Hashable, CaseIterable {
    case concise
    case balanced
    case detailed
}

// MARK: - Validation

extension AssistantProfile {
    enum ValidationError: Error, Sendable {
        case nameTooShort
        case nameTooLong
        case ownerMismatch
    }

    static let minimumNameLength = 1
    static let maximumNameLength = 64

    static func validateDisplayName(_ name: String) throws {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= minimumNameLength else { throw ValidationError.nameTooShort }
        guard trimmed.count <= maximumNameLength else { throw ValidationError.nameTooLong }
    }

    func withDisplayName(_ name: String, updatedAt: Date = Date()) throws -> AssistantProfile {
        try AssistantProfile.validateDisplayName(name)
        return AssistantProfile(
            id: id,
            ownerID: ownerID,
            displayName: name.trimmingCharacters(in: .whitespacesAndNewlines),
            avatarRole: avatarRole,
            voiceSettings: voiceSettings,
            stylePreference: stylePreference,
            providerOverrideID: providerOverrideID,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - Factory defaults

extension AssistantProfile {
    /// Creates the default Maya assistant for a new owner.
    static func defaultMaya(ownerID: UserID) -> AssistantProfile {
        AssistantProfile(
            ownerID: ownerID,
            displayName: "Maya",
            avatarRole: .maya
        )
    }

    /// Creates the default Saar assistant for a new owner.
    static func defaultSaar(ownerID: UserID) -> AssistantProfile {
        AssistantProfile(
            ownerID: ownerID,
            displayName: "Saar",
            avatarRole: .saar
        )
    }
}

// MARK: - Float clamping helper

private extension Float {
    func clamped(to range: ClosedRange<Float>) -> Float {
        Swift.max(range.lowerBound, Swift.min(range.upperBound, self))
    }
}
