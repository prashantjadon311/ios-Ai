# 05. Exact Swift edits, cross-file caller map, and verified integration contracts

**Pinned GitHub baseline:** `2918293e7355290ba722bb734652c9ad70c75a9f`. **All source paths below begin at `PersonalAssistant.swiftpm/`.** Pinned line numbers refer to the fifth published commit and MUST be regenerated with `rg -n` after any local edit. Each code block is marked **PINNED EDIT** or **REFERENCE CODE**; only a genuine whole-app Apple build can certify iOS compilation. Consult the revised audit `01_*` and code blueprint `02_*` for full defect/proof mapping. This document contains proposed source, not actual edits to the user's repository.

## Part A: G0 compiler fixes. Apply these as one dependency-complete change, then compile the actual AppModule

### CODE-G0-01. `Package.swift:10–14`, localized resources and Apple CI (C01)

The effective target manifest must have precisely one `defaultLocalization: "en",` immediately after `name: "PersonalAssistant",` inside `Package(...)`:

```swift
let package = Package(
    name: "PersonalAssistant",
    defaultLocalization: "en",
    platforms: [
        .iOS("18.6")
    ],
    // LEAVE the original products, AppModule executable target,
    // appIcon, orientations and generated settings unchanged.
)
```

**The fragment is deliberately NOT a complete replacement Package.swift.** Modify the actual app candidate manifest by the supported Playgrounds-generated workflow or a recorded, deterministic package export transform; Apple Playgrounds may regenerate this file. In CI, a disposable patched copy is useful to reveal later errors but is NOT evidence that the actual imported iPad package is fixed. Preserve both `Resources/en.lproj` and `Resources/hi.lproj`; do not delete a locale merely to turn CI green. **One coherent check:** manifest resolves, real iOS target type-checks, `Bundle.module`/resource lookup and the actual iPad exported candidate are tested. See `06_*` for reproducible Mac build rather than a guessed scheme.

### CODE-G0-02. `Domain/ApprovalRequest.swift:31–83` plus policy/coordinator/persistence (C02)

**PINNED EDIT.** Current domain constructor has no `canonicalArguments`/`sessionGeneration`, while `Tools/ToolPolicyEngine.swift:67–81` passes them and `Security/ApprovalCoordinator.swift:33–57` reads them. Replace **only** the current `ApprovalRequest` struct with the following preserving all other domain declarations in the file:

```swift
struct ApprovalRequest: Identifiable, Codable, Sendable, Hashable {
    let id: ApprovalID
    let invocationID: UUID
    let toolID: String
    let schemaVersion: Int
    let ownerID: UserID
    let traceID: TraceID
    let payloadHash: Data
    let riskLevel: ToolRiskLevel
    let humanReadableSummary: String
    let recipient: String
    let dataClasses: [PrivacyClass]
    let canonicalArguments: Data
    let sessionGeneration: UUID
    let expiresAt: Date
    var status: ApprovalStatus
    let createdAt: Date
    var updatedAt: Date

    init(
        id: ApprovalID = ApprovalID(),
        invocationID: UUID,
        toolID: String,
        schemaVersion: Int,
        ownerID: UserID,
        traceID: TraceID,
        payloadHash: Data,
        riskLevel: ToolRiskLevel,
        humanReadableSummary: String,
        recipient: String,
        dataClasses: [PrivacyClass],
        canonicalArguments: Data,
        sessionGeneration: UUID,
        expiresAt: Date,
        status: ApprovalStatus = .pending,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.invocationID = invocationID
        self.toolID = toolID
        self.schemaVersion = schemaVersion
        self.ownerID = ownerID
        self.traceID = traceID
        self.payloadHash = payloadHash
        self.riskLevel = riskLevel
        self.humanReadableSummary = humanReadableSummary
        self.recipient = recipient
        self.dataClasses = dataClasses
        self.canonicalArguments = canonicalArguments
        self.sessionGeneration = sessionGeneration
        self.expiresAt = expiresAt
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
```

