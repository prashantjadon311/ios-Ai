// Persistence/StoreModels.swift
// SOLE owner of all SwiftData @Model class declarations.
// Per V3 §Persistence placement — only this file defines @Model classes.

import Foundation
import SwiftData

// MARK: - Stored User Profile

@Model
final class StoredUserProfile {
    @Attribute(.unique) var id: UUID
    var displayName: String
    var accountStateRaw: String
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID, displayName: String, accountStateRaw: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.displayName = displayName
        self.accountStateRaw = accountStateRaw
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Stored Assistant Profile

@Model
final class StoredAssistantProfile {
    @Attribute(.unique) var id: UUID
    var ownerID: UUID
    var displayName: String
    var avatarRoleRaw: String
    var voiceSettingsData: Data     // Codable VoiceSettings → JSON
    var stylePreferenceRaw: String
    var providerOverrideIDRaw: UUID?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID, ownerID: UUID, displayName: String, avatarRoleRaw: String,
        voiceSettingsData: Data, stylePreferenceRaw: String, providerOverrideIDRaw: UUID?,
        createdAt: Date, updatedAt: Date
    ) {
        self.id = id
        self.ownerID = ownerID
        self.displayName = displayName
        self.avatarRoleRaw = avatarRoleRaw
        self.voiceSettingsData = voiceSettingsData
        self.stylePreferenceRaw = stylePreferenceRaw
        self.providerOverrideIDRaw = providerOverrideIDRaw
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Stored Conversation

@Model
final class StoredConversation {
    @Attribute(.unique) var id: UUID
    var ownerID: UUID
    var assistantID: UUID
    var title: String
    var stateRaw: String
    var lastMessageAt: Date?
    var lastMessagePreview: String?
    var messageCount: Int
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID, ownerID: UUID, assistantID: UUID, title: String, stateRaw: String,
        lastMessageAt: Date?, lastMessagePreview: String?, messageCount: Int,
        createdAt: Date, updatedAt: Date
    ) {
        self.id = id
        self.ownerID = ownerID
        self.assistantID = assistantID
        self.title = title
        self.stateRaw = stateRaw
        self.lastMessageAt = lastMessageAt
        self.lastMessagePreview = lastMessagePreview
        self.messageCount = messageCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Stored Message

@Model
final class StoredMessage {
    @Attribute(.unique) var id: UUID
    var conversationID: UUID
    var ownerID: UUID
    var traceIDRaw: UUID?
    var roleRaw: String
    var partsData: Data           // Codable [ContentPart] → JSON
    var sourceRaw: String
    var sensitivityRaw: Int
    var statusRaw: String
    var sequenceNumber: Int
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID, conversationID: UUID, ownerID: UUID, traceIDRaw: UUID?,
        roleRaw: String, partsData: Data, sourceRaw: String, sensitivityRaw: Int,
        statusRaw: String, sequenceNumber: Int, createdAt: Date, updatedAt: Date
    ) {
        self.id = id
        self.conversationID = conversationID
        self.ownerID = ownerID
        self.traceIDRaw = traceIDRaw
        self.roleRaw = roleRaw
        self.partsData = partsData
        self.sourceRaw = sourceRaw
        self.sensitivityRaw = sensitivityRaw
        self.statusRaw = statusRaw
        self.sequenceNumber = sequenceNumber
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Stored Memory Item

@Model
final class StoredMemoryItem {
    @Attribute(.unique) var id: UUID
    var ownerID: UUID
    var content: String
    var tagsData: Data              // [String] → JSON
    var verificationStateRaw: String
    var sourceRefsData: Data        // [MemorySourceRef] → JSON
    var revision: Int
    var expiresAt: Date?
    var isDeleted: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID, ownerID: UUID, content: String, tagsData: Data,
        verificationStateRaw: String, sourceRefsData: Data, revision: Int,
        expiresAt: Date?, isDeleted: Bool, createdAt: Date, updatedAt: Date
    ) {
        self.id = id
        self.ownerID = ownerID
        self.content = content
        self.tagsData = tagsData
        self.verificationStateRaw = verificationStateRaw
        self.sourceRefsData = sourceRefsData
        self.revision = revision
        self.expiresAt = expiresAt
        self.isDeleted = isDeleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Stored Task Definition

@Model
final class StoredTaskDefinition {
    @Attribute(.unique) var id: UUID
    var ownerID: UUID
    var title: String
    var taskDescription: String
    var scheduleData: Data?          // TaskSchedule → JSON
    var recurrenceData: Data?        // TaskRecurrence → JSON
    var revision: Int
    var isArchived: Bool
    var notificationIdentifiersData: Data   // [String] → JSON
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID, ownerID: UUID, title: String, taskDescription: String,
        scheduleData: Data?, recurrenceData: Data?, revision: Int,
        isArchived: Bool, notificationIdentifiersData: Data,
        createdAt: Date, updatedAt: Date
    ) {
        self.id = id
        self.ownerID = ownerID
        self.title = title
        self.taskDescription = taskDescription
        self.scheduleData = scheduleData
        self.recurrenceData = recurrenceData
        self.revision = revision
        self.isArchived = isArchived
        self.notificationIdentifiersData = notificationIdentifiersData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Stored Task Run

@Model
final class StoredTaskRun {
    @Attribute(.unique) var id: UUID
    var ownerID: UUID
    var taskID: UUID
    var definitionRevision: Int
    var occurrenceKeyData: Data      // TaskOccurrenceKey → JSON
    var statusRaw: String
    var stepsData: Data              // [TaskStepRecord] → JSON
    var scheduledAt: Date
    var startedAt: Date?
    var completedAt: Date?
    var errorMessage: String?
    var notificationID: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID, ownerID: UUID, taskID: UUID, definitionRevision: Int,
        occurrenceKeyData: Data, statusRaw: String, stepsData: Data,
        scheduledAt: Date, startedAt: Date?, completedAt: Date?,
        errorMessage: String?, notificationID: String?, createdAt: Date, updatedAt: Date
    ) {
        self.id = id
        self.ownerID = ownerID
        self.taskID = taskID
        self.definitionRevision = definitionRevision
        self.occurrenceKeyData = occurrenceKeyData
        self.statusRaw = statusRaw
        self.stepsData = stepsData
        self.scheduledAt = scheduledAt
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.errorMessage = errorMessage
        self.notificationID = notificationID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Stored Provider Configuration

@Model
final class StoredProviderConfiguration {
    @Attribute(.unique) var id: UUID
    var ownerID: UUID
    var providerKindRaw: String
    var displayName: String
    var baseURLString: String?
    var catalogURLString: String?
    var keychainKey: String          // reference only, NOT the secret
    var isEnabled: Bool
    var budgetLimitData: Data?       // Decimal → JSON string
    var modelOverride: String?
    var catalogTTLSeconds: Int
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID, ownerID: UUID, providerKindRaw: String, displayName: String,
        baseURLString: String?, catalogURLString: String?, keychainKey: String,
        isEnabled: Bool, budgetLimitData: Data?, modelOverride: String?,
        catalogTTLSeconds: Int, createdAt: Date, updatedAt: Date
    ) {
        self.id = id
        self.ownerID = ownerID
        self.providerKindRaw = providerKindRaw
        self.displayName = displayName
        self.baseURLString = baseURLString
        self.catalogURLString = catalogURLString
        self.keychainKey = keychainKey
        self.isEnabled = isEnabled
        self.budgetLimitData = budgetLimitData
        self.modelOverride = modelOverride
        self.catalogTTLSeconds = catalogTTLSeconds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Stored Approval Request

@Model
final class StoredApprovalRequest {
    @Attribute(.unique) var id: UUID
    var invocationID: UUID
    var toolID: String
    var schemaVersion: Int
    var ownerID: UUID
    var traceIDRaw: UUID
    var payloadHash: Data
    var riskLevelRaw: String
    var humanReadableSummary: String
    var recipient: String
    var dataClassesData: Data        // [PrivacyClass] → JSON
    var expiresAt: Date
    var statusRaw: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID, invocationID: UUID, toolID: String, schemaVersion: Int,
        ownerID: UUID, traceIDRaw: UUID, payloadHash: Data, riskLevelRaw: String,
        humanReadableSummary: String, recipient: String, dataClassesData: Data,
        expiresAt: Date, statusRaw: String, createdAt: Date, updatedAt: Date
    ) {
        self.id = id
        self.invocationID = invocationID
        self.toolID = toolID
        self.schemaVersion = schemaVersion
        self.ownerID = ownerID
        self.traceIDRaw = traceIDRaw
        self.payloadHash = payloadHash
        self.riskLevelRaw = riskLevelRaw
        self.humanReadableSummary = humanReadableSummary
        self.recipient = recipient
        self.dataClassesData = dataClassesData
        self.expiresAt = expiresAt
        self.statusRaw = statusRaw
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Stored Audit Event

@Model
final class StoredAuditEvent {
    @Attribute(.unique) var id: UUID
    var ownerID: UUID
    var traceIDRaw: UUID?
    var categoryRaw: String
    var action: String
    var outcomeRaw: String
    var toolID: String?
    var operationKey: String?
    var externalReference: String?
    var redactedSummary: String?
    var createdAt: Date

    init(
        id: UUID, ownerID: UUID, traceIDRaw: UUID?, categoryRaw: String,
        action: String, outcomeRaw: String, toolID: String?, operationKey: String?,
        externalReference: String?, redactedSummary: String?, createdAt: Date
    ) {
        self.id = id
        self.ownerID = ownerID
        self.traceIDRaw = traceIDRaw
        self.categoryRaw = categoryRaw
        self.action = action
        self.outcomeRaw = outcomeRaw
        self.toolID = toolID
        self.operationKey = operationKey
        self.externalReference = externalReference
        self.redactedSummary = redactedSummary
        self.createdAt = createdAt
    }
}

// MARK: - Stored App Preference

@Model
final class StoredAppPreference {
    @Attribute(.unique) var ownerID: UUID
    var privacyModeRaw: String
    var consentsData: Data           // [ConsentRecord] → JSON
    var activeAssistantIDRaw: UUID?
    var appearanceModeRaw: String
    var localeIdentifier: String?
    var updatedAt: Date

    init(
        ownerID: UUID, privacyModeRaw: String, consentsData: Data,
        activeAssistantIDRaw: UUID?, appearanceModeRaw: String,
        localeIdentifier: String?, updatedAt: Date
    ) {
        self.ownerID = ownerID
        self.privacyModeRaw = privacyModeRaw
        self.consentsData = consentsData
        self.activeAssistantIDRaw = activeAssistantIDRaw
        self.appearanceModeRaw = appearanceModeRaw
        self.localeIdentifier = localeIdentifier
        self.updatedAt = updatedAt
    }
}

// MARK: - Stored Attachment

@Model
final class StoredAttachment {
    @Attribute(.unique) var id: UUID
    var ownerID: UUID
    var filename: String
    var mimeType: String
    var byteSize: Int
    var storageURLString: String
    var extractedText: String?
    var createdAt: Date

    init(
        id: UUID,
        ownerID: UUID,
        filename: String,
        mimeType: String,
        byteSize: Int,
        storageURLString: String = "",
        extractedText: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.ownerID = ownerID
        self.filename = filename
        self.mimeType = mimeType
        self.byteSize = byteSize
        self.storageURLString = storageURLString
        self.extractedText = extractedText
        self.createdAt = createdAt
    }
}

// MARK: - Stored Tool Receipt

@Model
final class StoredToolReceipt {
    @Attribute(.unique) var id: UUID
    var invocationID: UUID
    var operationKey: String
    var statusRaw: String
    var toolID: String
    var ownerID: UUID
    var traceIDRaw: UUID
    var externalReference: String?
    var redactedResult: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID,
        invocationID: UUID,
        operationKey: String,
        statusRaw: String,
        toolID: String,
        ownerID: UUID,
        traceIDRaw: UUID,
        externalReference: String? = nil,
        redactedResult: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.invocationID = invocationID
        self.operationKey = operationKey
        self.statusRaw = statusRaw
        self.toolID = toolID
        self.ownerID = ownerID
        self.traceIDRaw = traceIDRaw
        self.externalReference = externalReference
        self.redactedResult = redactedResult
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
