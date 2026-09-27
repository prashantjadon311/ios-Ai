// Features/Configuration/ModelPickerView.swift
// Dynamic model picker populated from ModelCatalogClient.
// Per V3 §Features/Configuration and P08 requirements.

import SwiftUI

struct ModelPickerView: View {
    @Environment(AppContainer.self) private var container
    @State private var selectedModel: String = "llama-3.3-70b-versatile"
    @State private var modelsByProvider: [String: [ModelDescriptor]] = [:]

    var body: some View {
        List {
            ForEach(modelsByProvider.keys.sorted(), id: \.self) { providerID in
                if let models = modelsByProvider[providerID], !models.isEmpty {
                    Section(providerTitle(for: providerID)) {
                        ForEach(models) { model in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(model.displayName)
                                        .font(.body)
                                    Text(model.id)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if selectedModel == model.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedModel = model.id
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Model")
        .task {
            loadModels()
        }
    }

    private func loadModels() {
        modelsByProvider = ModelCatalogClient.loadBundledCatalog()
    }

    private func providerTitle(for id: String) -> String {
        switch id {
        case "groq": return "Groq"
        case "openRouter": return "OpenRouter"
        case "openAI": return "OpenAI"
        case "gemini": return "Google Gemini"
        case "nvidia": return "NVIDIA NIM"
        case "appleFoundationModels": return "Apple Intelligence (On-Device)"
        default: return id
        }
    }
}
