// Tools/ToolInvocationCoordinator.swift
// Algorithm B05: Coordinates two-phase tool execution with durable receipts.
// Per V3 §B05 and §Tools/ToolInvocationCoordinator.swift blueprint.
// Guarantees PREPARED receipt persistence before any side effect and prevents ambiguous replay.

import Foundation

actor ToolInvocationCoordinator {
    private let receiptStore: ToolReceiptStore
    private let policyEngine: ToolPolicyEngine

    init(receiptStore: ToolReceiptStore = ToolReceiptStore(), policyEngine: ToolPolicyEngine = ToolPolicyEngine()) {
        self.receiptStore = receiptStore
        self.policyEngine = policyEngine
    }

    func executeCall(
        authorizedCall: AuthorizedToolCall,
        executor: @Sendable (Data) async throws -> String
    ) async throws -> String {
        let opKey = authorizedCall.invocationID.uuidString

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
        _ = await receiptStore.recordPrepared(
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
            await receiptStore.updateStatus(id: authorizedCall.invocationID, status: .succeeded, result: result)
            return result
        } catch is CancellationError {
            await receiptStore.updateStatus(id: authorizedCall.invocationID, status: .ambiguous, result: "Cancelled mid-execution")
            throw AppError.sideEffectAmbiguous(operationKey: authorizedCall.toolID)
        } catch {
            await receiptStore.updateStatus(id: authorizedCall.invocationID, status: .failed, result: error.localizedDescription)
            throw error
        }
    }
}
