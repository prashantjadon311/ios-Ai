// Voice/SpeechRecognizerProtocol.swift
// Sendable protocol abstraction for speech recognition engines.
// Per V3 §Voice/SpeechRecognizerProtocol.swift blueprint.

import Foundation

protocol SpeechRecognizerProtocol: Sendable {
    func startRecognition(locale: Locale) async throws -> AsyncThrowingStream<String, Error>
    func stopRecognition() async
}
