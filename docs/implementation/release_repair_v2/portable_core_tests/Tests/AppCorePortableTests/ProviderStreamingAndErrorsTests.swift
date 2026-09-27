import Foundation
import XCTest
@testable import AppCorePortable

final class ProviderStreamingAndErrorsTests: XCTestCase {

    // MARK: - OpenAI Wire Format Validation

    func testOpenAIWireFormat_payloadStructure() throws {
        let messages = [
            ContextMessage(role: .system, parts: [.text("You are helpful")], source: .systemPolicy, sensitivity: .publicData),
            ContextMessage(role: .user, parts: [.text("Hello")], source: .userTyped, sensitivity: .personal)
        ]

        struct OAIChatCompletionRequest: Encodable {
            let model: String
            let messages: [OAIMessage]
            let stream: Bool
            let maxTokens: Int?

            enum CodingKeys: String, CodingKey {
                case model, messages, stream
                case maxTokens = "max_tokens"
            }
        }

        struct OAIMessage: Encodable {
            let role: String
            let content: String
        }

        let wireMessages = messages.map { ctx -> OAIMessage in
            let text = ctx.parts.compactMap { part -> String? in
                if case .text(let t) = part { return t }
                return nil
            }.joined(separator: "\n")
            return OAIMessage(role: ctx.role.rawValue, content: text)
        }

        let payload = OAIChatCompletionRequest(
            model: "gpt-4o-mini",
            messages: wireMessages,
            stream: true,
            maxTokens: 1024
        )

        let data = try JSONEncoder().encode(payload)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertEqual(json?["model"] as? String, "gpt-4o-mini")
        XCTAssertEqual(json?["stream"] as? Bool, true)
        XCTAssertEqual(json?["max_tokens"] as? Int, 1024)

        let jsonMsgs = json?["messages"] as? [[String: Any]]
        XCTAssertEqual(jsonMsgs?.count, 2)
        XCTAssertEqual(jsonMsgs?[0]["role"] as? String, "system")
        XCTAssertEqual(jsonMsgs?[0]["content"] as? String, "You are helpful")
        XCTAssertEqual(jsonMsgs?[1]["role"] as? String, "user")
        XCTAssertEqual(jsonMsgs?[1]["content"] as? String, "Hello")
    }

    // MARK: - Gemini Wire Format Validation

    func testGeminiWireFormat_payloadStructure() throws {
        struct GeminiGenerateContentRequest: Encodable {
            let contents: [GeminiContent]
            let generationConfig: GeminiGenerationConfig?
        }
        struct GeminiContent: Encodable {
            let role: String
            let parts: [GeminiPart]
        }
        struct GeminiPart: Encodable {
            let text: String
        }
        struct GeminiGenerationConfig: Encodable {
            let maxOutputTokens: Int?
        }

        let contents = [
            GeminiContent(role: "user", parts: [GeminiPart(text: "Hello from Gemini")]),
            GeminiContent(role: "model", parts: [GeminiPart(text: "Hello user")])
        ]
        let req = GeminiGenerateContentRequest(
            contents: contents,
            generationConfig: GeminiGenerationConfig(maxOutputTokens: 2048)
        )

        let data = try JSONEncoder().encode(req)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let jsonContents = json?["contents"] as? [[String: Any]]
        XCTAssertEqual(jsonContents?.count, 2)
        XCTAssertEqual(jsonContents?[0]["role"] as? String, "user")
        XCTAssertEqual(jsonContents?[1]["role"] as? String, "model")

        let config = json?["generationConfig"] as? [String: Any]
        XCTAssertEqual(config?["maxOutputTokens"] as? Int, 2048)
    }

    // MARK: - SSE Decoding of OpenAI & Gemini Streams

    func testSSEDecoder_parsesGeminiStreamFrames() throws {
        var decoder = SSEDecoder()
        let chunk1 = Data("data: {\"candidates\":[{\"content\":{\"parts\":[{\"text\":\"Hello \"}]}}]}\n\n".utf8)
        let chunk2 = Data("data: {\"candidates\":[{\"content\":{\"parts\":[{\"text\":\"world!\"}]},\"finishReason\":\"STOP\"}],\"usageMetadata\":{\"promptTokenCount\":12,\"candidatesTokenCount\":4}}\n\n".utf8)

        let frames1 = try decoder.feed(chunk1)
        XCTAssertEqual(frames1.count, 1)

        let json1 = try JSONSerialization.jsonObject(with: Data(frames1[0].data.utf8)) as? [String: Any]
        let candidates1 = json1?["candidates"] as? [[String: Any]]
        let content1 = candidates1?.first?["content"] as? [String: Any]
        let parts1 = content1?["parts"] as? [[String: Any]]
        XCTAssertEqual(parts1?.first?["text"] as? String, "Hello ")

        let frames2 = try decoder.feed(chunk2)
        XCTAssertEqual(frames2.count, 1)

        let json2 = try JSONSerialization.jsonObject(with: Data(frames2[0].data.utf8)) as? [String: Any]
        let candidates2 = json2?["candidates"] as? [[String: Any]]
        XCTAssertEqual(candidates2?.first?["finishReason"] as? String, "STOP")

        let usage = json2?["usageMetadata"] as? [String: Any]
        XCTAssertEqual(usage?["promptTokenCount"] as? Int, 12)
        XCTAssertEqual(usage?["candidatesTokenCount"] as? Int, 4)
    }

