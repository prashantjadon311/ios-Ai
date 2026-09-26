# ios-Ai V1 — Exact File-Level Repair Blueprint, Contracts and Algorithms

**Purpose:** A senior-engineer implementation specification for Gemini. It is deliberately more concrete than an instruction to “fix tests.” Every significant repair identifies actual files, source-level root cause, intended code/data flow, a reference code shape or pseudocode, negative tests and a gate. This blueprint targets immutable GitHub commit `b34423ec90f705f129d567300a3cbc534f7559e7`. First reconcile a potentially newer local HEAD; never overwrite a valid unpublished fix.  
**IMPORTANT:** Swift fragments below are **reference implementations/typed pseudocode**, not a certified drop-in patch. Validate actual project declarations and SDK signatures with an Apple compiler before claiming build success. Keep `PersonalAssistant.swiftpm/Package.swift` the genuine Playgrounds-generated base.  
**Authority:** V3 `00`, `12`, `13`, `14`, `15` outrank this corrective packet if there is a documented conflict. The separate `00_DOUBLE_PASS_ENGINEERING_AUDIT.md` enumerates defects and independent acceptance checks.

## 0. The coherent product Gemini must finish

- Local-first iPhone/iPad SwiftUI app with five primary routes: Dashboard, Tasks, History, Configuration, Settings. Supporting real Chat, approval, assistant profile, provider, memory, task editor/detail, voice, permission and diagnostics screens.
- Distinct independently renameable Maya/Saar **assistant profiles**, not fictitious independent authenticated multi-person accounts. Persist voice/locale/style/model preferences per profile, but owner/session isolation for all stored data. Additional cloud family accounts, Firestore sync, Google Drive restore and Small AI inference remain FUTURE under canonical V3.
- Actual user-supplied-key Groq/OpenRouter/custom OpenAI-compatible streaming; no invented provider replies, unverified model IDs, silent tool execution or disguised offline cloud inference.
- User-visible privacy/consent, Keychain, persisted conversation/history/memory/tasks, bounded context and accurate budget notices; executable approved local tools and real scheduled **notifications** (not guaranteed background AI processing).
- Runtime conditional modern Apple APIs; actual supported legacy Speech/AVSpeechSynthesizer; iPad verification supplied by the human user; iPhone separate distribution test.

## 1. Immediate source reconciliation and compiler repair (R0/R1)

**R0:** `git rev-parse --show-toplevel`, `git status --porcelain=v1`, `git rev-parse HEAD`, `git fetch origin main` where authorized, compare against `b34423ec`, inspect untracked files, preserve user modifications, register all existing fixes in `docs/implementation/DEFECT_REGISTER.md`. Snapshot source tree SHA and existing app data fixture. Do not run bulk regeneration scripts. Verify `python3 docs/spec/v3/20_VALIDATE_HANDOFF.py` as *documentation-only*.

**R1.1 — composition + router: concrete source mismatch.**

Files: `App/AppContainer.swift`, `AI/Routing/ModelRouter.swift`, `AI/Providers/OpenAICompatibleProvider.swift`, `Domain/ProviderConfiguration.swift`, `Domain/AIModelDescriptor.swift`, `Security/KeychainVault.swift`, `Persistence/ConfigurationRepository.swift`.

- The constructor call site is `ModelRouter(keychainVault: vault, initialProviders: initialProviders)`, while the existing router only declares `init(keychainVault:)`. The orchestrator calls `route(...privacyMode:)`, which does not exist. **Do not make these compile by deleting privacy from the caller.** Implement one consistent router contract with `privacyMode` and explicit per-owner, per-provider config/credentials.
- `providers[provider.providerID]` registers `groq` / `openRouter`, while `providers[config.id.rawValue.uuidString]` looks up UUIDs. Use one canonical identity. Recommended: registry keyed by `ProviderKind.rawValue` for built-in adapters; custom providers require a per-configuration UUID registry/factory. Keep `ProviderConfigID` separate from provider kind; preserve custom endpoint uniqueness.
- An ownerless `OpenAICompatibleProvider` returns `[]` from `models()`. Either construct a provider bound to the active owner/config (and invalidate on switch) or give model/catalog requests explicit owner context via a new versioned interface; update *all* callers. Never treat a random default model string as verified available.
- Keys: `KeychainVault` uses `(bundleID, localOwnerUUID, providerID, purpose)`. Persist and resolve the same `providerID` **at setup and dispatch**; do not save under `groq` then look up a UUID. Use `await` for actor methods.

**Reference contract (adapt to verified declaration and Swift 6 isolation):**

```swift
actor ModelRouter {
    private let vault: KeychainVault
    private var builtIns: [ProviderKind: any AssistantModel]
    private var customByConfigID: [ProviderConfigID: any AssistantModel] = [:]

    init(vault: KeychainVault, initialProviders: [any AssistantModel]) {
        self.vault = vault
        // Validate unique provider IDs, map known built-ins by their declared kind.
        // Never silently overwrite duplicated IDs.
    }

    func route(
        requirements: CapabilityRequirements,
        ownerID: UserID,
        configs: [ProviderConfiguration],
        privacyMode: PrivacyMode,
        consents: [DataEgressDestination: ConsentRecord]
    ) async -> RoutingResult {
        // (1) privateOnly => no network provider, unless a proven eligible LOCAL adapter.
        // (2) ownerID == config.ownerID; config.isEnabled; valid approved HTTPS endpoint.
        // (3) explicit consent for destination and input PrivacyClass.
        // (4) await vault.hasSecret(ownerID:providerID:) using the SAME key as save.
        // (5) verified model ID, health, context window, tools/vision/json/stream requirements.
        //     UNKNOWN capability fails when required; do not silently remove features.
        // (6) budgets/preference order. Return .noneEligible(reason:) otherwise.
    }
}
```

**A Swift compiler will reject a synchronous actor method calling `vault.hasSecret(...)` without `await`.** `ModelDescriptor.capabilities` uses tri-state `CapabilityValue`; implement positive matching (`.yes`) for required features and verify `contextLimit >= requirements.minimumContextTokens`. A base URL should be built per approved config and never derived from untrusted model output. Preserve model catalog TTL and indicate when catalog assertions are unverified. Network health `unknown` is not the same as known healthy.

**R1.2 — exact DTO compilation reconciliation.**

Files: `Domain/ApprovalRequest.swift`, `Domain/Errors.swift`, `AI/Routing/AssistantOrchestrator.swift`, `Domain/ProviderConfiguration.swift`, `Features/Configuration/ProviderDetailView.swift`, `Persistence/ConfigurationRepository.swift`.

1. `ApprovalRequest`: `init` currently writes `self.dataClasses = dataClasses` while the stored field is absent. Add **`let dataClasses: [PrivacyClass]`** with complete Codable/mapping updates; make `canonicalArguments` and `sessionGeneration` **required, non-default**; construct both only after strict policy validation.
2. `AppError`: add an appropriate `case toolExecutionFailed(toolID: String, message: String)` **or** map to an existing error consistently across ToolInvocationCoordinator/tests/UX. Do not catch and return fake success.
3. `UsageEstimate` in `Domain/ProviderConfiguration.swift` is *not* the three-argument form used by orchestrator. Populate traceID, providerID, modelID, input/output tokens, estimated cost, `isActual` and `recordedAt`; provider token usage reported by a real provider is `isActual=true`, locally estimated values are advisory.
4. `ProviderDetailView.saveKey()` calls `saveProviderConfig(config)` while `ConfigurationRepository` requires `saveProviderConfig(_:session:)`. Capture current session on the main actor, require the matching owner inside the repository, compare live generation before and after asynchronous secret storage, and roll back or surface partial success if config persistence fails.
5. Map SwiftData `@Model` objects to immutable Sendable DTO **inside the owning isolation domain**, not after returning raw models across actors. The current repository family mixes actors with `mainContext`. Adopt a consistent owner for a given context, change incrementally, and prove no SwiftData model escapes its actor context; do not casually replace all storage architecture without compiler evidence.