**Caller check:** `ToolPolicyEngine.swift` must use the exact constructor; `ApprovalCoordinator.swift` must read newly declared fields, validate the current trusted session and not accept a hash echoed by an untrusted UI as independent recomputation; `Features/Approvals/{ApprovalViewModel,ApprovalDetailView,ApprovalCenterView}.swift` must actually surface exact approval intent. **Persistence check:** `StoredApprovalRequest` (`Persistence/StoreModels.swift:283–322`) lacks these two fields. Add them only with an owner- and version-aware migration; do not discard existing user records. Completing the struct is a **compiler fix, NOT authorization completion**. G3 remains disabled until a real durable approval and receipt flow passes adversarial tests.

### CODE-G0-03. `Avatar/AvatarAssetCatalog.swift:8–44` and all AvatarIdentity users (C03)

**PINNED EDIT:** declare once at file scope, outside the current `AvatarAssetCatalog`:

```swift
enum AvatarIdentity: String, CaseIterable, Codable, Sendable, Hashable {
    case maya = "Maya"
    case saar = "Saar"
}

extension AvatarRole {
    var identity: AvatarIdentity {
        switch self {
        case .maya: .maya
        case .saar: .saar
        }
    }
}
```

**PINNED EDIT:** insert in existing `enum AvatarAssetCatalog` without deleting the valid `glowColors(for role: AvatarRole)` implementation:

```swift
static func primaryColor(for identity: AvatarIdentity) -> SwiftUI.Color {
    switch identity {
    case .maya: .init(hue: 0.55, saturation: 0.7, brightness: 0.85)
    case .saar: .init(hue: 0.08, saturation: 0.7, brightness: 0.85)
    }
}

static func secondaryColor(for identity: AvatarIdentity) -> SwiftUI.Color {
    switch identity {
    case .maya: .init(hue: 0.65, saturation: 0.6, brightness: 0.8)
    case .saar: .init(hue: 0.15, saturation: 0.7, brightness: 0.85)
    }
}

static func glowColors(for identity: AvatarIdentity) -> [SwiftUI.Color] {
    switch identity {
    case .maya: glowColors(for: AvatarRole.maya)
    case .saar: glowColors(for: AvatarRole.saar)
    }
}
```

**Mandatory callers** at pinned lines: `AvatarView:8–24,33,47–58`, `AvatarPickerView:8,14–26`, `AvatarStateController:12,29`, `Features/Assistant/AssistantProfileView:16`, `Features/Dashboard/AssistantHeader:6`; inspect `AssistantSwitcher` too. `DesignSystem/AppTheme.swift:61–67` ALREADY implements `AvatarRole.themeColor`. **Do not duplicate it.** Assert actual `Maya.imageset`/`Saar.imageset` resources resolve on device; `Image(identity.rawValue)` silently showing no image does not constitute success.

### CODE-G0-04. Other precise source edits (C04–C07,C11)

| Pin | Exact change | Proof |
|---|---|---|
| `Features/Onboarding/OnboardingView.swift:87–94` | Delete ONLY `extension AppSession { func completeOnboarding() async ... }` since `App/AppSession.swift:174–176` already owns this member. | No duplicate declaration; onboarding persistence tested separately. |
| `Features/Approvals/ApprovalDetailView.swift:18` | Replace `Text(request.summary)` with `Text(request.humanReadableSummary)`. Also show recipient and risk separately. | Approval detail compiles and user reviews exact typed intent. |
| `Features/Configuration/AIConfigurationView.swift:13` | Replace the literal with `Text("Temperature: " + temperature.formatted(.number.precision(.fractionLength(1))))`. | Linux parser accepts corrected grammar; real UI still needs persisted settings. |
| `AI/Providers/AppleFoundationModelProvider.swift:25` | Replace `AppError.unsupportedCapability(name: "...")` with `AppError.unsupportedCapability("...")`. `Domain/Errors.swift:17` is unlabeled. | The conditional provider file must still compile on the iOS target. |
| `Tasks/TaskPlanner.swift:8–15` | Do not reference missing `TaskStep`. Use the pure description planner below; do not auto-label unexecuted tasks completed. | Foundation-only portable test + AppModule compile. |
| `Tasks/TaskRunExecutor.swift:8–21` | Change `TaskStep` to canonical `TaskStepRecord`; require a real, injectable operation and propagate errors. | A deliberately throwing action never produces a completed step. |

