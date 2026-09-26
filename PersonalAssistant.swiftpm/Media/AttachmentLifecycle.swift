// Media/AttachmentLifecycle.swift
// Sandbox file storage with 24-hour cleanup for orphaned temporary files.
// Per V3 §Media/AttachmentLifecycle.swift blueprint.

import Foundation

struct AttachmentLifecycleManager: Sendable {
    static func attachmentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let dir = paths[0].appendingPathComponent("Attachments", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static func saveAttachment(data: Data, filename: String) throws -> URL {
        let dir = attachmentsDirectory()
        let fileURL = dir.appendingPathComponent(UUID().uuidString + "_" + filename)
        try data.write(to: fileURL)
        return fileURL
    }

    static func purgeOldAttachments(olderThanSeconds: TimeInterval = 86400) {
        let dir = attachmentsDirectory()
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
}
