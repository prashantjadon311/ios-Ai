// Persistence/AuditRepository.swift
// Persists redacted audit events (no PII, no raw tokens).

import Foundation
import SwiftData

actor AuditRepository {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    @MainActor
    private var context: ModelContext { modelContainer.mainContext }

    func record(_ event: AuditEvent) async throws {
        try await MainActor.run {
            let stored = StoredAuditEvent(
                id: event.id.rawValue,
                ownerID: event.ownerID.rawValue,
                traceIDRaw: event.traceID?.rawValue,
                categoryRaw: event.category.rawValue,
                action: event.action,
                outcomeRaw: event.outcome.rawValue,
                toolID: event.toolID,
                operationKey: event.operationKey,
                externalReference: event.externalReference,
                redactedSummary: event.redactedSummary,
                createdAt: event.createdAt
            )
            context.insert(stored)
            try context.save()
        }
    }

    func recentEvents(ownerID: UserID, limit: Int = 100) async throws -> [AuditEvent] {
        let ownerUUID = ownerID.rawValue
        let stored = try await MainActor.run {
            var descriptor = FetchDescriptor<StoredAuditEvent>(
                predicate: #Predicate { $0.ownerID == ownerUUID },
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            descriptor.fetchLimit = limit
            return try context.fetch(descriptor)
        }
        return stored.map { s in
            AuditEvent(
                id: AuditEventID(rawValue: s.id),
                ownerID: UserID(rawValue: s.ownerID),
                traceID: s.traceIDRaw.map { TraceID(rawValue: $0) },
                category: AuditCategory(rawValue: s.categoryRaw) ?? .toolExecution,
                action: s.action,
                outcome: AuditOutcome(rawValue: s.outcomeRaw) ?? .failed,
                toolID: s.toolID,
                operationKey: s.operationKey,
                externalReference: s.externalReference,
                redactedSummary: s.redactedSummary,
                createdAt: s.createdAt
            )
        }
    }
}
