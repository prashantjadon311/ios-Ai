// App/AppSession.swift
// MainActor observable source of truth for current owner, active assistant, and lock state.
// Per V3 §App/AppSession.swift blueprint and §Strong identity and session.

import Foundation
import SwiftUI
import Observation

@MainActor
@Observable
final class AppSession {

    // MARK: - Published state

    /// Active owner profile (nil during bootstrap or recovery).
    private(set) var currentProfile: UserProfile?
    /// Active assistant (Maya or Saar).
    private(set) var activeAssistant: AssistantProfile?
    /// Both assistant profiles for the current owner.
    private(set) var assistantProfiles: [AssistantProfile] = []
    /// App-level preferences.
    private(set) var preferences: AppPreference?
    /// Session token (generation changes on account switch).
    private(set) var sessionToken: SessionToken?
    /// Whether the app is in locked state (biometric/passcode required).
    private(set) var isLocked: Bool = false
    /// Whether first-run onboarding is required.
    var requiresOnboarding: Bool = false
    /// Store recovery is required — show diagnostics screen.
    private(set) var storeRecoveryRequired: Bool = false
    private(set) var storeRecoveryReason: String?

    // MARK: - Dependencies

    private let conversationRepository: ConversationRepository
    private let configurationRepository: ConfigurationRepository
    private let keychainVault: KeychainVault

    // MARK: - Init

    init(
        conversationRepository: ConversationRepository,
        configurationRepository: ConfigurationRepository,
        keychainVault: KeychainVault
    ) {
        self.conversationRepository = conversationRepository
        self.configurationRepository = configurationRepository
        self.keychainVault = keychainVault
    }

    // MARK: - Bootstrap

    /// Loads stored active owner or creates two new profiles exactly once on empty store.
    func bootstrapLocalProfile() async {
        do {
            let profiles = try await configurationRepository.allUserProfiles()
            if profiles.isEmpty {
                // First launch: create owner + both assistants
                let owner = UserProfile(displayName: "Me")
                let maya = AssistantProfile.defaultMaya(ownerID: owner.id)
                let saar = AssistantProfile.defaultSaar(ownerID: owner.id)
                try await configurationRepository.saveUserProfile(owner)
                try await configurationRepository.saveAssistantProfile(maya)
                try await configurationRepository.saveAssistantProfile(saar)
                let prefs = AppPreference(ownerID: owner.id, activeAssistantID: maya.id)
                try await configurationRepository.savePreferences(prefs)
                activateProfile(owner, assistants: [maya, saar], prefs: prefs)
                requiresOnboarding = true
            } else {
                guard let owner = profiles.first else { return }
                let assistants = try await configurationRepository.assistantProfiles(ownerID: owner.id)
                let prefs = (try? await configurationRepository.preferences(ownerID: owner.id))
                    ?? AppPreference(ownerID: owner.id)
                activateProfile(owner, assistants: assistants, prefs: prefs)
            }
        } catch {
            requiresOnboarding = true
        }
    }

    private func activateProfile(
        _ owner: UserProfile,
        assistants: [AssistantProfile],
        prefs: AppPreference
    ) {
        currentProfile = owner
        assistantProfiles = assistants
        preferences = prefs
        let activeID = prefs.activeAssistantID
        activeAssistant = assistants.first { $0.id == activeID } ?? assistants.first
        sessionToken = SessionToken(userID: owner.id)
    }

    // MARK: - Profile switch

    /// Switches to a different local profile. Increments generation first, cancels old work.
    func switchProfile(to targetProfile: UserProfile) async throws {
        // 1. Increment generation to invalidate old callbacks
        sessionToken = SessionToken(userID: targetProfile.id)
        // 2. Clear caches
        activeAssistant = nil
        assistantProfiles = []
        preferences = nil
        currentProfile = nil
        // 3. Load new profile
        let assistants = try await configurationRepository.assistantProfiles(ownerID: targetProfile.id)
        let prefs = (try? await configurationRepository.preferences(ownerID: targetProfile.id))
            ?? AppPreference(ownerID: targetProfile.id)
        activateProfile(targetProfile, assistants: assistants, prefs: prefs)
    }

    // MARK: - Session capture

    /// Returns the current session token.
    func captureSession() throws -> SessionToken {
        guard let token = sessionToken else {
            throw AppError.notAuthenticated
        }
        return token
    }

    /// Validates that the given token still matches the current session.
    func requireCurrent(_ token: SessionToken) throws {
        guard let current = sessionToken else {
            throw AppError.notAuthenticated
        }
        try SessionGuard.require(token: token, against: current)
    }

    // MARK: - Assistant switching

    func setActiveAssistant(_ assistant: AssistantProfile) async throws {
        guard let owner = currentProfile else { throw AppError.notAuthenticated }
        guard assistant.ownerID == owner.id else {
            throw AppError.ownerMismatch(requested: assistant.ownerID, current: owner.id)
        }
        activeAssistant = assistant
        if var prefs = preferences {
            prefs.activeAssistantID = assistant.id
            prefs.updatedAt = Date()
            preferences = prefs
            try await configurationRepository.savePreferences(prefs)
        }
    }

    func updatePrivacyMode(_ mode: PrivacyMode) async throws {
        guard let owner = currentProfile else { throw AppError.notAuthenticated }
        var prefs = preferences ?? AppPreference(ownerID: owner.id)
        prefs.privacyMode = mode
        prefs.updatedAt = Date()
        preferences = prefs
        try await configurationRepository.savePreferences(prefs)
    }

    // MARK: - Lock

    func lock() {
        isLocked = true
    }

    func unlock() {
        isLocked = false
    }

    // MARK: - Store recovery

    func markStoreRecoveryRequired(reason: String) {
        storeRecoveryRequired = true
        storeRecoveryReason = reason
    }

    // MARK: - Onboarding completion

    func completeOnboarding() async {
        requiresOnboarding = false
    }
}

