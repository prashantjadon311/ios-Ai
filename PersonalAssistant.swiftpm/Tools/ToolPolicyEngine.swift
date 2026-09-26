// Tools/ToolPolicyEngine.swift
// Evaluates tool proposals against policy, session, and data classification.
// Per V3 §B05 — validated before ApprovalRequest is created.

import Foundation
import CryptoKit

// MARK: - Policy engine

struct ToolPolicyEngine: Sendable {

    // MARK: - Evaluate (B05)

    /// Validates and routes a raw ToolProposal to deny/ask/permit.
    func evaluate(
        proposal: ToolProposal,
        ownerID: UserID,
        session: SessionToken,
        privacyMode: PrivacyMode
    ) throws -> ToolDecision {
        // 1. Tool must be in registry
        guard let definition = ToolRegistry.definition(for: proposal.toolID) else {
            return .deny(reason: "Unknown tool '\(proposal.toolID)'")
        }

        // 2. Schema version must match
        guard definition.schemaVersion == proposal.schemaVersion else {
            return .deny(reason: "Tool '\(proposal.toolID)' version mismatch: expected \(definition.schemaVersion), got \(proposal.schemaVersion)")
        }

        // 3. Owner and session must match
        guard session.userID == ownerID else {
            return .deny(reason: "Session owner mismatch")
        }

        // 4. Validate argument JSON (basic well-formed check — full validation in W09)
        guard !proposal.argumentsJSON.isEmpty,
              (try? JSONSerialization.jsonObject(with: proposal.argumentsJSON)) != nil else {
            return .deny(reason: "Tool arguments are not valid JSON")
        }

        // 5. Privacy mode: high-risk external tools blocked in private-only
        if privacyMode == .privateOnly && definition.riskLevel == .high {
            return .deny(reason: "High-risk external tool blocked in Private Only mode")
        }

        // 6. Low-risk, no-approval tools can be permitted directly
        if !definition.requiresApproval && definition.riskLevel == .low {
            let authorized = AuthorizedToolCall(
                approvalID: ApprovalID(),
                invocationID: proposal.invocationID,
                toolID: proposal.toolID,
                schemaVersion: proposal.schemaVersion,
                ownerID: ownerID,
                traceID: proposal.traceID,
                canonicalArguments: proposal.argumentsJSON,
                payloadHash: computeHash(proposal: proposal, ownerID: ownerID, session: session),
                authorizedAt: Date(),
                expiresAt: Date().addingTimeInterval(300),
                sessionGeneration: session.generation
            )
            return .permit(authorized)
        }

        // 7. Requires approval — build ApprovalRequest
        let hash = computeHash(proposal: proposal, ownerID: ownerID, session: session)
        let approvalRequest = ApprovalRequest(
            invocationID: proposal.invocationID,
            toolID: proposal.toolID,
            schemaVersion: proposal.schemaVersion,
            ownerID: ownerID,
            traceID: proposal.traceID,
            payloadHash: hash,
            riskLevel: definition.riskLevel,
            humanReadableSummary: humanReadable(definition: definition, args: proposal.argumentsJSON),
            recipient: definition.name,
            dataClasses: [.personal],  // W09 will inspect args for classification
            expiresAt: Date().addingTimeInterval(120)  // 2-minute approval window
        )
        return .ask(approvalRequest)
    }

    // MARK: - Canonical hash (B05 algorithm)

    /// SHA-256 over length-prefixed canonical fields.
    func computeHash(proposal: ToolProposal, ownerID: UserID, session: SessionToken) -> Data {
        var hasher = SHA256()
        func feed(_ string: String) {
            let data = Data(string.utf8)
            let lengthBytes = withUnsafeBytes(of: UInt32(data.count).bigEndian) { Data($0) }
            hasher.update(data: lengthBytes)
            hasher.update(data: data)
        }
        feed(ownerID.rawValue.uuidString)
        feed(session.generation.uuidString)
        feed(proposal.toolID)
        feed(String(proposal.schemaVersion))
        hasher.update(data: proposal.argumentsJSON)
        return Data(hasher.finalize())
    }

    private func humanReadable(definition: ToolDefinition, args: Data) -> String {
        if let json = try? JSONSerialization.jsonObject(with: args) as? [String: Any], !json.isEmpty {
            let details = json.map { "\($0.key): \($0.value)" }.sorted().joined(separator: ", ")
            return "\(definition.name) (\(details))"
        }
        return "Allow \(definition.name): \(definition.description)"
    }
}
