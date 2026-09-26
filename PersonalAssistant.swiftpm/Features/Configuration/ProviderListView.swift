// Features/Configuration/ProviderListView.swift
import SwiftUI

struct ProviderListView: View {
    var body: some View {
        List {
            NavigationLink("Groq") {
                ProviderDetailView(providerName: "Groq", providerID: "groq")
            }
            NavigationLink("OpenRouter") {
                ProviderDetailView(providerName: "OpenRouter", providerID: "openRouter")
            }
            NavigationLink("Custom Endpoint") {
                ProviderDetailView(providerName: "Custom", providerID: "custom")
            }
        }
        .navigationTitle("Providers")
    }
}
