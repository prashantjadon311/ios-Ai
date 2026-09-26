// Voice/VoiceCoordinator.swift
// Tap-to-talk voice lifecycle coordinator.
// Per V3 §B07 finite state machine: idle→permissionRequest→capturing→transcribing→modelThinking→speaking→idle.

import Foundation
import Observation

// MARK: - Voice state machine (B07)

enum VoiceState: Sendable, Equatable {
    case idle
    case permissionRequest
    case capturing
    case transcribing
    case modelThinking
    case toolActing
    case speaking
    case unavailable(reason: String)
}

@MainActor
@Observable
final class VoiceCoordinator {

    private(set) var state: VoiceState = .idle
    private(set) var currentSessionID: VoiceSessionID = VoiceSessionID()
    private(set) var lastTranscript: String?
    private(set) var isAvailable: Bool = false

    private let capabilityCenter: CapabilityCenter
    private let commandBus: ApplicationCommandBus
    private let microphoneCapture: MicrophoneCapture
    private let speechRecognizer: LegacySpeechRecognizer

    // Monotonically increasing session ID — new on every start (B07)
    private var sessionGeneration: Int = 0
    private var streamTask: Task<Void, Never>?

    init(
        capabilityCenter: CapabilityCenter,
        commandBus: ApplicationCommandBus,
        microphoneCapture: MicrophoneCapture = MicrophoneCapture(),
        speechRecognizer: LegacySpeechRecognizer = LegacySpeechRecognizer()
    ) {
        self.capabilityCenter = capabilityCenter
        self.commandBus = commandBus
        self.microphoneCapture = microphoneCapture
        self.speechRecognizer = speechRecognizer
    }

    // MARK: - Begin (must be from direct user intent only — B07)

    func begin(conversationID: ConversationID) async {
        guard state == .idle else { return }

        // Check capability (fail-closed)
        let decision = capabilityCenter.isAvailable(feature: .voiceInput)
        guard decision.isAvailable else {
            state = .unavailable(reason: decision.reason ?? "Voice unavailable")
            return
        }

        // New monotonically-increasing session ID
        sessionGeneration += 1
        currentSessionID = VoiceSessionID()
        let capturedGeneration = sessionGeneration

        state = .capturing
        lastTranscript = nil

        do {
            #if canImport(AVFAudio) && canImport(Speech)
            let recognizer = self.speechRecognizer
            try await microphoneCapture.startCapture { buffer in
                Task {
                    await recognizer.appendBuffer(buffer)
                }
            }
            #else
            try await microphoneCapture.startCapture()
            #endif

            let stream = try await speechRecognizer.startRecognition(locale: Locale.current)
            streamTask = Task { [weak self] in
                do {
                    for try await text in stream {
                        guard let self = self else { break }
                        guard self.sessionGeneration == capturedGeneration else { break }
                        self.lastTranscript = text
                    }
                } catch {
                    guard let self = self, self.sessionGeneration == capturedGeneration else { return }
                    self.stop()
                }
            }
        } catch {
            state = .unavailable(reason: error.localizedDescription)
            await microphoneCapture.stopCapture()
            await speechRecognizer.stopRecognition()
        }
    }

    // MARK: - Stop (B07: stop TTS before capture, release audio session)

    func stop() {
        state = .idle
        streamTask?.cancel()
        streamTask = nil
        Task {
            await microphoneCapture.stopCapture()
            await speechRecognizer.stopRecognition()
        }
    }

    // MARK: - Handle interruption (B07)

    func handleInterruption() {
        stop()  // Always stop on any interruption
    }
}
