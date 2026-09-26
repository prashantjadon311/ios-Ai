// Security/EncryptionService.swift
// Symmetric AES-GCM data encryption using native CryptoKit.
// Per V3 §Security/EncryptionService.swift blueprint.

import Foundation
import CryptoKit

struct EncryptionService: Sendable {
    static func encrypt(data: Data, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        guard let combined = sealedBox.combined else {
            throw AppError.validationFailed(field: "encryption", reason: "Encryption failed to combine payload")
        }
        return combined
    }

    static func decrypt(data: Data, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }
}
