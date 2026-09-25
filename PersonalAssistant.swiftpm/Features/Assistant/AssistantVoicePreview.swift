// Features/Assistant/AssistantVoicePreview.swift
// Preview selected voice without recording microphone.
// Per V3 §Features/Assistant/AssistantVoicePreview.swift blueprint.

import SwiftUI
#if canImport(AVFoundation)
import AVFoundation
#endif

struct AssistantVoicePreview: View {
    @Binding var settings: VoiceSettings
    let assistantName: String

    @State private var isPlaying: Bool = false
    #if canImport(AVFoundation)
    @State private var synthesizer = AVSpeechSynthesizer()
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
    }

    private func speakSample() {
        #if canImport(AVFoundation)
        let sampleText = "Hello! I am \(assistantName), your personal assistant."
        let utterance = AVSpeechUtterance(string: sampleText)
        utterance.rate = settings.rate * AVSpeechUtteranceDefaultSpeechRate * 2
        utterance.pitchMultiplier = settings.pitchMultiplier
        utterance.volume = settings.volume
        if let loc = settings.localeIdentifier {
            utterance.voice = AVSpeechSynthesisVoice(language: loc)
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
