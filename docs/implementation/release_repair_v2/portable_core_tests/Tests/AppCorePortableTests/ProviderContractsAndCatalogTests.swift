import Foundation
import XCTest
@testable import AppCorePortable

final class ProviderContractsAndCatalogTests: XCTestCase {

    // MARK: - Provider Kind & Egress Destinations Mapping

    func testProviderKind_allDestinationsMappedCorrectly() {
        XCTAssertEqual(ProviderKind.groq.egressDestination, .groqAPI)
        XCTAssertEqual(ProviderKind.openRouter.egressDestination, .openRouterAPI)
        XCTAssertEqual(ProviderKind.custom.egressDestination, .customEndpoint)
        XCTAssertEqual(ProviderKind.appleFoundation.egressDestination, .appleFoundationModel)
        XCTAssertEqual(ProviderKind.managedGateway.egressDestination, .managedGateway)
        XCTAssertEqual(ProviderKind.openAI.egressDestination, .openAIAPI)
        XCTAssertEqual(ProviderKind.gemini.egressDestination, .geminiAPI)
        XCTAssertEqual(ProviderKind.nvidia.egressDestination, .nvidiaAPI)
    }

    // MARK: - Privacy Policy Engine Egress Enforcement for New Providers

    func testPrivacyPolicyEngine_blocksNewProvidersInPrivateOnly() {
        let newDestinations: [DataEgressDestination] = [.openAIAPI, .geminiAPI, .nvidiaAPI]
        for dest in newDestinations {
            XCTAssertThrowsError(
                try PrivacyPolicyEngine.checkEgressAllowed(
                    destination: dest,
                    privacyMode: .privateOnly,
                    dataClass: .personal,
                    consent: nil
                ),
                "Destination \(dest) must be blocked in privateOnly mode"
            ) { error in
                guard case AppError.privacyDenied(let route, _) = error else {
                    XCTFail("Expected privacyDenied, got: \(error)")
                    return
                }
                XCTAssertEqual(route, dest.rawValue)
            }
        }
    }

    func testPrivacyPolicyEngine_requiresExplicitConsentForNewProviders() {
        let newDestinations: [DataEgressDestination] = [.openAIAPI, .geminiAPI, .nvidiaAPI]
        for dest in newDestinations {
            // cloudAllowed without consent -> must throw privacyDenied
            XCTAssertThrowsError(
                try PrivacyPolicyEngine.checkEgressAllowed(
                    destination: dest,
                    privacyMode: .cloudAllowed,
                    dataClass: .personal,
                    consent: nil
                )
            ) { error in
                guard case AppError.privacyDenied(let route, _) = error else {
                    XCTFail("Expected privacyDenied, got: \(error)")
                    return
                }
                XCTAssertEqual(route, dest.rawValue)
            }

            // cloudAllowed with explicit granted consent -> succeeds
            let consent = ConsentRecord(
                destination: dest,
                maximumDataClass: .personal,
                isGranted: true,
                grantedAt: Date()
            )
            XCTAssertNoThrow(
                try PrivacyPolicyEngine.checkEgressAllowed(
                    destination: dest,
                    privacyMode: .cloudAllowed,
                    dataClass: .personal,
                    consent: consent
                )
            )
        }
    }

    // MARK: - API Key Validation (ChatGPT Plus / Gemini Advanced Consumer Rejection)

    func testAPIKeyValidator_rejectsEmptyOrWhitespace() {
        let emptyResult = ProviderAPIKeyValidator.validate(key: "", for: .openAI)
        XCTAssertEqual(emptyResult, .failure(.empty))

        let whitespaceResult = ProviderAPIKeyValidator.validate(key: "   \n\t  ", for: .gemini)
        XCTAssertEqual(whitespaceResult, .failure(.empty))

        let keyWithSpaces = ProviderAPIKeyValidator.validate(key: "sk-123 456", for: .openAI)
        XCTAssertEqual(keyWithSpaces, .failure(.containsWhitespace))
    }

