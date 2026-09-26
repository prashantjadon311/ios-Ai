// Features/Configuration/AIConfigurationView.swift
import SwiftUI

struct AIConfigurationView: View {
    @State private var maxTokens = 2048
    @State private var temperature = 0.7

    var body: some View {
        Form {
            Section("Generation Settings") {
                Stepper("Response Limit: \(maxTokens) tokens", value: $maxTokens, in: 256...8192, step: 256)
                VStack(alignment: .leading) {
                    Text("Temperature: " + temperature.formatted(.number.precision(.fractionLength(1))))
                    Slider(value: $temperature, in: 0.0...1.0, step: 0.1)
                }
            }
        }
        .navigationTitle("AI Configuration")
    }
}
