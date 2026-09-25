// Domain/UserProfile.swift
// Local guest/account identity and visibility boundaries.
// Single responsibility: owner profile DTO, no SwiftData imports.

import Foundation

/// V3 §Stable business entities — OwnerProfile.
/// Local-only identity; no server authentication in V1.
struct UserProfile: Identifiable, Codable, Sendable, Hashable {
    let id: UserID
    let displayName: String
    let createdAt: Date
    let updatedAt: Date

    /// V1 is always local; future cloud auth is NEXT scope.
    var accountState: AccountState

    init(
        id: UserID = UserID(),
        displayName: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        accountState: AccountState = .localGuest
    ) {
        self.id = id
        self.displayName = displayName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.accountState = accountState
    }

    /// Returns a new profile with the given display name (immutable update pattern).
    func withDisplayName(_ name: String) -> UserProfile {
        UserProfile(
            id: id,
            displayName: name,
            createdAt: createdAt,
            updatedAt: Date(),
            accountState: accountState
        )
    }
}

// MARK: - Account state

enum AccountState: String, Codable, Sendable, Hashable, CaseIterable {
    /// Single local owner, no network authentication. V1 default.
    case localGuest
    /// Future: Sign in with Apple + server auth. NEXT scope.
    case signedIn
    /// Profile is archived/deleted but records retained for audit.
    case archived
}

// MARK: - Profile validation

extension UserProfile {
    enum ValidationError: Error, Sendable {
        case nameTooShort
        case nameTooLong
        case nameContainsForbiddenChars
    }

    static let minimumNameLength = 1
    static let maximumNameLength = 64

    static func validateDisplayName(_ name: String) throws {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= minimumNameLength else {
            throw ValidationError.nameTooShort
        }
        guard trimmed.count <= maximumNameLength else {
            throw ValidationError.nameTooLong
        }
    }
}
