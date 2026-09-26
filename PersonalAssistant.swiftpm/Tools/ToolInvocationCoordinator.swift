// Tools/ToolInvocationCoordinator.swift
// Algorithm B05: Coordinates two-phase tool execution with durable receipts.
// Per V3 §B05 and §Tools/ToolInvocationCoordinator.swift blueprint.

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
        // 1. Commit durable PREPARED receipt before any side effect
        _ = await receiptStore.recordPrepared(
            id: authorizedCall.invocationID,
            invocationID: authorizedCall.invocationID,
            toolID: authorizedCall.toolID,
            ownerID: authorizedCall.ownerID,
            traceID: authorizedCall.traceID,
            operationKey: authorizedCall.invocationID.uuidString
        )

        // 2. Perform execution with error catch
        do {
            let result = try await executor(authorizedCall.canonicalArguments)
            await receiptStore.updateStatus(id: authorizedCall.invocationID, status: .completed, result: result)
            return result
        } catch is CancellationError {
            await receiptStore.updateStatus(id: authorizedCall.invocationID, status: .ambiguous, result: "Cancelled mid-execution")
            throw AppError.sideEffectAmbiguous(operation: authorizedCall.toolID)
        } catch {
            await receiptStore.updateStatus(id: authorizedCall.invocationID, status: .failed, result: error.localizedDescription)
            throw error
        }
    }
}
