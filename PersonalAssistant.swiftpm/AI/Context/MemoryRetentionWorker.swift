// AI/Context/MemoryRetentionWorker.swift
// Evaluates memory items for expiration and retention policies.
// Per V3 §AI/Context/MemoryRetentionWorker.swift blueprint.

import Foundation

struct MemoryRetentionWorker: Sendable {
    static func filterExpired(memories: [MemoryItem], now: Date = Date()) -> [MemoryItem] {
        memories.filter { $0.isActive(at: now) }
    }
}
