// Features/Configuration/ConfigurationView.swift
// Configuration screen — provider setup, AI model, privacy routing, voice, tool permissions.

import SwiftUI

struct ConfigurationView: View {
    @Environment(AppSession.self) private var session

    var body: some View {
        NavigationStack {
            Form {
                Section("AI Providers") {
                    NavigationLink("Provider Setup") {
                        ProviderListView()
                    }
                    NavigationLink("AI Configuration") {
                        AIConfigurationView()
                    }
                    NavigationLink("Model Selection") {
                        ModelPickerView()
                    }
                }

                Section("Privacy & Routing") {
                    NavigationLink("Privacy Routing") {
                        PrivacyRoutingView()
                    }
                }

                Section("Voice") {
                    NavigationLink("Voice Settings") {
                        VoiceConfigurationView()
                    }
                }

                Section("Tools") {
                    NavigationLink("Tool Permissions") {
                        ToolPermissionsView()
                    }
                }

                Section("Assistant") {
                    NavigationLink("Assistant Profiles") {
                        AssistantProfileView()
                    }
                    NavigationLink("Memory") {
                        MemoryBrowserView()
                    }
                }
            }
            .navigationTitle("Configuration")
        }
    }
}

// MARK: - Stub views for sub-screens (W05/W06/W07/W10/W12 implementations)

struct AIConfigurationView: View {
    var body: some View {
        Text("AI Configuration — W06 implementation")
            .navigationTitle("AI Configuration")
    }
}

struct ModelPickerView: View {
    var body: some View {
        Text("Model Picker — W05 implementation")
            .navigationTitle("Select Model")
    }
}

struct PrivacyRoutingView: View {
    var body: some View {
        Text("Privacy Routing — W06/W12 implementation")
            .navigationTitle("Privacy Routing")
    }
}

struct ProviderListView: View {
    var body: some View {
        Text("Provider List — W05/W12 implementation")
            .navigationTitle("Providers")
    }
}

struct ProviderDetailView: View {
    var body: some View {
        Text("Provider Detail — W12 implementation")
            .navigationTitle("Provider")
    }
}

struct VoiceConfigurationView: View {
    var body: some View {
        Text("Voice Configuration — W07 implementation")
            .navigationTitle("Voice")
    }
}

struct ToolPermissionsView: View {
    var body: some View {
        Text("Tool Permissions — W09 implementation")
            .navigationTitle("Tool Permissions")
    }
}

struct AssistantProfileView: View {
    var body: some View {
        Text("Assistant Profile — W04 implementation")
            .navigationTitle("Assistant Profile")
    }
}

struct MemoryBrowserView: View {
    var body: some View {
        Text("Memory Browser — W10 implementation")
            .navigationTitle("Memory")
    }
}
