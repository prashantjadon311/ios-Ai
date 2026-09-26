// AI/Providers/CustomEndpointProvider.swift
// User-configurable custom OpenAI-compatible endpoint provider.
// Per V3 §AI/Providers/CustomEndpointProvider.swift blueprint.

import Foundation

actor CustomEndpointProvider: AssistantModel {
    let providerID: String = "custom"
    private let underlying: OpenAICompatibleProvider

    init(baseURL: URL, keychainVault: KeychainVault, httpClient: HTTPClient) {
        self.underlying = OpenAICompatibleProvider(
            providerID: "custom",
            baseURL: baseURL,
            keychainVault: keychainVault,
            httpClient: httpClient
        )
    }

    func models() async throws -> [ModelDescriptor] {
        try await underlying.models()
    }

    func stream(_ request: AssistantRequest) async throws -> AsyncThrowingStream<AssistantEvent, Error> {
        try await underlying.stream(request)
    }
}
