// Security/DataClassifier.swift
// Classifies data sensitivity tier.
// Per V3 §Security/DataClassifier.swift blueprint.

import Foundation

struct DataClassifier: Sendable {
    static func classify(content: String) -> PrivacyClass {
        let lower = content.lowercased()
        if lower.contains("password") || lower.contains("api_key") || lower.contains("secret") {
            return .secret
        }
        if lower.contains("passport") || lower.contains("ssn") || lower.contains("health") {
            return .sensitive
        }
        if lower.contains("my ") || lower.contains("i like") || lower.contains("remember") {
            return .personal
        }
        return .publicData
    }
}
