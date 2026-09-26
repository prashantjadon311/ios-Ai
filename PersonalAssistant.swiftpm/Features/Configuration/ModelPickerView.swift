// Features/Configuration/ModelPickerView.swift
import SwiftUI

struct ModelPickerView: View {
    @State private var selectedModel: String = "llama-3.3-70b-versatile"
    let availableModels = [
        "llama-3.3-70b-versatile",
        "llama-3.1-8b-instant",
        "meta-llama/llama-3.3-70b-instruct"
    ]

    var body: some View {
        List {
            ForEach(availableModels, id: \.self) { model in
                HStack {
                    Text(model)
                    Spacer()
                    if selectedModel == model {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedModel = model
                }
            }
        }
        .navigationTitle("Select Model")
    }
}
