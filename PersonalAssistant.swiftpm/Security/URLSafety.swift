// Security/URLSafety.swift
// SSRF prevention, HTTPS enforcement, and destination safety checks.
// Per V3 §Security/URLSafety.swift blueprint, T013.

import Foundation

struct URLSafetyValidator: Sendable {
    static let blockedHosts: Set<String> = [
        "localhost", "127.0.0.1", "0.0.0.0", "169.254.169.254", "::1"
    ]

    static func isSafe(url: URL) -> Bool {
        do {
            try validateDestination(url)
            return true
        } catch {
            return false
        }
    }

    static func validateDestination(_ url: URL) throws {
        guard let scheme = url.scheme?.lowercased(), scheme == "https" else {
            throw AppError.validationFailed(field: "scheme", reason: "Only secure HTTPS URLs are permitted")
        }
        guard let host = url.host?.lowercased(), !host.isEmpty else {
            throw AppError.validationFailed(field: "host", reason: "Missing or invalid host")
        }
        if blockedHosts.contains(host) || host.hasPrefix("192.168.") || host.hasPrefix("10.") {
            throw AppError.privacyDenied(route: url.absoluteString, requiredClass: .secret)
        }
    }
}
