// Persistence/ConfigurationRepository.swift
// Persists user profiles, assistant profiles, provider configs, and app preferences.
// Actor-isolated to prevent concurrent ModelContext access.

import Foundation
import SwiftData

actor ConfigurationRepository {

    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    // MARK: - Context helper

    @MainActor
    private var context: ModelContext { modelContainer.mainContext }

    // MARK: - User profiles

    func allUserProfiles() async throws -> [UserProfile] {
        let stored = try await MainActor.run {
            try context.fetch(FetchDescriptor<StoredUserProfile>())
        }
        return try stored.map { try UserProfileMapper.toDomain($0) }
    }

    func saveUserProfile(_ profile: UserProfile) async throws {
        try await MainActor.run {
            let descriptor = FetchDescriptor<StoredUserProfile>(
                predicate: #Predicate { $0.id == profile.id.rawValue }
            )
            if let existing = try context.fetch(descriptor).first {
                UserProfileMapper.update(stored: existing, from: profile)
            } else {
                context.insert(try UserProfileMapper.toStored(profile))
            }
            try context.save()
        }
    }

    // MARK: - Assistant profiles

    func assistantProfiles(ownerID: UserID) async throws -> [AssistantProfile] {
        let ownerUUID = ownerID.rawValue
        let stored = try await MainActor.run {
            let descriptor = FetchDescriptor<StoredAssistantProfile>(
                predicate: #Predicate { $0.ownerID == ownerUUID }
            )
            return try context.fetch(descriptor)
        }
        return try stored.map { try AssistantProfileMapper.toDomain($0) }
    }

    func saveAssistantProfile(_ profile: AssistantProfile) async throws {
        try await MainActor.run {
            let id = profile.id.rawValue
            let descriptor = FetchDescriptor<StoredAssistantProfile>(
                predicate: #Predicate { $0.id == id }
            )
            if let existing = try context.fetch(descriptor).first {
                try AssistantProfileMapper.update(stored: existing, from: profile)
            } else {
                context.insert(try AssistantProfileMapper.toStored(profile))
            }
            try context.save()
        }
    }

    // MARK: - App preferences

    func preferences(ownerID: UserID) async throws -> AppPreference {
        let ownerUUID = ownerID.rawValue
        let stored = try await MainActor.run {
            let descriptor = FetchDescriptor<StoredAppPreference>(
                predicate: #Predicate { $0.ownerID == ownerUUID }
            )
            return try context.fetch(descriptor).first
        }
        guard let stored else {
            return AppPreference(ownerID: ownerID)
        }
        let mode = PrivacyMode(rawValue: stored.privacyModeRaw) ?? .cloudAllowed
        let appearance = AppearanceMode(rawValue: stored.appearanceModeRaw) ?? .system
        var prefs = AppPreference(ownerID: ownerID, activeAssistantID: stored.activeAssistantIDRaw.map { AssistantID(rawValue: $0) })
        prefs.privacyMode = mode
        prefs.appearanceMode = appearance
        prefs.localeIdentifier = stored.localeIdentifier
        prefs.updatedAt = stored.updatedAt
        if let records = try? JSONDecoder().decode([ConsentRecord].self, from: stored.consentsData) {
            var consentMap: [DataEgressDestination: ConsentRecord] = [:]
            for record in records {
                consentMap[record.destination] = record
            }
            prefs.consents = consentMap
        }
        return prefs
    }

    func savePreferences(_ prefs: AppPreference) async throws {
        let ownerUUID = prefs.ownerID.rawValue
        let consentsData = (try? JSONEncoder().encode(Array(prefs.consents.values))) ?? Data()
        try await MainActor.run {
            let descriptor = FetchDescriptor<StoredAppPreference>(
                predicate: #Predicate { $0.ownerID == ownerUUID }
            )
            if let existing = try context.fetch(descriptor).first {
                existing.privacyModeRaw = prefs.privacyMode.rawValue
                existing.consentsData = consentsData
                existing.activeAssistantIDRaw = prefs.activeAssistantID?.rawValue
                existing.appearanceModeRaw = prefs.appearanceMode.rawValue
                existing.localeIdentifier = prefs.localeIdentifier
                existing.updatedAt = prefs.updatedAt
            } else {
                let stored = StoredAppPreference(
                    ownerID: ownerUUID,
                    privacyModeRaw: prefs.privacyMode.rawValue,
                    consentsData: consentsData,
                    activeAssistantIDRaw: prefs.activeAssistantID?.rawValue,
                    appearanceModeRaw: prefs.appearanceMode.rawValue,
                    localeIdentifier: prefs.localeIdentifier,
                    updatedAt: prefs.updatedAt
                )
                context.insert(stored)
            }
            try context.save()
        }
    }

    // MARK: - Provider configurations

    func providerConfigs(ownerID: UserID) async throws -> [ProviderConfiguration] {
        let ownerUUID = ownerID.rawValue
        let stored = try await MainActor.run {
            let descriptor = FetchDescriptor<StoredProviderConfiguration>(
                predicate: #Predicate { $0.ownerID == ownerUUID }
            )
            return try context.fetch(descriptor)
        }
        return stored.map { ProviderConfigMapper.toDomain($0) }
    }

    func saveProviderConfig(_ config: ProviderConfiguration, session: SessionToken) async throws {
        try await MainActor.run {
            let id = config.id.rawValue
            let descriptor = FetchDescriptor<StoredProviderConfiguration>(
                predicate: #Predicate { $0.id == id }
            )
            if let existing = try context.fetch(descriptor).first {
                let updated = ProviderConfigMapper.toStored(config)
                existing.displayName = updated.displayName
                existing.baseURLString = updated.baseURLString
                existing.catalogURLString = updated.catalogURLString
                existing.isEnabled = updated.isEnabled
                existing.budgetLimitData = updated.budgetLimitData
                existing.modelOverride = updated.modelOverride
                existing.catalogTTLSeconds = updated.catalogTTLSeconds
                existing.updatedAt = updated.updatedAt
            } else {
                context.insert(ProviderConfigMapper.toStored(config))
            }
            try context.save()
        }
    }
}