**R1.3 — avatar-type unification, including actual callers.**

Files: `Avatar/AvatarView.swift`, `Avatar/AvatarAssetCatalog.swift`, `Avatar/AvatarState.swift`, `Avatar/AvatarStateController.swift`, `Features/Assistant/AssistantProfileView.swift`, `Features/Dashboard/AssistantHeader.swift`, `Features/Dashboard/DashboardView.swift`, `Features/Assistant/AssistantSwitcher.swift`, `Resources/Assets.xcassets/{Maya,Saar}.imageset/Contents.json`.

- Choose canonical `AvatarRole` from `Domain/AssistantProfile.swift` (`.maya`, `.saar`) and `AvatarState` from `Avatar/AvatarState.swift` (`idle/listening/thinking/speaking/error`). Do not invent a second `AvatarActivityState` unless the entire contract/index and every caller genuinely migrate together. Existing `AvatarIdentity` can be mapped one-way or removed only after call-site migration.
- Provide actual catalog functions `assetName(for role: AvatarRole)`, `glowColors(for role: AvatarRole)`, or adjust the view to the catalog's existing API in ONE coherent change. `AvatarView(role:state:size:)` must match all call sites; status must reflect actual voice/model state, not merely a timer. Fallback monogram if asset cannot load. Respect Reduce Motion and VoiceOver.
- Six small PNG files were added in fourth commit, but they depict star/diamond emblems; do not call them realistic human character avatars. If product spec requires illustrated Maya/Saar, deliver legally usable final assets or honestly record visual scope limitation. `Package.swift` still has a placeholder smiley app icon.

**R1.4 — concurrency/SDK/manifest proof.**

- Compile *genuine `AppModule` on macOS with a verified compatible Xcode/iOS SDK*. First detect available Xcode via `xcodebuild -version`, `xcodebuild -showsdks`, list project/package schemes using Xcode actually recognizing `.swiftpm`; **don't assume** `-scheme PersonalAssistant` works merely because the product has that name. If necessary create a documented auxiliary **Xcode build harness** retaining the original `.swiftpm` untouched.
- Swift 6 and framework compatibility: `@MainActor` UI changes only on main actor; no `AVAudioPCMBuffer` casually captured across `@Sendable` tasks; `KeychainVault`, `ModelRouter` and SwiftData actor calls await correctly; `#available` checks use actual OS availability, not just `canImport`.
- Detect unique `@main`, duplicate declarations, stale call sites, missing view types and resource bundle paths. Fix ALL actual compiler errors; preserve warning output; run a Debug *and* Release build if available. No claim that Python bracket/substring scans substitute for compilation.

## 2. Real user-visible AI chat vertical slice (R2/W05–W06)

**Owning files and flow:**

`DashboardView.swift` -> `DashboardViewModel.swift` -> `AppRouter.swift` / `ApplicationCommandBus.swift` -> `ChatView.swift` -> `ChatViewModel.swift` -> `ConversationRepository.swift` -> `ContextBuilder.swift` -> `ModelRouter.swift` -> `OpenAICompatibleProvider.swift` -> `HTTPClient.swift` -> `SSEDecoder.swift` -> `AssistantOrchestrator.swift` -> persisted `MessageRecord` -> UI/history/relaunch.

### 2.1 Chat creation, Quick Ask and multi-turn identity

**Current defect:** Dashboard `onAsk(text:)` ignores `text`, new `ChatViewModel` stores its initial optional conversation ID in a `let` and can create a different conversation every subsequent send. UI appends fabricated assistant DTOs instead of reading the repository's canonical saved record.

**Preferred design:** Implement a typed, single-use `ChatLaunchIntent` carrying `conversationID` and original prompt, passed through `AppRouter` to ChatView. `ChatViewModel` owns `private(set) var activeConversationID: ConversationID?`, set immediately after the repository creates it. The launch intent's ID must be consumed atomically once; do not both pre-save the text and allow ChatView to save it again. Choose **one** implementation path:

- A: Dashboard creates persistent conversation, routes Chat with initial draft and launchID; ChatViewModel consumes the launchID, persists user turn exactly once and calls orchestrator automatically. If offline, keep draft and explain pending status without silently losing it.
- B: Dashboard calls a shared `SendTurnUseCase` before navigation and ChatViewModel attaches to existing run; needs durable trace and reload semantics. **Do not mix A and B**.

**Reference typed shape:**

```swift
struct ChatLaunchIntent: Hashable, Sendable {
    let id: UUID                // single-use launch token
    let conversationID: ConversationID
    let initialText: String     // passed intact; never dropped
}

@MainActor
final class ChatViewModel {
    private(set) var activeConversationID: ConversationID?
    private var consumedLaunchIDs: Set<UUID> = []

    func consume(_ intent: ChatLaunchIntent) async throws {
        guard consumedLaunchIDs.insert(intent.id).inserted else { return }
        activeConversationID = intent.conversationID
        composerText = intent.initialText
        await send()           // send() must not create a second conversation
    }
}
```

This is a **design sketch**. Adapt to actual `@Observable` class, nav sheet enum and real repo methods. On every send, atomically allocate a stable `traceID`, persist the user's pending message once, and preserve `activeConversationID` for N>1 turns. A navigation duplicate or view re-render must not transmit twice.

### 2.2 Context composition B04: trusted hierarchy and bounded context

**Current issues:** ContextBuilder exists but ChatViewModel manually creates the context. Retrieved user memory is promoted to `.system` role; older history is chosen first; budget is not guaranteed for full memory and active user query.

Implementation algorithm, independently testable with a pure function/fake token counter:

1. Capture the active owner/session/assistant and selected provider's **verified context limit**. Reserve expected response tokens, mandatory system policy and complete current query first. Fail `contextTooLarge` if these cannot fit; do not silently omit the current query.
2. Select only verified, active, owner-scoped memories whose privacy class and source consent allow disclosure to the selected route. Encode memories as **untrusted referenced data**, not top-level system authority; mark `ContextSource.retrievedMemory`. Explicitly fence suspicious instructions as data.
3. Select most recent eligible history backward until budget fits, then restore chronological order for the provider. Preserve original role/source; never upgrade `retrievedDocument` or toolOutput to system instructions. Deterministically deduplicate current query against persisted pending user message.
4. Count all components with a conservative estimator; cap byte size as well as token estimate; attach provenance IDs/revisions so deletion/revocation invalidates future packets; re-check privacy/session before transport dispatch.
5. Pass the resulting **`ContextPacket.messages`** to `AssistantRequest`, not the unsanitized ChatViewModel mapping. Never store model hidden reasoning.

```text
available = verified_context_window - requested_output_budget - provider_overhead
require tokens(system_policy + current_user_query) <= available
append trusted app policy only
append selected allowed memories tagged as UNTRUSTED DATA; bound and budgeted
select newest eligible prior history, then chronological reorder
append original current user query exactly ONCE
assert total_estimated_tokens <= available
assert all source owners equal active owner
assert all disclosed privacy classes permitted by destination consent
```

### 2.3 Provider and streaming state machine B03

Files: `AI/Routing/AssistantOrchestrator.swift`, `OpenAICompatibleProvider.swift`, `ModelRouter.swift`, `SSEDecoder.swift`, `HTTPClient.swift`, `AI/Transport/RetryPolicy.swift`, `AI/Transport/ModelCatalogClient.swift`, `Persistence/ConversationRepository.swift`, `Features/Chat/ChatViewModel.swift`.

