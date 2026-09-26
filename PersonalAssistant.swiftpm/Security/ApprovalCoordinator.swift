// Security/ApprovalCoordinator.swift
// Manages the state machine of human-in-the-loop tool approvals.
// Per V3 §Security/ApprovalCoordinator.swift blueprint.

import Foundation

actor ApprovalCoordinator {
    private var pendingRequests: [ApprovalID: ApprovalRequest] = [:]

    func register(request: ApprovalRequest) {
        pendingRequests[request.id] = request
    }

    func approve(
        requestID: ApprovalID,
        expectedPayloadHash: Data? = nil,
        currentSession: SessionToken? = nil,
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

        // Session binding enforcement
        if let currentSession {
            guard req.sessionToken.generationID == currentSession.generationID else {
                throw AppError.validationFailed(field: "sessionToken", reason: "Session generation mismatch")
            }
        }

        // Exact cryptographic digest match
        if let expected = expectedPayloadHash, expected != req.payloadHash {
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
            sessionGeneration: currentSession?.generationID ?? req.sessionToken.generationID
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
