// AI/Context/MemoryConflictResolver.swift
// Resolves conflicts when new memory proposals overlap existing items.
// Per V3 §AI/Context/MemoryConflictResolver.swift blueprint.

import Foundation

struct MemoryConflictResolver: Sendable {
    static func findConflicts(newContent: String, existingMemories: [MemoryItem]) -> [MemoryItem] {
        let newLower = newContent.lowercased()
        return existingMemories.filter { item in
            let existingLower = item.content.lowercased()
            return newLower.contains(existingLower) || existingLower.contains(newLower)
        }
    }
}