**REFERENCE CODE, replaces the fake task planner:**

```swift
import Foundation

struct TaskPlanner: Sendable {
    static func planDescriptions(for goal: String) -> [String] {
        let trimmed = goal.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        return [
            "Analyze goal: " + trimmed,
            "Execute approved primary action",
            "Verify outcome and persist receipt"
        ]
    }
}
```

**REFERENCE CODE, executor of already-started local steps only (not an autonomous agent):**

```swift
import Foundation

actor TaskRunExecutor {
    func executeLocalStep(
        _ startedStep: TaskStepRecord,
        operation: @Sendable (TaskStepRecord) async throws -> Void
    ) async throws -> TaskStepRecord {
        guard startedStep.status == .running else {
            throw AppError.validationFailed(
                field: "step.status", reason: "Local step must be running"
            )
        }
        try Task.checkCancellation()
        try await operation(startedStep)
        try Task.checkCancellation()
        var finished = startedStep
        finished.status = .completed
        finished.completedAt = Date()
        return finished
    }
}
```

The caller must persist the `.running` step **before** beginning the real action, then persist `.completed` only after a verified operation result. An injected no-op closure is **not proof** that a calendar event, notification or external write happened. Externally ambiguous effects must go through the durable B05 ledger. V1 only promises real **local reminders**, not unbounded background LLM autonomy. Do not wire optional `TaskPlanner` into user-visible features without an executable path.

### CODE-G0-05. Mandatory compile command loop (C08–C11)

From Ubuntu VS Code use `scripts/check_swift_syntax.sh` and `portable_core_tests/` on **actual source copies**, but never call those an iOS build. On authorized macOS/CI, run `xcodebuild -version`, `xcodebuild -showsdks`, `xcodebuild -list` on the actual package, determine the **actual** scheme and use `xcodebuild ... CODE_SIGNING_ALLOWED=NO build`. Record exact Apple build logs on the exact SHA. If direct app playground build is unsupported, construct a validated Xcode wrapper referencing the SAME app source, then separately prove physical `.swiftpm` import. The package-generated `Package.swift` remains a special lifecycle risk; fixing a temporary CI copy cannot alone certify the iPad artifact.

## Part B: G1 AI/chat correction: one exact outbound message, model identity and durable terminal state

### CODE-G1-01. `Features/Dashboard/DashboardViewModel.swift:50–59`, `AppRouter.swift:18–59`, `ChatView.swift`, `ChatViewModel.swift` (A01)

**ALGORITHM CONTRACT:** exactly one owner of initial-draft consumption. Introduce a typed launch payload rather than only `AppSheet.chat(ConversationID)`:

```swift
struct ChatLaunchIntent: Hashable, Sendable {
    let conversationID: ConversationID
    let initialText: String
    let launchNonce: UUID     // generated once when user taps Send
}
```

**Atomic dependent edits:** update `AppSheet`'s associated case + `id` switch, `AppRouter.openChat`, `AdaptiveLayout.sheetDestination`, `ChatView` initializer/state and `ChatViewModel`'s one-shot launch consumer **together**. A SwiftUI `.task` may rerun; the unique `launchNonce` must be recorded in the durable message store, not merely an ephemeral `Set<UUID>`. Do not both insert in Dashboard and insert again in Chat. In `ChatViewModel.send()`, maintain one pending send identifier through retries/relaunch. A failed model/configuration preflight must leave the draft recoverable and cannot invent an assistant reply.

