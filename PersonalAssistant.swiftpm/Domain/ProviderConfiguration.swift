// Domain/ProviderConfiguration.swift
// Provider and model configuration domain types.
// No networking or SwiftData imports.

import Foundation

// MARK: - Provider configuration

/// V3 §Stable business entities — ProviderConfig.
/// API key is a KEYCHAIN reference only — never stored in this struct.
struct ProviderConfiguration: Identifiable, Codable, Sendable, Hashable {
    let id: ProviderConfigID
    let ownerID: UserID
    let providerKind: ProviderKind
    var displayName: String
    var baseURL: URL?
    var catalogURL: URL?
    /// Keychain lookup key (not the secret itself).
    var keychainKey: String
    var isEnabled: Bool
    var budgetLimitUSD: Decimal?
    var modelOverride: String?
    var catalogTTLSeconds: Int
    let createdAt: Date
    var updatedAt: Date

    init(
        id: ProviderConfigID = ProviderConfigID(),
        ownerID: UserID,
        providerKind: ProviderKind,
        displayName: String,
        baseURL: URL? = nil,
        catalogURL: URL? = nil,
        keychainKey: String,
        isEnabled: Bool = false,
        budgetLimitUSD: Decimal? = nil,
        modelOverride: String? = nil,
        catalogTTLSeconds: Int = 86400,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.ownerID = ownerID
        self.providerKind = providerKind
        self.displayName = displayName
        self.baseURL = baseURL
        self.catalogURL = catalogURL
        self.keychainKey = keychainKey
        self.isEnabled = isEnabled
        self.budgetLimitUSD = budgetLimitUSD
        self.modelOverride = modelOverride
        self.catalogTTLSeconds = catalogTTLSeconds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Provider kind

enum ProviderKind: String, Codable, Sendable, Hashable, CaseIterable {
    case groq
    case openRouter
    case custom            // user-specified OpenAI-compatible endpoint
    case appleFoundation   // COND — gated at runtime
    case managedGateway    // NEXT — not V1
}

// MARK: - Model descriptor

/// V3 §Canonical AI request/response — ModelDescriptor.
struct ModelDescriptor: Identifiable, Codable, Sendable, Hashable {
    let id: String            // provider model ID (e.g. "llama3-8b-8192")
    let providerID: String    // ProviderConfigID.rawValue.uuidString
    let displayName: String
    let capabilities: ModelCapabilitySet
    let contextLimit: Int?
    var available: Bool?      // nil = unknown (fails if required)
    var verifiedAt: Date?
}

// MARK: - Capability set

/// Tri-state capability: .yes/.no/.unknown — unknown fails if capability is required (I11).
enum CapabilityValue: String, Codable, Sendable, Hashable, CaseIterable {
    case yes
    case no
    case unknown
}

struct ModelCapabilitySet: Codable, Sendable, Hashable {
    var textChat: CapabilityValue
    var tools: CapabilityValue
    var vision: CapabilityValue
    var streaming: CapabilityValue
    var jsonMode: CapabilityValue

    init(
        textChat: CapabilityValue = .yes,
        tools: CapabilityValue = .unknown,
        vision: CapabilityValue = .unknown,
        streaming: CapabilityValue = .unknown,
        jsonMode: CapabilityValue = .unknown
    ) {
        self.textChat = textChat
        self.tools = tools
        self.vision = vision
        self.streaming = streaming
        self.jsonMode = jsonMode
    }
}

// MARK: - Capability requirements

/// V3 §Canonical AI request/response — CapabilityRequirements.
struct CapabilityRequirements: Codable, Sendable, Hashable {
    var needsVision: Bool
    var needsTools: Bool
    var needsJSON: Bool
    var minimumContextTokens: Int
    var allowedPrivacy: PrivacyClass

    init(
        needsVision: Bool = false,
        needsTools: Bool = false,
        needsJSON: Bool = false,
        minimumContextTokens: Int = 0,
        allowedPrivacy: PrivacyClass = .personal
    ) {
        self.needsVision = needsVision
        self.needsTools = needsTools
        self.needsJSON = needsJSON
        self.minimumContextTokens = minimumContextTokens
        self.allowedPrivacy = allowedPrivacy
    }
}

// MARK: - Usage estimate

struct UsageEstimate: Codable, Sendable, Hashable {
    let traceID: TraceID
    let providerID: String
    let modelID: String
    let inputTokens: Int?
    let outputTokens: Int?
    /// Estimated, not guaranteed — advisory only per A16.
    let estimatedCostUSD: Decimal?
    let isActual: Bool  // true only when authoritative usage from provider
    let recordedAt: Date
}

// MARK: - Budget status

struct BudgetStatus: Sendable {
    let limitUSD: Decimal?
    let estimatedSpentUSD: Decimal
    let isAdvisory: Bool  // always true for client-side budget per A16
    let isExceeded: Bool
}
