import Foundation
import XCTest
@testable import AppCorePortable

final class CloudSyncAndBackupContractsTests: XCTestCase {

    // MARK: - P09 Firestore Sync & Outbox Contracts

    func testSyncOutboxRecord_operationKey_isDeterministicAndScoped() {
        let record = SyncOutboxRecord(
            ownerID: "user_alice_123",
            entityType: .task,
            entityID: "task_abc",
            revision: 3,
            payloadJSON: "{\"title\":\"Buy groceries\"}",
            isDeleted: false,
            createdAt: Date(timeIntervalSince1970: 1700000000)
        )

        XCTAssertEqual(record.operationKey, "user_alice_123:task:task_abc:3")
        XCTAssertEqual(record.ownerID, "user_alice_123")
        XCTAssertEqual(record.entityType, .task)
        XCTAssertEqual(record.revision, 3)
        XCTAssertFalse(record.isDeleted)
    }

    func testFirestoreSyncAdapter_outboxQueue_deduplicatesByOperationKey() throws {
        let adapter = FirestoreSyncAdapter(activeOwnerID: "user_alice_123", configuration: nil)

        let record1 = SyncOutboxRecord(
            ownerID: "user_alice_123",
            entityType: .task,
            entityID: "task_1",
            revision: 1,
            payloadJSON: "{\"title\":\"Step 1\"}"
        )
        let record1Duplicate = SyncOutboxRecord(
            ownerID: "user_alice_123",
            entityType: .task,
            entityID: "task_1",
            revision: 1,
            payloadJSON: "{\"title\":\"Step 1 (duplicate)\"}"
        )
        let record2 = SyncOutboxRecord(
            ownerID: "user_alice_123",
            entityType: .task,
            entityID: "task_1",
            revision: 2,
            payloadJSON: "{\"title\":\"Step 1 edited\"}"
        )

        try adapter.queueOutbox(record: record1)
        try adapter.queueOutbox(record: record1Duplicate) // Should be deduplicated
        try adapter.queueOutbox(record: record2)          // New revision, queued

        let pending = adapter.pendingOutbox(ownerID: "user_alice_123")
        XCTAssertEqual(pending.count, 2)
        XCTAssertEqual(pending[0].revision, 1)
        XCTAssertEqual(pending[1].revision, 2)
    }

    func testFirestoreSyncAdapter_queueOutbox_wrongOwner_throwsWrongOwner() {
        let adapter = FirestoreSyncAdapter(activeOwnerID: "user_alice_123", configuration: nil)

        let wrongOwnerRecord = SyncOutboxRecord(
            ownerID: "user_bob_456",
            entityType: .project,
            entityID: "proj_999",
            revision: 1,
            payloadJSON: "{\"title\":\"Bob's Secret Project\"}"
        )

        XCTAssertThrowsError(try adapter.queueOutbox(record: wrongOwnerRecord)) { error in
            guard case AppError.wrongOwner = error else {
                XCTFail("Expected AppError.wrongOwner, got \(error)")
                return
            }
        }
    }

    func testFirestoreSyncAdapter_pendingOutbox_strictOwnerIsolation() throws {
        let adapterAlice = FirestoreSyncAdapter(activeOwnerID: "user_alice_123", configuration: nil)
        try adapterAlice.queueOutbox(record: SyncOutboxRecord(
            ownerID: "user_alice_123",
            entityType: .reminder,
            entityID: "rem_1",
            revision: 1,
            payloadJSON: "{\"title\":\"Call doctor\"}"
        ))

        // Querying for another owner must strictly return empty
        let bobPending = adapterAlice.pendingOutbox(ownerID: "user_bob_456")
        XCTAssertTrue(bobPending.isEmpty)

        let alicePending = adapterAlice.pendingOutbox(ownerID: "user_alice_123")
        XCTAssertEqual(alicePending.count, 1)
    }