**Acceptance:** fake provider request recorder shows exactly one request with the original Quick Ask text after sheet re-presentation, and the on-disk conversation has exactly one corresponding user message.

### CODE-G1-02. `ModelPickerView:4–30`, `ProviderDetailView:65–108`, `ModelRouter:39–91`, `OpenAICompatibleProvider:141–174` (A02–A05)

**PINNED ROUTER GUARD:** inside the candidate-config loop, before choosing a provider, enforce identity and exact model:

```swift
guard config.ownerID == ownerID, config.isEnabled else { continue }
guard let raw = config.modelOverride?.trimmingCharacters(in: .whitespacesAndNewlines),
      !raw.isEmpty, raw != "default" else { continue }
let selectedModelID = raw
```

**Do not stop here:** replace the current provider's hardcoded fallback model (around `OpenAICompatibleProvider:150`) with the routed `selectedModelID`, either through a request `modelOverride` whose provenance was checked or a per-config provider. `ModelDescriptor.providerID`/registry keys must not mix `ProviderKind.rawValue` and `ProviderConfigID.uuidString`. **Do not infer tools/vision capability from substrings in model IDs.** A missing, unknown or expired capability claim fails the *required* capability. Persist actual selection and distinguish custom config IDs, base URLs and Keychain IDs. Dynamic model catalogs require owner/credentials and current privacy consent.

### CODE-G1-03. `ContextBuilder:14–93`, `HistoryRetriever:14–17`, `ChatViewModel:111–125` (A06,A13)

**ALGORITHM CONTRACT:** assemble one trusted system policy, owner-verified memories as **quoted untrusted data**, most-recent committed conversation messages sorted chronologically, and exactly one active user turn. The current `ContextBuilder` inserts memories as `role:.system` at `:40–46`; preserve provenance without elevating instructions. Reserve system+active query+output token margin before adding recent history and memory. Do not implement "summarization" by truncating oldest messages and calling it a summary. Pagination must fetch the newest page rather than the suffix of the first 50. Do not send rich attachment parts to a text-only model silently: typed unsupported-capability or an explicit user-approved extraction route.

### CODE-G1-04. `AssistantOrchestrator:31–160`, `ConversationRepository:54–180`, `OpenAICompatibleProvider:176–219` (A07–A10)

**PINNED BEHAVIOR:** remove `try?` around assistant checkpoint writes and `finishAssistantMessage`; when they fail, surface a typed persistence error and mark local UI status truthful. Commit an assistant placeholder or an explicit failure record before a network call so a zero-delta termination can be represented. Exactly one completion event; after any visible token, no silent provider fallback. Capture and revalidate session generation before/after every awaited boundary. At network dispatch, authorize egress freshly. At EOF without observed `[DONE]` or an explicitly documented provider-equivalent terminal event, return **interrupted**, not `.completed`.

**REFERENCE cancellation skeleton, add equivalent handling at BOTH `HTTPClient.stream` and provider stream:**

```swift
return AsyncThrowingStream { continuation in
    let producer = Task {
        do {
            // Stream from the already-authorized, redirect-safe URLSession child.
            // Check Task cancellation before each yield/checkpoint.
            // Emit at most one legitimate terminal event.
        } catch {
            continuation.finish(throwing: error)
        }
    }
    continuation.onTermination = { @Sendable _ in producer.cancel() }
}
```

The above is **NOT paste-ready production network code**. For credentialed `URLSession`, pass a **real redirect-rejecting delegate** to both data and byte-stream paths. Host allowlists must bind the exact normalized HTTPS origin, not default to unconstrained empty set. Verify that `Authorization` cannot be forwarded to any 30x target in tests. Current `HTTPClient.swift:88` contains only a comment promising a delegate; it does not exist. Instrument real cancellation through the lowest URLSession task/async-bytes child, not just an unused `streamTask.cancel()` string.

