// Security/KeychainVault.swift
// Secure BYOK API key storage using Keychain Services.
// Per V3 §B10 and §Security/KeychainVault.swift blueprint.
// Namespace: (bundleID, localOwnerID, providerID, purpose)
// Access: kSecAttrAccessibleWhenUnlockedThisDeviceOnly

import Foundation
#if canImport(Security)
import Security
#else
typealias OSStatus = Int32
typealias CFString = String
let errSecSuccess: OSStatus = 0
let errSecItemNotFound: OSStatus = -25300
let errSecInteractionNotAllowed: OSStatus = -25308
let errSecParam: OSStatus = -50
let errSecDecode: OSStatus = -26275
let errSecDuplicateItem: OSStatus = -25299

let kSecClass: CFString = "class"
let kSecClassGenericPassword: CFString = "genp"
let kSecAttrService: CFString = "svce"
let kSecValueData: CFString = "v_Data"
let kSecAttrAccessible: CFString = "pdmn"
let kSecAttrAccessibleWhenUnlockedThisDeviceOnly: CFString = "akpu"
let kSecReturnData: CFString = "r_Data"
let kSecMatchLimit: CFString = "m_Limit"
let kSecMatchLimitOne: CFString = "m_LimitOne"
#endif

// MARK: - Backend Protocol & Drivers

protocol KeychainBackend: Sendable {
    func secItemAdd(_ query: [CFString: Any]) -> OSStatus
    func secItemUpdate(_ query: [CFString: Any], _ attributes: [CFString: Any]) -> OSStatus
    func secItemCopyMatching(_ query: [CFString: Any], _ result: inout AnyObject?) -> OSStatus
    func secItemDelete(_ query: [CFString: Any]) -> OSStatus
}

#if canImport(Security)
final class AppleKeychainBackend: KeychainBackend, @unchecked Sendable {
    func secItemAdd(_ query: [CFString: Any]) -> OSStatus {
        SecItemAdd(query as CFDictionary, nil)
    }

    func secItemUpdate(_ query: [CFString: Any], _ attributes: [CFString: Any]) -> OSStatus {
        SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    }

    func secItemCopyMatching(_ query: [CFString: Any], _ result: inout AnyObject?) -> OSStatus {
        SecItemCopyMatching(query as CFDictionary, &result)
    }

    func secItemDelete(_ query: [CFString: Any]) -> OSStatus {
        SecItemDelete(query as CFDictionary)
    }
}
#endif

final class SimulatedKeychainBackend: KeychainBackend, @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [String: Data] = [:]
    var isLocked: Bool = false
    var injectedUpdateError: OSStatus? = nil
    var injectedAddError: OSStatus? = nil

    func secItemAdd(_ query: [CFString: Any]) -> OSStatus {
        lock.lock()
        defer { lock.unlock() }
        if isLocked { return errSecInteractionNotAllowed }
        if let err = injectedAddError { return err }
        guard let service = query[kSecAttrService] as? String,
              let data = query[kSecValueData] as? Data else {
            return errSecParam
        }
        if storage[service] != nil {
            return errSecDuplicateItem
        }
        storage[service] = data
        return errSecSuccess
    }

    func secItemUpdate(_ query: [CFString: Any], _ attributes: [CFString: Any]) -> OSStatus {
        lock.lock()
        defer { lock.unlock() }
        if isLocked { return errSecInteractionNotAllowed }
        if let err = injectedUpdateError { return err }
        guard let service = query[kSecAttrService] as? String,
              let data = attributes[kSecValueData] as? Data else {
            return errSecParam
        }
        guard storage[service] != nil else {
            return errSecItemNotFound
        }
        storage[service] = data
        return errSecSuccess
    }

    func secItemCopyMatching(_ query: [CFString: Any], _ result: inout AnyObject?) -> OSStatus {
        lock.lock()
        defer { lock.unlock() }
        if isLocked { return errSecInteractionNotAllowed }
        guard let service = query[kSecAttrService] as? String else {
            return errSecParam
        }
        guard let data = storage[service] else {
            return errSecItemNotFound
        }
        if let returnData = query[kSecReturnData] as? Bool, returnData {
            result = data as AnyObject
        }
        return errSecSuccess
    }

    func secItemDelete(_ query: [CFString: Any]) -> OSStatus {
        lock.lock()
        defer { lock.unlock() }
        if isLocked { return errSecInteractionNotAllowed }
        guard let service = query[kSecAttrService] as? String else {
            return errSecParam
        }
        storage.removeValue(forKey: service)
        return errSecSuccess
    }
}

