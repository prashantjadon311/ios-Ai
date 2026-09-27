// Features/Assistant/AssistantVoicePreview.swift
// Preview selected voice without recording microphone.
// Per V3 §Features/Assistant/AssistantVoicePreview.swift and Phase P05 requirements:
// 1. Resets delegate state on speech completion/cancellation/failure.
// 2. Halts previous TTS playback before starting new persona speech.
// 3. Selects verified installed voice identifier or falls back safely.

import SwiftUI
#if canImport(AVFoundation)
import AVFoundation

private final class VoicePreviewSynthesizerDelegate: NSObject, AVSpeechSynthesizerDelegate, @unchecked Sendable {
    var onFinish: (@MainActor () -> Void)?

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            onFinish?()
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            onFinish?()
        }
    }
}
#endif

struct AssistantVoicePreview: View {
    @Binding var settings: VoiceSettings
    let assistantName: String

    @State private var isPlaying: Bool = false
    #if canImport(AVFoundation)
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var delegate = VoicePreviewSynthesizerDelegate()
    #endif

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Speed (rate) slider
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                HStack {
                    Text("Speech Rate")
                        .font(.subheadline)
                    Spacer()
                    Text(String(format: "%.1fx", settings.rate * 2))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Slider(value: $settings.rate, in: 0.1...1.0, step: 0.05)
                    .accessibilityLabel("Speech rate")
            }

            // Pitch slider
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                HStack {
                    Text("Pitch")
                        .font(.subheadline)
                    Spacer()
                    Text(String(format: "%.1fx", settings.pitchMultiplier))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Slider(value: $settings.pitchMultiplier, in: 0.5...2.0, step: 0.1)
                    .accessibilityLabel("Voice pitch")
            }

            // Test voice button
            Button {
                if isPlaying {
                    stopSpeaking()
                } else {
                    speakSample()
                }
            } label: {
                HStack {
                    Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                    Text(isPlaying ? "Stop Preview" : "Preview Voice")
                }
                .frame(minWidth: AppTheme.minimumTapTarget, minHeight: AppTheme.minimumTapTarget)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel(isPlaying ? "Stop voice preview" : "Preview voice for \(assistantName)")
        }
        .onDisappear {
            stopSpeaking()
        }
    }

    private func speakSample() {
        #if canImport(AVFoundation)
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        delegate.onFinish = {
            self.isPlaying = false
        }
        synthesizer.delegate = delegate

        let sampleText = "Hello! I am \(assistantName), your personal assistant."
        let utterance = AVSpeechUtterance(string: sampleText)
        let computedRate = settings.rate * AVSpeechUtteranceDefaultSpeechRate * 2
        utterance.rate = min(max(computedRate, AVSpeechUtteranceMinimumSpeechRate), AVSpeechUtteranceMaximumSpeechRate)
        utterance.pitchMultiplier = min(max(settings.pitchMultiplier, 0.5), 2.0)
        utterance.volume = min(max(settings.volume, 0.0), 1.0)

        // Use installed identifier if verified, or fallback to locale
        if let id = settings.voiceIdentifier,
           let voice = AVSpeechSynthesisVoice(identifier: id) {
            utterance.voice = voice
        } else if let loc = settings.localeIdentifier,
                  let voice = AVSpeechSynthesisVoice(language: loc) {
            utterance.voice = voice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }

        synthesizer.speak(utterance)
        isPlaying = true
        #endif
    }

    private func stopSpeaking() {
        #if canImport(AVFoundation)
        synthesizer.stopSpeaking(at: .immediate)
        #endif
        isPlaying = false
    }
}