Existing `AssistantModel.stream(_:)` returns `AsyncThrowingStream<AssistantEvent, Error>` and `TurnUIEvent` enumerates started, delta, toolProposalPending, usageUpdate, completed, interrupted, failed. Implement these **states**: `pending -> routing -> connecting -> streaming -> checkpointing -> complete | interrupted | failed | awaitingApproval`. One trace = one logical turn. Reject old-session events and late deltas after completion. An unexpected EOF without a provider completion sentinel is **interrupted**, not `.completed`. On provider failure **before first visible token and before any side effects**, fallback may occur only to another actually eligible route with same privacy/capabilities and a bounded retry policy. **After first visible delta or executable tool action, never silently stitch output from another model.** Incomplete tool fragments are discarded on disconnect; no invocation until validated and authorized.

**SSE/event algorithm:** preserve split UTF-8 byte boundaries, CRLF, multiline `data:`, `event/id`, `[DONE]`, provider error payload, max event/frame and total response bytes, partial JSON fragments and `usage`. `SSEDecoder.finish()` errors propagate. `OpenAICompatibleProvider.stream()` must not synthesize successful `completed` for a stream that ends without a verified stop/terminal marker. Model choice must be selected by router, not by guessing hardcoded `llama-*` defaults. Assemble tool-call JSON by provider call ID/index with a strict buffer cap; no fragment gets to ToolPolicy until complete; check actual provider format differences through fixtures.

**Reference execution skeleton:**

```swift
// Semantic pseudocode. Name/return types must match verified project contracts.
let token = try await currentSession.captureAndValidate(owner: ownerID)
let prefs = try await preferencesRepo.preferences(ownerID: ownerID) // no silent default
let packet = try await contextBuilder.buildValidatedPacket(...)
let route = await router.route(requirements: req.requirements,
                               ownerID: ownerID,
                               configs: configs,
                               privacyMode: prefs.privacyMode,
                               consents: prefs.consents)
guard case .selected(let provider, let modelID) = route else { throw ... }
try await egressGate.requirePermit(route, packet: packet, session: token)
var emittedVisible = false
var terminalSeen = false
for try await event in try await provider.stream(routedRequest) {
    try Task.checkCancellation()
    try await currentSession.requireCurrent(token)
    switch event {
    case .textDelta(let delta, let seq):
        // Reject out-of-order sequence; persist checkpoint or surface failure.
        try await conversations.appendAssistantCheckpoint(..., deltaText: delta, session: token)
        emittedVisible = true
        await emit(.textDelta(delta, sequence: seq))
    case .toolProposal(let proposal):
        // Assemble + strict schema, privacy, permission and human approval.
        // Only emit pending UI; NEVER execute inside provider callback.
    case .completed(let finishReason):
        try await conversations.finishAssistantMessage(..., status: .complete, session: token)
        terminalSeen = true
        await emit(.completed(traceID: req.traceID, finishReason: finishReason))
    case .failed(let providerError): throw providerError
    default: ...
    }
}
if !terminalSeen { markInterruptedAndShowRetry() }
// In catch: if emittedVisible OR any tool side effect, mark interrupted; no failover.
```

**Critical order:** if a delta is shown before disk persistence, a crash may lose visible text; if disk fails, do not emit `.completed`. Decide documented checkpoint granularity (e.g., throttled/atomic by buffered chunks), and test midstream disk failure. Remove `try?` from persistence state changes and provider completion pathways. Maintain `isActual` usage metadata correctly.

### 2.4 HTTP security, cancellation and provider errors

- The current `HTTPClient.init(session:.shared, allowedHosts:[])` cannot enforce all declared redirect rules. Build a dedicated `URLSession` with an immutable validating redirect delegate for network AI requests, positive per-provider host allowlists and HTTPS-only endpoints. Validate the **initial URL and every redirect** including scheme, host, port, URL userinfo and unsafe address classes; reject redirects to unapproved domains. Avoid claiming arbitrary hostname checks completely eliminate DNS rebinding. External user-opened URLs are a separate explicit UI action, not silently fetched by the AI HTTP client.
- `HTTPClient.stream`: bridge URLSession's underlying request lifetime to AsyncThrowingStream via `continuation.onTermination`; cancel the underlying task on cancellation, deadline or owner change. Implement a real deadline and response byte cap; do not allocate a 1-byte `Data` object for every byte indefinitely if a bounded-chunk bridge is possible. Avoid sending raw key strings to logs, diagnostics, errors or trace tags.
- `RetryPolicy`: 401/403 require reconfiguration, 429 honors provider Retry-After, transient 5xx can be retried only within route/turn semantics; never blindly retry non-idempotent tool actions. Health check and retry count must be bounded. Unknown billing is **advisory**, not an account-level guaranteed ceiling.
- `ModelCatalogClient` currently uses `Data(contentsOf:)` rather than authorized async shared transport; route catalogs through the same HTTPS/consent policy or bundle a verified static allowlist when offline. Show provider-specific unavailable/capability unknown states instead of inventing capabilities.

**Reference delegate shape:**

```swift
final class ValidatingRedirectDelegate: NSObject, URLSessionTaskDelegate {
    let approvedHosts: Set<String>
    init(approvedHosts: Set<String>) { self.approvedHosts = approvedHosts }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        guard let url = request.url,
              url.scheme?.lowercased() == "https",
              let host = url.host?.lowercased(),
              approvedHosts.contains(host),
              (try? URLSafetyValidator.validateDestination(url)) != nil else {
            completionHandler(nil)
            return
        }
        completionHandler(request)
    }
}
```

**Compile/update for actual Swift 6 delegate isolation.** The snippet is illustrative only; also reject embedded credentials, explicit dangerous ports, IP-literal or private/metadata hosts at request source; route by explicit destination. A custom endpoint must be separately authorized and tested; do not leave `allowedHosts=[]` meaning unrestricted.

**R2 PASS:** executable fake-provider tests for multi-turn same conversation, 1-byte SSE fragmentation including Unicode, provider JSON/tool fragments, 401/429/5xx, no fallback after first visible token, missing terminal, cancellation, app relaunch checkpoint, offline/private-only *zero HTTP*; separate opt-in live test with a user's nonproduction BYOK key after R3 transport and privacy gates pass. The published `scratch/test_chat_slice.py` may stay as source-pattern lint but CANNOT certify R2.

## 3. Fail-closed privacy, credential lifecycle and real tool execution (R3/W02/W09/W12)

### 3.1 Central privacy, consent, owner/session checks

Files: `Domain/PrivacyAndConsent.swift`, `Security/PrivacyPolicyEngine.swift`, `App/AppSession.swift`, `Persistence/ConfigurationRepository.swift`, `Features/Settings/PrivacySettingsView.swift`, `Features/Configuration/PrivacyRoutingView.swift`, `AI/Routing/ModelRouter.swift`, `AI/Transport/HTTPClient.swift`, `AI/Providers/OpenAICompatibleProvider.swift`, `Media/AttachmentProcessor.swift`, `Search/SpotlightProjection.swift`.

**Current latent contradiction:** `AppPreference.consents` exists but `ConfigurationRepository.preferences(ownerID:)` reconstructs preferences **without decoding `StoredAppPreference.consentsData`**. Updating an existing StoredAppPreference doesn't write `consentsData`; only new-record insertion encodes it. Both screens can display inconsistent privacy; one screen saves only local `@State`. A cloud-mode picker by itself must not mint provider/STT/attachment consent.

**Required coding:**

