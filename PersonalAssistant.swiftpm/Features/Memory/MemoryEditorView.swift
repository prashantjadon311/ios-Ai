// Features/Memory/MemoryEditorView.swift
import SwiftUI

struct MemoryEditorView: View {
    @State var content: String = ""
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextEditor(text: $content)
                    .frame(minHeight: 150)
            }
            .navigationTitle("Edit Memory")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(content)
                        dismiss()
                    }
                }
            }
        }
    }
}
