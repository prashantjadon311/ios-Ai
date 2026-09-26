// AI/Transport/SSEDecoder.swift
// Byte-correct Server-Sent Events decoder per V3 §B01.
// Supports \r\n, \n, comments, multiline data, event/id/retry, oversized frame cap.

import Foundation

// MARK: - SSE Frame

struct SSEFrame: Sendable {
    var event: String?
    var id: String?
    var data: String  // joined with \n if multiple data: lines
    var retry: Int?
}

// MARK: - SSE Decoder

/// Stateful byte-correct SSE decoder (B01 algorithm).
/// Feed raw bytes; call finish() at EOF.
struct SSEDecoder {

    // MARK: - Configuration

    static let defaultMaxFrameBytes: Int = 256 * 1024   // 256 KiB
    static let defaultMaxTotalBytes: Int = 2 * 1024 * 1024  // 2 MiB

    let maxFrameBytes: Int
    let maxTotalBytes: Int

    enum DecoderError: Error, Sendable {
        case frameTooLarge(size: Int, limit: Int)
        case totalSizeLimitExceeded
        case invalidUTF8
        case nullInEventID
        case incompleteEventAtEOF
    }

    // MARK: - State

    private var buffer: Data = Data()
    private var totalBytesProcessed: Int = 0
    // Accumulated fields for current event
    private var currentEvent: String?
    private var currentID: String?
    private var currentDataLines: [String] = []
    private var currentRetry: Int?

    init(maxFrameBytes: Int = defaultMaxFrameBytes, maxTotalBytes: Int = defaultMaxTotalBytes) {
        self.maxFrameBytes = maxFrameBytes
        self.maxTotalBytes = maxTotalBytes
    }

    // MARK: - B01 feed

    /// Append incoming bytes and extract complete frames.
    mutating func feed(_ bytes: Data) throws -> [SSEFrame] {
        totalBytesProcessed += bytes.count
        guard totalBytesProcessed <= maxTotalBytes else {
            throw DecoderError.totalSizeLimitExceeded
        }
        buffer.append(bytes)
        return try extractFrames()
    }

    // MARK: - EOF

    /// B01 §7: process terminal incomplete line per protocol, emit pending event.
    mutating func finish() throws -> [SSEFrame] {
        var frames = try extractFrames()
        // If buffer has trailing data (no final blank line), emit pending event if data present
        if !buffer.isEmpty {
            if let line = try extractLine(allowNoNewline: true) {
                try processLine(line)
            }
        }
        if !currentDataLines.isEmpty {
            let frame = SSEFrame(
                event: currentEvent,
                id: currentID,
                data: currentDataLines.joined(separator: "\n"),
                retry: currentRetry
            )
            frames.append(frame)
        }
        return frames
    }

    // MARK: - Internal extraction

    private mutating func extractFrames() throws -> [SSEFrame] {
        var frames: [SSEFrame] = []
        while true {
            // Find LF byte
            guard let lfIndex = buffer.firstIndex(of: 0x0A) else {
                if buffer.count > maxFrameBytes {
                    throw DecoderError.frameTooLarge(size: buffer.count, limit: maxFrameBytes)
                }
                break
            }
            // Slice raw line (may include trailing CR)
            let rawLine = buffer[buffer.startIndex..<lfIndex]
            buffer = buffer[(lfIndex + 1)...]  // advance past LF

            // Strip single trailing CR
            var lineBytes = rawLine
            if lineBytes.last == 0x0D { lineBytes = lineBytes.dropLast() }

            // Validate frame size
            if lineBytes.count > maxFrameBytes {
                throw DecoderError.frameTooLarge(size: lineBytes.count, limit: maxFrameBytes)
            }

            // Decode UTF-8 strictly (B01 §3)
            guard let lineStr = String(bytes: lineBytes, encoding: .utf8) else {
                throw DecoderError.invalidUTF8
            }

            // Blank line → dispatch event if data present (B01 §4)
            if lineStr.isEmpty {
                if !currentDataLines.isEmpty {
                    let frame = SSEFrame(
                        event: currentEvent,
                        id: currentID,
                        data: currentDataLines.joined(separator: "\n"),
                        retry: currentRetry
                    )
                    frames.append(frame)
                }
                // Reset accumulator
                currentEvent = nil
                currentID = nil
                currentDataLines = []
                currentRetry = nil
                continue
            }

            try processLine(lineStr)
        }
        return frames
    }

    private mutating func processLine(_ line: String) throws {
        // B01 §5: comment
        if line.hasPrefix(":") { return }

        // B01 §5: parse first colon only
        let fieldName: String
        var fieldValue: String

        if let colonIdx = line.firstIndex(of: ":") {
            fieldName = String(line[line.startIndex..<colonIdx])
            let afterColon = line[line.index(after: colonIdx)...]
            // Strip single leading space (B01 §5)
            if afterColon.first == " " {
                fieldValue = String(afterColon.dropFirst())
            } else {
                fieldValue = String(afterColon)
            }
        } else {
            fieldName = line
            fieldValue = ""
        }

        switch fieldName {
        case "data":
            currentDataLines.append(fieldValue)
        case "event":
            currentEvent = fieldValue.isEmpty ? nil : fieldValue
        case "id":
            // B01 §6: reject NUL in ID
            guard !fieldValue.contains("\0") else { throw DecoderError.nullInEventID }
            currentID = fieldValue.isEmpty ? nil : fieldValue
        case "retry":
            if let ms = Int(fieldValue) { currentRetry = ms }
        default:
            break  // unknown field names are ignored per SSE spec
        }
    }

    private mutating func extractLine(allowNoNewline: Bool) throws -> String? {
        if let lfIndex = buffer.firstIndex(of: 0x0A) {
            let raw = buffer[buffer.startIndex..<lfIndex]
            buffer = buffer[(lfIndex + 1)...]
            var lineBytes = raw
            if lineBytes.last == 0x0D { lineBytes = lineBytes.dropLast() }
            guard let str = String(bytes: lineBytes, encoding: .utf8) else {
                throw DecoderError.invalidUTF8
            }
            return str
        }
        if allowNoNewline && !buffer.isEmpty {
            guard let str = String(bytes: buffer, encoding: .utf8) else {
                throw DecoderError.invalidUTF8
            }
            buffer = Data()
            return str
        }
        return nil
    }
}
