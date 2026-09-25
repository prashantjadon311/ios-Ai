// Domain/Identifiers.swift
// Strong-typed stable IDs and owner references.
// Single responsibility: one canonical set of ID wrappers; no duplication in other files.

import Foundation

// MARK: - Primary identity wrappers

struct UserID: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    let rawValue: UUID
    init(rawValue: UUID) { self.rawValue = rawValue }
    init() { self.rawValue = UUID() }
    var description: String { "UserID(\(rawValue))" }
}

struct AssistantID: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    let rawValue: UUID
    init(rawValue: UUID) { self.rawValue = rawValue }
    init() { self.rawValue = UUID() }
    var description: String { "AssistantID(\(rawValue))" }
}

struct ConversationID: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    let rawValue: UUID
    init(rawValue: UUID) { self.rawValue = rawValue }
    init() { self.rawValue = UUID() }
    var description: String { "ConversationID(\(rawValue))" }
}

struct MessageID: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    let rawValue: UUID
    init(rawValue: UUID) { self.rawValue = rawValue }
    init() { self.rawValue = UUID() }
    var description: String { "MessageID(\(rawValue))" }
}

struct TraceID: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    let rawValue: UUID
    init(rawValue: UUID) { self.rawValue = rawValue }
    init() { self.rawValue = UUID() }
    var description: String { "TraceID(\(rawValue))" }
}

struct TaskID: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    let rawValue: UUID
    init(rawValue: UUID) { self.rawValue = rawValue }
    init() { self.rawValue = UUID() }
    var description: String { "TaskID(\(rawValue))" }
}

struct TaskRunID: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    let rawValue: UUID
    init(rawValue: UUID) { self.rawValue = rawValue }
    init() { self.rawValue = UUID() }
    var description: String { "TaskRunID(\(rawValue))" }
}

struct MemoryItemID: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    let rawValue: UUID
    init(rawValue: UUID) { self.rawValue = rawValue }
    init() { self.rawValue = UUID() }
    var description: String { "MemoryItemID(\(rawValue))" }
}

struct AttachmentID: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    let rawValue: UUID
    init(rawValue: UUID) { self.rawValue = rawValue }
    init() { self.rawValue = UUID() }
    var description: String { "AttachmentID(\(rawValue))" }
}

struct ApprovalID: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    let rawValue: UUID
    init(rawValue: UUID) { self.rawValue = rawValue }
    init() { self.rawValue = UUID() }
    var description: String { "ApprovalID(\(rawValue))" }
}

struct AuditEventID: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    let rawValue: UUID
    init(rawValue: UUID) { self.rawValue = rawValue }
    init() { self.rawValue = UUID() }
    var description: String { "AuditEventID(\(rawValue))" }
}

struct ProviderConfigID: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    let rawValue: UUID
    init(rawValue: UUID) { self.rawValue = rawValue }
    init() { self.rawValue = UUID() }
    var description: String { "ProviderConfigID(\(rawValue))" }
}

// MARK: - Session

/// Encapsulates owner identity and a monotonically-increasing generation for stale-session detection.
struct SessionToken: Sendable, Equatable, Codable {
    let userID: UserID
    let generation: UUID

    init(userID: UserID, generation: UUID = UUID()) {
        self.userID = userID
        self.generation = generation
    }
}

// MARK: - Stable occurrence identity for task scheduling (B06)

/// Uniquely identifies one scheduled occurrence of a task run.
struct TaskOccurrenceKey: Hashable, Codable, Sendable {
    let taskID: TaskID
    let definitionRevision: Int
    let scheduledOccurrenceID: UUID
}

// MARK: - Voice session monotonic ID

struct VoiceSessionID: RawRepresentable, Hashable, Sendable {
    let rawValue: UUID
    init(rawValue: UUID) { self.rawValue = rawValue }
    init() { self.rawValue = UUID() }
}