**REFERENCE redirect delegate for an Apple-compatible URLSession context:**

```swift
final class RejectCredentialRedirects: NSObject, URLSessionTaskDelegate {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        completionHandler(nil)
    }
}
```

For iOS 18.6 use available URLSession `data(for:delegate:)` and `bytes(for:delegate:)` or a configured isolated session; test on the installed Apple SDK. This redirect delegate alone does NOT perform current owner/consent/IP validation. Avoid `URLSession.shared` for an authorization-dependent client unless each task has a real redirect delegate and bounded response.

## Part C: G2 single privacy, session and Keychain authority

### CODE-G2-01. `AppSession:146–153`, `PrivacySettingsView:12–19`, `PrivacyRoutingView:56–78` (S08,S09)

**PINNED EDIT in `AppSession`, replace existing `updatePrivacyMode` body:**

```swift
func updatePrivacyMode(_ mode: PrivacyMode) async throws {
    guard let owner = currentProfile else { throw AppError.notAuthenticated }
    var next = preferences ?? AppPreference(ownerID: owner.id)
    next.privacyMode = mode
    next.updatedAt = Date()
    try await configurationRepository.savePreferences(next)
    preferences = next
    // Next integration change: revoke active external requests when
    // moving to .privateOnly, under a single central egress generation.
}
```

**MANDATORY callers:** both privacy screens must call THIS method, await success before showing saved status and roll back optimistic local selection on failure. `PrivacyRoutingView` currently writes directly to `ConfigurationRepository`, so AppSession and the router can disagree. `AssistantOrchestrator:42–43` defaults to `.cloudAllowed` if preference read fails: **replace with deny-outbound and a visible error**. Central `HTTPClient` egress must recheck current owner/session, exact destination-specific consent, privacy class and request type for BOTH `GET /models` and `POST /chat/completions`. A preference service actor must serialize concurrent updates. Tightening privacy must cancel preexisting in-flight cloud tasks; a new router filter alone is insufficient.

### CODE-G2-02. `KeychainVault:38–64,114–161` (S10)

**REFERENCE CODE, replace delete-before-add with update-first:**

```swift
let query: [CFString: Any] = [
    kSecClass: kSecClassGenericPassword,
    kSecAttrService: key
]
let update: [CFString: Any] = [kSecValueData: data]
let updateStatus = SecItemUpdate(query as CFDictionary, update as CFDictionary)
switch updateStatus {
case errSecSuccess:
    break
case errSecItemNotFound:
    let add: [CFString: Any] = [
        kSecClass: kSecClassGenericPassword,
        kSecAttrService: key,
        kSecValueData: data,
        kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    ]
    let addStatus = SecItemAdd(add as CFDictionary, nil)
    guard addStatus == errSecSuccess else {
        throw VaultError.writeFailed(status: addStatus)
    }
default:
    throw VaultError.writeFailed(status: updateStatus)
}
```

**Security caveats:** before applying, inspect original service/account query semantics and test `errSecDuplicateItem`, locked vault, restore and failed updates; a missing item is not an unlocked item. `removeAll` must account for config-specific custom Keychain IDs, not only five enum provider kinds; do not use unbounded indiscriminate Keychain deletion. The provider config transaction must not claim both key and model settings saved unless both persisted, or must perform explicit compensating repair.

### CODE-G2-03. Owner and session checks (S11–S16)

All repository writes should accept owner and current session authority and include owner predicates. `ConversationRepository.appendPendingUserMessage` currently inserts a message even when the conversation lookup returns nil (`:83–92`); change to `guard let ownedConversation = ... else { throw ownerMismatch/notFound }` **before** inserting, and use a stable per-message client ID/sequence transaction. In `MemoryRepository.verify/revise`, query on BOTH memory ID and owner UUID. A cross-owner ID must be indistinguishable from absent and cause **zero writes**. After every `await`, UI callback verifies captured generation; owner switch/lock cancels outstanding AI, voice and tool tasks. `AppSession.bootstrapLocalProfile:76–78` must show recovery instead of treating any DB exception as first-run.

