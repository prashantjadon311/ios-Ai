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

    // Monotonically increasing session ID — new on every start (B07)
    private var sessionGeneration: Int = 0

    init(capabilityCenter: CapabilityCenter, commandBus: ApplicationCommandBus) {
        self.capabilityCenter = capabilityCenter
        self.commandBus = commandBus
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
        let capturedSessionID = currentSessionID

        state = .capturing

        // Real STT implementation in W07
        // Placeholder for W01-W03 compilation
        try? await Task.sleep(for: .milliseconds(100))

        // Verify session still valid (B07 stale callback guard)
        guard currentSessionID == capturedSessionID, state == .capturing else { return }

        state = .idle
    }

    // MARK: - Stop (B07: stop TTS before capture, release audio session)

    func stop() {
        let wasActive = state != .idle && state != .unavailable(reason: "")
        state = .idle
        lastTranscript = nil
        // Release AVAudioSession — real implementation in W07
    }

    // MARK: - Handle interruption (B07)

    func handleInterruption() {
        stop()  // Always stop on any interruption
    }
}
