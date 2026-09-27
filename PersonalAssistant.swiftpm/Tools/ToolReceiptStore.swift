// Tools/ToolReceiptStore.swift
// Algorithm B05: Durable SwiftData-backed ledger persisting PREPARED receipts before side effects.
// Per V3 §B05 and §Tools/ToolReceiptStore.swift blueprint.
// Prevents duplicate side effects and reconciles ambiguous states.

import Foundation
#if canImport(SwiftData) && !PORTABLE_CORE
import SwiftData
#endif

actor ToolReceiptStore {
    private var inMemoryCache: [UUID: ToolReceipt] = [:]
    #if canImport(SwiftData) && !PORTABLE_CORE
    private let modelContainer: ModelContainer?

    init(modelContainer: ModelContainer? = nil) {
        self.modelContainer = modelContainer
    }

    @MainActor
    private var context: ModelContext? {
        modelContainer?.mainContext
    }
    #else
    init() {}
    #endif

    // Fault injection hooks for testing failure boundaries
    var onRecordPreparedHook: (@Sendable (UUID, String) throws -> Void)?
    var onUpdateStatusHook: (@Sendable (UUID, ToolReceiptStatus) throws -> Void)?

    func setRecordPreparedHook(_ hook: (@Sendable (UUID, String) throws -> Void)?) {
        self.onRecordPreparedHook = hook
    }

    func setUpdateStatusHook(_ hook: (@Sendable (UUID, ToolReceiptStatus) throws -> Void)?) {
        self.onUpdateStatusHook = hook
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
        if let hook = onRecordPreparedHook {
            try hook(id, operationKey)
        }

        // Check in-memory cache first for idempotency collision
        if let existing = inMemoryCache.values.first(where: { $0.operationKey == operationKey }) {
            if existing.status == .prepared || existing.status == .ambiguous {
                throw AppError.sideEffectAmbiguous(operationKey: operationKey)
            } else if existing.status == .succeeded {
                return existing
            } else {
                throw AppError.toolExecutionFailed(toolID: toolID, message: "Prior execution attempt failed")
            }
        }

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

        #if canImport(SwiftData) && !PORTABLE_CORE
        if let modelContainer {
            do {
                try await MainActor.run {
                    let ctx = modelContainer.mainContext
                    var descriptor = FetchDescriptor<StoredToolReceipt>(
                        predicate: #Predicate { $0.operationKey == operationKey }
                    )
                    descriptor.fetchLimit = 1
                    if let existing = try ctx.fetch(descriptor).first {
                        let status = ToolReceiptStatus(rawValue: existing.statusRaw) ?? .ambiguous
                        if status == .prepared || status == .ambiguous {
                            throw AppError.sideEffectAmbiguous(operationKey: operationKey)
                        } else if status == .succeeded {
                            throw AppError.toolExecutionFailed(toolID: toolID, message: "Prior execution succeeded")
                        } else {
                            throw AppError.toolExecutionFailed(toolID: toolID, message: "Prior execution attempt failed")
                        }
                    }

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
            } catch {
                inMemoryCache.removeValue(forKey: id)
                throw error
            }
        }
        #endif

        inMemoryCache[id] = receipt
        return receipt
    }

    // MARK: - Update Status (Succeeded / Failed / Ambiguous)

    func updateStatus(
        id: UUID,
        status: ToolReceiptStatus,
        result: String? = nil,
        externalReference: String? = nil
    ) async throws {
        if let hook = onUpdateStatusHook {
            try hook(id, status)
        }

        if var cached = inMemoryCache[id] {
            cached.status = status
            cached.redactedResult = result
            cached.externalReference = externalReference
            cached.updatedAt = Date()
            inMemoryCache[id] = cached
        }

        #if canImport(SwiftData) && !PORTABLE_CORE
        if let modelContainer {
            try await MainActor.run {
                let ctx = modelContainer.mainContext
                var descriptor = FetchDescriptor<StoredToolReceipt>(
                    predicate: #Predicate { $0.id == id }
                )
                descriptor.fetchLimit = 1
                if let stored = try ctx.fetch(descriptor).first {
                    stored.statusRaw = status.rawValue
                    stored.redactedResult = result
                    stored.externalReference = externalReference
                    stored.updatedAt = Date()
                    try ctx.save()
                }
            }
        }
        #endif
    }

    // MARK: - Queries

    func getReceipt(id: UUID) async -> ToolReceipt? {
        if let cached = inMemoryCache[id] {
            return cached
        }

        #if canImport(SwiftData) && !PORTABLE_CORE
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
        #endif

        return nil
    }

    func receiptForOperationKey(_ operationKey: String) async -> ToolReceipt? {
        if let cached = inMemoryCache.values.first(where: { $0.operationKey == operationKey }) {
            return cached
        }

        #if canImport(SwiftData) && !PORTABLE_CORE
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
        #endif

        return nil
    }

    // MARK: - Algorithm B05: Startup Reconciliation

    /// Reconciles any orphaned PREPARED receipts from a crash or killed process into AMBIGUOUS.
    /// Never auto-retries ambiguous operations.
    @discardableResult
    func reconcileStartup() async -> Int {
        var inMemoryCount = 0
        for (id, receipt) in inMemoryCache where receipt.status == .prepared {
            var updated = receipt
            updated.status = .ambiguous
            updated.redactedResult = "Execution interrupted by process termination"
            updated.updatedAt = Date()
            inMemoryCache[id] = updated
            inMemoryCount += 1
        }

        #if canImport(SwiftData) && !PORTABLE_CORE
        guard let modelContainer else { return inMemoryCount }

        return await MainActor.run {
            let ctx = modelContainer.mainContext
            let preparedRaw = ToolReceiptStatus.prepared.rawValue
            let descriptor = FetchDescriptor<StoredToolReceipt>(
                predicate: #Predicate { $0.statusRaw == preparedRaw }
            )
            guard let orphaned = try? ctx.fetch(descriptor) else { return inMemoryCount }
            let count = orphaned.count
            for stored in orphaned {
                stored.statusRaw = ToolReceiptStatus.ambiguous.rawValue
                stored.redactedResult = "Execution interrupted by process termination"
                stored.updatedAt = Date()
            }
            if count > 0 {
                try? ctx.save()
            }
            return max(count, inMemoryCount)
        }
        #else
        return inMemoryCount
        #endif
    }
}