- Repair `ConfigurationRepository` to persist/decode *all* `AppPreference` fields, including consent dictionary and cached accessibility flags where relevant, with explicit decode error handling. Never silently replace corrupted stored consent with a permissive default. Existing users without a consent record are **not consented**. Update `AppSession.preferences` after a successful saved mutation, including privacy, permissions and assistant selection; do not recreate whole preference objects when changing one field.
- Use a single `DataEgressPolicy.requirePermit(ownerID:session:destination:dataClass:recipient:...)` before **each outbound operation**: chat, model list/catalog, remote STT, thumbnail/previews, analytics (if any), link preview, attachments, remote tools and future backup. A user-initiated Safari open in private-only must be a separately disclosed explicit action under V3 S005, never automatic content transfer.
- Capture `SessionToken` before any async work; after awaited user prompt/provider request/file read check live session generation again. Inbound stream callbacks, memory/index updates, and tools must reject stale owner data. No in-flight bytes can be recovered after they have already left the device; disclose this limitation honestly.

```swift
struct EgressDecision: Sendable {
    let ownerID: UserID
    let destination: DataEgressDestination
    let recipient: URL?
    let maximumAllowedClass: PrivacyClass
    let sessionGeneration: UUID
}

// Reference policy logic, not an unchecked blanket cloud switch:
func authorizeEgress(prefs: AppPreference,
                     destination: DataEgressDestination,
                     dataClass: PrivacyClass,
                     session: SessionToken) throws -> EgressDecision {
    guard session.userID == prefs.ownerID else { throw AppError.notAuthenticated }
    // Only a separately VERIFIED fully local OS operation gets this local exception.
    // Never classify remote STT or a network-backed integration as .system.
    if destination == .system {
        return EgressDecision(ownerID: prefs.ownerID,
                              destination: destination,
                              recipient: nil,
                              maximumAllowedClass: .secret,
                              sessionGeneration: session.generation)
    }
    guard prefs.privacyMode == .cloudAllowed else {
        throw AppError.privacyDenied(route: destination.rawValue, requiredClass: dataClass)
    }
    guard let consent = prefs.consents[destination], consent.isGranted,
          dataClass <= consent.maximumDataClass else {
        throw AppError.privacyDenied(route: destination.rawValue, requiredClass: dataClass)
    }
    // Enforce validated destination/recipient, expiry/revocation, per-channel scope.
    // Return a short-lived permit bound to the session and content classification.
}
```

The real gate must handle the local `.system` and local Apple adapter cases without treating all device processing as remote transfer. `Private Only` must stop outgoing cloud content; the UI must show local-only limitations if no verified local model exists. A dynamic provider endpoint is **not** implicitly authorized just because `cloudAllowed` was selected.

### 3.2 Keychain rotation and accurate BYOK disclosure

Files: `Security/KeychainVault.swift`, `Security/CredentialLifecycle.swift`, `Features/Configuration/ProviderDetailView.swift`, `Persistence/ConfigurationRepository.swift`, `Security/Redaction.swift`.

- Existing `setSecret` calls `SecItemDelete` then `SecItemAdd`. Prefer `SecItemUpdate` on an existing item and `SecItemAdd` only when absent; preserve the previous functioning secret on update failures, check `OSStatus` every time. Device-locked errors differ from genuinely missing credentials. Test first save, overwrite, denied/locked read, restore after no-key, delete and owner switching.
- A custom provider's credential namespace must use actual config reference or stable registered provider key consistently. `removeAll(owner:)` currently loops only provider-kind strings, missing arbitrary custom config IDs/purposes; maintain owner-scoped credential catalog or enumerate safely, never delete other owners' keys.
- Honest UI disclosure: keys are stored on this device in Keychain but are transmitted as authorization headers to **the selected user-configured AI provider** when requests are made. They are not sent to an invented developer-owned service. `ProviderDetailView` must not claim they never reach any server. Show separate states `key saved locally`, `provider configured`, `model verified`, and `live connection verified`; never merge them into a fake green indicator.
- Never put bearer tokens in request error messages, redacted audit, metrics, crash reports or git-tracked JSON. Never commit user's test key or inject fake CI credentials.

### 3.3 Exact approval payload B05

Files: `Domain/ApprovalRequest.swift`, `Tools/ToolRegistry.swift`, `Tools/ToolPolicyEngine.swift`, `Tools/ToolRiskClassifier.swift`, `Security/ApprovalCoordinator.swift`, `Features/Approvals/{ApprovalCenterView,ApprovalDetailView,ApprovalViewModel}.swift`, `Features/Configuration/ToolPermissionsView.swift`.

**Canonical rule:** model-produced function-name/JSON bytes are untrusted proposals, not authorized calls. The canonical `ApprovalRequest` must contain non-default `ownerID`, `sessionGeneration`, `invocationID`, `traceID`, validated normalized `toolID`/`schemaVersion`, **typed validated args**, final destination/recipient, `dataClasses`, permission scope, expiry and an exact hash over all action-changing fields. Deny unknown JSON keys, wrong JSON primitive types, overlong fields, unwanted file URLs, disallowed destinations and changed recipient. Map camelCase aliases only during strict *proposal normalization*, never permit two different executor contracts to share an unsafe alias.

**Deterministic hash input:** use versioned length-prefixed typed binary encoding or a fully tested JSON canonicalization algorithm. Include domain separator (`IOS_AI_TOOL_APPROVAL_V1`), owner UUID, current session generation UUID, invocation UUID, trace UUID, canonical tool/version, recipient and destination, canonical validated arguments bytes, privacy classes, scope, issued/expiry timestamps and any external account. Use stable big-endian length prefixes; canonicalize Unicode/number representations; SHA-256 digest over the final assembled bytes. **Hashing raw JSON bytes while displaying parsed/reordered values is NOT an exact human approval contract**. Add tests for semantic mutation, Unicode normalization, field order, duplicate JSON keys, null vs absent, changed URL/account and large numbers.

**Corrected typed construction schematic:**

```swift
let validated = try registry.validateStrictly(
    toolID: proposal.toolID,
    version: proposal.schemaVersion,
    rawJSON: proposal.argumentsJSON,
    ownerID: currentOwner,
    session: currentSession,
    privacy: currentPrivacy
)
let canonicalBytes = try canonicalEncoder.encode(validated)
let digest = hashFullyBoundApproval(
    invocationID: proposal.invocationID,
    owner: currentOwner,
    sessionGeneration: currentSession.generation,
    tool: validated.definition,
    canonicalArguments: canonicalBytes,
    recipient: validated.recipient,
    dataClasses: validated.dataClasses,
    expiresAt: explicitExpiry
)
let request = ApprovalRequest(
    invocationID: proposal.invocationID,
    toolID: validated.definition.toolID,
    schemaVersion: validated.definition.schemaVersion,
    ownerID: currentOwner,
    traceID: proposal.traceID,
    payloadHash: digest,
    riskLevel: validated.definition.riskLevel,
    humanReadableSummary: validated.displaySummary,
    recipient: validated.recipient,
    dataClasses: validated.dataClasses,
    canonicalArguments: canonicalBytes,
    sessionGeneration: currentSession.generation,
    expiresAt: explicitExpiry
)
```

No `Data()` default for canonical args; no random UUID default for session generation. `ApprovalCoordinator.approve` requires exact expected digest and the **actual live current session**, verifies owner/session/expiry and transfers an atomic single-use approval to execution. After app restart, rehydrate/expire persisted pending approvals according to the V3 recovery policy; never silently approve. Approval UI displays exact consequences and recipient, allows approve/reject, and records the decision; local permission toggles persist and are enforced by policy (not mere `@State`). A UI-provided `request.payloadHash` does not constitute independent payload revalidation if the underlying action has mutated since display.

### 3.4 Durable receipt ledger, idempotency and final execution authorization

