// Features/Assistant/AssistantNameEditor.swift
import SwiftUI

struct AssistantNameEditor: View {
    @Binding var name: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField("Assistant Name", text: $name)
            }
            .navigationTitle("Edit Name")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { dismiss() }
                }
            }
        }
    }
}
