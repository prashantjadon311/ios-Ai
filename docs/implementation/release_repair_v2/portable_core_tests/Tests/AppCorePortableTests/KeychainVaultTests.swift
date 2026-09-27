import Foundation
import XCTest
@testable import AppCorePortable

final class KeychainVaultTests: XCTestCase {

    // MARK: - 1. Basic Set & Read Round Trip

    func testSetSecretAndCopySecret_roundTrip() async throws {
        let backend = SimulatedKeychainBackend()
        let vault = KeychainVault(backend: backend)
        let owner = UserID()

        let initialExists = await vault.hasSecret(ownerID: owner, providerID: "groq")
        XCTAssertFalse(initialExists)

        try await vault.setSecret(ownerID: owner, providerID: "groq", value: "gsk_test_key_12345")

        let exists = await vault.hasSecret(ownerID: owner, providerID: "groq")
        XCTAssertTrue(exists)

        let retrieved = try await vault.copySecret(ownerID: owner, providerID: "groq")
        XCTAssertEqual(retrieved, "gsk_test_key_12345")
    }

    // MARK: - 2. Atomic Update: Failure Preserves Existing Secret

    func testSetSecret_atomicUpdate_preservesPreviousOnFailure() async throws {
        let backend = SimulatedKeychainBackend()
        let vault = KeychainVault(backend: backend)
        let owner = UserID()

        // Store initial valid secret
        try await vault.setSecret(ownerID: owner, providerID: "groq", value: "initial_secret_v1")
        let initialRetrieved = try await vault.copySecret(ownerID: owner, providerID: "groq")
        XCTAssertEqual(initialRetrieved, "initial_secret_v1")

        // Inject simulated update failure (e.g. disk or OS error)
        backend.injectedUpdateError = -50

        do {
            try await vault.setSecret(ownerID: owner, providerID: "groq", value: "replacement_secret_v2")
            XCTFail("Expected writeFailed error")
        } catch let error as KeychainVault.VaultError {
            XCTAssertEqual(error, .writeFailed(status: -50))
        }

        // Restore normal backend behavior and verify the old secret is still safe and intact
        backend.injectedUpdateError = nil
        let preserved = try await vault.copySecret(ownerID: owner, providerID: "groq")
        XCTAssertEqual(preserved, "initial_secret_v1", "Existing secret must NOT be deleted or destroyed if update fails")
    }

    // MARK: - 3. Safe Rotation

    func testRotateSecret_success_updatesSecret() async throws {
        let backend = SimulatedKeychainBackend()
        let vault = KeychainVault(backend: backend)
        let owner = UserID()

        try await vault.setSecret(ownerID: owner, providerID: "openrouter", value: "sk_or_old")
        try await vault.rotateSecret(ownerID: owner, providerID: "openrouter", newValue: "sk_or_new")

        let current = try await vault.copySecret(ownerID: owner, providerID: "openrouter")
        XCTAssertEqual(current, "sk_or_new")
    }

