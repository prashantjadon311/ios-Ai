# 02 — Canonical types, interfaces, concurrency and invariants

This document is a design-level Swift coding contract. Signatures may need mechanical spelling corrections against the actual installed SDK during W00; semantic input/output and policy invariants are frozen. Most domain types must conform to `Sendable` and `Codable` when persisted/transferred. Never encode executable closures or Keychain secret bytes in DTOs.

## Strong identity and session
```swift
struct UserID: RawRepresentable, Hashable, Codable, Sendable { let rawValue: UUID }
struct AssistantID: RawRepresentable, Hashable, Codable, Sendable { let rawValue: UUID }
struct ConversationID: RawRepresentable, Hashable, Codable, Sendable { let rawValue: UUID }
struct TraceID: RawRepresentable, Hashable, Codable, Sendable { let rawValue: UUID }
struct SessionToken: Sendable, Equatable { let userID: UserID; let generation: UUID }
```
`SessionGuard.require(token:)` checks both owner and generation; every repository query requires an explicit `UserID` and every asynchronous write/Tool action revalidates current session before acting. Switching account cancels old user work and changes generation BEFORE exposing new data. Never derive server authorization from a client owner ID.

## Canonical AI request/response
```swift
enum PrivacyClass: Int, Codable, Sendable { case publicData=0, personal=1, sensitive=2, secret=3 }
struct CapabilityRequirements: Codable, Sendable {
    var needsVision: Bool; var needsTools: Bool; var needsJSON: Bool
    var minimumContextTokens: Int; var allowedPrivacy: PrivacyClass
}
struct ModelDescriptor: Identifiable, Codable, Sendable {
    let id: String; let providerID: String; let capabilities: CapabilitySet
    let contextLimit: Int?; let available: Bool?; let verifiedAt: Date?
}
struct AssistantRequest: Sendable {
    let traceID: TraceID; let owner: UserID; let conversationID: ConversationID
    let messages: [ContextMessage]; let requirements: CapabilityRequirements
    let responseLimit: Int; let allowedTools: [ToolDefinition]; let session: SessionToken
}
enum AssistantEvent: Sendable {
    case started(modelID: String)
    case textDelta(String, sequence: Int)
    case toolProposal(ToolProposal)
    case usage(input: Int?, output: Int?, estimatedCost: Decimal?)
    case completed(finishReason: String)
    case failed(ProviderFailure)
}
protocol AssistantModel: Sendable {
    var providerID: String { get }
    func models() async throws -> [ModelDescriptor]
    func stream(_ request: AssistantRequest) async throws -> AsyncThrowingStream<AssistantEvent, Error>
}
```
Use numeric capability tri-state `.yes/.no/.unknown`, **unknown fails required capability**. `allowedPrivacy` represents permitted maximum disclosure for the chosen route; do not compare string descriptions. Provider `available` unknown does not equal confirmed Apple device support.

## Streaming contract
Each user turn owns one `traceID` and at most one final visible completion. Content deltas are monotonically ordered per stream. Tool calls have `providerCallID`, `toolName`, `schemaVersion`, `argumentsData` and source trust metadata; they are merely *proposals*. A `reasoningSummary` event is permitted ONLY if provider offers an explicitly user-visible safe summary; never store or expose private chain of thought or provider debugging traces. Preserve raw tool proposal ONLY in redacted diagnostic data, not automatic user-facing text.

## Context contract
```swift
struct ContextMessage: Codable, Sendable {
  let role: ContextRole; let parts: [ContentPart]
  let source: ContextSource; let sensitivity: PrivacyClass
}
struct ContextPacket: Sendable {
  let messages: [ContextMessage]; let estimatedInputTokens: Int
  let sourceIDs: [UUID]; let selectedMemoryRevisions: [UUID]
}
```
Ordering: trusted policy + explicit user instruction + permitted recent history + separately tagged memories + untrusted document/tool text. Untrusted content is *never* reclassified as higher-priority instructions. Secret values and irrelevant personal details are excluded before provider routing.

