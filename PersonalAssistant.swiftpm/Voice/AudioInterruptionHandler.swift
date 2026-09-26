// Voice/AudioInterruptionHandler.swift
// Observes system audio interruptions (e.g. incoming phone call) and halts speech.
// Per V3 §Voice/AudioInterruptionHandler.swift blueprint.

import Foundation
#if canImport(AVFAudio)
import AVFAudio
#endif

final class AudioInterruptionHandler: Sendable {
    private let onInterruption: @Sendable () -> Void

    init(onInterruption: @Sendable @escaping () -> Void) {
        self.onInterruption = onInterruption
        #if canImport(AVFAudio)
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.onInterruption()
        }
        #endif
    }
}