Files: `Persistence/StoreModels.swift`, `Persistence/SchemaV1.swift`, `Persistence/AppMigrationPlan.swift`, `Tools/ToolReceiptStore.swift`, `Tools/ToolInvocationCoordinator.swift`, `Security/ApprovalCoordinator.swift`, `Security/SessionGuard.swift`, `Persistence/AuditRepository.swift`, `Tasks/TaskRecovery.swift`.

**Critical existing defect:** `ToolReceiptStore.recordPrepared` returns `ToolReceipt` even when `try? ctx.save()` fails; `ToolInvocationCoordinator` then runs the executor. An actor method with an `await` between `receiptForOperationKey` and `recordPrepared` allows two callers to race. A dictionary cache is not durability; `SchemaV1` now lists StoredToolReceipt but migration from prior schema is unverified.

**Mandatory implementation design:**

1. Introduce a **throwing, atomic `reservePrepared` operation** encapsulating duplicate check, unique stable operation-key insertion and durable `ModelContext.save()` in one isolated storage transaction. Prefer a real schema uniqueness constraint on stable opKey if the installed SwiftData SDK supports it; still serialize the caller's operation reservation. Use owner-scoped operation key; identical retries must get the existing receipt without dispatch. No optional `modelContainer`: shipping DI must require the persistent container, tests inject a deterministic failing store.
2. Immediately before side effect, re-check **current** session generation, owner, approval digest, expiry, one-time consumption, destination, permissions and privacy. The executor must be an allowlisted typed tool associated with the validated definition, not a caller-provided arbitrary closure in the public production API.
3. Commit PREPARED to disk, check save success, only **then** dispatch. Recheck the same stable operation key after await points; maintain a clear single ownership/serialized dispatch boundary. On confirmed external success, persist SUCCEEDED with actual external reference and *redacted* result; on certain no-dispatch failure, FAILED; on ambiguous timeout/cancel/network failure after possible dispatch, AMBIGUOUS and require human review. Recovered PREPARED after process restart is conservatively AMBIGUOUS, never automatic replay. Do not mark success based on a string returned by a stub.
4. On startup, reconcile before tools become available. On persistence failure while reconciling, **disable external tools** and surface recovery, rather than `return 0` implying no orphaned work. Any remote retry must be backed by a proven external service idempotency contract or an explicit user-approved new operation.

```text
execute(approvedCall):
  assert current owner == approvedCall.owner && generation still current
  assert now < expiry && digest(approvedCall) == approved payload
  assert explicit permission/consent/privacy/destination still allowed
  receipt = TRY ATOMIC_DURABLE_RESERVE(unique operationKey, status=PREPARED)
  if receipt already exists: return preexisting verified success receipt OR deny replay
  # Once dispatched, assume ambiguity unless confirmed safe result arrives.
  result = TRY AWAIT real allowlisted executor.run(approvedCall)
  TRY DURABLE_SET_STATUS(SUCCEEDED, realExternalReference, sanitizedReceipt)
  return verified result
on ambiguity/error after dispatch:
  TRY DURABLE_SET_STATUS(AMBIGUOUS)
  show Needs Review, never auto-retry
on store fault before dispatch:
  STOP; zero side effects; show storage recovery error
```

**Important migration:** test an existing store produced by the **third commit** (`SchemaV1` without `StoredToolReceipt`) opening in the new build; if incompatible, define a legitimate versioned migration from the actual previous model state, include fixture hashes and backup/export. Do not delete the original database to produce a green launch. Fresh installs have a separate fixture.

**R3 acceptance tests:** `approval_changed_payload_denied`, `approval_unicode_canonical`, `approval_reuse_denied`, `approval_owner_switch_denied`, `approval_expired_denied`, `receipt_save_failure_zero_external_dispatch`, `two_concurrent_same_key_one_dispatch`, `restart_prepared_ambiguous`, `timeout_after_remote_success_no_automatic_replay`, `privateOnly_zero_content_egress`, `revoke_consent_during_stream`, `credential_rotation_preserves_old_key_on_failure`, `secret_not_in_logs`.

### 3.5 Real tool adapters vs fake successes

`Tools/{CreateReminderTool,CalendarTool,ContactsLookupTool,CreateTaskTool,OpenURLTool,SaveNoteTool,SearchHistoryTool,ReadAttachmentTool}.swift`, `Integrations/{CalendarAdapter,RemindersAdapter,ContactsAdapter,URLLauncher}.swift`, `Tools/ToolRegistry.swift`.

Most concrete tools have a `ToolDefinition` but no execution. `CalendarTool.execute` only checks calendar access then claims event created; `OpenURLTool.execute` validates then claims browser open. **Remove misleading success paths immediately.** Implement scoped, typed, user-approved V1 tools behind verified adapters: local task create, local notes/memory proposal, owner-filtered history search, approved URL open, local reminder scheduling; Calendar and Contacts are CONDITIONAL until real EventKit/Contacts permission and runtime tests pass. Registry IDs/JSON schemas/executor IDs must be identical after normalized alias handling. Use the OS's actual success/callback/external ID, not a formatted string to prove execution.

Example expected Calendar flow: parse/validate start/end time and calendar selection, obtain appropriate write permission, compose `EKEvent`, save using `EKEventStore.save` on the correct calendar, read resulting `eventIdentifier`, emit durable receipt and sanitized audit. If denied, do not claim created. Browser open: after exact URL approval and safe URL validation, invoke `UIApplication.shared.open` (main actor); completion may reflect handoff accepted, **not** that target content loaded or an external website action succeeded. Always let the OS enforce permissions; local permissions toggles cannot substitute for OS grants.

## 4. Tasks, voice, avatars, memory, search, attachments and all five screens (R4/W04,W07–W12)

### 4.1 Task scheduling B06, persistence, notifications and recovery

Files: `Domain/TaskDefinition.swift`, `Tasks/{TaskScheduler,TaskRecurrence,TaskIdempotency,LocalReminderScheduler,TaskEngineActor,TaskRecovery,TaskStateMachine,TaskRunExecutor,ForegroundExecutor,ContinuedBackgroundExecutor,RemoteTaskScheduler}.swift`, `Persistence/TaskRepository.swift`, `Features/Tasks/{TaskEditorView,TaskDashboardViewModel,TaskDashboardView,TaskDetailView}.swift`.

- Use existing `TaskDefinition` fields `schedule: TaskSchedule?`, `recurrence: TaskRecurrence?`, `revision: Int`, `notificationIdentifiers: [String]`. `TaskOccurrenceKey` fields `taskID`, `definitionRevision`, `scheduledOccurrenceID`. One deterministic **scheduled occurrence UUID** per `(taskID, revision, intended scheduled UTC instant)` is already implemented. Remove/guard legacy random default overload from production scheduling, and make `TaskRepository.reserveOccurrenceKey` accept the actual scheduledDate instead of setting `scheduledAt=Date()`. If stored key decoding fails, raise recovery, **never create a random replacement identity**.
- `TaskRecurrenceCalculator` currently supports frequency arithmetic but ignores `daysOfWeek`, `dayOfMonth`, `endCondition` and edge cases when a month lacks day 31; implement explicit documented selection policy. Preserve originally selected **IANA timezone and wall-clock hour/minute** across DST. `Calendar.nextDate` must use matching/repeated-time policies on real fixtures, and the engine must materialize at most one persisted occurrence per stable key even if the system clock jumps or the app restarts.
- A notification request ID should incorporate the specific deterministic occurrence key, not just the task ID, so multiple future occurrences can be managed independently. Edit/delete must remove obsolete notifications and store new scheduled IDs only on confirmed notification center acceptance. On permission denial, retain task but visibly mark alert unscheduled, do not silently suppress. On boot, reconcile persisted notification IDs against pending requests and resolve skipped/expired occurrences without false completed AI jobs.
- `TaskEditorView` currently swallows reminder scheduling failures, creates a **new** `LocalReminderScheduler` instead of sharing the DI instance and closes UI after save without surfacing unscheduled alert. Inject the shared scheduler/task use case. `TaskRepository.upsertDefinition` and run transitions must include owner-scoped predicates and current-session validation, not merely a global UUID lookup; `ConversationRepository.appendPendingUserMessage` must verify the specified conversation actually belongs to the current owner before insert. Never let a crafted identifier write orphaned or another owner's records. Revision compare-and-set must ensure an update preserves ID, conflicts reject and a create starts at the correct revision. A manual task may still work offline; `UNUserNotificationCenter` notification **does not execute a background AI agent**.

