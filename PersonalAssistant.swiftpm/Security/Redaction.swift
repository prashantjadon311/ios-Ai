// Security/Redaction.swift
// Scrubs PII and API keys from logs, error toasts, and diagnostics.
// Per V3 §Security/Redaction.swift blueprint.

import Foundation

struct ContentRedactor: Sendable {
    static func redactSecrets(in text: String) -> String {
        var result = text
        // Scrub bearer tokens
        let bearerPattern = /Bearer\s+[A-Za-z0-9_\-\.]+/
        result.replace(bearerPattern, with: "Bearer [REDACTED]")

        // Scrub sk- keys
        let skPattern = /sk-[A-Za-z0-9_\-]+/
        result.replace(skPattern, with: "sk-[REDACTED]")

        // Scrub email addresses
        let emailPattern = /[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}/
        result.replace(emailPattern, with: "[EMAIL_REDACTED]")

        return result
    }
}