    func testRotateSecret_missingKey_throwsNotFound() async {
        let backend = SimulatedKeychainBackend()
        let vault = KeychainVault(backend: backend)
        let owner = UserID()

        do {
            try await vault.rotateSecret(ownerID: owner, providerID: "nonexistent", newValue: "new_value")
            XCTFail("Expected notFound error")
        } catch let error as KeychainVault.VaultError {
            guard case .notFound = error else {
                XCTFail("Expected notFound, got \(error)")
                return
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testRotateSecret_failure_preservesPreviousSecret() async throws {
        let backend = SimulatedKeychainBackend()
        let vault = KeychainVault(backend: backend)
        let owner = UserID()

        try await vault.setSecret(ownerID: owner, providerID: "groq", value: "working_key")

        backend.injectedUpdateError = -50

        do {
            try await vault.rotateSecret(ownerID: owner, providerID: "groq", newValue: "corrupted_attempt")
            XCTFail("Expected writeFailed error")
        } catch let error as KeychainVault.VaultError {
            XCTAssertEqual(error, .writeFailed(status: -50))
        }

        backend.injectedUpdateError = nil
        let preserved = try await vault.copySecret(ownerID: owner, providerID: "groq")
        XCTAssertEqual(preserved, "working_key", "Rotation failure must leave previous secret untouched")
    }

    // MARK: - 4. Per-Owner Isolation

    func testPerOwnerIsolation() async throws {
        let backend = SimulatedKeychainBackend()
        let vault = KeychainVault(backend: backend)
        let ownerA = UserID()
        let ownerB = UserID()

        try await vault.setSecret(ownerID: ownerA, providerID: "openai", value: "key_owner_a")
        try await vault.setSecret(ownerID: ownerB, providerID: "openai", value: "key_owner_b")

        let aVal = try await vault.copySecret(ownerID: ownerA, providerID: "openai")
        let bVal = try await vault.copySecret(ownerID: ownerB, providerID: "openai")
        XCTAssertEqual(aVal, "key_owner_a")
        XCTAssertEqual(bVal, "key_owner_b")

        // Deleting Owner A's key does not affect Owner B
        try await vault.removeSecret(ownerID: ownerA, providerID: "openai")
        let aExists = await vault.hasSecret(ownerID: ownerA, providerID: "openai")
        let bExists = await vault.hasSecret(ownerID: ownerB, providerID: "openai")
        XCTAssertFalse(aExists)
        XCTAssertTrue(bExists)
        let bValAfter = try await vault.copySecret(ownerID: ownerB, providerID: "openai")
        XCTAssertEqual(bValAfter, "key_owner_b")
    }

    // MARK: - 5. Dynamic Registry & Account Wipe (removeAll)

    func testDynamicRegistry_and_removeAllWipesCustomProviders() async throws {
        let backend = SimulatedKeychainBackend()
        let vault = KeychainVault(backend: backend)
        let ownerA = UserID()
        let ownerB = UserID()

        // Store standard provider + custom endpoints for Owner A
        try await vault.setSecret(ownerID: ownerA, providerID: "groq", value: "groq_key_a")
        try await vault.setSecret(ownerID: ownerA, providerID: "custom_endpoint_finance", value: "custom_key_1")
        try await vault.setSecret(ownerID: ownerA, providerID: "custom_endpoint_medical", value: "custom_key_2")

        // Store standard + custom for Owner B
        try await vault.setSecret(ownerID: ownerB, providerID: "groq", value: "groq_key_b")
        try await vault.setSecret(ownerID: ownerB, providerID: "custom_endpoint_finance", value: "custom_key_b")

        let aHasGroqBefore = await vault.hasSecret(ownerID: ownerA, providerID: "groq")
        let aHasFinanceBefore = await vault.hasSecret(ownerID: ownerA, providerID: "custom_endpoint_finance")
        let aHasMedBefore = await vault.hasSecret(ownerID: ownerA, providerID: "custom_endpoint_medical")
        XCTAssertTrue(aHasGroqBefore)
        XCTAssertTrue(aHasFinanceBefore)
        XCTAssertTrue(aHasMedBefore)

        // Wipe Owner A
        try await vault.removeAll(ownerID: ownerA)

        // Verify Owner A's secrets are ALL gone (including custom endpoints)
        let aHasGroqAfter = await vault.hasSecret(ownerID: ownerA, providerID: "groq")
        let aHasFinanceAfter = await vault.hasSecret(ownerID: ownerA, providerID: "custom_endpoint_finance")
        let aHasMedAfter = await vault.hasSecret(ownerID: ownerA, providerID: "custom_endpoint_medical")
        XCTAssertFalse(aHasGroqAfter)
        XCTAssertFalse(aHasFinanceAfter)
        XCTAssertFalse(aHasMedAfter)

        // Verify Owner B's secrets remain intact
        let bHasGroq = await vault.hasSecret(ownerID: ownerB, providerID: "groq")
        let bHasFinance = await vault.hasSecret(ownerID: ownerB, providerID: "custom_endpoint_finance")
        XCTAssertTrue(bHasGroq)
        XCTAssertTrue(bHasFinance)
        let bGroq = try await vault.copySecret(ownerID: ownerB, providerID: "groq")
        let bFinance = try await vault.copySecret(ownerID: ownerB, providerID: "custom_endpoint_finance")
        XCTAssertEqual(bGroq, "groq_key_b")
        XCTAssertEqual(bFinance, "custom_key_b")
    }

    // MARK: - 6. Device Lock Handling

    func testLockedVault_returnsLockedError() async throws {
        let backend = SimulatedKeychainBackend()
        let vault = KeychainVault(backend: backend)
        let owner = UserID()

        try await vault.setSecret(ownerID: owner, providerID: "groq", value: "secret_before_lock")

        // Simulate device locked
        backend.isLocked = true

        do {
            _ = try await vault.copySecret(ownerID: owner, providerID: "groq")
            XCTFail("Expected locked error on copySecret")
        } catch let error as KeychainVault.VaultError {
            XCTAssertEqual(error, .locked)
        }

        do {
            try await vault.setSecret(ownerID: owner, providerID: "groq", value: "new_secret")
            XCTFail("Expected locked error on setSecret")
        } catch let error as KeychainVault.VaultError {
            XCTAssertEqual(error, .locked)
        }

        do {
            try await vault.rotateSecret(ownerID: owner, providerID: "groq", newValue: "rotated_secret")
            XCTFail("Expected locked error on rotateSecret")
        } catch let error as KeychainVault.VaultError {
            XCTAssertEqual(error, .locked)
        }

        do {
            try await vault.removeSecret(ownerID: owner, providerID: "groq")
            XCTFail("Expected locked error on removeSecret")
        } catch let error as KeychainVault.VaultError {
            XCTAssertEqual(error, .locked)
        }

        // Unlock and verify original secret is intact
        backend.isLocked = false
        let preserved = try await vault.copySecret(ownerID: owner, providerID: "groq")
        XCTAssertEqual(preserved, "secret_before_lock")
    }

    // MARK: - 7. Remove Secret Untracks From Registry

    func testRemoveSecret_untracksFromRegistry() async throws {
        let backend = SimulatedKeychainBackend()
        let vault = KeychainVault(backend: backend)
        let owner = UserID()

        try await vault.setSecret(ownerID: owner, providerID: "custom_temp", value: "temp_val")
        let credentialsBefore = await vault.registeredCredentials(ownerID: owner)
        XCTAssertTrue(credentialsBefore.contains { $0.providerID == "custom_temp" })

        try await vault.removeSecret(ownerID: owner, providerID: "custom_temp")
        let credentialsAfter = await vault.registeredCredentials(ownerID: owner)
        XCTAssertFalse(credentialsAfter.contains { $0.providerID == "custom_temp" })
        let tempExists = await vault.hasSecret(ownerID: owner, providerID: "custom_temp")
        XCTAssertFalse(tempExists)
    }
}
