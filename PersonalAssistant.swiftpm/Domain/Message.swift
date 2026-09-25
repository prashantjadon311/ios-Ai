// Domain/Message.swift
// Chat message domain types: ContextMessage, ContentPart, MessageRecord.

import Foundation

// MARK: - Content parts

/// A typed content element within a message.
enum ContentPart: Codable, Sendable, Hashable {
    case text(String)
    case attachment(AttachmentID)
    case toolResult(invocationID: UUID, summary: String)
}

// MARK: - Message role

enum ContextRole: String, Codable, Sendable, Hashable, CaseIterable {
    case user
    case assistant
    case system      // trusted policy/safety instructions only
    case toolResult  // returned execution result, tagged untrusted
}

// MARK: - Context source (trust boundary)

enum ContextSource: String, Codable, Sendable, Hashable, CaseIterable {
    case userTyped          // highest trust among user-generated
    case userVoice          // same trust, different input method
    case assistantGenerated // model output
    case systemPolicy       // trusted app policy text
    case retrievedDocument  // untrusted, tagged as data
    case retrievedMemory    // verified user memory
    case toolOutput         // untrusted tool response
}

// MARK: - Context message (used to build context packets)

/// V3 §Context contract — ContextMessage.
/// Never reclassify untrusted source as higher priority.
struct ContextMessage: Codable, Sendable, Hashable {
    let role: ContextRole
    let parts: [ContentPart]
    let source: ContextSource
    let sensitivity: PrivacyClass
}

// MARK: - Context packet

/// Assembled context to send to an AI provider.
struct ContextPacket: Sendable {
    let messages: [ContextMessage]
    let estimatedInputTokens: Int
    let sourceIDs: [UUID]
    let selectedMemoryRevisions: [UUID]
}

// MARK: - Persisted message record

/// A persisted message in a conversation. Distinct from ContextMessage (which is transient).
struct MessageRecord: Identifiable, Codable, Sendable, Hashable {
    let id: MessageID
    let conversationID: ConversationID
    let ownerID: UserID
    let traceID: TraceID?
    let role: ContextRole
    let parts: [ContentPart]
    let source: ContextSource
    let sensitivity: PrivacyClass
    var status: MessageStatus
    let createdAt: Date
    var updatedAt: Date
    /// Sequence within the conversation for stable ordering.
    let sequenceNumber: Int

    init(
        id: MessageID = MessageID(),
        conversationID: ConversationID,
        ownerID: UserID,
        traceID: TraceID? = nil,
        role: ContextRole,
        parts: [ContentPart],
        source: ContextSource,
        sensitivity: PrivacyClass = .personal,
        status: MessageStatus = .complete,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        sequenceNumber: Int
    ) {
        self.id = id
        self.conversationID = conversationID
        self.ownerID = ownerID
        self.traceID = traceID
        self.role = role
        self.parts = parts
        self.source = source
        self.sensitivity = sensitivity
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.sequenceNumber = sequenceNumber
    }
}

// MARK: - Message status

/// Tracks the lifecycle state of an assistant response message.
enum MessageStatus: String, Codable, Sendable, Hashable, CaseIterable {
    case pending       // user message awaiting provider response
    case streaming     // assistant response in progress
    case complete      // successfully finished
    case interrupted   // user cancelled or stream died mid-response
    case failed        // provider error, message preserved with error note
    case awaitingApproval // tool proposal pending user decision
}