```swift
// Reference occurrence identity, already reflected in fourth-commit scheduler.
func stableOccurrenceID(taskID: TaskID, revision: Int, fireDate: Date) -> UUID {
    let epochSecond = Int64(fireDate.timeIntervalSince1970)
    let stableFields = "\(taskID.rawValue.uuidString):\(revision):\(epochSecond)"
    let sha = SHA256.hash(data: Data(stableFields.utf8))
    // Convert first 16 digest bytes to UUID, using documented deterministic encoding.
}
```

**Tests:** New York 2026-03-08 nonexistent 02:30; New York 2026-11-01 repeated 01:30 (first occurrence only); monthly 31st; end-after-count; timezone change; simultaneous schedule call; dirty app restart; denied notification; canceled task alert; updated revision invalidates old request; store conflict; force-quit DOES NOT secretly execute AI.

### 4.2 Voice B07: complete microphone -> transcription -> assistant -> TTS

Files: `Voice/{VoiceCoordinator,MicrophoneCapture,LegacySpeechRecognizer,ModernSpeechTranscriber,SpeechRecognizerProtocol,AppleSpeechSynthesizer,AudioInterruptionHandler,VoiceLocalePolicy}.swift`, `Features/Chat/{ChatView,ChatViewModel,ChatComposer}.swift`, `Features/Configuration/VoiceConfigurationView.swift`, `Features/Assistant/AssistantVoicePreview.swift`, `App/CapabilityCenter.swift`, `App/ApplicationCommandBus.swift`, `Package.swift`/App Settings privacy keys.

Current coordinator starts the microphone tap **before** it initializes speech recognition. The last-reported iPad instructions refer to a mic button that current `ChatView` does not render. Reorder and connect the entire path:

```text
USER TAPS MIC (only direct user intent)
  -> ask/check microphone AND Speech permission
  -> validate chosen assistant locale against actual on-device support
  -> create new VoiceSessionID and cancellation generation
  -> configure AVAudioSession and instantiate SFSpeechAudioBufferRecognitionRequest
  -> START recognition BEFORE recording buffers are forwarded
  -> start AVAudioEngine tap with safe audio-buffer handoff
  -> stream partial transcript visibly; only final or user-confirmed text enters composer
  -> user presses Send (or explicit setting permits immediate send)
  -> ChatViewModel sends one persisted turn through the same chat pipeline
  -> once real assistant text finalizes, synthesize with selected available voice
  -> pause/cancel on interruption, background, lock, owner switch or permission revocation
  -> remove audio tap, end request, cancel recognition, release AVAudioSession
```

The audio callback may run on a real-time thread; do **not** invoke heavy Swift actor work or move mutable `AVAudioPCMBuffer` into an unsafely detached Task without a proven lifetime/copy/serialization strategy. Use a bounded audio queue/bridge with safe copies and compiler-validated isolation. `SFSpeechRecognizer` availability != recognized locale/offline availability; do not silently route Hindi voice to remote STT. `ModernSpeechTranscriber` remains conditional on actual API/SDK/device and permissions. TTS preview must clear `isPlaying` when synthesis completes via real delegate, not only when tapped to stop. Any Siri-like continuous listening is OUT OF V1.

**UI:** add visible 44pt+ microphone control, permission explanation, live transcript display, stop/retry, voice availability warning, selected Maya/Saar voice/locale, speaking animation and voice-over/accessibility. Use independently stored male/female *available* voice choices; do not promise a particular timbre where a locale's system voice is absent. Full audio device proof requires actual iPad.

### 4.3 Memory/provenance and history search

Files: `AI/Context/{ContextBuilder,MemoryRetriever,MemoryProposalEngine,MemoryConflictResolver,MemoryRetentionWorker,HistoryRetriever,ConversationSummarizer}.swift`, `Persistence/MemoryRepository.swift`, `Search/{LocalTextIndex,HistorySearchCoordinator,IndexMaintenance,SpotlightProjection}.swift`, `Features/Memory/{MemoryBrowserView,MemoryEditorView,MemoryReviewQueue,MemorySourceView}.swift`, `Features/History/{HistoryView,HistoryViewModel,HistoryFilterSheet,ActionTimelineView}.swift`.

- User-inferred memory remains **PROPOSED**, not verified; user must explicitly accept before long-term selected context reuse (V3), with provenance and revision. Current trigger-matching memory proposer recognizes only hardcoded English phrases; expose it as a conservative proposal helper, not intelligent automatic extraction. Honor requested deletions from database, context cache, local search and optional Spotlight. Do not silently swallow index deletion failures.
- Current `HistorySearchCoordinator.search` only filters conversation **titles**, not message bodies, tasks and audit history. Implement owner-filtered text index scope(s), record provenance and require authorization before indexing sensitive content. Index rebuild/relaunch tests, owner cross-query 0 results, soft-deleted conversation excluded and deleted memory never reintroduced to context.
- `LocalTextIndex` is in-memory; if persistence/indexing is claimed, create a tested rebuild or persistent index. Optional Spotlight requires explicit opt-in, indexed content classification and removal on deletion, not automatic indexing of personal text.

### 4.4 Attachments B09: protected storage and deletion boundary

Files: `Media/{AttachmentPicker,AttachmentValidator,AttachmentProcessor,AttachmentLifecycle,DocumentTextExtractor,VisionTextRecognizer,ImageOptimizer}.swift`, `Persistence/AttachmentRepository.swift`, `Features/Chat/ChatAttachmentStrip.swift`, `Domain/Attachment.swift`, `AI/Context/ContextBuilder.swift`.

- Fourth-commit `AttachmentLifecycle` moves active files to Application Support. Further required: `Application Support/Attachments/<ownerUUID>/<attachmentID>/...`, standardized path verification and no symlink escape, `FileProtectionType` according to V3 threat model, sensible backup exclusion, atomic write/rename, valid file type and size checks, owner-bound metadata, cleanup of failed imports. `deleteAttachment(fileURL:)` currently takes an arbitrary URL and can delete anything the app can access: replace with `(ownerID, attachmentID)` plus stored ownership/path lookup and a sandbox-root containment check.
- MIME validation currently rejects a few magic-byte patterns but leaves unspecified MIME types insufficiently controlled. Allowlist supported document/image types, validate full PDF/JPEG/PNG signatures and image decoding, cap 20MB and decoded image pixels, PDF pages/OCR time, reject zip/disguised executables, and separate temporary scratch from durable user attachments. Do not send raw file to cloud unless model vision capability, user consent, recipient disclosure, data class and per-attachment upload consent all pass.
- `AttachmentRepository` is a `ModelActor` unlike the MainActor-backed repo pattern. Verify coherent SwiftData access and owner isolation; ensure stream tasks never retain raw unprotected temp files after cancellation.

### 4.5 Actual screen functionality and app resources

