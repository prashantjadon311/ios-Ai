// Domain/ApprovalRequest.swift
// Typed tool proposal, approval request, authorized call, receipt and executor protocol.
// Per V3 §Typed tools and approval and §B05.

import Foundation

// MARK: - Tool proposal (from provider, unvalidated)

/// V3 §Canonical AI request/response — ToolProposal.
/// Raw proposal from provider wire. NOT directly executable.
struct ToolProposal: Codable, Sendable, Hashable {
    let invocationID: UUID
    let toolID: String
    let schemaVersion: Int
    let argumentsJSON: Data
    let traceID: TraceID
    let sourceIDs: [UUID]  // message/context IDs that sourced this proposal
}

// MARK: - Tool decision (result of policy evaluation)

/// Result of ToolPolicyEngine.evaluate().
enum ToolDecision: Sendable {
    case deny(reason: String)
    case ask(ApprovalRequest)
    case permit(AuthorizedToolCall)
}

// MARK: - Approval request (pending user review)

struct ApprovalRequest: Identifiable, Codable, Sendable, Hashable {
    let id: ApprovalID
    let invocationID: UUID
    let toolID: String
    let schemaVersion: Int
    let ownerID: UserID
    let traceID: TraceID
    /// Canonical payload hash (B05 algorithm).
    let payloadHash: Data
    let riskLevel: ToolRiskLevel
    let humanReadableSummary: String
    /// Exact recipient: URL, service name, account category.
    let recipient: String
    /// Canonical arguments bytes reviewed by the user.
    let canonicalArguments: Data
    /// Session generation when approval was created.
    let sessionGeneration: UUID
    let expiresAt: Date
    var status: ApprovalStatus
    let createdAt: Date
    var updatedAt: Date

    init(
        id: ApprovalID = ApprovalID(),
        invocationID: UUID,
        toolID: String,
        schemaVersion: Int,
        ownerID: UserID,
        traceID: TraceID,
        payloadHash: Data,
        riskLevel: ToolRiskLevel,
        humanReadableSummary: String,
        recipient: String,
        dataClasses: [PrivacyClass],
        canonicalArguments: Data = Data(),
        sessionGeneration: UUID = UUID(),
        expiresAt: Date,
        status: ApprovalStatus = .pending,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.invocationID = invocationID
        self.toolID = toolID
        self.schemaVersion = schemaVersion
        self.ownerID = ownerID
        self.traceID = traceID
        self.payloadHash = payloadHash
        self.riskLevel = riskLevel
        self.humanReadableSummary = humanReadableSummary
        self.recipient = recipient
        self.dataClasses = dataClasses
        self.canonicalArguments = canonicalArguments
        self.sessionGeneration = sessionGeneration
        self.expiresAt = expiresAt
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Approval status (atomic single-use transition)

/// Atomic single-use transition: pending → approved/rejected/expired.
enum ApprovalStatus: String, Codable, Sendable, Hashable, CaseIterable {
    case pending
    case approved
    case rejected
    case expired

    func canTransition(to next: ApprovalStatus) -> Bool {
        switch (self, next) {
        case (.pending, .approved),
             (.pending, .rejected),
             (.pending, .expired):
            return true
        default:
            return false  // no re-approving a consumed approval
        }
    }
}

// MARK: - Authorized tool call (post-approval, pre-execution)

/// Produced only by ApprovalCoordinator after confirmed payload hash match.
struct AuthorizedToolCall: Codable, Sendable {
    let approvalID: ApprovalID
    let invocationID: UUID
    let toolID: String
    let schemaVersion: Int
    let ownerID: UserID
    let traceID: TraceID
    let canonicalArguments: Data  // canonical JSON bytes
    let payloadHash: Data         // must match at execution time
    let authorizedAt: Date
    let expiresAt: Date
    let sessionGeneration: UUID   // session generation at approval; must match current
}

// MARK: - Tool receipt (durable execution record, written before side effect)

/// V3 §Typed tools and approval — ToolReceipt.
struct ToolReceipt: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    let invocationID: UUID
    let operationKey: String  // stable unique key for idempotency tracking
    var status: ToolReceiptStatus
    let toolID: String
    let ownerID: UserID
    let traceID: TraceID
    let externalReference: String?
    let redactedResult: String?
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        invocationID: UUID,
        operationKey: String,
        status: ToolReceiptStatus,
        toolID: String,
        ownerID: UserID,
        traceID: TraceID,
        externalReference: String? = nil,
        redactedResult: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.invocationID = invocationID
        self.operationKey = operationKey
        self.status = status
        self.toolID = toolID
        self.ownerID = ownerID
        self.traceID = traceID
        self.externalReference = externalReference
        self.redactedResult = redactedResult
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// V3 §Typed tools and approval — ToolReceiptStatus.
enum ToolReceiptStatus: String, Codable, Sendable, Hashable, CaseIterable {
    case prepared   // durable intent written before dispatch
    case succeeded
    case failed
    case ambiguous  // timeout after dispatch — NEVER auto-replayed
}

// MARK: - Tool executor protocol

protocol ToolExecutor: Sendable {
    var toolID: String { get }
    func run(_ call: AuthorizedToolCall) async throws -> ToolReceipt
}

// MARK: - Tool risk level

enum ToolRiskLevel: String, Codable, Sendable, Hashable, CaseIterable, Comparable {
    case low    // read-only, reversible
    case medium // writes to local app state
    case high   // external side effect (network, calendar, contacts)

    private var order: Int {
        switch self {
        case .low: return 0
        case .medium: return 1
        case .high: return 2
        }
    }

    static func < (lhs: ToolRiskLevel, rhs: ToolRiskLevel) -> Bool {
        lhs.order < rhs.order
    }
}
