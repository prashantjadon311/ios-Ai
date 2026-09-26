// Persistence/StoreBootstrap.swift
// Initializes ModelContainer and handles migration failure gracefully.
// Per V3 §Persistence placement and B10: migration failure preserves data, no empty-store reset.

import Foundation
import SwiftData

enum StoreBootstrap {

    enum BootstrapResult {
        case success(ModelContainer)
        case recoveryRequired(reason: String, originalStoreURL: URL?)
    }

    /// Creates the ModelContainer from SchemaV1.
    /// On migration failure: preserves original store, returns recoveryRequired.
    /// Never silently destroys data to force a green launch.
    static func makeContainer(inMemory: Bool = false) -> BootstrapResult {
        let schema = Schema(SchemaV1.models)
        let configuration: ModelConfiguration

        if inMemory {
            configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        } else {
            // Default store in Application Support
            configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        }

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            return .success(container)
        } catch {
            // Do NOT reset/delete the store. Preserve original and surface recovery path.
            let storeURL = configuration.url
            return .recoveryRequired(
                reason: "Store failed to open: \(error.localizedDescription). Original store preserved at \(storeURL.path).",
                originalStoreURL: storeURL
            )
        }
    }

    /// Preview/test in-memory container. DEBUG only.
    static func makePreviewContainer() -> ModelContainer {
        switch makeContainer(inMemory: true) {
        case .success(let container):
            return container
        case .recoveryRequired(let reason, _):
            // In-memory containers should never fail; crash fast in DEBUG.
            preconditionFailure("In-memory container failed: \(reason)")
        }
    }
}
