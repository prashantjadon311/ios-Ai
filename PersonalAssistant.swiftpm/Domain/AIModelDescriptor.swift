// Domain/AIModelDescriptor.swift
// AssistantEvent, AssistantRequest, AssistantModel protocol — canonical AI contract.
// Per V3 §Canonical AI request/response and §AI/Contracts.

import Foundation

// MARK: - AssistantRequest

/// V3 §Canonical AI request/response — AssistantRequest.
struct AssistantRequest: Sendable {
    let traceID: TraceID
    let owner: UserID
    let conversationID: ConversationID
    let messages: [ContextMessage]
    let requirements: CapabilityRequirements
    let responseLimit: Int
    let allowedTools: [ToolDefinition]
    let session: SessionToken

    init(
        traceID: TraceID,
        owner: UserID,
        conversationID: ConversationID,
        messages: [ContextMessage],
        requirements: CapabilityRequirements,
        responseLimit: Int = 2048,
        allowedTools: [ToolDefinition] = [],
        session: SessionToken
    ) {
        self.traceID = traceID
        self.owner = owner
        self.conversationID = conversationID
        self.messages = messages
        self.requirements = requirements
        self.responseLimit = responseLimit
        self.allowedTools = allowedTools
        self.session = session
    }
}

// MARK: - Tool definition (schema for the provider)

struct ToolDefinition: Codable, Sendable, Hashable {
    let toolID: String
    let schemaVersion: Int
    let name: String
    let description: String
    let parameterSchema: Data   // JSON Schema bytes
    let riskLevel: ToolRiskLevel
    let requiresApproval: Bool

    init(
        toolID: String,
        schemaVersion: Int,
        name: String,
        description: String,
        parameterSchema: Data,
        riskLevel: ToolRiskLevel,
        requiresApproval: Bool
    ) {
        self.toolID = toolID
        self.schemaVersion = schemaVersion
        self.name = name
        self.description = description
        self.parameterSchema = parameterSchema
        self.riskLevel = riskLevel
        self.requiresApproval = requiresApproval
    }
}

// MARK: - AssistantEvent

/// V3 §Canonical AI request/response — AssistantEvent.
/// Streaming events emitted from AssistantModel.stream().
enum AssistantEvent: Sendable {
    case started(modelID: String)
    case textDelta(String, sequence: Int)   // monotonically ordered
    case toolProposal(ToolProposal)
    case usage(input: Int?, output: Int?, estimatedCost: Decimal?)
    case completed(finishReason: String)
    case failed(ProviderFailure)
}

// MARK: - TurnUIEvent (orchestrator → Chat view)

/// Events emitted by AssistantOrchestrator to the Chat view model.
enum TurnUIEvent: Sendable {
    case started(traceID: TraceID, modelID: String)
    case textDelta(String, sequence: Int)
    case toolProposalPending(ApprovalRequest)
    case usageUpdate(UsageEstimate)
    case completed(traceID: TraceID, finishReason: String)
    case interrupted(traceID: TraceID, reason: String)
    case failed(traceID: TraceID, error: AppError)
}

// MARK: - AssistantModel protocol

/// V3 §Canonical AI request/response — AssistantModel.
/// Sendable because provider instances are shared across actor boundaries.
protocol AssistantModel: Sendable {
    var providerID: String { get }
    func models() async throws -> [ModelDescriptor]
    func stream(_ request: AssistantRequest) async throws -> AsyncThrowingStream<AssistantEvent, Error>
}

// MARK: - Feature decision (from CapabilityCenter)

struct FeatureDecision: Sendable {
    let isAvailable: Bool
    let reason: String?
    let requiredAction: String?

    static let unavailable = FeatureDecision(isAvailable: false, reason: "Not available", requiredAction: nil)
    static let available = FeatureDecision(isAvailable: true, reason: nil, requiredAction: nil)

    init(isAvailable: Bool, reason: String? = nil, requiredAction: String? = nil) {
        self.isAvailable = isAvailable
        self.reason = reason
        self.requiredAction = requiredAction
    }
}

// MARK: - Capability snapshot

struct CapabilitySnapshot: Sendable {
    var speechRecognitionLocales: [String]
    var hasNotificationPermission: Bool
    var hasCalendarPermission: Bool
    var hasContactsPermission: Bool
    var hasPhotoPermission: Bool
    var hasMicrophonePermission: Bool
    var networkAvailable: Bool
    var foundationModelsAvailable: Bool  // COND, runtime checked
    var providerHealthMap: [String: Bool]
    let capturedAt: Date

    init() {
        speechRecognitionLocales = []
        hasNotificationPermission = false
        hasCalendarPermission = false
        hasContactsPermission = false
        hasPhotoPermission = false
        hasMicrophonePermission = false
        networkAvailable = false
        foundationModelsAvailable = false
        providerHealthMap = [:]
        capturedAt = Date()
    }
}
