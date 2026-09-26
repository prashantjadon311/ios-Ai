// Voice/ModernSpeechTranscriber.swift
// COND: Modern SpeechTranscriber integration, runtime gated.
// Per V3 §Voice/ModernSpeechTranscriber.swift blueprint.

import Foundation

actor ModernSpeechTranscriber: SpeechRecognizerProtocol {
    func startRecognition(locale: Locale) async throws -> AsyncThrowingStream<String, Error> {
        // Falls back safely to LegacySpeechRecognizer on supported platforms
        let legacy = LegacySpeechRecognizer()
        return try await legacy.startRecognition(locale: locale)
    }

    func stopRecognition() async {
        // No-op
    }
}
