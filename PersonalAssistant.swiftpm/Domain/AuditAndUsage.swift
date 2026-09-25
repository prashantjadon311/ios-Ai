// Domain/AuditAndUsage.swift
// AuditEvent and UsageEstimate (audit copy) domain types.

import Foundation

/// V3 §Stable business entities — AuditEvent.
/// Redacted audit: contains invocation summary, outcome, external reference.
/// Never stores raw private content, tokens, or user message text.
struct AuditEvent: Identifiable, Codable, Sendable, Hashable {
    let id: AuditEventID
    let ownerID: UserID
    let traceID: TraceID?
    let category: AuditCategory
    let action: String          // brief non-PII description
    let outcome: AuditOutcome
    let toolID: String?
    let operationKey: String?
    let externalReference: String?  // e.g. task ID, redacted URL
    let redactedSummary: String?    // max 200 chars, no PII
    let createdAt: Date
}

// MARK: - Audit category

enum AuditCategory: String, Codable, Sendable, Hashable, CaseIterable {
    case toolExecution
    case providerRequest
    case dataEgress
    case profileSwitch
    case memoryOperation
    case taskOperation
    case deletion
    case keychainAccess
    case permissionChange
}

// MARK: - Audit outcome

enum AuditOutcome: String, Codable, Sendable, Hashable, CaseIterable {
    case succeeded
    case failed
    case denied
    case ambiguous
    case interrupted
    case cancelled
}
