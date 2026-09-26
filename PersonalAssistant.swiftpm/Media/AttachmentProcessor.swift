// Media/AttachmentProcessor.swift
// Ingestion pipeline: validate -> store in sandbox -> OCR/extract text.
// Per V3 §Media/AttachmentProcessor.swift blueprint.

import Foundation

actor AttachmentProcessor {
    func process(data: Data, filename: String, mimeType: String) async throws -> (url: URL, extractedText: String) {
        try AttachmentValidator.validate(data: data, expectedMime: mimeType)
        let savedURL = try AttachmentLifecycleManager.saveAttachment(data: data, filename: filename)
        var text = ""
        if mimeType == "application/pdf" {
            text = DocumentTextExtractor.extractText(from: data)
        }
        return (savedURL, text)
    }
}
