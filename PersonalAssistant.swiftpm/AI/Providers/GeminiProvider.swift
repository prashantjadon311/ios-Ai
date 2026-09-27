// AI/Providers/GeminiProvider.swift
// Native Google Gemini API provider adapter.
// Uses native Gemini wire format (contents/parts, streamGenerateContent?alt=sse, x-goog-api-key header).
// Per V3 §AI/Providers and P08 requirements.

import Foundation

// MARK: - Gemini Wire DTOs (provider-internal only)

private struct GeminiGenerateContentRequest: Encodable {
    let contents: [GeminiContent]
    let systemInstruction: GeminiSystemInstruction?
    let generationConfig: GeminiGenerationConfig?
}

private struct GeminiContent: Encodable {
    let role: String
    let parts: [GeminiPart]
}

private struct GeminiPart: Encodable {
    let text: String
}

private struct GeminiSystemInstruction: Encodable {
    let parts: [GeminiPart]
}

private struct GeminiGenerationConfig: Encodable {
    let maxOutputTokens: Int?
}

// MARK: - Gemini Provider

actor GeminiProvider: AssistantModel {
    let providerID: String = "gemini"
    private let baseURL: URL
    private let keychainVault: KeychainVault
    private let ownerID: UserID?
    private let httpClient: HTTPClient
    private var modelCache: (models: [ModelDescriptor], cachedAt: Date)?
    private let catalogTTL: TimeInterval
    private let defaultModelID: String

    init(
        keychainVault: KeychainVault,
        ownerID: UserID? = nil,
        httpClient: HTTPClient,
        baseURL: URL = URL(string: "https://generativelanguage.googleapis.com/v1beta")!,
        catalogTTL: TimeInterval = 86400,
        defaultModelID: String = "gemini-2.0-flash"
    ) {
        self.keychainVault = keychainVault
        self.ownerID = ownerID
        self.httpClient = httpClient
        self.baseURL = baseURL
        self.catalogTTL = catalogTTL
        self.defaultModelID = defaultModelID
    }

    // MARK: - models()

    func models() async throws -> [ModelDescriptor] {
        if let cache = modelCache, Date().timeIntervalSince(cache.cachedAt) < catalogTTL {
            return cache.models
        }
        guard let owner = ownerID else { return [] }
        let apiKey = try await keychainVault.copySecret(ownerID: owner, providerID: providerID)

        let modelsURL = baseURL.appendingPathComponent("models")
        let response = try await httpClient.send(request: HTTPRequest(
            url: modelsURL,
            method: "GET",
            headers: [
                "x-goog-api-key": apiKey,
                "Accept": "application/json"
            ]
        ))

        guard response.statusCode == 200 else {
            throw ProviderFailure(
                providerID: providerID,
                statusCode: response.statusCode,
                errorCode: response.statusCode == 401 || response.statusCode == 403 ? "unauthorized" : "http_\(response.statusCode)",
                message: "Gemini models endpoint returned \(response.statusCode)",
                isRetryable: (500...599).contains(response.statusCode)
            )
        }

        var result: [ModelDescriptor] = []
        if let json = try? JSONSerialization.jsonObject(with: response.body) as? [String: Any],
           let modelsArray = json["models"] as? [[String: Any]] {
            result = modelsArray.compactMap { item -> ModelDescriptor? in
                guard let name = item["name"] as? String else { return nil }
                // Strip "models/" prefix if present
                let cleanID = name.replacingOccurrences(of: "models/", with: "")
                guard !cleanID.isEmpty else { return nil }

                // Check supportedGenerationMethods
                if let methods = item["supportedGenerationMethods"] as? [String],
                   !methods.contains("generateContent") && !methods.contains("streamGenerateContent") {
                    return nil
                }

                let displayName = (item["displayName"] as? String) ?? cleanID
                let inputLimit = item["inputTokenLimit"] as? Int

                return ModelDescriptor(
                    id: cleanID,
                    providerID: self.providerID,
                    displayName: displayName,
                    capabilities: ModelCapabilitySet(
                        textChat: .yes,
                        tools: .yes,
                        vision: .yes,
                        streaming: .yes,
                        jsonMode: .yes
                    ),
                    contextLimit: inputLimit ?? 1048576,
                    available: true,
                    verifiedAt: Date()
                )
            }
        }

        if result.isEmpty {
            // Fallback to canonical Gemini models if parsing returned empty
            result = [
                ModelDescriptor(
                    id: "gemini-2.0-flash",
                    providerID: providerID,
                    displayName: "Gemini 2.0 Flash",
                    capabilities: ModelCapabilitySet(textChat: .yes, tools: .yes, vision: .yes, streaming: .yes, jsonMode: .yes),
                    contextLimit: 1048576,
                    available: true,
                    verifiedAt: Date()
                ),
                ModelDescriptor(
                    id: "gemini-1.5-flash",
                    providerID: providerID,
                    displayName: "Gemini 1.5 Flash",
                    capabilities: ModelCapabilitySet(textChat: .yes, tools: .yes, vision: .yes, streaming: .yes, jsonMode: .yes),
                    contextLimit: 1048576,
                    available: true,
                    verifiedAt: Date()
                )
            ]
        }

        modelCache = (result, Date())
        return result
    }

    // MARK: - stream()

    func stream(_ request: AssistantRequest) async throws -> AsyncThrowingStream<AssistantEvent, Error> {
        let apiKey = try await keychainVault.copySecret(ownerID: request.owner, providerID: providerID)

        let selectedModel = request.modelOverride ?? defaultModelID

        // Build Gemini wire contents
        var contents: [GeminiContent] = []
        var systemTexts: [String] = []

        for msg in request.messages {
            let text = msg.parts.compactMap { part -> String? in
                if case .text(let t) = part { return t }
                return nil
            }.joined(separator: "\n")

            switch msg.role {
            case .system:
                if !text.isEmpty { systemTexts.append(text) }
            case .assistant:
                contents.append(GeminiContent(role: "model", parts: [GeminiPart(text: text)]))
            case .user:
                contents.append(GeminiContent(role: "user", parts: [GeminiPart(text: text)]))
            case .toolResult:
                contents.append(GeminiContent(role: "user", parts: [GeminiPart(text: text)]))
            }
        }

        let systemInstruction: GeminiSystemInstruction? = systemTexts.isEmpty ? nil :
            GeminiSystemInstruction(parts: systemTexts.map { GeminiPart(text: $0) })

        let body = GeminiGenerateContentRequest(
            contents: contents,
            systemInstruction: systemInstruction,
            generationConfig: GeminiGenerationConfig(maxOutputTokens: request.responseLimit)
        )

        guard let bodyData = try? JSONEncoder().encode(body) else {
            throw ProviderFailure(providerID: providerID, message: "Failed to encode Gemini request")
        }

        guard let endpointURL = URL(string: "\(baseURL.absoluteString)/models/\(selectedModel):streamGenerateContent?alt=sse") else {
            throw ProviderFailure(providerID: providerID, message: "Invalid Gemini stream URL")
        }

        let httpRequest = HTTPRequest(
            url: endpointURL,
            method: "POST",
            headers: [
                "x-goog-api-key": apiKey,
                "Content-Type": "application/json",
                "Accept": "text/event-stream"
            ],
            body: bodyData
        )

        return AsyncThrowingStream { continuation in
            let producer = Task {
                var decoder = SSEDecoder()
                var sequence = 0
                var receivedTerminal = false
                continuation.yield(.started(modelID: selectedModel))

                do {
                    let byteStream = await httpClient.stream(request: httpRequest)
                    for try await chunk in byteStream {
                        if Task.isCancelled {
                            continuation.finish(throwing: CancellationError())
                            return
                        }
                        let frames = try decoder.feed(chunk)
                        for frame in frames {
                            if let data = frame.data.data(using: .utf8),
                               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {

                                // Check for candidates
                                if let candidates = json["candidates"] as? [[String: Any]] {
                                    for candidate in candidates {
                                        if let content = candidate["content"] as? [String: Any],
                                           let parts = content["parts"] as? [[String: Any]] {
                                            for part in parts {
                                                if let text = part["text"] as? String, !text.isEmpty {
                                                    continuation.yield(.textDelta(text, sequence: sequence))
                                                    sequence += 1
                                                }
                                            }
                                        }

                                        if let finishReason = candidate["finishReason"] as? String, !finishReason.isEmpty {
                                            receivedTerminal = true
                                            continuation.yield(.completed(finishReason: finishReason.lowercased()))
                                        }
                                    }
                                }

                                // Check for usageMetadata
                                if let usage = json["usageMetadata"] as? [String: Any] {
                                    let promptTokens = usage["promptTokenCount"] as? Int
                                    let candidateTokens = usage["candidatesTokenCount"] as? Int
                                    continuation.yield(.usage(input: promptTokens, output: candidateTokens, estimatedCost: nil))
                                }

                                // Check for API errors in body
                                if let errObj = json["error"] as? [String: Any] {
                                    let code = errObj["code"] as? Int
                                    let msg = (errObj["message"] as? String) ?? "Gemini API error"
                                    let isRetryable = (code ?? 0) >= 500
                                    let failure = ProviderFailure(
                                        providerID: providerID,
                                        statusCode: code,
                                        errorCode: code == 400 || code == 401 || code == 403 ? "unauthorized" : "gemini_error",
                                        message: msg,
                                        isRetryable: isRetryable
                                    )
                                    continuation.yield(.failed(failure))
                                    continuation.finish(throwing: failure)
                                    return
                                }
                            }
                        }
                    }

                    _ = try decoder.finish()
                    if !receivedTerminal {
                        continuation.yield(.completed(finishReason: "stop"))
                    }
                    continuation.finish()
                } catch {
                    if let httpErr = error as? HTTPClientError, case .httpStatus(let code, let msg) = httpErr {
                        let isRetryable = (500...599).contains(code)
                        let failure = ProviderFailure(
                            providerID: providerID,
                            statusCode: code,
                            errorCode: code == 401 || code == 403 ? "unauthorized" : (code == 429 ? "rate_limited" : "http_\(code)"),
                            message: msg ?? "HTTP \(code)",
                            isRetryable: isRetryable,
                            retryAfter: code == 429 ? Date().addingTimeInterval(30) : nil
                        )
                        continuation.yield(.failed(failure))
                        continuation.finish(throwing: failure)
                    } else {
                        continuation.finish(throwing: error)
                    }
                }
            }
            continuation.onTermination = { @Sendable _ in
                producer.cancel()
            }
        }
    }
}
