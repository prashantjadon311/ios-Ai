// AI/Providers/NvidiaNIMProvider.swift
// NVIDIA NIM provider wrapper using OpenAI-compatible wire format.
// Per V3 §AI/Providers and P08 requirements.

import Foundation

actor NvidiaNIMProvider: AssistantModel {
    let providerID: String = "nvidia"
    private let underlying: OpenAICompatibleProvider

    init(keychainVault: KeychainVault, httpClient: HTTPClient) {
        self.underlying = OpenAICompatibleProvider(
            providerID: "nvidia",
            baseURL: URL(string: "https://integrate.api.nvidia.com/v1")!,
            keychainVault: keychainVault,
            httpClient: httpClient,
            defaultModelID: "meta/llama-3.3-70b-instruct"
        )
    }

    func models() async throws -> [ModelDescriptor] {
        try await underlying.models()
    }

    func stream(_ request: AssistantRequest) async throws -> AsyncThrowingStream<AssistantEvent, Error> {
        try await underlying.stream(request)
    }
}
