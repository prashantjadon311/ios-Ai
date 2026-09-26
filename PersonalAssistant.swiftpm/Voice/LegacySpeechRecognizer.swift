// Voice/LegacySpeechRecognizer.swift
// SFSpeechRecognizer audio-buffer streaming implementation.
// Per V3 §Voice/LegacySpeechRecognizer.swift blueprint.

import Foundation
#if canImport(Speech)
import Speech
#endif

actor LegacySpeechRecognizer: SpeechRecognizerProtocol {
    #if canImport(Speech)
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    #endif

    func startRecognition(locale: Locale) async throws -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            #if canImport(Speech)
            guard let recognizer = SFSpeechRecognizer(locale: locale), recognizer.isAvailable else {
                continuation.finish(throwing: AppError.unsupportedCapability("Speech recognition unavailable for locale \(locale.identifier)"))
                return
            }

            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            self.recognitionRequest = request

            self.recognitionTask = recognizer.recognitionTask(with: request) { result, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                if let result = result {
                    continuation.yield(result.bestTranscription.formattedString)
                    if result.isFinal {
                        continuation.finish()
                    }
                }
            }
            #else
            continuation.finish(throwing: AppError.unsupportedCapability("Speech framework not available"))
            #endif
        }
    }

    func stopRecognition() async {
        #if canImport(Speech)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        #endif
    }

    #if canImport(Speech) && canImport(AVFAudio)
    func appendBuffer(_ buffer: AVAudioPCMBuffer) {
        recognitionRequest?.append(buffer)
    }
    #endif
}
