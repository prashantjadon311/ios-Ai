// Domain/Conversation.swift
// Conversation title, assistant association and lifecycle.

import Foundation

/// V3 §Stable business entities — Conversation.
struct Conversation: Identifiable, Codable, Sendable, Hashable {
    let id: ConversationID
    let ownerID: UserID
    let assistantID: AssistantID
    var title: String
    var state: ConversationState
    /// Updated when the last message is appended.
    var lastMessageAt: Date?
    var lastMessagePreview: String?
    let createdAt: Date
    var updatedAt: Date
    var messageCount: Int

    init(
        id: ConversationID = ConversationID(),
        ownerID: UserID,
        assistantID: AssistantID,
        title: String = "New Conversation",
        state: ConversationState = .active,
        lastMessageAt: Date? = nil,
        lastMessagePreview: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        messageCount: Int = 0
    ) {
        self.id = id
        self.ownerID = ownerID
        self.assistantID = assistantID
        self.title = title
        self.state = state
        self.lastMessageAt = lastMessageAt
        self.lastMessagePreview = lastMessagePreview
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.messageCount = messageCount
    }
}

// MARK: - State machine

/// Archive/delete state machine per V3 spec.
enum ConversationState: String, Codable, Sendable, Hashable, CaseIterable {
    case active
    case archived
    case deleted  // tombstone — retained for audit, not user-visible

    /// Valid transitions (pure function, no side effects).
    func canTransition(to next: ConversationState) -> Bool {
        switch (self, next) {
        case (.active, .archived),
             (.active, .deleted),
             (.archived, .active),
             (.archived, .deleted):
            return true
        default:
            return false
        }
    }
}

// MARK: - Immutable updates

extension Conversation {
    func archiving(at date: Date = Date()) throws -> Conversation {
        guard state.canTransition(to: .archived) else {
            throw ConversationError.invalidTransition(from: state, to: .archived)
        }
        return Conversation(
            id: id, ownerID: ownerID, assistantID: assistantID,
            title: title, state: .archived,
            lastMessageAt: lastMessageAt, lastMessagePreview: lastMessagePreview,
            createdAt: createdAt, updatedAt: date, messageCount: messageCount
        )
    }

    func deleting(at date: Date = Date()) throws -> Conversation {
        guard state.canTransition(to: .deleted) else {
            throw ConversationError.invalidTransition(from: state, to: .deleted)
        }
        return Conversation(
            id: id, ownerID: ownerID, assistantID: assistantID,
            title: title, state: .deleted,
            lastMessageAt: lastMessageAt, lastMessagePreview: nil,
            createdAt: createdAt, updatedAt: date, messageCount: messageCount
        )
    }

    func withLastMessage(preview: String?, at date: Date) -> Conversation {
        Conversation(
            id: id, ownerID: ownerID, assistantID: assistantID,
            title: title, state: state,
            lastMessageAt: date,
            lastMessagePreview: preview.map { String($0.prefix(100)) },
            createdAt: createdAt, updatedAt: date, messageCount: messageCount + 1
        )
    }
}

// MARK: - Errors

enum ConversationError: Error, Sendable {
    case invalidTransition(from: ConversationState, to: ConversationState)
    case ownerMismatch
}
