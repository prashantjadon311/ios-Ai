// Domain/MemoryItem.swift
// Explicit user-approved memory items with provenance and lifecycle.

import Foundation

/// V3 §Stable business entities — MemoryItem.
/// Model-inferred memory does NOT become verified automatically (A13/B08 invariant).
struct MemoryItem: Identifiable, Codable, Sendable, Hashable {
    let id: MemoryItemID
    let ownerID: UserID
    var content: String
    var tags: [String]
    var verificationState: VerificationState
    var sourceRefs: [MemorySourceRef]
    /// Monotonically increasing on each revision (compare-and-set guard).
    var revision: Int
    var expiresAt: Date?
    let createdAt: Date
    var updatedAt: Date
    var isDeleted: Bool

    init(
        id: MemoryItemID = MemoryItemID(),
        ownerID: UserID,
        content: String,
        tags: [String] = [],
        verificationState: VerificationState = .proposed,
        sourceRefs: [MemorySourceRef] = [],
        revision: Int = 1,
        expiresAt: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isDeleted: Bool = false
    ) {
        self.id = id
        self.ownerID = ownerID
        self.content = content
        self.tags = tags
        self.verificationState = verificationState
        self.sourceRefs = sourceRefs
        self.revision = revision
        self.expiresAt = expiresAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isDeleted = isDeleted
    }

    /// Is this memory currently active (verified, not expired, not deleted)?
    func isActive(at now: Date = Date()) -> Bool {
        guard !isDeleted, verificationState == .verified else { return false }
        if let exp = expiresAt { return now < exp }
        return true
    }
}

// MARK: - Verification state

/// Model-proposed memories require explicit user confirmation before use.
enum VerificationState: String, Codable, Sendable, Hashable, CaseIterable {
    case proposed    // AI suggested, awaiting user review
    case verified    // user explicitly approved
    case rejected    // user dismissed
    case expired     // time-based expiry
}

// MARK: - Source provenance

struct MemorySourceRef: Codable, Sendable, Hashable {
    let conversationID: ConversationID?
    let messageID: MessageID?
    let summarized: Bool
    let capturedAt: Date
}

// MARK: - Immutable updates (compare-and-set revision guard)

extension MemoryItem {
    enum UpdateError: Error, Sendable {
        case revisionConflict(expected: Int, actual: Int)
        case alreadyDeleted
    }

    func verifying(at date: Date = Date(), expectedRevision: Int) throws -> MemoryItem {
        guard revision == expectedRevision else {
            throw UpdateError.revisionConflict(expected: expectedRevision, actual: revision)
        }
        return MemoryItem(
            id: id, ownerID: ownerID, content: content,
            tags: tags, verificationState: .verified, sourceRefs: sourceRefs,
            revision: revision + 1, expiresAt: expiresAt,
            createdAt: createdAt, updatedAt: date
        )
    }

    func deleting(at date: Date = Date()) throws -> MemoryItem {
        guard !isDeleted else { throw UpdateError.alreadyDeleted }
        var copy = self
        copy.isDeleted = true
        copy.updatedAt = date
        copy.revision += 1
        return copy
    }
}
