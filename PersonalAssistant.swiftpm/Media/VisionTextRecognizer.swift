// Media/VisionTextRecognizer.swift
// COND: Vision framework OCR for image text extraction.
// Per V3 §Media/VisionTextRecognizer.swift blueprint.

import Foundation
#if canImport(Vision)
import Vision
#endif

actor VisionTextRecognizer {
    func recognizeText(from imageData: Data) async throws -> String {
        #if canImport(Vision)
        guard let cgImage = CGImageSourceCreateWithData(imageData as CFData, nil).flatMap({ CGImageSourceCreateImageAtIndex($0, 0, nil) }) else {
            return ""
        }
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { req, err in
                if let err = err {
                    continuation.resume(throwing: err)
                    return
                }
                let observations = req.results as? [VNRecognizedTextObservation] ?? []
                let strings = observations.compactMap { $0.topCandidates(1).first?.string }
                continuation.resume(returning: strings.joined(separator: "\n"))
            }
            request.recognitionLevel = .accurate
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
        #else
        return ""
        #endif
    }
}
