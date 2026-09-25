// Security/KeychainVault.swift
// Secure BYOK API key storage using Keychain Services.
// Per V3 §B10 and §Security/KeychainVault.swift blueprint.
// Namespace: (bundleID, localOwnerID, providerID, purpose)
// Access: kSecAttrAccessibleWhenUnlockedThisDeviceOnly

import Foundation
import Security

// MARK: - Keychain vault actor

/// Serialized actor for Keychain operations.
/// Distinguishes device-locked (errSecInteractionNotAllowed) from missing (errSecItemNotFound).
/// Never stores secret bytes in UserDefaults, logs, or DTOs.
actor KeychainVault {

    // MARK: - Errors

    enum VaultError: Error, Sendable {
        case locked                       // device locked, SecItem returned errSecInteractionNotAllowed
        case notFound(key: String)        // item genuinely absent
        case writeFailed(status: OSStatus)
        case readFailed(status: OSStatus)
        case deleteFailed(status: OSStatus)
        case migrationUnsupported         // device restore: must re-enter key
    }

    // MARK: - Namespace construction

    private func serviceKey(ownerID: UserID, providerID: String, purpose: String) -> String {
        // Stable composite key: bundleID.ownerUUID.providerID.purpose
        let bundle = Bundle.main.bundleIdentifier ?? "com.personalassistant"
        return "\(bundle).\(ownerID.rawValue.uuidString).\(providerID).\(purpose)"
    }

    // MARK: - Write

    func setSecret(
        ownerID: UserID,
        providerID: String,
        purpose: String = "apiKey",
        value: String
    ) throws {
        guard let data = value.data(using: .utf8) else {
            throw VaultError.writeFailed(status: errSecParam)
        }
        let key = serviceKey(ownerID: ownerID, providerID: providerID, purpose: purpose)
        // Delete any existing item first to avoid duplicates
        let deleteQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: key,
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        let addQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: key,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw VaultError.writeFailed(status: status)
        }
    }

    // MARK: - Read

    func copySecret(
        ownerID: UserID,
        providerID: String,
        purpose: String = "apiKey"
    ) throws -> String {
        let key = serviceKey(ownerID: ownerID, providerID: providerID, purpose: purpose)
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne,
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data, let str = String(data: data, encoding: .utf8) else {
                throw VaultError.readFailed(status: errSecDecode)
            }
            return str
        case errSecItemNotFound:
            throw VaultError.notFound(key: key)
        case errSecInteractionNotAllowed:
            // Device is locked — distinct from absent
            throw VaultError.locked
        default:
            throw VaultError.readFailed(status: status)
        }
    }

    // MARK: - Delete

    func removeSecret(ownerID: UserID, providerID: String, purpose: String = "apiKey") throws {
        let key = serviceKey(ownerID: ownerID, providerID: providerID, purpose: purpose)
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: key,
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw VaultError.deleteFailed(status: status)
        }
    }

    // MARK: - Rotate

    func rotateSecret(
        ownerID: UserID,
        providerID: String,
        purpose: String = "apiKey",
        newValue: String
    ) throws {
        // setSecret handles delete-then-add
        try setSecret(ownerID: ownerID, providerID: providerID, purpose: purpose, value: newValue)
    }

    // MARK: - Remove all for owner (account wipe)

    func removeAll(ownerID: UserID) throws {
        // Enumerate by service prefix — delete all items for this owner
        let prefix = {
            let bundle = Bundle.main.bundleIdentifier ?? "com.personalassistant"
            return "\(bundle).\(ownerID.rawValue.uuidString)."
        }()

        // Note: Keychain does not support prefix queries natively.
        // In V1 we maintain a list of known provider/purpose combinations.
        let knownProviders = ProviderKind.allCases.map(\.rawValue)
        let purposes = ["apiKey"]
        for provider in knownProviders {
            for purpose in purposes {
                let key = "\(prefix)\(provider).\(purpose)"
                let query: [CFString: Any] = [
                    kSecClass: kSecClassGenericPassword,
                    kSecAttrService: key,
                ]
                SecItemDelete(query as CFDictionary)  // ignore not-found errors
            }
        }
    }

    // MARK: - Check if key exists (without reading value)

    func hasSecret(ownerID: UserID, providerID: String, purpose: String = "apiKey") -> Bool {
        let key = serviceKey(ownerID: ownerID, providerID: providerID, purpose: purpose)
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: key,
            kSecMatchLimit: kSecMatchLimitOne,
        ]
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
}
