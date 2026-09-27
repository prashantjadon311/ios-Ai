// AI/Providers/OpenAIProvider.swift
// Direct OpenAI API provider wrapper using OpenAI-compatible wire format.
// Per V3 §AI/Providers and P08 requirements.

import Foundation

actor OpenAIProvider: AssistantModel {
    let providerID: String = "openAI"
    private let underlying: OpenAICompatibleProvider

    init(keychainVault: KeychainVault, httpClient: HTTPClient) {
        self.underlying = OpenAICompatibleProvider(
            providerID: "openAI",
            baseURL: URL(string: "https://api.openai.com/v1")!,
            keychainVault: keychainVault,
            httpClient: httpClient,
            defaultModelID: "gpt-4o-mini"
        )
    }

    func models() async throws -> [ModelDescriptor] {
        try await underlying.models()
    }

    func stream(_ request: AssistantRequest) async throws -> AsyncThrowingStream<AssistantEvent, Error> {
        try await underlying.stream(request)
    }
}
