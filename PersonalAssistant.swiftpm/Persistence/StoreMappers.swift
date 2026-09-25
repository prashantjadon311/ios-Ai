// Persistence/StoreMappers.swift
// Maps between @Model stored objects and immutable Sendable domain records.
// Per V3 §Persistence placement: mapping happens inside persistence isolation boundary.
// Never pass @Model objects across actor boundaries.

import Foundation
import SwiftData

// MARK: - JSON codec helper

private let jsonEncoder: JSONEncoder = {
    let e = JSONEncoder()
    e.dateEncodingStrategy = .iso8601
    return e
}()

private let jsonDecoder: JSONDecoder = {
    let d = JSONDecoder()
    d.dateDecodingStrategy = .iso8601
    return d
}()

private func encode<T: Encodable>(_ value: T) throws -> Data {
    try jsonEncoder.encode(value)
}

private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    try jsonDecoder.decode(type, from: data)
}

// MARK: - UserProfile mappings

enum UserProfileMapper {
    static func toDomain(_ stored: StoredUserProfile) throws -> UserProfile {
        let state = AccountState(rawValue: stored.accountStateRaw) ?? .localGuest
        return UserProfile(
            id: UserID(rawValue: stored.id),
            displayName: stored.displayName,
            createdAt: stored.createdAt,
            updatedAt: stored.updatedAt,
            accountState: state
        )
    }

    static func toStored(_ domain: UserProfile) throws -> StoredUserProfile {
        StoredUserProfile(
            id: domain.id.rawValue,
            displayName: domain.displayName,
            accountStateRaw: domain.accountState.rawValue,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt
        )
    }

    static func update(stored: StoredUserProfile, from domain: UserProfile) {
        stored.displayName = domain.displayName
        stored.accountStateRaw = domain.accountState.rawValue
        stored.updatedAt = domain.updatedAt
    }
}

// MARK: - AssistantProfile mappings

enum AssistantProfileMapper {
    static func toDomain(_ stored: StoredAssistantProfile) throws -> AssistantProfile {
        let role = AvatarRole(rawValue: stored.avatarRoleRaw) ?? .maya
        let style = StylePreference(rawValue: stored.stylePreferenceRaw) ?? .balanced
        let voice = try decode(VoiceSettings.self, from: stored.voiceSettingsData)
        let providerOverride = stored.providerOverrideIDRaw.map { ProviderConfigID(rawValue: $0) }
        return AssistantProfile(
            id: AssistantID(rawValue: stored.id),
            ownerID: UserID(rawValue: stored.ownerID),
            displayName: stored.displayName,
            avatarRole: role,
            voiceSettings: voice,
            stylePreference: style,
            providerOverrideID: providerOverride,
            createdAt: stored.createdAt,
            updatedAt: stored.updatedAt
        )
    }

    static func toStored(_ domain: AssistantProfile) throws -> StoredAssistantProfile {
        let voiceData = try encode(domain.voiceSettings)
        return StoredAssistantProfile(
            id: domain.id.rawValue,
            ownerID: domain.ownerID.rawValue,
            displayName: domain.displayName,
            avatarRoleRaw: domain.avatarRole.rawValue,
            voiceSettingsData: voiceData,
            stylePreferenceRaw: domain.stylePreference.rawValue,
            providerOverrideIDRaw: domain.providerOverrideID?.rawValue,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt
        )
    }

    static func update(stored: StoredAssistantProfile, from domain: AssistantProfile) throws {
        stored.displayName = domain.displayName
        stored.voiceSettingsData = try encode(domain.voiceSettings)
        stored.stylePreferenceRaw = domain.stylePreference.rawValue
        stored.providerOverrideIDRaw = domain.providerOverrideID?.rawValue
        stored.updatedAt = domain.updatedAt
    }
}

// MARK: - Conversation mappings

enum ConversationMapper {
    static func toDomain(_ stored: StoredConversation) -> Conversation {
        let state = ConversationState(rawValue: stored.stateRaw) ?? .active
        return Conversation(
            id: ConversationID(rawValue: stored.id),
            ownerID: UserID(rawValue: stored.ownerID),
            assistantID: AssistantID(rawValue: stored.assistantID),
            title: stored.title,
            state: state,
            lastMessageAt: stored.lastMessageAt,
            lastMessagePreview: stored.lastMessagePreview,
            createdAt: stored.createdAt,
            updatedAt: stored.updatedAt,
            messageCount: stored.messageCount
        )
    }

    static func toStored(_ domain: Conversation) -> StoredConversation {
        StoredConversation(
            id: domain.id.rawValue,
            ownerID: domain.ownerID.rawValue,
            assistantID: domain.assistantID.rawValue,
            title: domain.title,
            stateRaw: domain.state.rawValue,
            lastMessageAt: domain.lastMessageAt,
            lastMessagePreview: domain.lastMessagePreview,
            messageCount: domain.messageCount,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt
        )
    }

    static func update(stored: StoredConversation, from domain: Conversation) {
        stored.title = domain.title
        stored.stateRaw = domain.state.rawValue
        stored.lastMessageAt = domain.lastMessageAt
        stored.lastMessagePreview = domain.lastMessagePreview
        stored.messageCount = domain.messageCount
        stored.updatedAt = domain.updatedAt
    }
}