Files: `DesignSystem/AdaptiveLayout.swift`, `Features/Dashboard/*`, `Features/Tasks/*`, `Features/History/*`, `Features/Configuration/*`, `Features/Settings/*`, `Features/Approvals/*`, `Features/Assistant/*`, `Features/Onboarding/*`, `App/AppRouter.swift`, `App/AppSession.swift`, `Resources/*`.

- Five tabs/sidebar destinations must be REAL. Dashboard Quick Ask, avatar switch, recent conversation, task cards and new voice control; Tasks create/edit/repeat/delete/cancel; History conversation reopen/search/action audit; Configuration BYOK provider/model, privacy/consent, tool permissions, voice, Maya/Saar; Settings privacy, appearance, notification, security, storage/export/delete, accessibility, permission status and truthful diagnostics. Every enabled button/toggle persists and influences actual service behavior; otherwise disable with explanatory reason.
- `SettingsSubViews.swift` still displays `W03/W12/W13 implementation` copy. Replace those with actual functionality or honest unavailable states; no misleading active controls. `ApprovalCenterView` must show real pending requests from shared `ApprovalCoordinator` rather than permanent “No Pending Approvals.” `SettingsView` currently has Clear All Data disabled: V3 mandates a real owner-scoped deletion/export workflow only when implemented and tested; don't enable an unsafe half-delete action.
- Keep `PrivacySettingsView` and `PrivacyRoutingView` synchronized to the same `AppPreference` repository/use case. Once privacy is changed, update active session snapshot and cancel/deny ongoing transfer consistently. `ProviderDetailView` must save/rotate a key and config using current session, separately test connectivity, and show accurately whether model is supported and whether user has enabled that provider.
- Maya/Saar assets exist as simple colored symbols. Render them consistently; allow independently renameable profiles and chosen voice, locale, style and optionally route override to survive app relaunch. Respect Reduce Motion, Dynamic Type, VoiceOver and iPad keyboard focus/landscape. Provide a proper icon asset when preparing distribution; `Package.swift` currently still declares smiley placeholder.
- A genuine `.swiftpm` created by the iPad must be preserved; test resource discovery, localized strings and actual app capabilities. `ContentView.swift` is only the retained template entry alias where still required; single `@main` should live in `MyApp.swift`. Do not claim Firestore/iCloud/multi-family authentication is present in V1; document actual single-device/local-profile limits.

**R4 tests:** five independent UI routes, offline states, owner/session switch, Maya/Saar persistence/restart, VoiceOver large text/dark/iPad landscape, negative permission flows, notification lifecycle, safe deletion/export, bad provider key/config and no false success labels.

## 5. Test architecture, Mac CI and iPad release gates (R5/W13–W14)

### 5.1 Convert labels into real executable proof

`scratch/verify_matrix.py` and `scratch/test_chat_slice.py` are source-string static checks, **not** executable Swift feature or security tests. Keep them as an inexpensive static lint, with honest naming. Create a real XCTest/Swift Testing target or independently verified companion Xcode test harness referencing the actual production core, not copied mock reimplementations. Use deterministic fake provider, fake URLSession/urlProtocol where valid, temp in-memory SwiftData container, fake notification center abstraction, fake secure store, fake/denied permissions, injected faulting receipt store and fixed date/time zone clock.

Minimum true behavioral tests, in dependency order:

| Suite | Fixtures/scenarios | Proves |
|---|---|---|
| DTO / compiler | exact shared types, owner IDs, Codable, Sendable, invalid schema | W01 no duplicate or inconsistent protocols |
| Storage | fresh, relaunch, third-commit DB fixture, corrupt store | W02 migration/no destructive reset |
| HTTP/SSE | UTF-8 1-byte splits, CRLF, two-line data, EOF mid-json, 401/429/5xx, max bytes, cancel/deadline, malicious redirect | W05 actual stream and network safety |
| Fake model turn | first chunk, 2+ turns, partial disconnect, valid terminal, incomplete tool, duplicate launch, owner switch | W06 B03, persistence, sequencing |
| Policy | privacy-only zero requests, missing consent, secret data, revoked mid-flight, stale generation, no invalid model fallback | W06/W09 trust boundary |
| Tool ledger | malformed args, digest/recipient mutation, TTL, concurrent same key, save failure, process restart, ambiguous remote success | W09 B05 exactly-once-or-needs-review behavior |
| Task | DST spring/fall, month-end, count/until, notification denied/canceled, concurrent reservation, restart | W08 B06 |
| Memory/media | owner-isolated retrieval, proposal review, delete cache/index, MIME spoof, safe file path, cancel/temp cleanup | W10/W11 |
| UI/device | five screens, no placeholder controls, assistant prefs, actual mic/TTS, background notification, dark/dynamic type, keyboard | W03/W04/W07/W12/W14 |

**Matrix traceability:** Every canonical `T001–T028` and `S001–S018` row gets either a *real executable test identifier and actual result* or `NOT_RUN/BLOCKED` reason, platform and owner. No 46/46 claim from source greps. No claim that all tests are executable on Ubuntu.

### 5.2 CI architecture that actually reaches the Apple compiler

The fourth workflow's macOS build was skipped because it depends on red Python `verify`. Repair the underlying S014/T008/T010/T024 bugs, but **run build diagnostics independently**. Use separate jobs for `static-verify` (Linux), `ios-compile` (compatible macOS/Xcode) and `swift-behavior-tests` (macOS, real Swift test target). A final aggregate release-gate job `needs: [static-verify, ios-compile, swift-behavior-tests]` should fail if ANY mandatory job fails. Do not set branch green using `continue-on-error` or weaken tests to match source text.

**Exact detection sequence for macOS runner (choose actual installed SDK rather than guessing Xcode):**

```bash
set -euo pipefail
uname -a
xcode-select -p
xcodebuild -version
xcodebuild -showsdks
find /Applications -maxdepth 2 -name 'Xcode*.app' -print
# Verify SDK actually supports compilation/deployment for generated iOS 18.6 template.
# Inspect `PersonalAssistant.swiftpm/Package.swift` without rewriting it.
# In Xcode GUI or its supported CLI, discover actual autogenerated AppModule scheme.
# Only AFTER scheme/project detection, run a real simulator build with CODE_SIGNING_ALLOWED=NO.
# A missing compatible SDK or unrecognized `.swiftpm` is a BLOCKED external gate,
# not a pass; create a verified auxiliary Xcode harness if necessary.
```

Don't quietly fall back to Xcode 15.4: it cannot be assumed compatible with an iOS 18.6 minimum deployment. Do not assert an `xcodebuild -scheme PersonalAssistant` invocation is valid before scheme discovery. Separate tested simulator build from user-device import and signing. Preserve full stdout/stderr as an artifact along with `git rev-parse HEAD`, toolchain/SDK versions, command and exit status. Test Xcode Release compilation where feasible; fixture tests and simulator smoke use a FAKE provider by default, never live API keys in public CI.

### 5.3 iPad handoff and evidence boundary

The user can import and attempt to build a copy of the current project today **without private data/keys** to collect diagnostics; reliable personal use requires Mac CI/behavioral tests plus real iPad proof. After Gemini creates a verified candidate:

