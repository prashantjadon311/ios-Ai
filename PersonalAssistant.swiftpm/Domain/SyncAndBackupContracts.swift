// Domain/SyncAndBackupContracts.swift
// Domain contracts, status models, and protocols for optional Firestore sync (P09)
// and client-side encrypted Google Drive backup (P10).
// Fail-closed privacy, strict owner UID isolation, zero credential fabrication.

import Foundation

enum CloudSyncStatus: Equatable, Sendable, Codable {
    case disabled
    case blockedMissingCredentials(reason: String)
    case idle
    case syncing(progress: Double)
    case synced(lastSync: Date)
    case conflictDetected(entityID: String, localRevision: Int, remoteRevision: Int)
    case error(String)
}

enum SyncEntityType: String, Codable, Sendable {
    case task
    case project
    case reminder
    case conversation
    case memory
}

struct SyncOutboxRecord: Identifiable, Equatable, Sendable, Codable {
    let id: UUID
    let ownerID: String
    let entityType: SyncEntityType
    let entityID: String
    let revision: Int
    let payloadJSON: String
    let isDeleted: Bool
    let createdAt: Date
    let deletedAt: Date?

    var operationKey: String {
        "\(ownerID):\(entityType.rawValue):\(entityID):\(revision)"
    }

    init(
        id: UUID = UUID(),
        ownerID: String,
        entityType: SyncEntityType,
        entityID: String,
        revision: Int,
        payloadJSON: String,
        isDeleted: Bool = false,
        createdAt: Date = Date(),
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.ownerID = ownerID
        self.entityType = entityType
        self.entityID = entityID
        self.revision = revision
        self.payloadJSON = payloadJSON
        self.isDeleted = isDeleted
        self.createdAt = createdAt
        self.deletedAt = deletedAt
    }
}

enum ConflictResolutionStrategy: String, Sendable, Codable {
    case clientWins
    case serverWins
    case manual
}

struct FirebaseProjectConfiguration: Equatable, Sendable, Codable {
    let projectID: String
    let apiKey: String
    let bundleID: String

    init(projectID: String, apiKey: String, bundleID: String) {
        self.projectID = projectID
        self.apiKey = apiKey
        self.bundleID = bundleID
    }
}

struct GoogleDriveOAuthConfiguration: Equatable, Sendable, Codable {
    let clientID: String
    let scopes: [String]
    let accessToken: String?

    init(clientID: String, scopes: [String], accessToken: String? = nil) {
        self.clientID = clientID
        self.scopes = scopes
        self.accessToken = accessToken
    }
}

struct EncryptedBackupManifest: Equatable, Sendable, Codable {
    let manifestVersion: Int
    let schemaVersion: Int
    let ownerID: String
    let createdAt: Date
    let algorithm: String
    let saltBase64: String
    let nonceBase64: String
    let tagBase64: String
    let ciphertextBase64: String
    let itemCounts: [String: Int]
    let checksumSHA256: String

    init(
        manifestVersion: Int = 1,
        schemaVersion: Int = 1,
        ownerID: String,
        createdAt: Date = Date(),
        algorithm: String = "AES-256-GCM",
        saltBase64: String,
        nonceBase64: String,
        tagBase64: String,
        ciphertextBase64: String,
        itemCounts: [String: Int] = [:],
        checksumSHA256: String
    ) {
        self.manifestVersion = manifestVersion
        self.schemaVersion = schemaVersion
        self.ownerID = ownerID
        self.createdAt = createdAt
        self.algorithm = algorithm
        self.saltBase64 = saltBase64
        self.nonceBase64 = nonceBase64
        self.tagBase64 = tagBase64
        self.ciphertextBase64 = ciphertextBase64
        self.itemCounts = itemCounts
        self.checksumSHA256 = checksumSHA256
    }

    func verifyOwner(expectedOwnerID: String) -> Bool {
        ownerID == expectedOwnerID
    }

    func verifyTamperProofTag(expectedTag: String) -> Bool {
        tagBase64 == expectedTag
    }
}

enum BackupStatus: Equatable, Sendable {
    case idle
    case blockedMissingCredentials(reason: String)
    case inProgress(phase: String)
    case completed(lastBackup: Date, manifest: EncryptedBackupManifest)
    case failed(reason: String)
}

protocol CloudSyncEngineProtocol: Sendable {
    var status: CloudSyncStatus { get }
    func queueOutbox(record: SyncOutboxRecord) throws
    func pendingOutbox(ownerID: String) -> [SyncOutboxRecord]
    func drainOutbox(ownerID: String) async throws -> Int
    func cancelSync(ownerID: String)
}

protocol EncryptedBackupEngineProtocol: Sendable {
    var status: BackupStatus { get }
    func createBackup(ownerID: String, recoveryKey: String, items: [String: Any]) async throws -> EncryptedBackupManifest
    func stageRestore(manifest: EncryptedBackupManifest, ownerID: String, recoveryKey: String) async throws -> [String: Any]
}
