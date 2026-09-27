// Domain/ActionContracts.swift
// Unified domain contracts for touch, text, voice, and shortcut actions.
// Per V7 Phase P02/P03 and docs/04 Exact Engineering Contracts Section A & D.

import Foundation

enum ActionSource: String, Codable, Sendable, Hashable {
    case touch
    case text
    case voice
    case shortcut
}

enum ActionPayload: Codable, Sendable, Hashable {
    case task(title: String, description: String, schedule: TaskSchedule?, recurrence: TaskRecurrence?)
    case reminder(title: String, fireDate: Date, timezoneIdentifier: String, recurrence: TaskRecurrence?)
    case conversation(conversationID: ConversationID, message: String)
}

struct ValidatedAction: Sendable, Hashable {
    let ownerID: UserID
    let sessionGeneration: UUID
    let operationID: UUID
    let source: ActionSource
    let payload: ActionPayload

    init(
        ownerID: UserID,
        sessionGeneration: UUID,
        operationID: UUID = UUID(),
        source: ActionSource,
        payload: ActionPayload
    ) {
        self.ownerID = ownerID
        self.sessionGeneration = sessionGeneration
        self.operationID = operationID
        self.source = source
        self.payload = payload
    }
}

enum ActionStatus: String, Codable, Sendable, Hashable {
    case prepared
    case stored
    case failed
    case ambiguous
}

enum NotificationScheduleStatus: String, Codable, Sendable, Hashable {
    case none
    case scheduled
    case alertNotScheduled
    case failed
}

struct ActionReceipt: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    let ownerID: UserID
    let operationID: UUID
    let targetEntityID: String
    var dbStatus: ActionStatus
    var notificationStatus: NotificationScheduleStatus
    let wasApproved: Bool
    let redactedSummary: String
    let timestamp: Date

    init(
        id: UUID = UUID(),
        ownerID: UserID,
        operationID: UUID,
        targetEntityID: String,
        dbStatus: ActionStatus,
        notificationStatus: NotificationScheduleStatus = .none,
        wasApproved: Bool,
        redactedSummary: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.ownerID = ownerID
        self.operationID = operationID
        self.targetEntityID = targetEntityID
        self.dbStatus = dbStatus
        self.notificationStatus = notificationStatus
        self.wasApproved = wasApproved
        self.redactedSummary = redactedSummary
        self.timestamp = timestamp
    }
}

struct VoiceLaunchRequest: Sendable, Hashable {
    let avatarRole: AvatarRole
    let nonce: UUID
    let createdAt: Date
    let source: ActionSource

    init(
        avatarRole: AvatarRole,
        nonce: UUID = UUID(),
        createdAt: Date = Date(),
        source: ActionSource = .shortcut
    ) {
        self.avatarRole = avatarRole
        self.nonce = nonce
        self.createdAt = createdAt
        self.source = source
    }

    /// 15-second TTL check (Contract D, Prompt 05)
    func isExpired(currentTime: Date = Date()) -> Bool {
        currentTime.timeIntervalSince(createdAt) > 15.0
    }
}

protocol TaskRepositoryProtocol: Sendable {
    func taskDefinitions(ownerID: UserID) async throws -> [TaskDefinition]
    func upsertDefinition(_ definition: TaskDefinition, expectedRevision: Int) async throws
}
