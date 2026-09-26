// Tools/ToolReceiptStore.swift
// Algorithm B05: Durable SwiftData-backed ledger persisting PREPARED receipts before side effects.
// Per V3 §B05 and §Tools/ToolReceiptStore.swift blueprint.
// Prevents duplicate side effects and reconciles ambiguous states.

import Foundation
import SwiftData

actor ToolReceiptStore {
    private var inMemoryCache: [UUID: ToolReceipt] = [:]
    private let modelContainer: ModelContainer?

    init(modelContainer: ModelContainer? = nil) {
        self.modelContainer = modelContainer
    }

    @MainActor
    private var context: ModelContext? {
        modelContainer?.mainContext
    }

    // MARK: - Record PREPARED (Idempotency Reservation)

    func recordPrepared(
        id: UUID = UUID(),
        invocationID: UUID,
        toolID: String,
        ownerID: UserID,
        traceID: TraceID,
        operationKey: String
    ) async throws -> ToolReceipt {
        let receipt = ToolReceipt(
            id: id,
            invocationID: invocationID,
            operationKey: operationKey,
            status: .prepared,
            toolID: toolID,
            ownerID: ownerID,
            traceID: traceID,
            externalReference: nil,
            redactedResult: nil,
            createdAt: Date(),
            updatedAt: Date()
        )

        inMemoryCache[id] = receipt

        if let modelContainer {
            try await MainActor.run {
                let ctx = modelContainer.mainContext
                let stored = StoredToolReceipt(
                    id: id,
                    invocationID: invocationID,
                    operationKey: operationKey,
                    statusRaw: ToolReceiptStatus.prepared.rawValue,
                    toolID: toolID,
                    ownerID: ownerID.rawValue,
                    traceIDRaw: traceID.rawValue,
                    externalReference: nil,
                    redactedResult: nil,
                    createdAt: receipt.createdAt,
                    updatedAt: receipt.updatedAt
                )
                ctx.insert(stored)
                try ctx.save()
            }
        }

        return receipt
    }

    // MARK: - Update Status (Succeeded / Failed / Ambiguous)

    func updateStatus(
        id: UUID,
        status: ToolReceiptStatus,
        result: String? = nil,
        externalReference: String? = nil
    ) async {
        if var cached = inMemoryCache[id] {
            cached.status = status
            cached.updatedAt = Date()
            inMemoryCache[id] = cached
        }

        if let modelContainer {
            await MainActor.run {
                let ctx = modelContainer.mainContext
                var descriptor = FetchDescriptor<StoredToolReceipt>(
                    predicate: #Predicate { $0.id == id }
                )
                descriptor.fetchLimit = 1
                if let stored = (try? ctx.fetch(descriptor))?.first {
                    stored.statusRaw = status.rawValue
                    stored.redactedResult = result
                    stored.externalReference = externalReference
                    stored.updatedAt = Date()
                    try? ctx.save()
                }
            }
        }
    }

    // MARK: - Queries

    func getReceipt(id: UUID) async -> ToolReceipt? {
        if let cached = inMemoryCache[id] {
            return cached
        }

        if let modelContainer {
            return await MainActor.run {
                let ctx = modelContainer.mainContext
                var descriptor = FetchDescriptor<StoredToolReceipt>(
                    predicate: #Predicate { $0.id == id }
                )
                descriptor.fetchLimit = 1
                guard let s = (try? ctx.fetch(descriptor))?.first else { return nil }
                return ToolReceipt(
                    id: s.id,
                    invocationID: s.invocationID,
                    operationKey: s.operationKey,
                    status: ToolReceiptStatus(rawValue: s.statusRaw) ?? .ambiguous,
                    toolID: s.toolID,
                    ownerID: UserID(rawValue: s.ownerID),
                    traceID: TraceID(rawValue: s.traceIDRaw),
                    externalReference: s.externalReference,
                    redactedResult: s.redactedResult,
                    createdAt: s.createdAt,
                    updatedAt: s.updatedAt
                )
            }
        }

        return nil
    }

    func receiptForOperationKey(_ operationKey: String) async -> ToolReceipt? {
        if let cached = inMemoryCache.values.first(where: { $0.operationKey == operationKey }) {
            return cached
        }

        if let modelContainer {
            return await MainActor.run {
                let ctx = modelContainer.mainContext
                var descriptor = FetchDescriptor<StoredToolReceipt>(
                    predicate: #Predicate { $0.operationKey == operationKey }
                )
                descriptor.fetchLimit = 1
                guard let s = (try? ctx.fetch(descriptor))?.first else { return nil }
                return ToolReceipt(
                    id: s.id,
                    invocationID: s.invocationID,
                    operationKey: s.operationKey,
                    status: ToolReceiptStatus(rawValue: s.statusRaw) ?? .ambiguous,
                    toolID: s.toolID,
                    ownerID: UserID(rawValue: s.ownerID),
                    traceID: TraceID(rawValue: s.traceIDRaw),
                    externalReference: s.externalReference,
                    redactedResult: s.redactedResult,
                    createdAt: s.createdAt,
                    updatedAt: s.updatedAt
                )
            }
        }

        return nil
    }

    // MARK: - Algorithm B05: Startup Reconciliation

    /// Reconciles any orphaned PREPARED receipts from a crash or killed process into AMBIGUOUS.
    /// Never auto-retries ambiguous operations.
    @discardableResult
    func reconcileStartup() async -> Int {
        guard let modelContainer else { return 0 }

        return await MainActor.run {
            let ctx = modelContainer.mainContext
            let preparedRaw = ToolReceiptStatus.prepared.rawValue
            let descriptor = FetchDescriptor<StoredToolReceipt>(
                predicate: #Predicate { $0.statusRaw == preparedRaw }
            )
            guard let orphaned = try? ctx.fetch(descriptor) else { return 0 }
            let count = orphaned.count
            for stored in orphaned {
                stored.statusRaw = ToolReceiptStatus.ambiguous.rawValue
                stored.redactedResult = "Execution interrupted by process termination"
                stored.updatedAt = Date()
            }
            if count > 0 {
                try? ctx.save()
            }
            return count
        }
    }
}
