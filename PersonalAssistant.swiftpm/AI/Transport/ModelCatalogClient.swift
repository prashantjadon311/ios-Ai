// AI/Transport/ModelCatalogClient.swift
// Parses ProviderCatalog.json from bundle resources.
// Per V3 §AI/Transport/ModelCatalogClient.swift blueprint.

import Foundation

struct ModelCatalogClient: Sendable {
    static func loadBundledCatalog() -> [String: Any]? {
        guard let url = Bundle.main.url(forResource: "ProviderCatalog", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json
    }
}