## Part D: G3 real approval/receipt security (must stay disabled until all negative tests pass)

### CODE-G3-01. Canonical intent / approval / execution chain (S01–S07)

1. Decode every proposed tool's strict **typed** arguments, reject unknown keys and parse/normalize actual recipient, dates, length bounds and data classes. A successfully parsed arbitrary JSON object is NOT schema validation.
2. Freeze canonical payload fields: format version, owner UUID, session generation, tool ID/version, invocation ID, exact typed arguments, recipient, expiry, sensitivity classes and purpose. Encode with explicit length prefixes/field order or deterministic canonical JSON; verify the same bytes across approval and dispatch. SHA-256 is a **consistency digest**, not authentication against an attacker who can modify both record and hash. Match exact original typed payload at dispatch.
3. Persist approval payload and status with owner scope and a tested schema migration. UI shows real `ApprovalViewModel.pendingRequests`, recipient, argument summary and Approve/Reject. `ApprovalCenterView:9–22` currently always shows an empty state.
4. Recheck actual current permission, session and destination immediately before any external side effect. An authorization from a stale owner or revoked consent does not carry over.
5. The durable receipt store must reserve the operation **atomically and uniquely in one non-suspending database operation** and `try modelContext.save()` before execution; no in-memory production fallback. Unknown or ambiguous external effects must remain `needsReview`/`.ambiguous`, with zero automatic replay.

### CODE-G3-02. `StoreModels.swift:423–461` and `ToolReceiptStore.swift:24–105` schema implementation decision (S04–S05)

**REFERENCE code for an explicit unique scope key**, conditional on a successful versioned schema migration:

```swift
// Inside StoredToolReceipt (preserve original fields and initializers):
@Attribute(.unique) var scopedOperationKey: String
// Assign a stable canonical value, e.g. uppercase-unambiguous
// ownerUUID + ":" + operationKey normalized/hashed as approved.
```

**REFERENCE reservation algorithm (PSEUDOCODE, deliberately not Swift):**

```text
reserveAndCommitPrepared(ownerID, operationKey, intent):
    scope = canonicalOwnerID + ":" + canonicalOperationKey
    execute inside one isolated ModelContext transaction WITHOUT awaits:
        if receipt[scope] exists: return duplicate
        insert StoredToolReceipt(scope=scope, status=PREPARED, intent=validatedIntent)
        try modelContext.save()
        if save throws: rollback, propagate error, execute NOTHING
    return the newly committed PREPARED receipt
```

Gemini must implement this in the **real existing `ToolReceiptStore`**, not create a second model/ledger or paste a `fatalError` placeholder. The state machine also needs throwing durable transitions, a unique store key and actual restart recovery.

**Better narrow coding sequence:** add the migrated unique scoped key, implement one throwing reserve method, implement throwing receipt status transitions, connect `ToolInvocationCoordinator`, wire real pending UI, then run concurrent requests + injected save failure + restart-after-prepared tests. Only afterward enable a limited real tool. A fake “success” string from a tool without an actual OS operation is prohibited.

## Part E: G4 required local V1 features, no claims without behavior

### CODE-G4-01. Tasks: `TaskRecurrence.swift:28–75`, `LocalReminderScheduler.swift:14–53`, `TaskEditorView.swift:151–167`

The current recurrence ignores `daysOfWeek`, `dayOfMonth`, `afterCount` and `until`; its DST-gap fallback uses `DateComponents(minute:)` only. Algorithm: preserve original `TaskSchedule` timezone and wall-clock anchor; compute recurrence candidates from the anchor according to daily/weekly/monthly/yearly rules; filter weekday/month-day/end counts; resolve a nonexistent local time via a documented policy (e.g., next valid 03:00 for 02:30 spring gap); resolve ambiguous fall-back time via `.first`; enforce strictly increasing UTC instants, max iterations, and deterministic occurrence identity `owner + taskID + revision + intended UTC` with unique durable storage. Test US/Eastern 2026 DST, monthly 31, leap day and edited notification removal.

