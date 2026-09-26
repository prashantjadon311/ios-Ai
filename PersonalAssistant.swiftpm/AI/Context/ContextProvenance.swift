// AI/Context/ContextProvenance.swift
// Non-PII SHA-256 digest of assembled context messages.
// Per V3 §AI/Context/ContextProvenance.swift blueprint.

import Foundation
import CryptoKit

struct ContextProvenanceDigest: Sendable {
    static func computeDigest(for messages: [ContextMessage]) -> Data {
        var hasher = SHA256()
        for msg in messages {
            hasher.update(data: Data(msg.role.rawValue.utf8))
            for part in msg.parts {
                if case .text(let t) = part {
                    hasher.update(data: Data(t.utf8))
                }
            }
        }
        return Data(hasher.finalize())
    }
}