    func testFirestoreSyncAdapter_versionedTombstone_preservesDeletionMetadata() throws {
        let deleteDate = Date(timeIntervalSince1970: 1700001000)
        let tombstone = SyncOutboxRecord(
            ownerID: "user_alice_123",
            entityType: .conversation,
            entityID: "conv_old",
            revision: 5,
            payloadJSON: "{}",
            isDeleted: true,
            createdAt: Date(timeIntervalSince1970: 1700000000),
            deletedAt: deleteDate
        )

        XCTAssertTrue(tombstone.isDeleted)
        XCTAssertEqual(tombstone.deletedAt, deleteDate)
        XCTAssertEqual(tombstone.operationKey, "user_alice_123:conversation:conv_old:5")
    }

    func testFirestoreSyncAdapter_missingCredentials_evaluatesToBlockedMissingCredentials() async {
        // Without Firebase project config, status must be honest BLOCKED_NO_CREDENTIALS / BLOCKED_ENV
        let adapter = FirestoreSyncAdapter(activeOwnerID: "user_alice_123", configuration: nil)

        let status = adapter.status
        guard case .blockedMissingCredentials(let reason) = status else {
            XCTFail("Expected .blockedMissingCredentials, got \(status)")
            return
        }
        XCTAssertTrue(reason.contains("Firebase") || reason.contains("credentials") || reason.contains("unconfigured"))

        // Attempting to drain outbox without credentials throws AppError.unauthorized
        do {
            _ = try await adapter.drainOutbox(ownerID: "user_alice_123")
            XCTFail("drainOutbox without credentials should throw")
        } catch {
            guard case AppError.unauthorized = error else {
                XCTFail("Expected AppError.unauthorized, got \(error)")
                return
            }
        }
    }

    func testFirestoreSyncAdapter_cancelSync_preservesPendingOutboxForReconnection() throws {
        let adapter = FirestoreSyncAdapter(activeOwnerID: "user_alice_123", configuration: nil)
        try adapter.queueOutbox(record: SyncOutboxRecord(
            ownerID: "user_alice_123",
            entityType: .task,
            entityID: "task_offline",
            revision: 1,
            payloadJSON: "{\"title\":\"Offline task\"}"
        ))

        adapter.cancelSync(ownerID: "user_alice_123")

        // Queued items must not be erased on sync cancellation
        let pending = adapter.pendingOutbox(ownerID: "user_alice_123")
        XCTAssertEqual(pending.count, 1)
        XCTAssertEqual(pending.first?.entityID, "task_offline")
    }

    // MARK: - P10 Encrypted Drive Backup Contracts

    func testEncryptedBackupManifest_tamperDetection() {
        let manifest = EncryptedBackupManifest(
            manifestVersion: 1,
            schemaVersion: 1,
            ownerID: "user_alice_123",
            createdAt: Date(timeIntervalSince1970: 1700000000),
            algorithm: "AES-256-GCM",
            saltBase64: "c2FsdF9leGFtcGxl",
            nonceBase64: "bm9uY2VfZXhhbXBsZQ==",
            tagBase64: "dGFnX2V4YW1wbGU=",
            ciphertextBase64: "Y2lwaGVydGV4dF9leGFtcGxl",
            itemCounts: ["tasks": 5, "reminders": 2],
            checksumSHA256: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        )

        XCTAssertTrue(manifest.verifyOwner(expectedOwnerID: "user_alice_123"))
        XCTAssertFalse(manifest.verifyOwner(expectedOwnerID: "user_bob_456"))

        XCTAssertTrue(manifest.verifyTamperProofTag(expectedTag: "dGFnX2V4YW1wbGU="))
        XCTAssertFalse(manifest.verifyTamperProofTag(expectedTag: "tampered_tag_value"))
    }

