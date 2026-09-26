// Security/ApprovalCoordinator.swift
// Manages the state machine of human-in-the-loop tool approvals.
// Per V3 §Security/ApprovalCoordinator.swift blueprint.

import Foundation

actor ApprovalCoordinator {
    private var pendingRequests: [ApprovalID: ApprovalRequest] = [:]

    func register(request: ApprovalRequest) {
        pendingRequests[request.id] = request
    }

    func approve(requestID: ApprovalID, expectedPayloadHash: Data? = nil) throws -> ApprovalRequest {
        guard let req = pendingRequests[requestID] else {
            throw AppError.validationFailed(field: "approvalID", reason: "Approval request not found")
        }
        if let expected = expectedPayloadHash, expected != req.payloadHash {
            throw AppError.approvalPayloadMismatch(invocationID: req.invocationID)
        }
        pendingRequests.removeValue(forKey: requestID)
        return req
    }

    func reject(requestID: ApprovalID) {
        pendingRequests.removeValue(forKey: requestID)
    }

    func allPending() -> [ApprovalRequest] {
        Array(pendingRequests.values)
    }
}
