// Domain/Attachment.swift
// Attachment metadata domain type (not binary data inline).
// Per V3 §Stable business entities and §B09.

import Foundation

/// V3 §Stable business entities — Attachment.
/// Stores metadata only; binary data is managed by AttachmentLifecycle.
struct Attachment: Identifiable, Codable, Sendable, Hashable {
    let id: AttachmentID
    let ownerID: UserID
    let conversationID: ConversationID?
    let messageID: MessageID?
    var filename: String
    var mimeType: String    // sniffed by AttachmentValidator, not trusted from extension
    var byteSize: Int
    var storageURL: URL     // app-scoped local file URL (never an arbitrary URL)
    var thumbnailURL: URL?  // optional local thumbnail, normalized
    var extractedTextRef: UUID?  // reference to extracted text record, if any
    var privacyClass: PrivacyClass
    var uploadState: AttachmentUploadState
    var isDeleted: Bool
    let createdAt: Date
    var updatedAt: Date

    init(
        id: AttachmentID = AttachmentID(),
        ownerID: UserID,
        conversationID: ConversationID? = nil,
        messageID: MessageID? = nil,
        filename: String,
        mimeType: String,
        byteSize: Int,
        storageURL: URL,
        thumbnailURL: URL? = nil,
        extractedTextRef: UUID? = nil,
        privacyClass: PrivacyClass = .personal,
        uploadState: AttachmentUploadState = .localOnly,
        isDeleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.ownerID = ownerID
        self.conversationID = conversationID
        self.messageID = messageID
        self.filename = filename
        self.mimeType = mimeType
        self.byteSize = byteSize
        self.storageURL = storageURL
        self.thumbnailURL = thumbnailURL
        self.extractedTextRef = extractedTextRef
        self.privacyClass = privacyClass
        self.uploadState = uploadState
        self.isDeleted = isDeleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Upload state

enum AttachmentUploadState: String, Codable, Sendable, Hashable, CaseIterable {
    case localOnly       // V1 default — never sent to provider without egress decision
    case pendingUpload   // queued for provider
    case uploaded        // confirmed at provider
    case failed          // upload failed
}

// MARK: - Supported MIME types (B09 allowlist)

extension Attachment {
    static let allowedMIMETypes: Set<String> = [
        "image/jpeg",
        "image/png",
        "image/heic",
        "image/heif",
        "image/webp",
        "application/pdf",
        "text/plain",
        "text/markdown",
        "text/csv",
    ]

    static let maximumByteSizeBytes = 20 * 1024 * 1024  // 20 MB

    var isAllowed: Bool {
        Attachment.allowedMIMETypes.contains(mimeType)
    }
}
