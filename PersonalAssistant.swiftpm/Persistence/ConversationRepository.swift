// Persistence/ConversationRepository.swift
// Persists conversations and messages with owner scoping.
// Per V3 §Persistence/ConversationRepository.swift blueprint.

import Foundation
import SwiftData

actor ConversationRepository {

    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    @MainActor
    private var context: ModelContext { modelContainer.mainContext }

    // MARK: - Create conversation

    func createConversation(owner: UserID, assistantID: AssistantID) async throws -> Conversation {
        let conv = Conversation(
            ownerID: owner,
            assistantID: assistantID,
            title: "New Conversation"
        )
        try await MainActor.run {
            context.insert(ConversationMapper.toStored(conv))
            try context.save()
        }
        return conv
    }

    // MARK: - List conversations

    func conversations(owner: UserID) async throws -> [Conversation] {
        let ownerUUID = owner.rawValue
        let stored = try await MainActor.run {
            var descriptor = FetchDescriptor<StoredConversation>(
                predicate: #Predicate {
                    $0.ownerID == ownerUUID &&
                    $0.stateRaw != "deleted"
                },
                sortBy: [SortDescriptor(\.lastMessageAt, order: .reverse)]
            )
            descriptor.fetchLimit = 200
            return try context.fetch(descriptor)
        }
        return stored.map { ConversationMapper.toDomain($0) }
    }

    // MARK: - Append user message (before sending to provider)

    func appendPendingUserMessage(
        owner: UserID,
        conversationID: ConversationID,
        parts: [ContentPart],
        session: SessionToken
    ) async throws -> MessageRecord {
        // Fetch next sequence number
        let ownerUUID = owner.rawValue
        let convUUID = conversationID.rawValue
        let count = try await MainActor.run {
            let descriptor = FetchDescriptor<StoredMessage>(
                predicate: #Predicate { $0.conversationID == convUUID && $0.ownerID == ownerUUID }
            )
            return try context.fetchCount(descriptor)
        }

        let msg = MessageRecord(
            conversationID: conversationID,
            ownerID: owner,
            role: .user,
            parts: parts,
            source: .userTyped,
            sensitivity: .personal,
            status: .pending,
            sequenceNumber: count
        )
        try await MainActor.run {
            context.insert(try MessageMapper.toStored(msg))
            // Update conversation last-message
            let convDesc = FetchDescriptor<StoredConversation>(
                predicate: #Predicate { $0.id == convUUID && $0.ownerID == ownerUUID }
            )
            if let conv = try context.fetch(convDesc).first {
                conv.messageCount += 1
                conv.lastMessageAt = msg.createdAt
            }
            try context.save()
        }
        return msg
    }

    // MARK: - Append assistant streaming checkpoint

    func appendAssistantCheckpoint(
        traceID: TraceID,
        conversationID: ConversationID,
        ownerID: UserID,
        deltaText: String,
        session: SessionToken
    ) async throws -> MessageID {
        let convUUID = conversationID.rawValue
        let ownerUUID = ownerID.rawValue
        let traceUUID = traceID.rawValue

        return try await MainActor.run {
            // Find existing streaming message for this trace
            let descriptor = FetchDescriptor<StoredMessage>(
                predicate: #Predicate {
                    $0.traceIDRaw == traceUUID &&
                    $0.ownerID == ownerUUID &&
                    $0.statusRaw == "streaming"
                }
            )
            if let existing = try context.fetch(descriptor).first {
                // Append delta to existing text part
                if var parts = try? JSONDecoder().decode([ContentPart].self, from: existing.partsData) {
                    if case .text(let t) = parts.last {
                        parts[parts.count - 1] = .text(t + deltaText)
                    } else {
                        parts.append(.text(deltaText))
                    }
                    existing.partsData = (try? JSONEncoder().encode(parts)) ?? existing.partsData
                    existing.updatedAt = Date()
                }
                try context.save()
                return MessageID(rawValue: existing.id)
            } else {
                // Create new streaming message
                let count = try context.fetchCount(
                    FetchDescriptor<StoredMessage>(
                        predicate: #Predicate { $0.conversationID == convUUID && $0.ownerID == ownerUUID }
                    )
                )
                let parts: [ContentPart] = deltaText.isEmpty ? [] : [.text(deltaText)]
                let partsData = (try? JSONEncoder().encode(parts)) ?? Data()
                let msg = StoredMessage(
                    id: UUID(),
                    conversationID: convUUID,
                    ownerID: ownerUUID,
                    traceIDRaw: traceUUID,
                    roleRaw: "assistant",
                    partsData: partsData,
                    sourceRaw: "assistantGenerated",
                    sensitivityRaw: PrivacyClass.personal.rawValue,
                    statusRaw: "streaming",
                    sequenceNumber: count,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                context.insert(msg)
                try context.save()
                return MessageID(rawValue: msg.id)
            }
        }
    }

    // MARK: - Finish assistant message

    func finishAssistantMessage(
        traceID: TraceID,
        ownerID: UserID,
        status: MessageStatus,
        session: SessionToken
    ) async throws {
        let traceUUID = traceID.rawValue
        let ownerUUID = ownerID.rawValue
        try await MainActor.run {
            let descriptor = FetchDescriptor<StoredMessage>(
                predicate: #Predicate { $0.traceIDRaw == traceUUID && $0.ownerID == ownerUUID }
            )
            if let msg = try context.fetch(descriptor).first {
                msg.statusRaw = status.rawValue
                msg.updatedAt = Date()
            }
            try context.save()
        }
    }

    // MARK: - Page messages (stable cursor pagination)

    func pageMessages(
        owner: UserID,
        conversationID: ConversationID,
        cursor: Int,
        limit: Int = 50
    ) async throws -> [MessageRecord] {
        let ownerUUID = owner.rawValue
        let convUUID = conversationID.rawValue
        let stored = try await MainActor.run {
            var descriptor = FetchDescriptor<StoredMessage>(
                predicate: #Predicate { $0.conversationID == convUUID && $0.ownerID == ownerUUID },
                sortBy: [SortDescriptor(\.sequenceNumber, order: .forward),
                         SortDescriptor(\.id, order: .forward)]
            )
            descriptor.fetchOffset = cursor
            descriptor.fetchLimit = limit
            return try context.fetch(descriptor)
        }
        return try stored.map { try MessageMapper.toDomain($0) }
    }

    // MARK: - Delete conversation (tombstone)

    func deleteConversation(
        id: ConversationID,
        owner: UserID,
        session: SessionToken
    ) async throws {
        let convUUID = id.rawValue
        let ownerUUID = owner.rawValue
        try await MainActor.run {
            let descriptor = FetchDescriptor<StoredConversation>(
                predicate: #Predicate { $0.id == convUUID && $0.ownerID == ownerUUID }
            )
            if let conv = try context.fetch(descriptor).first {
                conv.stateRaw = ConversationState.deleted.rawValue
                conv.lastMessagePreview = nil
                conv.updatedAt = Date()
            }
            try context.save()
        }
    }
}
