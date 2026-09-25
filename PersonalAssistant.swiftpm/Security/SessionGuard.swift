// Security/SessionGuard.swift
// Session token validation — checks owner AND generation before every read/write.
// Per V3 §Strong identity and session.

import Foundation

/// SessionGuard enforces that both owner identity and session generation match.
/// Every async write and tool action must revalidate the current session before acting.
struct SessionGuard: Sendable {

    enum GuardError: Error, Sendable {
        case notAuthenticated
        case sessionChanged(expected: UUID, current: UUID)
        case ownerMismatch(requested: UserID, current: UserID)
    }

    /// Validates that the provided token matches the current session.
    /// Throws if owner or generation does not match.
    static func require(token provided: SessionToken, against current: SessionToken) throws {
        guard provided.userID == current.userID else {
            throw GuardError.ownerMismatch(requested: provided.userID, current: current.userID)
        }
        guard provided.generation == current.generation else {
            throw GuardError.sessionChanged(
                expected: provided.generation,
                current: current.generation
            )
        }
    }

    /// Convenience: just validate that the user IDs match (for read operations
    /// where we want to ensure owner scoping but generation is not yet relevant).
    static func requireOwner(userID requested: UserID, against current: UserID) throws {
        guard requested == current else {
            throw GuardError.ownerMismatch(requested: requested, current: current)
        }
    }
}
