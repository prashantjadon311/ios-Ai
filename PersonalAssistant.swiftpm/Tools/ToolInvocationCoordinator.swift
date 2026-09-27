// Tools/ToolInvocationCoordinator.swift
// Algorithm B05: Coordinates two-phase tool execution with durable receipts.
// Per V3 §B05 and §Tools/ToolInvocationCoordinator.swift blueprint.
// Guarantees PREPARED receipt persistence before any side effect and prevents ambiguous replay.

import Foundation

actor ToolInvocationCoordinator {
    private let receiptStore: ToolReceiptStore
    private let policyEngine: (any Sendable)?

    init(receiptStore: ToolReceiptStore = ToolReceiptStore(), policyEngine: (any Sendable)? = nil) {
        self.receiptStore = receiptStore
        self.policyEngine = policyEngine
    }

    func executeCall(
        authorizedCall: AuthorizedToolCall,
        currentSession: SessionToken? = nil,
        executor: @Sendable (Data) async throws -> String
    ) async throws -> String {
        // Expiration check
        if Date() > authorizedCall.expiresAt {
            throw AppError.approvalExpired(invocationID: authorizedCall.invocationID)
        }

        // Session generation check
        if let currentSession, currentSession.generation != authorizedCall.sessionGeneration {
            throw AppError.sessionChanged(
                expectedGeneration: authorizedCall.sessionGeneration,
                currentGeneration: currentSession.generation
            )
        }

        // Owner-bound idempotency key (Prompt 03 P01-B item c)
        let opKey = "\(authorizedCall.ownerID.rawValue.uuidString):\(authorizedCall.toolID):\(authorizedCall.invocationID.uuidString)"

        // 0. Idempotency check: prevent duplicate execution of the same operation key
        if let existing = await receiptStore.receiptForOperationKey(opKey) {
            switch existing.status {
            case .succeeded:
                return existing.redactedResult ?? "Already executed successfully"
            case .prepared, .ambiguous:
                throw AppError.sideEffectAmbiguous(operationKey: opKey)
            case .failed:
                throw AppError.toolExecutionFailed(toolID: authorizedCall.toolID, message: "Prior execution attempt failed")
            }
        }

        // 1. Commit durable PREPARED receipt before any side effect
        _ = try await receiptStore.recordPrepared(
            id: authorizedCall.invocationID,
            invocationID: authorizedCall.invocationID,
            toolID: authorizedCall.toolID,
            ownerID: authorizedCall.ownerID,
            traceID: authorizedCall.traceID,
            operationKey: opKey
        )

        // 2. Perform execution with error catch
        do {
            let result = try await executor(authorizedCall.canonicalArguments)
            do {
                try await receiptStore.updateStatus(id: authorizedCall.invocationID, status: .succeeded, result: result)
            } catch {
                // If updating status to succeeded fails in durable storage, the side effect occurred
                // but persistence failed. Must mark receipt as ambiguous and raise sideEffectAmbiguous! Never return false success!
                try? await receiptStore.updateStatus(
                    id: authorizedCall.invocationID,
                    status: .ambiguous,
                    result: "External action completed but status persistence failed: \(error.localizedDescription)"
                )
                throw AppError.sideEffectAmbiguous(operationKey: opKey)
            }
            return result
        } catch is CancellationError {
            try? await receiptStore.updateStatus(id: authorizedCall.invocationID, status: .ambiguous, result: "Cancelled mid-execution")
            throw AppError.sideEffectAmbiguous(operationKey: opKey)
        } catch let appErr as AppError {
            throw appErr
        } catch {
            try? await receiptStore.updateStatus(id: authorizedCall.invocationID, status: .failed, result: error.localizedDescription)
            throw error
        }
    }
}
