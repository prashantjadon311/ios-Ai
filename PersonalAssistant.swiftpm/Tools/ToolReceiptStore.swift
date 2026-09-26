// Tools/ToolReceiptStore.swift
// Algorithm B05: Durable ledger persisting PREPARED receipts before side effects.
// Per V3 §B05 and §Tools/ToolReceiptStore.swift blueprint.

import Foundation

actor ToolReceiptStore {
    private var receipts: [UUID: ToolReceipt] = [:]

    func recordPrepared(id: UUID, invocationID: UUID, toolID: String, ownerID: UserID, traceID: TraceID, operationKey: String) -> ToolReceipt {
        let receipt = ToolReceipt(
            id: id,
            invocationID: invocationID,
            operationKey: operationKey,
            status: .prepared,
            toolID: toolID,
            ownerID: ownerID,
            traceID: traceID,
            createdAt: Date()
        )
        receipts[id] = receipt
        return receipt
    }

    func updateStatus(id: UUID, status: ToolReceiptStatus, result: String? = nil) {
        if var receipt = receipts[id] {
            receipt.status = status
            receipt.updatedAt = Date()
            receipts[id] = receipt
        }
    }

    func getReceipt(id: UUID) -> ToolReceipt? {
        receipts[id]
    }
}

