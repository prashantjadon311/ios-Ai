// Security/URLSafety.swift
// SSRF prevention, HTTPS enforcement, private/internal IP blocking, and destination safety checks.
// Per V3 §Security/URLSafety.swift blueprint, T013 and S005.

import Foundation

struct URLSafetyValidator: Sendable {
    static let blockedHosts: Set<String> = [
        "localhost",
        "localhost.localdomain",
        "broadcasthost",
        "127.0.0.1",
        "0.0.0.0",
        "169.254.169.254",
        "metadata.google.internal",
        "instance-data",
        "::1"
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
        // 1. Only HTTPS scheme permitted
        guard let scheme = url.scheme?.lowercased(), scheme == "https" else {
            throw AppError.validationFailed(field: "scheme", reason: "Only secure HTTPS URLs are permitted")
        }

        // 2. Host must be present
        guard let rawHost = url.host?.lowercased(), !rawHost.isEmpty else {
            throw AppError.validationFailed(field: "host", reason: "Missing or invalid host")
        }

        // Strip bracket notation for IPv6
        let host = rawHost.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))

        // 3. Known dangerous hostnames & metadata services
        if blockedHosts.contains(host) {
            throw AppError.privacyDenied(route: url.absoluteString, requiredClass: .secret)
        }

        // 4. Loopback (127.0.0.0/8 and 0.0.0.0/8)
        if host.hasPrefix("127.") || host == "0.0.0.0" || host == "::1" {
            throw AppError.privacyDenied(route: url.absoluteString, requiredClass: .secret)
        }

        // 5. Link-Local & AWS/Cloud Metadata (169.254.0.0/16 and fe80::/10)
        if host.hasPrefix("169.254.") || host.hasPrefix("fe80:") {
            throw AppError.privacyDenied(route: url.absoluteString, requiredClass: .secret)
        }

        // 6. RFC 1918 Private IPv4: 10.0.0.0/8, 192.168.0.0/16
        if host.hasPrefix("10.") || host.hasPrefix("192.168.") {
            throw AppError.privacyDenied(route: url.absoluteString, requiredClass: .secret)
        }

        // 7. RFC 1918 Private IPv4: 172.16.0.0/12 (172.16.x - 172.31.x)
        if host.hasPrefix("172.") {
            let parts = host.split(separator: ".")
            if parts.count >= 2, let secondOctet = Int(parts[1]), (16...31).contains(secondOctet) {
                throw AppError.privacyDenied(route: url.absoluteString, requiredClass: .secret)
            }
        }

        // 8. Carrier-Grade NAT RFC 6598: 100.64.0.0/10 (100.64.x - 100.127.x)
        if host.hasPrefix("100.") {
            let parts = host.split(separator: ".")
            if parts.count >= 2, let secondOctet = Int(parts[1]), (64...127).contains(secondOctet) {
                throw AppError.privacyDenied(route: url.absoluteString, requiredClass: .secret)
            }
        }

        // 9. IPv6 Unique Local Address: fc00::/7 (fc00: - fdff:)
        if host.hasPrefix("fc") || host.hasPrefix("fd") {
            if host.contains(":") {
                throw AppError.privacyDenied(route: url.absoluteString, requiredClass: .secret)
            }
        }

        // 10. Userinfo in URL (potential credentials / phishing obfuscation)
        if url.user != nil || url.password != nil {
            throw AppError.validationFailed(field: "userinfo", reason: "Embedded user credentials in URL are prohibited")
        }
    }
}
