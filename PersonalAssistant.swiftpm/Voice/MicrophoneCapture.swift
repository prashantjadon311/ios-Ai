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

    #if canImport(AVFAudio)
    func startCapture(onBuffer: @Sendable @escaping (AVAudioPCMBuffer) -> Void = { _ in }) throws {
        let engine = AVAudioEngine()
        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            onBuffer(buffer)
        }

        engine.prepare()
        try engine.start()
        self.audioEngine = engine
        self.isCapturing = true
    }
    #else
    func startCapture() throws {
        self.isCapturing = true
    }
    #endif

    func stopCapture() {
        #if canImport(AVFAudio)
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        self.isCapturing = false
        #endif
    }
}