// MARK: - Message mappings

enum MessageMapper {
    static func toDomain(_ stored: StoredMessage) throws -> MessageRecord {
        let role = ContextRole(rawValue: stored.roleRaw) ?? .user
        let source = ContextSource(rawValue: stored.sourceRaw) ?? .userTyped
        let privacy = PrivacyClass(rawValue: stored.sensitivityRaw) ?? .personal
        let status = MessageStatus(rawValue: stored.statusRaw) ?? .complete
        let parts = try decode([ContentPart].self, from: stored.partsData)
        return MessageRecord(
            id: MessageID(rawValue: stored.id),
            conversationID: ConversationID(rawValue: stored.conversationID),
            ownerID: UserID(rawValue: stored.ownerID),
            traceID: stored.traceIDRaw.map { TraceID(rawValue: $0) },
            role: role,
            parts: parts,
            source: source,
            sensitivity: privacy,
            status: status,
            createdAt: stored.createdAt,
            updatedAt: stored.updatedAt,
            sequenceNumber: stored.sequenceNumber
        )
    }

    static func toStored(_ domain: MessageRecord) throws -> StoredMessage {
        let partsData = try encode(domain.parts)
        return StoredMessage(
            id: domain.id.rawValue,
            conversationID: domain.conversationID.rawValue,
            ownerID: domain.ownerID.rawValue,
            traceIDRaw: domain.traceID?.rawValue,
            roleRaw: domain.role.rawValue,
            partsData: partsData,
            sourceRaw: domain.source.rawValue,
            sensitivityRaw: domain.sensitivity.rawValue,
            statusRaw: domain.status.rawValue,
            sequenceNumber: domain.sequenceNumber,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt
        )
    }
}

// MARK: - Memory item mappings

enum MemoryItemMapper {
    static func toDomain(_ stored: StoredMemoryItem) throws -> MemoryItem {
        let state = VerificationState(rawValue: stored.verificationStateRaw) ?? .proposed
        let tags = try decode([String].self, from: stored.tagsData)
        let sourceRefs = try decode([MemorySourceRef].self, from: stored.sourceRefsData)
        return MemoryItem(
            id: MemoryItemID(rawValue: stored.id),
            ownerID: UserID(rawValue: stored.ownerID),
            content: stored.content,
            tags: tags,
            verificationState: state,
            sourceRefs: sourceRefs,
            revision: stored.revision,
            expiresAt: stored.expiresAt,
            createdAt: stored.createdAt,
            updatedAt: stored.updatedAt,
            isDeleted: stored.isDeleted
        )
    }

    static func toStored(_ domain: MemoryItem) throws -> StoredMemoryItem {
        StoredMemoryItem(
            id: domain.id.rawValue,
            ownerID: domain.ownerID.rawValue,
            content: domain.content,
            tagsData: try encode(domain.tags),
            verificationStateRaw: domain.verificationState.rawValue,
            sourceRefsData: try encode(domain.sourceRefs),
            revision: domain.revision,
            expiresAt: domain.expiresAt,
            isDeleted: domain.isDeleted,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt
        )
    }
}

// MARK: - Provider configuration mappings

enum ProviderConfigMapper {
    static func toDomain(_ stored: StoredProviderConfiguration) -> ProviderConfiguration {
        let kind = ProviderKind(rawValue: stored.providerKindRaw) ?? .custom
        let baseURL = stored.baseURLString.flatMap { URL(string: $0) }
        let catalogURL = stored.catalogURLString.flatMap { URL(string: $0) }
        var budgetLimit: Decimal?
        if let data = stored.budgetLimitData,
           let str = String(data: data, encoding: .utf8),
           let d = Decimal(string: str) {
            budgetLimit = d
        }
        return ProviderConfiguration(
            id: ProviderConfigID(rawValue: stored.id),
            ownerID: UserID(rawValue: stored.ownerID),
            providerKind: kind,
            displayName: stored.displayName,
            baseURL: baseURL,
            catalogURL: catalogURL,
            keychainKey: stored.keychainKey,
            isEnabled: stored.isEnabled,
            budgetLimitUSD: budgetLimit,
            modelOverride: stored.modelOverride,
            catalogTTLSeconds: stored.catalogTTLSeconds,
            createdAt: stored.createdAt,
            updatedAt: stored.updatedAt
        )
    }

    static func toStored(_ domain: ProviderConfiguration) -> StoredProviderConfiguration {
        var budgetData: Data?
        if let limit = domain.budgetLimitUSD {
            budgetData = "\(limit)".data(using: .utf8)
        }
        return StoredProviderConfiguration(
            id: domain.id.rawValue,
            ownerID: domain.ownerID.rawValue,
            providerKindRaw: domain.providerKind.rawValue,
            displayName: domain.displayName,
            baseURLString: domain.baseURL?.absoluteString,
            catalogURLString: domain.catalogURL?.absoluteString,
            keychainKey: domain.keychainKey,
            isEnabled: domain.isEnabled,
            budgetLimitData: budgetData,
            modelOverride: domain.modelOverride,
            catalogTTLSeconds: domain.catalogTTLSeconds,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt
        )
    }
}