    func testAPIKeyValidator_rejectsConsumerSubscriptionAccounts() {
        let chatgptPlusKey = ProviderAPIKeyValidator.validate(key: "chatgpt-plus-subscription", for: .openAI)
        guard case .failure(.consumerSubscriptionMistake(let prov, _)) = chatgptPlusKey else {
            XCTFail("Expected consumerSubscriptionMistake for ChatGPT Plus")
            return
        }
        XCTAssertEqual(prov, "OpenAI")

        let userEmail = ProviderAPIKeyValidator.validate(key: "developer@example.com", for: .openAI)
        guard case .failure(.consumerSubscriptionMistake) = userEmail else {
            XCTFail("Expected consumerSubscriptionMistake for email address")
            return
        }

        let geminiAdvanced = ProviderAPIKeyValidator.validate(key: "gemini-advanced-subscriber", for: .gemini)
        guard case .failure(.consumerSubscriptionMistake(let prov, _)) = geminiAdvanced else {
            XCTFail("Expected consumerSubscriptionMistake for Gemini Advanced")
            return
        }
        XCTAssertEqual(prov, "Google Gemini")
    }

    func testAPIKeyValidator_enforcesPrefixPerProvider() {
        // OpenAI requires sk-
        XCTAssertEqual(
            ProviderAPIKeyValidator.validate(key: "invalid-key-prefix", for: .openAI),
            .failure(.invalidFormat(provider: "OpenAI", expectedPrefix: "sk-"))
        )
        XCTAssertEqual(
            ProviderAPIKeyValidator.validate(key: "sk-proj-valid-openai-key-123", for: .openAI),
            .success("sk-proj-valid-openai-key-123")
        )

        // Gemini requires AIzaSy
        XCTAssertEqual(
            ProviderAPIKeyValidator.validate(key: "sk-12345", for: .gemini),
            .failure(.invalidFormat(provider: "Gemini", expectedPrefix: "AIzaSy"))
        )
        XCTAssertEqual(
            ProviderAPIKeyValidator.validate(key: "AIzaSyValidGeminiKeyABC123", for: .gemini),
            .success("AIzaSyValidGeminiKeyABC123")
        )

        // Groq requires gsk_
        XCTAssertEqual(
            ProviderAPIKeyValidator.validate(key: "gsk_valid_groq_key_999", for: .groq),
            .success("gsk_valid_groq_key_999")
        )

        // OpenRouter requires sk-or-
        XCTAssertEqual(
            ProviderAPIKeyValidator.validate(key: "sk-or-v1-abc1234", for: .openRouter),
            .success("sk-or-v1-abc1234")
        )

        // NVIDIA NIM requires nvapi-
        XCTAssertEqual(
            ProviderAPIKeyValidator.validate(key: "nvapi-valid-nim-key-xyz", for: .nvidia),
            .success("nvapi-valid-nim-key-xyz")
        )
    }

    // MARK: - Model Catalog Client TTL Cache & Stale Fallback

    func testModelCatalogClient_cachedModels_respectsTTL() async {
        let client = ModelCatalogClient()
        let now = Date()
        let testModels = [
            ModelDescriptor(
                id: "test-model-1",
                providerID: "test",
                displayName: "Test Model 1",
                capabilities: ModelCapabilitySet(),
                contextLimit: 4096,
                available: true,
                verifiedAt: now
            )
        ]

        // Populate with 10s TTL
        await client.updateCache(providerID: "test", models: testModels, ttlSeconds: 10, cachedAt: now)

        // At +5s -> fresh, returns models
        let freshResult = await client.cachedModels(providerID: "test", allowStale: false, now: now.addingTimeInterval(5))
        XCTAssertNotNil(freshResult)
        XCTAssertEqual(freshResult?.count, 1)
        XCTAssertEqual(freshResult?.first?.id, "test-model-1")

        // At +15s -> stale, cachedModels without allowStale returns nil
        let expiredResult = await client.cachedModels(providerID: "test", allowStale: false, now: now.addingTimeInterval(15))
        XCTAssertNil(expiredResult, "Stale cache must return nil when allowStale is false")

        // At +15s with allowStale: true -> returns stale models
        let staleResult = await client.cachedModels(providerID: "test", allowStale: true, now: now.addingTimeInterval(15))
        XCTAssertNotNil(staleResult, "Stale cache must be returned when allowStale is true")
        XCTAssertEqual(staleResult?.first?.id, "test-model-1")
    }

