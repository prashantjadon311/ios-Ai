// AI/Providers/OpenAICompatibleProvider.swift
// OpenAI-compatible streaming provider (used by Groq, OpenRouter, custom endpoints).
// Per V3 §AI/Providers/OpenAICompatibleProvider.swift blueprint.

import Foundation

// MARK: - Wire DTOs (provider-internal only, not in Domain/)

private struct OAIChatCompletionRequest: Encodable {
    let model: String
    let messages: [OAIMessage]
    let stream: Bool
    let maxTokens: Int?
    let tools: [OAIToolSchema]?

    enum CodingKeys: String, CodingKey {
        case model, messages, stream, tools
        case maxTokens = "max_tokens"
    }
}

private struct OAIMessage: Encodable {
    let role: String
    let content: String
}

private struct OAIToolSchema: Encodable {
    let type: String
    let function: OAIFunction

    struct OAIFunction: Encodable {
        let name: String
        let description: String
        let parameters: Data  // raw JSON Schema

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(description, forKey: .description)
            // Embed raw JSON
            if let obj = try? JSONSerialization.jsonObject(with: parameters) {
                try container.encode(AnyEncodable(obj), forKey: .parameters)
            }
        }
        enum CodingKeys: String, CodingKey { case name, description, parameters }
    }
}

private struct AnyEncodable: Encodable {
    let value: Any
    init(_ value: Any) { self.value = value }
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let d as [String: Any]:
            try container.encode(d.mapValues { AnyEncodable($0) })
        case let a as [Any]:
            try container.encode(a.map { AnyEncodable($0) })
        case let s as String: try container.encode(s)
        case let i as Int: try container.encode(i)
        case let b as Bool: try container.encode(b)
        default: try container.encode(String(describing: value))
        }
    }
}

// MARK: - Provider

actor OpenAICompatibleProvider: AssistantModel {
    let providerID: String
    private let baseURL: URL
    private let keychainVault: KeychainVault
    private let ownerID: UserID?
    private let httpClient: HTTPClient
    private var modelCache: (models: [ModelDescriptor], cachedAt: Date)?
    private let catalogTTL: TimeInterval

    init(
        providerID: String,
        baseURL: URL,
        keychainVault: KeychainVault,
        ownerID: UserID? = nil,
        httpClient: HTTPClient,
        catalogTTL: TimeInterval = 86400
    ) {
        self.providerID = providerID
        self.baseURL = baseURL
        self.keychainVault = keychainVault
        self.ownerID = ownerID
        self.httpClient = httpClient
        self.catalogTTL = catalogTTL
    }

    // MARK: - models()

    func models() async throws -> [ModelDescriptor] {
        if let cache = modelCache, Date().timeIntervalSince(cache.cachedAt) < catalogTTL {
            return cache.models
        }
        guard let owner = ownerID else { return [] }
        let apiKey = try keychainVault.copySecret(ownerID: owner, providerID: providerID)
        let modelsURL = baseURL.appendingPathComponent("models")
        let response = try await httpClient.send(request: HTTPRequest(
            url: modelsURL,
            method: "GET",
            headers: ["Authorization": "Bearer \(apiKey)"]
        ))
        guard response.statusCode == 200 else {
            throw ProviderFailure(
                providerID: providerID,
                statusCode: response.statusCode,
                message: "Models endpoint returned \(response.statusCode)"
            )
        }
        // Parse models list from standard OpenAI /models response format
        var result: [ModelDescriptor] = []
        if let json = try? JSONSerialization.jsonObject(with: response.body) as? [String: Any],
           let data = json["data"] as? [[String: Any]] {
            result = data.compactMap { item -> ModelDescriptor? in
                guard let id = item["id"] as? String, !id.isEmpty else { return nil }
                return ModelDescriptor(
                    id: id,
                    providerID: self.providerID,
                    displayName: id,
                    capabilities: ModelCapabilitySet(textChat: .yes, tools: .unknown, vision: .unknown, streaming: .yes, jsonMode: .unknown),
                    contextLimit: nil,
                    available: true,
                    verifiedAt: Date()
                )
            }
        }
        modelCache = (result, Date())
        return result
    }

    // MARK: - stream()

    func stream(_ request: AssistantRequest) async throws -> AsyncThrowingStream<AssistantEvent, Error> {
        let apiKey = try keychainVault.copySecret(ownerID: request.owner, providerID: providerID)

        // Build wire request
        let messages = request.messages.map { ctx -> OAIMessage in
            let text = ctx.parts.compactMap { part -> String? in
                if case .text(let t) = part { return t }
                return nil
            }.joined(separator: "\n")
            return OAIMessage(role: ctx.role.rawValue, content: text)
        }

        let selectedModel = (providerID == "groq") ? "llama-3.3-70b-versatile" : "meta-llama/llama-3.3-70b-instruct"

        let body = OAIChatCompletionRequest(
            model: selectedModel,
            messages: messages,
            stream: true,
            maxTokens: request.responseLimit,
            tools: nil
        )

        guard let bodyData = try? JSONEncoder().encode(body) else {
            throw ProviderFailure(providerID: providerID, message: "Failed to encode request")
        }

        let chatURL = baseURL.appendingPathComponent("chat/completions")
        let httpRequest = HTTPRequest(
            url: chatURL,
            method: "POST",
            headers: [
                "Authorization": "Bearer \(apiKey)",
                "Content-Type": "application/json",
                "Accept": "text/event-stream",
            ],
            body: bodyData
        )

        return AsyncThrowingStream { continuation in
            Task {
                var decoder = SSEDecoder()
                var sequence = 0
                continuation.yield(.started(modelID: selectedModel))
                do {
                    for try await chunk in httpClient.stream(request: httpRequest) {
                        let frames = try decoder.feed(chunk)
                        for frame in frames {
                            guard frame.data != "[DONE]" else {
                                continuation.yield(.completed(finishReason: "stop"))
                                continuation.finish()
                                return
                            }
                            if let data = frame.data.data(using: .utf8),
                               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                                if let choices = json["choices"] as? [[String: Any]],
                                   let delta = choices.first?["delta"] as? [String: Any],
                                   let content = delta["content"] as? String, !content.isEmpty {
                                    continuation.yield(.textDelta(content, sequence: sequence))
                                    sequence += 1
                                }
                                if let usage = json["usage"] as? [String: Any] {
                                    let promptTokens = usage["prompt_tokens"] as? Int
                                    let compTokens = usage["completion_tokens"] as? Int
                                    continuation.yield(.usage(input: promptTokens, output: compTokens, estimatedCost: nil))
                                }
                            }
                        }
                    }
                    let finalFrames = try? decoder.finish()
                    for frame in finalFrames ?? [] {
                        if frame.data == "[DONE]" {
                            continuation.yield(.completed(finishReason: "stop"))
                            continuation.finish()
                            return
                        }
                    }
                    continuation.yield(.completed(finishReason: "stop"))
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
