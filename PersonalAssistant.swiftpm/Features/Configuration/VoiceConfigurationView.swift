// Features/Configuration/VoiceConfigurationView.swift
import SwiftUI

struct VoiceConfigurationView: View {
    @State private var selectedVoice = "Default Apple Speech"

    var body: some View {
        Form {
            Section("Speech Output") {
                Picker("Voice", selection: $selectedVoice) {
                    Text("Default Apple Speech").tag("Default Apple Speech")
                    Text("Enhanced Samantha").tag("Enhanced Samantha")
                    Text("Rishi (Indian English)").tag("Rishi (Indian English)")
                }
            }
        }
        .navigationTitle("Voice Settings")
    }
}
