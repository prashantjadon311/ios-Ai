// Media/AttachmentValidator.swift
// Sniffs magic bytes, enforces 20MB limit, and rejects dangerous binary formats.
// Per V3 §Media/AttachmentValidator.swift blueprint, T019, S012.

import Foundation

struct AttachmentValidator: Sendable {
    static let maxSizeBytes: Int = 20 * 1024 * 1024  // 20 MiB

    /// Validates file size and inspects leading magic bytes to identify true file type (S012).
    static func validate(data: Data, claimedMime: String) throws {
        guard data.count <= maxSizeBytes else {
            throw AppError.attachmentTooLarge(bytes: data.count, limit: maxSizeBytes)
        }
        guard data.count >= 4 else {
            throw AppError.attachmentTypeDenied(detectedMIME: "unknown/too-small")
        }

        // Sniff header magic bytes
        let b0 = data[0], b1 = data[1], b2 = data[2], b3 = data[3]

        // Zip / PK archive (PK..)
        if b0 == 0x50 && b1 == 0x4B {
            throw AppError.attachmentTypeDenied(detectedMIME: "application/zip")
        }
        // ELF executable
        if b0 == 0x7F && b1 == 0x45 && b2 == 0x4C && b3 == 0x46 {
            throw AppError.attachmentTypeDenied(detectedMIME: "application/x-executable")
        }
        // Mach-O executable
        if (b0 == 0xFE && b1 == 0xED && b2 == 0xFA && (b3 == 0xCE || b3 == 0xCF)) ||
           (b0 == 0xCF && b1 == 0xFA && b2 == 0xED && b3 == 0xFE) {
            throw AppError.attachmentTypeDenied(detectedMIME: "application/x-mach-binary")
        }

        // If claimed PDF (%PDF-), verify header matches '%PDF' (0x25, 0x50, 0x44, 0x46)
        if claimedMime == "application/pdf" {
            guard b0 == 0x25 && b1 == 0x50 && b2 == 0x44 && b3 == 0x46 else {
                throw AppError.attachmentTypeDenied(detectedMIME: "spoofed/not-pdf")
            }
        }

        // If claimed image/png, verify 89 50 4E 47
        if claimedMime == "image/png" {
            guard b0 == 0x89 && b1 == 0x50 && b2 == 0x4E && b3 == 0x47 else {
                throw AppError.attachmentTypeDenied(detectedMIME: "spoofed/not-png")
            }
        }

        // If claimed image/jpeg, verify FF D8 FF
        if claimedMime == "image/jpeg" {
            guard b0 == 0xFF && b1 == 0xD8 && b2 == 0xFF else {
                throw AppError.attachmentTypeDenied(detectedMIME: "spoofed/not-jpeg")
            }
        }
    }
}
