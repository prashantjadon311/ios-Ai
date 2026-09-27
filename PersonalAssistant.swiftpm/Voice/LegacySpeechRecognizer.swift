// Voice/LegacySpeechRecognizer.swift
// SFSpeechRecognizer audio-buffer streaming implementation.
// Per V3 §Voice/LegacySpeechRecognizer.swift blueprint.

import Foundation
#if canImport(Speech)
import Speech
#endif
#if canImport(AVFAudio)
import AVFAudio
#endif

actor LegacySpeechRecognizer: SpeechRecognizerProtocol {
    #if canImport(Speech)
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    #endif

    private var privacyMode: PrivacyMode
    private var hasAppleSTTConsent: Bool

    init(privacyMode: PrivacyMode = .privateOnly, hasAppleSTTConsent: Bool = false) {
        self.privacyMode = privacyMode
        self.hasAppleSTTConsent = hasAppleSTTConsent
    }

    func updatePrivacyConfiguration(privacyMode: PrivacyMode, hasAppleSTTConsent: Bool) {
        self.privacyMode = privacyMode
        self.hasAppleSTTConsent = hasAppleSTTConsent
    }

    func startRecognition(locale: Locale) async throws -> AsyncThrowingStream<String, Error> {
        #if canImport(Speech)
        guard let recognizer = SFSpeechRecognizer(locale: locale), recognizer.isAvailable else {
            throw AppError.unsupportedCapability("Speech recognition unavailable for locale \(locale.identifier)")
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true

        if privacyMode == .privateOnly {
            if recognizer.supportsOnDeviceRecognition {
                request.requiresOnDeviceRecognition = true
            } else {
                throw AppError.unsupportedCapability("On-device speech recognition unsupported for locale in Private-Only mode")
            }
        } else {
            // Cloud allowed
            if hasAppleSTTConsent {
                request.requiresOnDeviceRecognition = false
            } else {
                if recognizer.supportsOnDeviceRecognition {
                    request.requiresOnDeviceRecognition = true
                } else {
                    throw AppError.privacyDenied(route: DataEgressDestination.appleSTT.rawValue, requiredClass: .sensitive)
                }
            }
        }

        self.recognitionRequest = request

        return AsyncThrowingStream { continuation in
            let task = recognizer.recognitionTask(with: request) { result, error in
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

            continuation.onTermination = { @Sendable _ in
                task.cancel()
                request.endAudio()
            }
        }
        #else
        throw AppError.unsupportedCapability("Speech framework not available")
        #endif
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
