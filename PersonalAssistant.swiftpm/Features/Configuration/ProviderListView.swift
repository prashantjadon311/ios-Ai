// Features/Configuration/ProviderListView.swift
// Lists available AI model providers for configuration.
// Per V3 §Features/Configuration and P08 requirements.

import SwiftUI

struct ProviderListView: View {
    var body: some View {
        List {
            Section("Cloud AI Providers") {
                NavigationLink("Groq") {
                    ProviderDetailView(providerName: "Groq", providerID: "groq")
                }
                NavigationLink("OpenRouter") {
                    ProviderDetailView(providerName: "OpenRouter", providerID: "openRouter")
                }
                NavigationLink("OpenAI") {
                    ProviderDetailView(providerName: "OpenAI", providerID: "openAI")
                }
                NavigationLink("Google Gemini") {
                    ProviderDetailView(providerName: "Google Gemini", providerID: "gemini")
                }
                NavigationLink("NVIDIA NIM") {
                    ProviderDetailView(providerName: "NVIDIA NIM", providerID: "nvidia")
                }
            }

            Section("On-Device") {
                NavigationLink("Apple Intelligence") {
                    ProviderDetailView(providerName: "Apple Intelligence", providerID: "appleFoundationModels")
                }
            }

            Section("Self-Hosted & Custom") {
                NavigationLink("Custom Endpoint") {
                    ProviderDetailView(providerName: "Custom Endpoint", providerID: "custom")
                }
            }
        }
        .navigationTitle("AI Providers")
    }
}
