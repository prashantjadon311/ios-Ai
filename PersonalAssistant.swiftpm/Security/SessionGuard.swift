// Security/SessionGuard.swift
// Session token validation — checks owner AND generation before every read/write.
// Per V3 §Strong identity and session.

import Foundation

/// SessionGuard enforces that both owner identity and session generation match.
/// Every async write and tool action must revalidate the current session before acting.
struct SessionGuard: Sendable {

    /// Validates that the provided token matches the current session.
    /// Throws AppError.ownerMismatch or AppError.sessionChanged if validation fails.
    static func require(token provided: SessionToken, against current: SessionToken) throws {
        guard provided.userID == current.userID else {
            throw AppError.ownerMismatch(requested: provided.userID, current: current.userID)
        }
        guard provided.generation == current.generation else {
            throw AppError.sessionChanged(
                expectedGeneration: provided.generation,
                currentGeneration: current.generation
            )
        }
    }

    /// Convenience: just validate that the user IDs match.
    static func requireOwner(userID requested: UserID, against current: UserID) throws {
        guard requested == current else {
            throw AppError.ownerMismatch(requested: requested, current: current)
        }
    }
}
