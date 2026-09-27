// AI/Transport/StreamingDeltaCoalescer.swift
// Manages bounded persistence of streaming text chunks to prevent excessive database writes.
// Per V3/V7 §B01 and Phase P05 requirements:
// 1. Coalesces incoming text deltas into a bounded buffer.
// 2. Flushes when buffer reaches flushThreshold (default: 128 characters) or on explicit flush.
// 3. Guarantees 0 lost characters and bounded persistence saves.

import Foundation

final class StreamingDeltaCoalescer: @unchecked Sendable {
    private let flushThreshold: Int
    private var buffer: String = ""
    private var totalReconstructedText: String = ""
    private var flushCount: Int = 0
    private let onFlush: (String) async throws -> Void

    init(flushThreshold: Int = 128, onFlush: @escaping (String) async throws -> Void) {
        self.flushThreshold = flushThreshold
        self.onFlush = onFlush
    }

    func append(delta: String) async throws {
        buffer += delta
        totalReconstructedText += delta
        if buffer.count >= flushThreshold {
            try await flush()
        }
    }

    func flush() async throws {
        guard !buffer.isEmpty else { return }
        let toFlush = buffer
        buffer = ""
        flushCount += 1
        try await onFlush(toFlush)
    }

    var currentBuffer: String {
        buffer
    }

    var fullText: String {
        totalReconstructedText
    }

    var totalFlushes: Int {
        flushCount
    }
}