## Typed tools and approval
```swift
struct ToolProposal: Codable, Sendable {
    let invocationID: UUID; let toolID: String; let schemaVersion: Int
    let argumentsJSON: Data; let traceID: TraceID; let sourceIDs: [UUID]
}
enum ToolDecision: Sendable { case deny(reason: String), ask(ApprovalRequest), permit(AuthorizedToolCall) }
enum ToolReceiptStatus: Codable, Sendable { case prepared, succeeded, failed, ambiguous }
struct ToolReceipt: Codable, Sendable {
    let invocationID: UUID; let operationKey: String; let status: ToolReceiptStatus
    let externalReference: String?; let redactedResult: String?
}
protocol ToolExecutor: Sendable {
    var toolID: String { get }
    func run(_ call: AuthorizedToolCall) async throws -> ToolReceipt
}
```
Approval hash: `SHA256(toolID || schemaVersion || canonicalJSON(arguments) || ownerID || relevantDataClass || destination)`; store creation and expiry, single-use permission, revoked when payload differs. Parameter schema rejects unknown fields; typed executor rechecks session, permission and budget after approval and immediately before side effect. Each attempted side effect saves PREPARED receipt *before* invocation; ambiguous network outcome remains AMBIGUOUS and never silently replays.

## Task state machine
`TaskDefinition` (mutable only through revisioned edits) and `TaskRun` (immutable occurrence identity, mutable guarded status) are distinct. States:
- `queued -> running|cancelled`
- `running -> waitingApproval|waitingNetwork|completed|failed|cancelRequested|interrupted`
- `waitingApproval -> queued|cancelled|failed`
- `waitingNetwork -> queued|cancelled`
- `cancelRequested -> cancelled|completed|failed|ambiguous`
- `interrupted -> queued` only if no unresolved external side effect; otherwise `needsReview`
- terminal: `completed|failed|cancelled|ambiguous`; retries create new *attempt* and preserve old receipt.
Persistent occurrence key `taskID + definitionRevision + scheduledLocalOccurrenceUniqueID`; notifications have their own stable ID. Local notification delivery != execution of arbitrary AI work.

## Persistence placement
`Persistence/StoreModels.swift` is sole owner of SwiftData `@Model` class declarations; `Persistence/SchemaV1.swift` has only `VersionedSchema.models` listing these types. Mapping to immutable Sendable domain records occurs in `StoreMappers.swift`. Never cross actor boundaries with `ModelContext` or managed model objects. Any write requires explicit owner predicate and full session recheck. Atomic transaction interface is actor-confined; no distributed transaction promise across iOS APIs.

## Voice
`VoiceSessionID` increments every start/restart and stale transcript callbacks are rejected. Allowed states: idle, requestingPermission, listening, transcribing, thinking, acting, speaking, stopped, error. No wake-word service. Voice output may be interrupted; microphone remains off unless a user gesture explicitly starts it. Cloud STT opt-in is separate from consent to use cloud LLMs.

## Error and result policy
Typed errors: `notAuthenticated`, `sessionChanged`, `permissionDenied`, `unsupportedCapability`, `noEligibleModel`, `rateLimited(retryAfter)`, `providerAuthInvalid`, `providerTransient`, `privacyDenied`, `budgetExceeded`, `validationFailed`, `interrupted`, `sideEffectAmbiguous`, `storageRecoveryRequired`. Views render actionable recovery; logs redact content, tokens and user personal data.

## Service ownership
`@MainActor`: `AppSession`, UI view models, avatar UI state and navigation. Actors: `IntelligenceRouter`, `ProviderHealthActor`, `ProviderBudgetActor`, `TaskEngineActor`, persisted write coordinator. Prefer `AsyncThrowingStream` for network/AI events and cancellation. `AppContainer` constructs real or injected fake services exactly once; view constructors receive protocols/view models. Protocols for sync/backup/managed gateway exist as separate future targets, not misleading V1 live controls.
