// AI/Providers/OpenRouterProvider.swift
// OpenRouter provider wrapper using OpenAI-compatible wire format.
// Per V3 §AI/Providers/OpenRouterProvider.swift blueprint.

import Foundation

actor OpenRouterProvider: AssistantModel {
    let providerID: String = "openRouter"
    private let underlying: OpenAICompatibleProvider

    init(keychainVault: KeychainVault, httpClient: HTTPClient) {
        self.underlying = OpenAICompatibleProvider(
            providerID: "openRouter",
            baseURL: URL(string: "https://openrouter.ai/api/v1")!,
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
