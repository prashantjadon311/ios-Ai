// Security/ApprovalCoordinator.swift
// Manages the state machine of human-in-the-loop tool approvals.
// Fail-closed authorization enforcing cryptographic payload digest and session generation.
// Per V3 §Security/ApprovalCoordinator.swift blueprint and Algorithm B05.

import Foundation

actor ApprovalCoordinator {
    private var pendingRequests: [ApprovalID: ApprovalRequest] = [:]

    func register(request: ApprovalRequest) {
        pendingRequests[request.id] = request
    }

    /// Authorizes a tool call strictly fail-closed.
    /// Requires exact cryptographic payload digest match and active session generation.
    func approve(
        requestID: ApprovalID,
        expectedPayloadHash: Data,
        currentSession: SessionToken,
        ttl: TimeInterval = 300
    ) throws -> AuthorizedToolCall {
        guard let req = pendingRequests[requestID] else {
            throw AppError.validationFailed(field: "approvalID", reason: "Approval request not found")
        }

        // TTL / Expiry enforcement
        if Date() > req.expiresAt {
            pendingRequests.removeValue(forKey: requestID)
            throw AppError.validationFailed(field: "expiresAt", reason: "Approval request has expired")
        }

        // Session binding enforcement: generation must match
        guard req.sessionGeneration == currentSession.generation else {
            throw AppError.validationFailed(field: "sessionToken", reason: "Session generation mismatch")
        }

        // Exact cryptographic digest match (mandatory, fail-closed)
        guard expectedPayloadHash == req.payloadHash else {
            throw AppError.approvalPayloadMismatch(invocationID: req.invocationID)
        }

        // Single-use: remove from pending
        pendingRequests.removeValue(forKey: requestID)

        let authorized = AuthorizedToolCall(
            approvalID: req.id,
            invocationID: req.invocationID,
            toolID: req.toolID,
            schemaVersion: req.schemaVersion,
            ownerID: req.ownerID,
            traceID: req.traceID,
            canonicalArguments: req.canonicalArguments,
            payloadHash: req.payloadHash,
            authorizedAt: Date(),
            expiresAt: Date().addingTimeInterval(ttl),
            sessionGeneration: currentSession.generation
        )
        return authorized
    }

    func reject(requestID: ApprovalID) {
        pendingRequests.removeValue(forKey: requestID)
    }

    func allPending() -> [ApprovalRequest] {
        Array(pendingRequests.values)
    }
}
