// Features/Configuration/PrivacyRoutingView.swift
import SwiftUI

struct PrivacyRoutingView: View {
    @State private var privacyMode: PrivacyMode = .standard

    var body: some View {
        Form {
            Section("Privacy Boundary") {
                Picker("Egress Mode", selection: $privacyMode) {
                    Text("Standard (BYOK Cloud)").tag(PrivacyMode.standard)
                    Text("Private Only (Local Only)").tag(PrivacyMode.privateOnly)
                }
                .pickerStyle(.inline)
            }
        }
        .navigationTitle("Privacy Routing")
    }
}
