// Features/Configuration/ConfigurationView.swift
// Configuration screen — provider setup, AI model, privacy routing, voice, tool permissions.
// Links to dedicated feature views in Features/Configuration, Features/Assistant, and Features/Memory.

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
