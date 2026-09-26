// Media/AttachmentLifecycle.swift
// Sandbox file storage distinguishing persistent user attachments from temporary processing scratch files.
// Per V3 §B09 and §Media/AttachmentLifecycle.swift blueprint.
// Active attachments reside in Application Support and are NEVER purged by age.

import Foundation

struct AttachmentLifecycleManager: Sendable {

    // MARK: - Persistent Attachments Directory (Application Support)

    /// Directory for durable user-owned attachments referenced by conversations or memories.
    /// Resides in Application Support and is never swept by periodic cache cleaners.
    static func persistentAttachmentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let dir = paths[0].appendingPathComponent("Attachments", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    /// Backwards compatible alias for persistentAttachmentsDirectory.
    static func attachmentsDirectory() -> URL {
        persistentAttachmentsDirectory()
    }

    // MARK: - Temporary Scratch Directory (Caches)

    /// Directory for transient picker streaming, OCR buffers, and unconfirmed uploads.
    static func temporaryDirectory() -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let dir = paths[0].appendingPathComponent("TempAttachments", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    // MARK: - Save Operations

    /// Saves a durable attachment into Application Support.
    static func saveAttachment(data: Data, filename: String) throws -> URL {
        let dir = persistentAttachmentsDirectory()
        let sanitized = filename.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "..", with: "")
        let fileURL = dir.appendingPathComponent(UUID().uuidString + "_" + sanitized)
        try data.write(to: fileURL, options: .atomic)
        return fileURL
    }

    /// Saves a transient scratch file into Caches.
    static func saveTemporaryFile(data: Data, filename: String) throws -> URL {
        let dir = temporaryDirectory()
        let sanitized = filename.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "..", with: "")
        let fileURL = dir.appendingPathComponent(UUID().uuidString + "_" + sanitized)
        try data.write(to: fileURL, options: .atomic)
        return fileURL
    }

    // MARK: - Purge Operations

    /// Sweeps only orphaned temporary scratch files older than the specified duration.
    /// Persistent attachments in Application Support are NEVER purged by this method.
    static func purgeOldTemporaryFiles(olderThanSeconds: TimeInterval = 86400) {
        let dir = temporaryDirectory()
        let cutoff = Date().addingTimeInterval(-olderThanSeconds)
        guard let files = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.creationDateKey]) else {
            return
        }
        for file in files {
            if let date = try? file.resourceValues(forKeys: [.creationDateKey]).creationDate, date < cutoff {
                try? FileManager.default.removeItem(at: file)
            }
        }
    }

    /// Backwards compatible alias: only purges temporary scratch directory.
    static func purgeOldAttachments(olderThanSeconds: TimeInterval = 86400) {
        purgeOldTemporaryFiles(olderThanSeconds: olderThanSeconds)
    }

    /// Explicit deletion of a persistent attachment when its associated message or memory is deleted.
    static func deleteAttachment(fileURL: URL) throws {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        try FileManager.default.removeItem(at: fileURL)
    }
}
