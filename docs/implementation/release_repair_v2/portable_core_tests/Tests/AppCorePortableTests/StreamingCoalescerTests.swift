// StreamingCoalescerTests.swift
// Tests bounded persistence coalescing for streaming AI tokens (Phase P05).
// Verifies:
// 1. 1000 tiny text deltas do NOT cause 1000 database saves.
// 2. Exact reconstructed text integrity is preserved.
// 3. Explicit flush on completion/interruption persists trailing tokens.
// 4. Threshold flush triggers exactly when buffer reaches capacity.

import XCTest
@testable import AppCorePortable

final class StreamingCoalescerTests: XCTestCase {

    func test1000TinyDeltas_doNotCause1000DatabaseSaves() async throws {
        var flushedChunks: [String] = []
        var flushCount = 0

        let coalescer = StreamingDeltaCoalescer(flushThreshold: 128) { chunk in
            flushedChunks.append(chunk)
            flushCount += 1
        }

        // Simulate 1000 single-character token emissions from an LLM stream
        for _ in 0..<1000 {
            try await coalescer.append(delta: "a")
        }

        // 1000 / 128 = 7 full flushes during streaming
        XCTAssertEqual(flushCount, 7, "1000 single-character deltas must only trigger 7 database flushes during streaming")
        XCTAssertEqual(coalescer.currentBuffer.count, 1000 - (7 * 128), "Remaining unwritten characters must stay in buffer until final flush")

        // Final completion flush
        try await coalescer.flush()
        XCTAssertEqual(flushCount, 8, "Total flushes including completion flush must be 8 (never 1000)")

        // Verify exact full text reconstruction
        let reconstructed = flushedChunks.joined()
        XCTAssertEqual(reconstructed.count, 1000)
        XCTAssertEqual(reconstructed, String(repeating: "a", count: 1000))
        XCTAssertEqual(coalescer.fullText, String(repeating: "a", count: 1000))
    }

    func testExactReconstructedTextIntegrity_withVaryingChunks() async throws {
        var flushedChunks: [String] = []

        let coalescer = StreamingDeltaCoalescer(flushThreshold: 64) { chunk in
            flushedChunks.append(chunk)
        }

        let words = ["Hello", " ", "world!", " ", "This", " ", "is", " ", "an", " ", "AI", " ", "assistant."]
        for word in words {
            try await coalescer.append(delta: word)
        }

        try await coalescer.flush()

        let combined = flushedChunks.joined()
        XCTAssertEqual(combined, "Hello world! This is an AI assistant.")
        XCTAssertEqual(coalescer.fullText, "Hello world! This is an AI assistant.")
    }

    func testFlushOnEmptyBuffer_doesNotTriggerSave() async throws {
        var flushCount = 0
        let coalescer = StreamingDeltaCoalescer(flushThreshold: 64) { _ in
            flushCount += 1
        }

        try await coalescer.flush()
        XCTAssertEqual(flushCount, 0, "Flushing an empty coalescer must not trigger any write")
    }

    func testThresholdFlush_triggersImmediatelyWhenCapacityReached() async throws {
        var flushedChunks: [String] = []

        let coalescer = StreamingDeltaCoalescer(flushThreshold: 10) { chunk in
            flushedChunks.append(chunk)
        }

        try await coalescer.append(delta: "12345")
        XCTAssertEqual(flushedChunks.count, 0)
        XCTAssertEqual(coalescer.currentBuffer, "12345")

        try await coalescer.append(delta: "67890")
        XCTAssertEqual(flushedChunks.count, 1)
        XCTAssertEqual(flushedChunks.first, "1234567890")
        XCTAssertEqual(coalescer.currentBuffer, "")
    }
}