`LocalReminderScheduler` may request `.notDetermined` notification permission **only from explicit task-save action**. Task definition save and OS notification scheduling are distinct outcomes; show “Task saved; alert not scheduled” with permission instructions instead of silent catch. On edited tasks cancel old pending IDs first and write fresh IDs only after OS accepts them. On launch reconcile pending IDs and archived tasks. `BGTaskScheduler` cannot promise continuously running autonomous AI on iPad; gate optional background executors OFF until a real supported feature and evidence exist.

### CODE-G4-02. Voice: `VoiceCoordinator.swift:53–121`, `LegacySpeechRecognizer.swift:29–59`

Request microphone/speech permissions from an explicit user tap BEFORE evaluating capability readiness; refresh `CapabilityCenter` after granting. Create recognition request and retain `self.recognitionTask = task` **before** accepting microphone audio buffers. Current `VoiceCoordinator` starts capture first and hops non-Sendable `AVAudioPCMBuffer` across a `Task`; redesign into one documented Apple-compatible ownership/isolation strategy. On stop: increment voice generation synchronously to reject stale callbacks, cancel actual recognition/recording and TTS, remove tap, deactivate session, and only then publish fully idle when asynchronous cleanup finishes. Test stop/restart and background interruption on actual iPad. `VoiceConfigurationView.swift` must bind installed voice IDs to persisted individual Maya/Saar `VoiceSettings`, not local hardcoded strings.

### CODE-G4-03. Search/memory/media: `MemoryRepository:29–86`, `LocalTextIndex:7–40`, `HistorySearchCoordinator:16–20`, `AttachmentLifecycle:38–82`

Owner-constrain every mutation, index and query. Treat proposed memory as UNTRUSTED until explicit user verification. Remove deleted memory from persistent storage/index and Spotlight if opted in; a tombstone must be checked at dispatch for queued index workers. Build a durable owner-partitioned index or advertise title-only search honestly. MIME admission MUST positive-allowlist supported images/PDF/text with bounded decode/PDF pages/OCR; validate claimed MIME against magic bytes/UTType and never silently upload attachments to a text-only model. Store per owner in Application Support with UUID-only server filenames and safe escaped display names. **Never accept a caller-supplied absolute file URL for deletion**; look up the attachment by owner+ID, verify canonical containment and symlink policy, then delete only that stored path.

### CODE-G4-04. UI: `ModelPickerView`, `AIConfigurationView`, `VoiceConfigurationView`, `ToolPermissionsView`, `SettingsSubViews`, `ApprovalCenterView`

A visible enabled selection MUST be persisted and applied to the actual owner-scoped service, or visibly marked unavailable and disabled if V3 permits optional scope. Implement five reachable screens with real post-restart persistence. `SecuritySettingsView` currently says “Secure Enclave / Keychain”, but ordinary Keychain secret storage does not prove Secure Enclave key residency: fix misleading text. `SettingsView` clear-all is disabled; either implement true owner-safe confirmed deletion if mandatory V1 or clearly mark not available without promising it. All mandatory code remains buildable even when a conditional feature is runtime-disabled.

## Part F: evidence minimum for every one of the above edits

For each change produce `git diff --check`, exact changed paths, source + caller search (`rg -n`), Linux parser result where relevant, target real Swift XCTest, **actual Apple AppModule build log** on the exact SHA, error/fault-injection result for security-sensitive paths and precise user-visible outcome. **Review both the diff and the regenerated executable test artifact.** Do not use `scratch/verify_matrix.py` substring PASS as runtime evidence. The user must independently press Run on the final `.swiftpm` on their iPad before anyone declares ready.
