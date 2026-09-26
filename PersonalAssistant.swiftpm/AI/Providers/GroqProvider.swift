// AI/Providers/GroqProvider.swift
// Groq cloud provider wrapper using OpenAI-compatible wire format.
// Per V3 §AI/Providers/GroqProvider.swift blueprint.

import Foundation

actor GroqProvider: AssistantModel {
    let providerID: String = "groq"
    private let underlying: OpenAICompatibleProvider

    init(keychainVault: KeychainVault, httpClient: HTTPClient) {
        self.underlying = OpenAICompatibleProvider(
            providerID: "groq",
            baseURL: URL(string: "https://api.groq.com/openai/v1")!,
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
