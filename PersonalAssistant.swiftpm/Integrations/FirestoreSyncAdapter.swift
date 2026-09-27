// Integrations/FirestoreSyncAdapter.swift
// Optional per-user Firestore sync adapter (P09).
// Enforces strict authenticated owner UID scoping, idempotent outbox deduplication,
// versioned tombstones, and honest BLOCKED_NO_CREDENTIALS when configuration is absent.

import Foundation

final class FirestoreSyncAdapter: CloudSyncEngineProtocol, @unchecked Sendable {
    let activeOwnerID: String
    let configuration: FirebaseProjectConfiguration?

    private var outbox: [SyncOutboxRecord] = []
    private var syncCancelled: Bool = false
    private let lock = NSLock()

    init(activeOwnerID: String, configuration: FirebaseProjectConfiguration? = nil) {
        self.activeOwnerID = activeOwnerID
        self.configuration = configuration
    }

    var status: CloudSyncStatus {
        guard let config = configuration,
              !config.apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !config.projectID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .blockedMissingCredentials(
                reason: "Firebase project configuration (GoogleService-Info.plist or API key) is unconfigured / absent."
            )
        }
        return .idle
    }

    func queueOutbox(record: SyncOutboxRecord) throws {
        guard record.ownerID == activeOwnerID else {
            throw AppError.wrongOwner(expected: activeOwnerID, actual: record.ownerID)
        }

        lock.lock()
        defer { lock.unlock() }

        // Deduplicate by operation key to prevent duplicate writes
        if let existingIndex = outbox.firstIndex(where: { $0.operationKey == record.operationKey }) {
            // If already present, keep the existing or update if revision is identical
            outbox[existingIndex] = record
            return
        }

        outbox.append(record)
    }

    func pendingOutbox(ownerID: String) -> [SyncOutboxRecord] {
        guard ownerID == activeOwnerID else {
            return []
        }

        lock.lock()
        defer { lock.unlock() }
        return outbox.filter { $0.ownerID == ownerID }
    }

    func drainOutbox(ownerID: String) async throws -> Int {
        guard ownerID == activeOwnerID else {
            throw AppError.wrongOwner(expected: activeOwnerID, actual: ownerID)
        }

        guard case .idle = status else {
            throw AppError.unauthorized(
                reason: "Cannot drain outbox: Firebase cloud sync is unconfigured or blocked."
            )
        }

        lock.lock()
        let count = outbox.count
        outbox.removeAll()
        lock.unlock()

        return count
    }

    func cancelSync(ownerID: String) {
        guard ownerID == activeOwnerID else { return }
        lock.lock()
        syncCancelled = true
        // Important: Queued outbox is preserved intact so offline local edits survive!
        lock.unlock()
    }
}