    func testModelCatalogClient_loadBundledFallbackCatalog() {
        let catalog = ModelCatalogClient.loadBundledCatalog()
        XCTAssertFalse(catalog.isEmpty)
        XCTAssertNotNil(catalog["groq"])
        XCTAssertNotNil(catalog["openRouter"])
        XCTAssertNotNil(catalog["openAI"])
        XCTAssertNotNil(catalog["gemini"])
        XCTAssertNotNil(catalog["nvidia"])
        XCTAssertNotNil(catalog["appleFoundationModels"])

        // Check OpenAI models
        let openaiModels = catalog["openAI"] ?? []
        XCTAssertTrue(openaiModels.contains { $0.id == "gpt-4o-mini" })
        XCTAssertTrue(openaiModels.contains { $0.id == "gpt-4o" })

        // Check Gemini models
        let geminiModels = catalog["gemini"] ?? []
        XCTAssertTrue(geminiModels.contains { $0.id == "gemini-2.0-flash" })

        // Check NVIDIA models
        let nvidiaModels = catalog["nvidia"] ?? []
        XCTAssertTrue(nvidiaModels.contains { $0.id == "meta/llama-3.3-70b-instruct" })
    }

    // MARK: - Apple Foundation Model Truthful Reporting

    func testAppleFoundationModelProvider_truthfulCapability() async {
        let provider = AppleFoundationModelProvider()
        let models = try? await provider.models()
        XCTAssertNotNil(models)
        XCTAssertEqual(models?.count, 1)

        let desc = models?.first
        XCTAssertEqual(desc?.id, "apple-intelligence-on-device")

        #if arch(arm64) && !targetEnvironment(simulator) && (os(iOS) || os(macOS))
        // On physical Apple Silicon hardware running supported OS
        #else
        // In Linux x86_64 host test environment: must honestly report unavailable
        XCTAssertEqual(desc?.available, false, "Must report available: false on unsupported platforms/simulators")
        #endif
    }

    // MARK: - Two Owners Keychain Isolation

    func testTwoOwners_isolatedSecrets() async throws {
        let backend = SimulatedKeychainBackend()
        let vault = KeychainVault(backend: backend)
        let owner1 = UserID()
        let owner2 = UserID()

        try await vault.setSecret(ownerID: owner1, providerID: "openAI", value: "sk-owner1-secret")
        try await vault.setSecret(ownerID: owner2, providerID: "openAI", value: "sk-owner2-secret")

        let read1 = try await vault.copySecret(ownerID: owner1, providerID: "openAI")
        let read2 = try await vault.copySecret(ownerID: owner2, providerID: "openAI")

        XCTAssertEqual(read1, "sk-owner1-secret")
        XCTAssertEqual(read2, "sk-owner2-secret")

        // Wipe owner 1
        try await vault.removeAll(ownerID: owner1)

        // Owner 1 should not have secret
        let hasSecret1 = await vault.hasSecret(ownerID: owner1, providerID: "openAI")
        XCTAssertFalse(hasSecret1)

        // Owner 2 must remain completely intact
        let hasSecret2 = await vault.hasSecret(ownerID: owner2, providerID: "openAI")
        XCTAssertTrue(hasSecret2)
        let read2After = try await vault.copySecret(ownerID: owner2, providerID: "openAI")
        XCTAssertEqual(read2After, "sk-owner2-secret")
    }
}
