// Voice/AppleSpeechSynthesizer.swift
// AVSpeechSynthesizer wrapper for high quality local text-to-speech.
// Per V3 §Voice/AppleSpeechSynthesizer.swift blueprint.

import Foundation
#if canImport(AVFAudio)
import AVFAudio
#endif

actor AppleSpeechSynthesizer {
    #if canImport(AVFAudio)
    private let synthesizer = AVSpeechSynthesizer()
    #endif

    func speak(text: String, language: String = "en-US") async {
        #if canImport(AVFAudio)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synthesizer.speak(utterance)
        #endif
    }

    func stop() async {
        #if canImport(AVFAudio)
        synthesizer.stopSpeaking(at: .immediate)
        #endif
    }
}
