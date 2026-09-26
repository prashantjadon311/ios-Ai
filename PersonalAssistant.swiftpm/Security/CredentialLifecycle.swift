// Security/CredentialLifecycle.swift
// Lifecycle management and rotation for Keychain credentials.
// Per V3 §Security/CredentialLifecycle.swift blueprint.

import Foundation

struct CredentialLifecycle: Sendable {
    static func canRotateKey(oldKey: String, newKey: String) -> Bool {
        !newKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && oldKey != newKey
    }
}
