// Voice/MicrophoneCapture.swift
// AVAudioEngine microphone audio tap and buffer streaming.
// Per V3 §Voice/MicrophoneCapture.swift blueprint.

import Foundation
#if canImport(AVFAudio)
import AVFAudio
#endif

actor MicrophoneCapture {
    #if canImport(AVFAudio)
    private var audioEngine: AVAudioEngine?
    #endif
    private(set) var isCapturing: Bool = false

    func startCapture() throws {
        #if canImport(AVFAudio)
        let engine = AVAudioEngine()
        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            // Audio buffer tapped
        }

        engine.prepare()
        try engine.start()
        self.audioEngine = engine
        self.isCapturing = true
        #endif
    }

    func stopCapture() {
        #if canImport(AVFAudio)
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        self.isCapturing = false
        #endif
    }
}