    func testDriveBackupAdapter_forbiddenSecretsInPayload_rejected() async {
        let adapter = DriveBackupAdapter(activeOwnerID: "user_alice_123", oauthConfiguration: nil)

        // Payloads containing API keys or BYOK secrets must be strictly rejected
        let taintedItems: [String: Any] = [
            "tasks": [["id": "1", "title": "Test"]],
            "apiKey": "sk-proj-secret-key-12345"
        ]

        do {
            _ = try await adapter.createBackup(
                ownerID: "user_alice_123",
                recoveryKey: "correct-horse-battery-staple",
                items: taintedItems
            )
            XCTFail("createBackup with secret key in payload should throw")
        } catch {
            guard case AppError.validationFailed(let field, _) = error else {
                XCTFail("Expected AppError.validationFailed, got \(error)")
                return
            }
            XCTAssertEqual(field, "backup_payload_secrets")
        }
    }

    func testDriveBackupAdapter_stageRestore_wrongOwner_throwsWrongOwner() async {
        let adapter = DriveBackupAdapter(activeOwnerID: "user_bob_456", oauthConfiguration: nil)

        let aliceManifest = EncryptedBackupManifest(
            manifestVersion: 1,
            schemaVersion: 1,
            ownerID: "user_alice_123",
            createdAt: Date(),
            algorithm: "AES-256-GCM",
            saltBase64: "c2FsdA==",
            nonceBase64: "bm9uY2U=",
            tagBase64: "dGFn",
            ciphertextBase64: "Y2lwaGVy",
            itemCounts: [:],
            checksumSHA256: "abc123"
        )

        do {
            _ = try await adapter.stageRestore(
                manifest: aliceManifest,
                ownerID: "user_bob_456",
                recoveryKey: "recovery_key"
            )
            XCTFail("stageRestore for mismatched owner should throw")
        } catch {
            guard case AppError.wrongOwner = error else {
                XCTFail("Expected AppError.wrongOwner, got \(error)")
                return
            }
        }
    }

    func testDriveBackupAdapter_stageRestore_tamperedTag_failsIntegrityCheck() async {
        let adapter = DriveBackupAdapter(activeOwnerID: "user_alice_123", oauthConfiguration: nil)

        let tamperedManifest = EncryptedBackupManifest(
            manifestVersion: 1,
            schemaVersion: 1,
            ownerID: "user_alice_123",
            createdAt: Date(),
            algorithm: "AES-256-GCM",
            saltBase64: "c2FsdA==",
            nonceBase64: "bm9uY2U=",
            tagBase64: "tampered_tag",
            ciphertextBase64: "Y2lwaGVy",
            itemCounts: [:],
            checksumSHA256: "abc123"
        )

        do {
            _ = try await adapter.stageRestore(
                manifest: tamperedManifest,
                ownerID: "user_alice_123",
                recoveryKey: "wrong_or_invalid_key"
            )
            XCTFail("stageRestore with tampered manifest should throw")
        } catch {
            guard case AppError.validationFailed = error else {
                XCTFail("Expected AppError.validationFailed, got \(error)")
                return
            }
        }
    }

    func testDriveBackupAdapter_missingOAuth_evaluatesToBlockedMissingCredentials() {
        let adapter = DriveBackupAdapter(activeOwnerID: "user_alice_123", oauthConfiguration: nil)

        let status = adapter.status
        guard case .blockedMissingCredentials(let reason) = status else {
            XCTFail("Expected .blockedMissingCredentials, got \(status)")
            return
        }
        XCTAssertTrue(reason.contains("Drive") || reason.contains("OAuth") || reason.contains("credentials"))
    }

    func testFirestoreSecurityRules_authoritativeRulesString_enforcesUidScoping() {
        let rules = FirestoreSecurityRules.rulesText
        XCTAssertTrue(rules.contains("service cloud.firestore"))
        XCTAssertTrue(rules.contains("match /users/{userId}"))
        XCTAssertTrue(rules.contains("request.auth != null"))
        XCTAssertTrue(rules.contains("request.auth.uid == userId"))
        XCTAssertTrue(rules.contains("allow read, write: if false;")) // deny-by-default for other collections
    }
}