1. Update release SHA, source-tree hash, privacy disclosures, licensing/dependencies, test ledger, icon/images and exact `.swiftpm` export. Ensure all source, resources and capabilities actually travel with the package (not just root ZIP/docs).
2. Follow `03_IPAD_IMPORT_AND_ACCEPTANCE_GUIDE.md`: Files app extraction, **Browse** in Swift Playgrounds to open genuine `PersonalAssistant.swiftpm`; confirm iPadOS compatibility, requested permissions and relevant purpose strings; tap Run App; capture complete issue list if compiler fails.
3. First launch **without** API keys, verify five screens, distinct Maya/Saar identity, local task and data persistence. Only after tested egress/Keychain security, enable user's disposable BYOK test credential and verify real streamed reply, cancellation and history after relaunch. Validate private-only zero cloud calls using a controlled test spy/environment before using sensitive data. Then test supported tap-to-talk, TTS, user notification, file permission and accessibility on physical iPad.
4. `MAC_CI_PASS` and `IPAD_PASS` are separate. Gemini on Ubuntu cannot physically run the user's device; if device access is missing, final status is `COMPILED_CANDIDATE_AWAITING_USER_IPAD` (or `COMPILE_BLOCKED` if no Mac evidence), not "fully shipped". iPhone signed install is a third independent gate.

**Do not automate arbitrary Git pushes, overwrite existing persistent data or send real personal material/keys to CI.** Commit locally with meaningful small commits; publish only when explicitly authorized.

## 6. Final file ownership / repair work-set index

The following list is an actionable **cross-file edit map**. Inspect every referenced file before editing; untouched coherent source must be preserved. The V3 manifest `docs/spec/v3/16_FILE_CONTRACT_INDEX.tsv` remains the full 266-entry file inventory. This index concentrates on the existing V1 shipping implementation rather than inventing new packages.

| Cluster / priority | Files to inspect and edit together | Mandatory output |
|---|---|---|
| Composition P0 | `App/{AppContainer,AppSession,AppRouter,CapabilityCenter}.swift`; `MyApp.swift`; `DesignSystem/AdaptiveLayout.swift` | One valid DI root, real selected owner/session, compile all five destinations |
| Canonical DTO P0 | `Domain/{Identifiers,Errors,AIModelDescriptor,ProviderConfiguration,ApprovalRequest,Message,PrivacyAndConsent,AssistantProfile,TaskDefinition}.swift` | Single typed ABI, no unsafe defaults, correct error and usage types |
| AI/routing P0 | `AI/Routing/{ModelRouter,AssistantOrchestrator}.swift`; `AI/Providers/{OpenAICompatibleProvider,GroqProvider,OpenRouterProvider,CustomEndpointProvider}.swift` | Correct async routing, exact owner and model, real terminal semantics |
| Transport P0 | `AI/Transport/{HTTPClient,SSEDecoder,RetryPolicy,ModelCatalogClient,ConnectivityMonitor}.swift`; `Security/URLSafety.swift` | Valid HTTPS + redirects, SSE fixtures, cancellation/deadline |
| Chat P0 | `Features/Chat/{ChatView,ChatViewModel,ChatComposer,StreamingStatusView,ToolActionCard}.swift`; `Features/Dashboard/{DashboardView,DashboardViewModel}.swift`; `Persistence/ConversationRepository.swift` | One stable multi-turn conversation with real persisted assistant output |
| Context P1 | `AI/Context/{ContextBuilder,TokenBudget,MemoryProposalEngine,MemoryRetriever,HistoryRetriever,ConversationSummarizer,ContextProvenance}.swift` | Deterministic owner-filtered bounded context, memory lower-trust role |
| Consent P0 | `Security/{PrivacyPolicyEngine,SessionGuard,KeychainVault,CredentialLifecycle,Redaction}.swift`; `Features/Configuration/{PrivacyRoutingView,ProviderDetailView,ToolPermissionsView}.swift`; `Features/Settings/PrivacySettingsView.swift`; `Persistence/ConfigurationRepository.swift` | One fail-closed egress and credential contract |
| Approval P0 | `Tools/{ToolRegistry,ToolPolicyEngine,ToolRiskClassifier,ToolInvocationCoordinator,ToolReceiptStore}.swift`; `Security/ApprovalCoordinator.swift`; `Features/Approvals/{ApprovalCenterView,ApprovalDetailView,ApprovalViewModel}.swift`; `Persistence/{StoreModels,SchemaV1,AppMigrationPlan,AuditRepository}.swift` | Exact single-use approval, durable atomic receipt before real side effects |
| Real tools P1 | `Tools/{CreateTaskTool,CreateReminderTool,SaveNoteTool,SearchHistoryTool,ReadAttachmentTool,OpenURLTool,CalendarTool,ContactsLookupTool}.swift`; `Integrations/{CalendarAdapter,RemindersAdapter,ContactsAdapter,URLLauncher}.swift` | Actual permissioned execution or visible disabled feature, no fake success |
| Tasks P1 | `Tasks/{TaskScheduler,TaskRecurrence,LocalReminderScheduler,TaskIdempotency,TaskEngineActor,TaskRecovery,TaskRunExecutor}.swift`; `Persistence/TaskRepository.swift`; `Features/Tasks/{TaskDashboardView,TaskDashboardViewModel,TaskEditorView,TaskDetailView}.swift` | Deterministic scheduled runs, actual notification lifecycle, safe restart |
| Voice P1 | `Voice/{VoiceCoordinator,MicrophoneCapture,LegacySpeechRecognizer,SpeechRecognizerProtocol,AppleSpeechSynthesizer,VoiceLocalePolicy,AudioInterruptionHandler}.swift`; `Features/Configuration/VoiceConfigurationView.swift`; `Features/Chat/ChatView.swift` | Visible tap-to-talk, live editable transcript, send, TTS and teardown |
| Avatar P0 compile | `Avatar/{AvatarView,AvatarAssetCatalog,AvatarState,AvatarStateController,AvatarPickerView}.swift`; `Features/Assistant/{AssistantProfileView,AssistantSwitcher,AssistantVoicePreview}.swift`; PNG assets | Shared role/state API with all real call sites |
| Memory/search P1 | `Persistence/MemoryRepository.swift`; `AI/Context/MemoryProposalEngine.swift`; `Search/{LocalTextIndex,HistorySearchCoordinator,IndexMaintenance,SpotlightProjection}.swift`; `Features/Memory/*`; `Features/History/*` | Provenance + approval, no owner leaks, deletion from all caches |
| Media P1 | `Media/{AttachmentPicker,AttachmentValidator,AttachmentLifecycle,AttachmentProcessor,DocumentTextExtractor,ImageOptimizer,VisionTextRecognizer}.swift`; `Persistence/AttachmentRepository.swift`; `Features/Chat/ChatAttachmentStrip.swift` | Protected owner files, safe content, consent before disclosure |
| Screens P1 | `Features/Settings/{SettingsView,SettingsViewModel,SettingsSubViews,PrivacySettingsView}.swift`; `Features/Configuration/{ConfigurationView,ModelPickerView,ProviderListView,AIConfigurationView}.swift`; `Features/Onboarding/*`; `DesignSystem/*` | Five genuine feature surfaces, truthful disabled states, accessibility |
| Tests/release P0 | `.github/workflows/ios-build.yml`; `scratch/{verify_matrix,test_chat_slice}.py`; new real Swift test harness; `docs/implementation/{DEFECT_REGISTER,RELEASE_EVIDENCE,IPAD_VERIFICATION_CHECKLIST}.md` | Independent Mac build, executable tests, verified evidence and clean device handoff |

## 7. Second-pass regression audit Gemini must execute after coding

Before calling its coding work “done”, Gemini must independently re-open **every edited file**, compare each change to the canonical V3 contract, follow every new initializer/case/field to all call sites and persistence mappers, rerun Swift compiler and tests, inspect new diffs for `try?` on critical writes, `return true` security bypasses, fake success text, arbitrary URLs, hardcoded API keys, owner/session mistakes, unhandled errors and unsafe migration. Audit `#available`/`canImport` assumptions on the actual SDK. Confirm previous bug families C01–C12 and B01–B24 have either real passing evidence or a documented blocked/disabled path. Repeat the verification on the **final commit**, not the previous audit's source. No paper-only "two audits passed" declaration.
