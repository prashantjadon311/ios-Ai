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

    init(event: String? = nil, id: String? = nil, data: String, retry: Int? = nil) {
        self.event = event
        self.id = id
        self.data = data
        self.retry = retry
    }
}

// MARK: - SSE Decoder

/// Stateful byte-correct SSE decoder (B01 algorithm).
/// Feed raw bytes; call finish() at EOF.
struct SSEDecoder: Sendable {

    // MARK: - Configuration

    static let defaultMaxFrameBytes: Int = 256 * 1024       // 256 KiB
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
            guard let lfIndex = buffer.firstIndex(of: 0x0A) else { break }
            let rawLine = buffer[buffer.startIndex..<lfIndex]
            buffer = buffer[(lfIndex + 1)...]

            var lineBytes = rawLine
            if lineBytes.last == 0x0D { lineBytes = lineBytes.dropLast() }

            if lineBytes.count > maxFrameBytes {
                throw DecoderError.frameTooLarge(size: lineBytes.count, limit: maxFrameBytes)
            }

            guard let lineStr = String(bytes: lineBytes, encoding: .utf8) else {
                throw DecoderError.invalidUTF8
            }

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
        if line.hasPrefix(":") { return }

        let fieldName: String
        var fieldValue: String

        if let colonIdx = line.firstIndex(of: ":") {
            fieldName = String(line[line.startIndex..<colonIdx])
            let afterColon = line[line.index(after: colonIdx)...]
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
            guard !fieldValue.contains("\0") else { throw DecoderError.nullInEventID }
            currentID = fieldValue.isEmpty ? nil : fieldValue
        case "retry":
            if let ms = Int(fieldValue) { currentRetry = ms }
        default:
            break
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
