// SSEDecoderTests.swift
// Tests byte-correct Server-Sent Events decoding per Phase P05 requirements:
// 1. 5k arbitrarily fragmented UTF-8 bytes.
// 2. Multiline data events.
// 3. Heartbeat (: comment) lines safely ignored.
// 4. Stop/cancel mid-event and EOF terminal frame processing.
// 5. Oversized frame cap enforcement.

import XCTest
@testable import AppCorePortable

final class SSEDecoderTests: XCTestCase {

    func test5kArbitrarilyFragmentedUTF8Bytes() throws {
        var decoder = SSEDecoder()

        // Generate ~5000 characters of SSE frames
        var rawSSEString = ""
        for i in 0..<100 {
            rawSSEString += "id: \(i)\nevent: message\ndata: Payload chunk number \(i) with some extra text padding to reach 5000 bytes overall length.\n\n"
        }

        let fullData = Data(rawSSEString.utf8)
        XCTAssertGreaterThan(fullData.count, 5000, "Raw SSE string must exceed 5000 bytes for this test")

        // Fragment into arbitrary small chunk sizes (e.g., 3, 7, 13, 17 bytes)
        var parsedFrames: [SSEFrame] = []
        var offset = 0
        let chunkSizes = [3, 7, 11, 13, 17, 23, 31, 5, 2]
        var chunkIndex = 0

        while offset < fullData.count {
            let chunkSize = min(chunkSizes[chunkIndex % chunkSizes.count], fullData.count - offset)
            let chunk = fullData.subdata(in: offset..<(offset + chunkSize))
            let frames = try decoder.feed(chunk)
            parsedFrames.append(contentsOf: frames)
            offset += chunkSize
            chunkIndex += 1
        }

        let terminalFrames = try decoder.finish()
        parsedFrames.append(contentsOf: terminalFrames)

        XCTAssertEqual(parsedFrames.count, 100, "Must correctly decode all 100 frames across arbitrary fragmented chunks")
        for i in 0..<100 {
            XCTAssertEqual(parsedFrames[i].id, "\(i)")
            XCTAssertEqual(parsedFrames[i].event, "message")
            XCTAssertEqual(parsedFrames[i].data, "Payload chunk number \(i) with some extra text padding to reach 5000 bytes overall length.")
        }
    }

    func testMultiLineDataEvents_joinedWithNewline() throws {
        var decoder = SSEDecoder()
        let sse = "data: First line\ndata: Second line\ndata: Third line\n\n"
        let frames = try decoder.feed(Data(sse.utf8))

        XCTAssertEqual(frames.count, 1)
        XCTAssertEqual(frames.first?.data, "First line\nSecond line\nThird line")
    }

    func testCommentsAndHeartbeats_safelyIgnored() throws {
        var decoder = SSEDecoder()
        let sse = ": keepalive heartbeat\n: another comment\ndata: Real data\n\n"
        let frames = try decoder.feed(Data(sse.utf8))

        XCTAssertEqual(frames.count, 1)
        XCTAssertEqual(frames.first?.data, "Real data")
    }

    func testOversizedFrame_throwsFrameTooLarge() {
        var decoder = SSEDecoder(maxFrameBytes: 128)
        let largeLine = String(repeating: "x", count: 200) + "\n"
        XCTAssertThrowsError(try decoder.feed(Data(largeLine.utf8))) { error in
            guard case SSEDecoder.DecoderError.frameTooLarge = error else {
                XCTFail("Expected frameTooLarge error, got \(error)")
                return
            }
        }
    }

    func testTerminalEOFWithoutTrailingNewline_emitsPendingFrame() throws {
        var decoder = SSEDecoder()
        let sse = "data: Incomplete frame at EOF"
        _ = try decoder.feed(Data(sse.utf8))
        let finalFrames = try decoder.finish()

        XCTAssertEqual(finalFrames.count, 1)
        XCTAssertEqual(finalFrames.first?.data, "Incomplete frame at EOF")
    }
}
