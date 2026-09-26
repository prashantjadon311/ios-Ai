// AI/Context/MemoryRetriever.swift
// Retrieves active, owner-verified memory items.
// Per V3 §AI/Context/MemoryRetriever.swift blueprint.

import Foundation

actor MemoryRetriever {
    private let memoryRepo: MemoryRepository

    init(memoryRepo: MemoryRepository) {
        self.memoryRepo = memoryRepo
    }

    func retrieveActiveMemories(ownerID: UserID) async throws -> [MemoryItem] {
        try await memoryRepo.activeMemories(ownerID: ownerID)
    }
}