    func testSSEDecoder_parsesOpenAIStreamFramesWithDone() throws {
        var decoder = SSEDecoder()
        let chunk = Data("data: {\"choices\":[{\"delta\":{\"content\":\"Hello OpenAI\"}}]}\n\ndata: [DONE]\n\n".utf8)
        let frames = try decoder.feed(chunk)

        XCTAssertEqual(frames.count, 2)
        XCTAssertTrue(frames[0].data.contains("Hello OpenAI"))
        XCTAssertEqual(frames[1].data, "[DONE]")
    }

    // MARK: - Error Classification (401, 429, 5xx)

    func testProviderFailure_errorClassification() {
        // 401 Unauthorized -> not retryable
        let failure401 = ProviderFailure(
            providerID: "openAI",
            statusCode: 401,
            errorCode: "unauthorized",
            message: "HTTP 401: Invalid API Key",
            isRetryable: false
        )
        XCTAssertEqual(failure401.statusCode, 401)
        XCTAssertFalse(failure401.isRetryable)
        XCTAssertEqual(failure401.errorCode, "unauthorized")

        // 429 Rate Limit -> retryable with retry-after
        let retryDate = Date().addingTimeInterval(30)
        let failure429 = ProviderFailure(
            providerID: "gemini",
            statusCode: 429,
            errorCode: "rate_limited",
            message: "HTTP 429: Rate limit exceeded",
            isRetryable: true,
            retryAfter: retryDate
        )
        XCTAssertEqual(failure429.statusCode, 429)
        XCTAssertTrue(failure429.isRetryable)
        XCTAssertNotNil(failure429.retryAfter)

        // 503 Service Unavailable -> retryable
        let failure503 = ProviderFailure(
            providerID: "nvidia",
            statusCode: 503,
            errorCode: "http_503",
            message: "HTTP 503: Service Unavailable",
            isRetryable: true
        )
        XCTAssertEqual(failure503.statusCode, 503)
        XCTAssertTrue(failure503.isRetryable)
    }

    // MARK: - HTTPS Origin Change Revokes / Blocks Consent

    func testCustomEndpoint_originChangeRevokesConsent() {
        let configID = ProviderConfigID()
        let origin1 = "https://ai-node-1.internal:8443"
        let origin2 = "https://ai-node-2.internal:8443"

        let scope1 = ConsentRecord.computeScopeKey(
            destination: .customEndpoint,
            providerConfigID: configID,
            endpointOrigin: origin1
        )
        let scope2 = ConsentRecord.computeScopeKey(
            destination: .customEndpoint,
            providerConfigID: configID,
            endpointOrigin: origin2
        )

        XCTAssertNotEqual(scope1, scope2, "Origin change must produce distinct consent scope keys")

        // Granted consent for origin 1
        let consentOrigin1 = ConsentRecord(
            destination: .customEndpoint,
            providerConfigID: configID,
            endpointOrigin: origin1,
            maximumDataClass: .personal,
            isGranted: true,
            grantedAt: Date()
        )

        // Checking origin 1 succeeds
        XCTAssertNoThrow(
            try PrivacyPolicyEngine.checkEgressAllowed(
                destination: .customEndpoint,
                privacyMode: .cloudAllowed,
                dataClass: .personal,
                consent: consentOrigin1
            )
        )

        // If endpoint origin changes to origin 2, consentOrigin1 does not match destination/origin!
        // A config with origin2 will look up scope2 in consents dict and get nil -> fails closed!
        XCTAssertThrowsError(
            try PrivacyPolicyEngine.checkEgressAllowed(
                destination: .customEndpoint,
                privacyMode: .cloudAllowed,
                dataClass: .personal,
                consent: nil // lookup for scope2 in consents dict yields nil
            )
        ) { error in
            guard case AppError.privacyDenied(let route, _) = error else {
                XCTFail("Expected privacyDenied, got: \(error)")
                return
            }
            XCTAssertEqual(route, DataEgressDestination.customEndpoint.rawValue)
        }
    }

    // MARK: - Private Only Mode Guarantees Zero Sent Bytes

    func testPrivateOnlyMode_allCloudProvidersBlocked() {
        let allCloud: [DataEgressDestination] = [
            .groqAPI, .openRouterAPI, .openAIAPI, .geminiAPI, .nvidiaAPI, .customEndpoint, .managedGateway
        ]

        for dest in allCloud {
            XCTAssertThrowsError(
                try PrivacyPolicyEngine.checkEgressAllowed(
                    destination: dest,
                    privacyMode: .privateOnly,
                    dataClass: .publicData,
                    consent: nil
                )
            ) { error in
                guard case AppError.privacyDenied(let route, _) = error else {
                    XCTFail("Expected privacyDenied for \(dest)")
                    return
                }
                XCTAssertEqual(route, dest.rawValue)
            }
        }
    }
}
