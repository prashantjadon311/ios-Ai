// Persistence/MemoryRepository.swift
// Persists memory items with owner scoping and verification lifecycle.
// Per V3 §Persistence/MemoryRepository.swift blueprint.

import Foundation
import SwiftData

actor MemoryRepository {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    @MainActor
    private var context: ModelContext { modelContainer.mainContext }

    // MARK: - Propose (AI-suggested, awaiting user review)

    func propose(memory: MemoryItem, sourceRefs: [MemorySourceRef]) async throws {
        try await MainActor.run {
            context.insert(try MemoryItemMapper.toStored(memory))
            try context.save()
        }
    }

    // MARK: - Verify (explicit user confirmation only)

    func verify(memoryID: MemoryItemID, expectedRevision: Int, userConfirmation: Bool) async throws {
        let uuid = memoryID.rawValue
        try await MainActor.run {
            let descriptor = FetchDescriptor<StoredMemoryItem>(
                predicate: #Predicate { $0.id == uuid }
            )
            guard let stored = try context.fetch(descriptor).first else { return }
            guard stored.revision == expectedRevision else {
                throw AppError.validationFailed(field: "revision", reason: "Revision conflict")
            }
            if userConfirmation {
                stored.verificationStateRaw = VerificationState.verified.rawValue
            } else {
                stored.verificationStateRaw = VerificationState.rejected.rawValue
            }
            stored.revision += 1
            stored.updatedAt = Date()
            try context.save()
        }
    }

    // MARK: - Revise (compare-and-set)

    func revise(memoryID: MemoryItemID, newContent: String, expectedRevision: Int) async throws {
        let uuid = memoryID.rawValue
        try await MainActor.run {
            let descriptor = FetchDescriptor<StoredMemoryItem>(
                predicate: #Predicate { $0.id == uuid }
            )
            guard let stored = try context.fetch(descriptor).first else { return }
            guard stored.revision == expectedRevision else {
                throw AppError.validationFailed(field: "revision", reason: "Revision conflict")
            }
            stored.content = newContent
            stored.revision += 1
            stored.updatedAt = Date()
            try context.save()
        }
    }

    // MARK: - Delete and deindex

    func deleteAndDeindex(memoryID: MemoryItemID, ownerID: UserID) async throws {
        let uuid = memoryID.rawValue
        let ownerUUID = ownerID.rawValue
        try await MainActor.run {
            let descriptor = FetchDescriptor<StoredMemoryItem>(
                predicate: #Predicate { $0.id == uuid && $0.ownerID == ownerUUID }
            )
            if let stored = try context.fetch(descriptor).first {
                stored.isDeleted = true
                stored.updatedAt = Date()
                stored.revision += 1
            }
            try context.save()
        }
        // TODO: Cancel index work and remove from Spotlight (W10)
    }

    // MARK: - Fetch active memories for context

    func activeMemories(ownerID: UserID) async throws -> [MemoryItem] {
        let ownerUUID = ownerID.rawValue
        let stored = try await MainActor.run {
            let descriptor = FetchDescriptor<StoredMemoryItem>(
                predicate: #Predicate {
                    $0.ownerID == ownerUUID &&
                    !$0.isDeleted &&
                    $0.verificationStateRaw == "verified"
                }
            )
            return try context.fetch(descriptor)
        }
        let now = Date()
        return try stored
            .map { try MemoryItemMapper.toDomain($0) }
            .filter { $0.isActive(at: now) }
    }

    // MARK: - Pending proposals (awaiting user review)

    func pendingProposals(ownerID: UserID) async throws -> [MemoryItem] {
        let ownerUUID = ownerID.rawValue
        let stored = try await MainActor.run {
            let descriptor = FetchDescriptor<StoredMemoryItem>(
                predicate: #Predicate {
                    $0.ownerID == ownerUUID &&
                    !$0.isDeleted &&
                    $0.verificationStateRaw == "proposed"
                }
            )
            return try context.fetch(descriptor)
        }
        return try stored.map { try MemoryItemMapper.toDomain($0) }
    }
}