// MARK: - Credential Registry Entry

struct CredentialRegistryEntry: Codable, Hashable, Sendable {
    let providerID: String
    let purpose: String
}

// MARK: - Keychain vault actor

actor KeychainVault {

    // MARK: - Errors

    enum VaultError: Error, Sendable, Equatable {
        case locked                       // device locked, SecItem returned errSecInteractionNotAllowed
        case notFound(key: String)        // item genuinely absent
        case writeFailed(status: OSStatus)
        case readFailed(status: OSStatus)
        case deleteFailed(status: OSStatus)
        case migrationUnsupported         // device restore: must re-enter key
    }

    private let backend: any KeychainBackend
    private var credentialRegistryCache: [UserID: Set<CredentialRegistryEntry>] = [:]

    init() {
        #if canImport(Security)
        self.backend = AppleKeychainBackend()
        #else
        self.backend = SimulatedKeychainBackend()
        #endif
    }

    init(backend: any KeychainBackend) {
        self.backend = backend
    }

    // MARK: - Namespace construction

    private func serviceKey(ownerID: UserID, providerID: String, purpose: String) -> String {
        let bundle = Bundle.main.bundleIdentifier ?? "com.personalassistant"
        return "\(bundle).\(ownerID.rawValue.uuidString).\(providerID).\(purpose)"
    }

    private func registryKey(ownerID: UserID) -> String {
        serviceKey(ownerID: ownerID, providerID: "__credential_registry__", purpose: "registry")
    }

    // MARK: - Dynamic Registry Management

    private func loadRegistry(ownerID: UserID) -> Set<CredentialRegistryEntry> {
        if let cached = credentialRegistryCache[ownerID] {
            return cached
        }
        let key = registryKey(ownerID: ownerID)
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne,
        ]
        var result: AnyObject?
        let status = backend.secItemCopyMatching(query, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let entries = try? JSONDecoder().decode(Set<CredentialRegistryEntry>.self, from: data) else {
            return []
        }
        credentialRegistryCache[ownerID] = entries
        return entries
    }

    private func saveRegistry(ownerID: UserID, entries: Set<CredentialRegistryEntry>) {
        credentialRegistryCache[ownerID] = entries
        guard let data = try? JSONEncoder().encode(entries) else { return }
        let key = registryKey(ownerID: ownerID)
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: key,
        ]
        let attrs: [CFString: Any] = [
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]
        let status = backend.secItemUpdate(query, attrs)
        if status == errSecItemNotFound {
            var addQuery = query
            addQuery[kSecValueData] = data
            addQuery[kSecAttrAccessible] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            _ = backend.secItemAdd(addQuery)
        }
    }

    private func trackCredential(ownerID: UserID, providerID: String, purpose: String) {
        guard providerID != "__credential_registry__" else { return }
        var entries = loadRegistry(ownerID: ownerID)
        entries.insert(CredentialRegistryEntry(providerID: providerID, purpose: purpose))
        saveRegistry(ownerID: ownerID, entries: entries)
    }

    private func untrackCredential(ownerID: UserID, providerID: String, purpose: String) {
        guard providerID != "__credential_registry__" else { return }
        var entries = loadRegistry(ownerID: ownerID)
        entries.remove(CredentialRegistryEntry(providerID: providerID, purpose: purpose))
        saveRegistry(ownerID: ownerID, entries: entries)
    }

    func registeredCredentials(ownerID: UserID) -> [(providerID: String, purpose: String)] {
        loadRegistry(ownerID: ownerID).map { ($0.providerID, $0.purpose) }
    }

    // MARK: - Write (Atomic Mutation via SecItemUpdate)

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

        let updateQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: key,
        ]
        let updateAttributes: [CFString: Any] = [
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]

        let updateStatus = backend.secItemUpdate(updateQuery, updateAttributes)
        switch updateStatus {
        case errSecSuccess:
            trackCredential(ownerID: ownerID, providerID: providerID, purpose: purpose)
            return
        case errSecItemNotFound:
            // Item does not exist yet; add it
            var addQuery = updateQuery
            addQuery[kSecValueData] = data
            addQuery[kSecAttrAccessible] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            let addStatus = backend.secItemAdd(addQuery)
            switch addStatus {
            case errSecSuccess:
                trackCredential(ownerID: ownerID, providerID: providerID, purpose: purpose)
                return
            case errSecInteractionNotAllowed:
                throw VaultError.locked
            case errSecDuplicateItem:
                // Retry update once in case of a race
                let retryStatus = backend.secItemUpdate(updateQuery, updateAttributes)
                if retryStatus == errSecSuccess {
                    trackCredential(ownerID: ownerID, providerID: providerID, purpose: purpose)
                    return
                }
                throw VaultError.writeFailed(status: retryStatus)
            default:
                throw VaultError.writeFailed(status: addStatus)
            }
        case errSecInteractionNotAllowed:
            throw VaultError.locked
        default:
            throw VaultError.writeFailed(status: updateStatus)
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
        let status = backend.secItemCopyMatching(query, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data, let str = String(data: data, encoding: .utf8) else {
                throw VaultError.readFailed(status: errSecDecode)
            }
            return str
        case errSecItemNotFound:
            throw VaultError.notFound(key: key)
        case errSecInteractionNotAllowed:
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
        let status = backend.secItemDelete(query)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            if status == errSecInteractionNotAllowed {
                throw VaultError.locked
            }
            throw VaultError.deleteFailed(status: status)
        }
        untrackCredential(ownerID: ownerID, providerID: providerID, purpose: purpose)
    }

    // MARK: - Rotate (Preserves previous secret on failure)

    func rotateSecret(
        ownerID: UserID,
        providerID: String,
        purpose: String = "apiKey",
        newValue: String
    ) throws {
        guard let data = newValue.data(using: .utf8) else {
            throw VaultError.writeFailed(status: errSecParam)
        }
        let key = serviceKey(ownerID: ownerID, providerID: providerID, purpose: purpose)

        let updateQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: key,
        ]
        let updateAttributes: [CFString: Any] = [
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]

        let status = backend.secItemUpdate(updateQuery, updateAttributes)
        switch status {
        case errSecSuccess:
            trackCredential(ownerID: ownerID, providerID: providerID, purpose: purpose)
        case errSecItemNotFound:
            throw VaultError.notFound(key: key)
        case errSecInteractionNotAllowed:
            throw VaultError.locked
        default:
            throw VaultError.writeFailed(status: status)
        }
    }

    // MARK: - Remove all for owner (account wipe with dynamic registry)

    func removeAll(ownerID: UserID) throws {
        var allEntries = loadRegistry(ownerID: ownerID)
        for provider in ProviderKind.allCases {
            allEntries.insert(CredentialRegistryEntry(providerID: provider.rawValue, purpose: "apiKey"))
        }

        for entry in allEntries {
            let key = serviceKey(ownerID: ownerID, providerID: entry.providerID, purpose: entry.purpose)
            let query: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: key,
            ]
            _ = backend.secItemDelete(query)
        }

        let regKey = registryKey(ownerID: ownerID)
        let regQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: regKey,
        ]
        _ = backend.secItemDelete(regQuery)
        credentialRegistryCache.removeValue(forKey: ownerID)
    }

    // MARK: - Check if key exists (without reading value)

    func hasSecret(ownerID: UserID, providerID: String, purpose: String = "apiKey") -> Bool {
        let key = serviceKey(ownerID: ownerID, providerID: providerID, purpose: purpose)
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: key,
            kSecMatchLimit: kSecMatchLimitOne,
        ]
        var result: AnyObject?
        let status = backend.secItemCopyMatching(query, &result)
        return status == errSecSuccess
    }
}
