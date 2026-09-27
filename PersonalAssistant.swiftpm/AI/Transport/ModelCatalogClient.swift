// AI/Transport/ModelCatalogClient.swift
// Parses ProviderCatalog.json from bundle resources and manages dynamic model catalog with TTL caching.
// Per V3 §AI/Transport/ModelCatalogClient.swift and P08 requirements.

import Foundation

// MARK: - Model Catalog Entry

struct ModelCatalogEntry: Sendable {
    let models: [ModelDescriptor]
    let cachedAt: Date
    let ttlSeconds: TimeInterval

    func isStale(now: Date = Date()) -> Bool {
        now.timeIntervalSince(cachedAt) > ttlSeconds
    }
}

// MARK: - Model Catalog Client

actor ModelCatalogClient {
    private var cache: [String: ModelCatalogEntry] = [:]

    init(initialEntries: [String: ModelCatalogEntry] = [:]) {
        self.cache = initialEntries
    }

    // MARK: - Cache Access

    func cachedModels(providerID: String, allowStale: Bool = false, now: Date = Date()) -> [ModelDescriptor]? {
        guard let entry = cache[providerID] else { return nil }
        if allowStale || !entry.isStale(now: now) {
            return entry.models
        }
        return nil
    }

    func updateCache(
        providerID: String,
        models: [ModelDescriptor],
        ttlSeconds: TimeInterval = 86400,
        cachedAt: Date = Date()
    ) {
        cache[providerID] = ModelCatalogEntry(
            models: models,
            cachedAt: cachedAt,
            ttlSeconds: ttlSeconds
        )
    }

    func clearCache(providerID: String? = nil) {
        if let providerID {
            cache.removeValue(forKey: providerID)
        } else {
            cache.removeAll()
        }
    }

    // MARK: - Dynamic Fetch with Stale Fallback

    func fetchModels(
        provider: any AssistantModel,
        ttlSeconds: TimeInterval = 86400,
        forceRefresh: Bool = false,
        now: Date = Date()
    ) async throws -> [ModelDescriptor] {
        if !forceRefresh, let cached = cachedModels(providerID: provider.providerID, allowStale: false, now: now) {
            return cached
        }

        do {
            let fetched = try await provider.models()
            updateCache(providerID: provider.providerID, models: fetched, ttlSeconds: ttlSeconds, cachedAt: now)
            return fetched
        } catch {
            // Graceful degraded mode: if stale cache exists, return it rather than failing
            if let stale = cachedModels(providerID: provider.providerID, allowStale: true, now: now) {
                return stale
            }
            throw error
        }
    }

    // MARK: - JSON Parsing & Bundled Fallback

    static func parseCatalog(from data: Data) -> [String: [ModelDescriptor]] {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let providers = json["providers"] as? [[String: Any]] else {
            return [:]
        }

        var result: [String: [ModelDescriptor]] = [:]
        for p in providers {
            guard let providerID = p["id"] as? String,
                  let modelsArray = p["models"] as? [[String: Any]] else {
                continue
            }

            var descriptors: [ModelDescriptor] = []
            for m in modelsArray {
                guard let id = m["id"] as? String else { continue }
                let name = (m["name"] as? String) ?? id
                let contextLength = m["contextLength"] as? Int
                let supportsTools = (m["supportsTools"] as? Bool) ?? false
                let supportsVision = (m["supportsVision"] as? Bool) ?? false

                descriptors.append(ModelDescriptor(
                    id: id,
                    providerID: providerID,
                    displayName: name,
                    capabilities: ModelCapabilitySet(
                        textChat: .yes,
                        tools: supportsTools ? .yes : .no,
                        vision: supportsVision ? .yes : .no,
                        streaming: .yes,
                        jsonMode: .unknown
                    ),
                    contextLimit: contextLength,
                    available: true,
                    verifiedAt: Date()
                ))
            }
            result[providerID] = descriptors
        }
        return result
    }

    static func loadBundledCatalog() -> [String: [ModelDescriptor]] {
        let bundle = Bundle.main
        if let url = bundle.url(forResource: "ProviderCatalog", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            let parsed = parseCatalog(from: data)
            if !parsed.isEmpty {
                return parsed
            }
        }

        // Programmatic default fallback if bundled resource is not loaded (e.g. testing)
        return defaultFallbackCatalog()
    }

    static func defaultFallbackCatalog() -> [String: [ModelDescriptor]] {
        [
            "groq": [
                ModelDescriptor(
                    id: "llama-3.3-70b-versatile",
                    providerID: "groq",
                    displayName: "Llama 3.3 70B Versatile",
                    capabilities: ModelCapabilitySet(textChat: .yes, tools: .yes, vision: .no, streaming: .yes, jsonMode: .unknown),
                    contextLimit: 128000,
                    available: true,
                    verifiedAt: Date()
                ),
                ModelDescriptor(
                    id: "llama-3.1-8b-instant",
                    providerID: "groq",
                    displayName: "Llama 3.1 8B Instant",
                    capabilities: ModelCapabilitySet(textChat: .yes, tools: .yes, vision: .no, streaming: .yes, jsonMode: .unknown),
                    contextLimit: 128000,
                    available: true,
                    verifiedAt: Date()
                )
            ],
            "openRouter": [
                ModelDescriptor(
                    id: "meta-llama/llama-3.3-70b-instruct",
                    providerID: "openRouter",
                    displayName: "Meta Llama 3.3 70B Instruct",
                    capabilities: ModelCapabilitySet(textChat: .yes, tools: .yes, vision: .no, streaming: .yes, jsonMode: .unknown),
                    contextLimit: 131072,
                    available: true,
                    verifiedAt: Date()
                )
            ],
            "openAI": [
                ModelDescriptor(
                    id: "gpt-4o",
                    providerID: "openAI",
                    displayName: "GPT-4o",
                    capabilities: ModelCapabilitySet(textChat: .yes, tools: .yes, vision: .yes, streaming: .yes, jsonMode: .yes),
                    contextLimit: 128000,
                    available: true,
                    verifiedAt: Date()
                ),
                ModelDescriptor(
                    id: "gpt-4o-mini",
                    providerID: "openAI",
                    displayName: "GPT-4o mini",
                    capabilities: ModelCapabilitySet(textChat: .yes, tools: .yes, vision: .yes, streaming: .yes, jsonMode: .yes),
                    contextLimit: 128000,
                    available: true,
                    verifiedAt: Date()
                )
            ],
            "gemini": [
                ModelDescriptor(
                    id: "gemini-2.0-flash",
                    providerID: "gemini",
                    displayName: "Gemini 2.0 Flash",
                    capabilities: ModelCapabilitySet(textChat: .yes, tools: .yes, vision: .yes, streaming: .yes, jsonMode: .yes),
                    contextLimit: 1048576,
                    available: true,
                    verifiedAt: Date()
                ),
                ModelDescriptor(
                    id: "gemini-1.5-flash",
                    providerID: "gemini",
                    displayName: "Gemini 1.5 Flash",
                    capabilities: ModelCapabilitySet(textChat: .yes, tools: .yes, vision: .yes, streaming: .yes, jsonMode: .yes),
                    contextLimit: 1048576,
                    available: true,
                    verifiedAt: Date()
                )
            ],
            "nvidia": [
                ModelDescriptor(
                    id: "meta/llama-3.3-70b-instruct",
                    providerID: "nvidia",
                    displayName: "Meta Llama 3.3 70B Instruct (NIM)",
                    capabilities: ModelCapabilitySet(textChat: .yes, tools: .yes, vision: .no, streaming: .yes, jsonMode: .unknown),
                    contextLimit: 131072,
                    available: true,
                    verifiedAt: Date()
                )
            ],
            "appleFoundationModels": [
                ModelDescriptor(
                    id: "apple-intelligence-on-device",
                    providerID: "appleFoundationModels",
                    displayName: "Apple Intelligence (On-Device)",
                    capabilities: ModelCapabilitySet(textChat: .no, tools: .no, vision: .no, streaming: .no, jsonMode: .no),
                    contextLimit: 4096,
                    available: false,
                    verifiedAt: Date()
                )
            ]
        ]
    }
}
