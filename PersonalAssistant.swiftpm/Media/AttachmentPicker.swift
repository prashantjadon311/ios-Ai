// Media/AttachmentPicker.swift
// PhotosUI PhotosPicker view wrapper for attachments.
// Per V3 §Media/AttachmentPicker.swift blueprint.

import SwiftUI
#if canImport(PhotosUI)
import PhotosUI
#endif

struct AttachmentPickerSheet: View {
    @Binding var isPresented: Bool
    let onDataSelected: (Data) -> Void

    #if canImport(PhotosUI)
    @State private var selectedItem: PhotosPickerItem?
    #endif

    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.Spacing.lg) {
                #if canImport(PhotosUI)
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("Choose Photo", systemImage: "photo")
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .onChange(of: selectedItem) { _, newItem in
                    guard let item = newItem else { return }
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            onDataSelected(data)
                            isPresented = false
                        }
                    }
                }
                #endif

                Button("Cancel") {
                    isPresented = false
                }
                .frame(maxWidth: .infinity, minHeight: 44)
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle("Add Attachment")
        }
    }
}
