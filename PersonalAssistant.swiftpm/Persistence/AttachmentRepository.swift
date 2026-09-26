// Persistence/AttachmentRepository.swift
// Actor managing SwiftData StoredAttachment models with owner isolation.
// Per V3 §Persistence/AttachmentRepository.swift blueprint.

import Foundation
import SwiftData

actor AttachmentRepository: ModelActor {
    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        let context = ModelContext(modelContainer)
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: context)
    }

    func saveAttachment(_ attachment: Attachment, extractedText: String? = nil) throws {
        let stored = StoredAttachment(
            id: attachment.id.rawValue,
            ownerID: attachment.ownerID.rawValue,
            filename: attachment.filename,
            mimeType: attachment.mimeType,
            byteSize: attachment.byteSize,
            storageURLString: attachment.storageURL.absoluteString,
            extractedText: extractedText,
            createdAt: attachment.createdAt
        )
        modelContext.insert(stored)
        try modelContext.save()
    }
}
