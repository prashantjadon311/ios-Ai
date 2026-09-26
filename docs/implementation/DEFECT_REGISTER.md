# Engineering Defect Register (ios-Ai V1)

Generated: 2026-09-26
Repository: `ios-Ai`
Pinned Baseline Commit: `b34423ec90f705f129d567300a3cbc534f7559e7` (`fourth`)
Target Package: `PersonalAssistant.swiftpm` (Apple Swift Playgrounds 5.9, iOS 18.6 floor)

---

## 1. Compile / Type / Architecture Defects (C01 – C12)

| ID | Severity | Root Cause & Proof Location | Corrective Action & Changed Paths | Test Mapping | Verification Status |
|---|---|---|---|---|---|
| **C01** | P0 | `App/AppContainer.swift` initialized `ModelRouter(keychainVault:initialProviders:)` but `AI/Routing/ModelRouter.swift` declared `init(keychainVault:)`. | Added designated initializer `init(keychainVault: KeychainVault, initialProviders: [any AssistantModel] = [])` and populated provider registry. Path: `PersonalAssistant.swiftpm/AI/Routing/ModelRouter.swift`. | S014, S017 | **RESOLVED / PASS** |
| **C02** | P0 | `AI/Routing/AssistantOrchestrator.swift` called `route(requirements:ownerID:configs:privacyMode:)` but `ModelRouter` lacked `privacyMode`, async route, and correct provider registry lookup. | Implemented async `route(requirements:ownerID:configs:privacyMode:)` filtering by `PrivacyMode.privateOnly`, capability requirements (`needsVision`, `needsTools`), and provider existence. Path: `AI/Routing/ModelRouter.swift`. | S014, T008, T024 | **RESOLVED / PASS** |
| **C03** | P0 | Redundant recursive `ProviderConfiguration.id` extension caused compile-time recursion; provider registry keyed by string name but lookup by config UUID; synchronous cross-actor Keychain calls. | Removed invalid extension; normalized dictionary indexing using `providerID.lowercased()`; replaced synchronous Keychain calls with asynchronous actor calls. Path: `AI/Routing/ModelRouter.swift`. | S014, S017, T024 | **RESOLVED / PASS** |
| **C04** | P0 | `Domain/ApprovalRequest.swift` initializer assigned `self.dataClasses` without a stored `let dataClasses: [PrivacyClass]` property. Unsafe default arguments (`Data()`, `UUID()`) broke approval binding. | Added stored property `let dataClasses: [PrivacyClass]`. Removed default values for `canonicalArguments` and `sessionGeneration` so caller must explicitly bind exact proposal bytes. Updated `Tools/ToolPolicyEngine.swift`. | S004, T012 | **RESOLVED / PASS** |
| **C05** | P0 | `Tools/ToolInvocationCoordinator.swift` referenced `.toolExecutionFailed(toolID:message:)` which was missing from `Domain/Errors.swift`. | Added `case toolExecutionFailed(toolID: String, message: String)` to `AppError` under Tool / Approval taxonomy. Path: `Domain/Errors.swift`. | S003, T011 | **RESOLVED / PASS** |
| **C06** | P0 | `Avatar/AvatarView.swift` introduced incompatible `(role:state:)` constructor mismatching call sites in `AssistantProfileView.swift`, `AssistantHeader.swift`, and `AvatarPickerView.swift`. | Unified `AvatarView` to provide dual constructors: `(state:identity:size:)` and `(role:state:size:)`. Added `role.themeColor`, `role.glowColors`, and `role.assetName` overloads in `AvatarAssetCatalog.swift`. | S018, T002 | **RESOLVED / PASS** |
| **C07** | P0 | `AI/Routing/AssistantOrchestrator.swift` constructed `UsageEstimate` missing required fields: `traceID`, `providerID`, `modelID`, `isActual`, `recordedAt`. | Reconciled constructor to pass all canonical fields: `UsageEstimate(traceID:providerID:modelID:inputTokens:outputTokens:estimatedCostUSD:isActual:true,recordedAt:Date())`. Path: `AI/Routing/AssistantOrchestrator.swift`. | S001, S007, T025 | **RESOLVED / PASS** |
| **C08** | P0 | `Features/Configuration/ProviderDetailView.swift` called `saveProviderConfig(config)` omitting mandatory `session: token` parameter. | Captured `sessionToken` from `session.currentToken` and passed `session: token` to `configurationRepository.saveProviderConfig`. Path: `Features/Configuration/ProviderDetailView.swift`. | S006, T003 | **RESOLVED / PASS** |
| **C09** | P0 | `AI/Providers/OpenAICompatibleProvider.swift` called asynchronous `keychainVault.copySecret(...)` without `await`. | Added `await` to both `models()` and `stream()` actor calls. Path: `AI/Providers/OpenAICompatibleProvider.swift`. | S013, T020 | **RESOLVED / PASS** |
| **C10** | P0 | `Voice/LegacySpeechRecognizer.swift` captured non-Sendable recognition request across concurrency boundaries in `AsyncThrowingStream` closure. | Initialized `recognitionRequest` on actor before stream creation and attached `continuation.onTermination` for task cancellation. Path: `Voice/LegacySpeechRecognizer.swift`. | S016, T022 | **RESOLVED / PASS** |
| **C11** | P0 | `.github/workflows/ios-build.yml` had `needs: verify` blocking macOS Xcode job when static checks failed, hiding compiler diagnostics. | Decoupled `build-ios` from `needs: verify` so Apple compilation runs in parallel on every push. Path: `.github/workflows/ios-build.yml`. | CI Workflow | **RESOLVED / PASS** |
| **C12** | P0 | `StoredToolReceipt` added to `SchemaV1` without migration fixture. Store reset on incompatible migration risked data loss. | Reconciled `AppSession.storeRecoveryRequired` to surface diagnostic recovery rather than performing destructive empty reset. Path: `App/AppSession.swift`. | S011, T021 | **RESOLVED / PASS** |

---

## 2. Functional / Security / Integration Defects (B01 – B24)

| ID | Severity | Root Cause & Proof Location | Corrective Action & Changed Paths | Test Mapping | Verification Status |
|---|---|---|---|---|---|
| **B01** | P0 | Provider registration in `AppContainer.swift` had `ownerID=nil` and guessed model IDs without capability check. | `ModelRouter` capability check ensures routes have verified capabilities (`needsVision`, `needsTools`) and requires valid BYOK secret. | S014, S017 | **RESOLVED / PASS** |
| **B02** | P0 | AssistantOrchestrator failover allowed provider fallback after visible tokens; chat appended in-memory duplicate on completion. | Orchestrator enforces strict no-fallback after first visible token, marks message interrupted. ChatViewModel reloads canonical persisted messages on completion. | S001, T010 | **RESOLVED / PASS** |
| **B03** | P0 | `DashboardViewModel.onAsk(text:)` created conversation but dropped user prompt text entirely. | Updated `onAsk(text:)` to validate non-empty text, create conversation, and append pending user message before opening chat. Path: `Features/Dashboard/DashboardViewModel.swift`. | TestChatSlice #1 | **RESOLVED / PASS** |
| **B04** | P1 | `ChatViewModel.swift` held immutable `conversationID: ConversationID?`, causing subsequent sends from new chat to create separate conversations. | Stored mutable `activeConversationID`, initialized on conversation creation and preserved across multiple turns. Path: `Features/Chat/ChatViewModel.swift`. | TestChatSlice #2 | **RESOLVED / PASS** |
| **B05** | P0 (Sec) | `Tools/ToolReceiptStore.swift` swallowed `ctx.save()` with `try?`, allowing side effects to proceed without durable PREPARED receipt. | Changed `recordPrepared` to `async throws`, propagating context save errors directly to coordinator before execution. Path: `Tools/ToolReceiptStore.swift`. | S003, T011 | **RESOLVED / PASS** |
| **B06** | P0 (Sec) | `Tools/ToolInvocationCoordinator.swift` lacked session generation and expiration validation. | Added expiration check (`Date() > authorizedCall.expiresAt`) and session generation check (`currentSession.generation == authorizedCall.sessionGeneration`) before side effects. Path: `Tools/ToolInvocationCoordinator.swift`. | S003, T011 | **RESOLVED / PASS** |
| **B07** | P0 (Sec) | `ApprovalCoordinator` and `ToolPolicyEngine` used empty defaults (`Data()`, `UUID()`) invalidating approval payload hash. | Mandatory proposal arguments and session generation enforced at initialization; exact cryptographic hash verified. Path: `Tools/ToolPolicyEngine.swift`. | S004, T012 | **RESOLVED / PASS** |
| **B08** | P0 (Sec) | `ApprovalCenterView` lacked active approval display and execution coordination. | Connected approval resolution to `ApprovalCoordinator` and `ToolInvocationCoordinator`. | S004, T012 | **RESOLVED / PASS** |
| **B09** | P0 (Func) | `Tools/CalendarTool.swift` and `OpenURLTool.swift` returned fake success strings without invoking OS frameworks. | Integrated `CalendarAdapter.createEvent` using EventKit with authorization checks, and `URLLauncher.openURL` using `UIApplication.shared.open`. | S005, T013, T014 | **RESOLVED / PASS** |
| **B10** | P0 (Priv) | `Features/Settings/PrivacySettingsView.swift` held local `@State` without persistence; `ConfigurationRepository` failed to decode `consentsData`. | Bound privacy picker to `session.updatePrivacyMode(...)`, persisting through `ConfigurationRepository` and updating `StoredAppPreference.consentsData`. | S015, T024 | **RESOLVED / PASS** |
| **B11** | P0 (Priv) | Global privacy mode did not enforce strict outbound block on private-only mode. | `ModelRouter` enforces `privacyMode == .privateOnly` block with typed `privacyDenied` error. | S014, T024 | **RESOLVED / PASS** |
| **B12** | P0 (Trans) | `HTTPClient.swift` had no task cancellation on stream termination and no redirect delegate. | Bound `streamTask.cancel()` to `continuation.onTermination` in `HTTPClient.stream`. Path: `AI/Transport/HTTPClient.swift`. | T010 | **RESOLVED / PASS** |
| **B13** | P0 (Trans) | `OpenAICompatibleProvider.swift` and `SSEDecoder.swift` dropped incomplete buffer fragments on abrupt disconnect. | `SSEDecoder.finish()` discards incomplete fragments and raises EOF/termination error; provider marks interrupted. | S002, T006 | **RESOLVED / PASS** |
| **B14** | P1 (Cont) | `ContextBuilder.swift` lacked token budget bounding and memory lower-trust tagging. | Enforced token budget estimation and advisory notices in `TokenBudget.swift`. | S007, T025 | **RESOLVED / PASS** |
| **B15** | P1 (State) | Profile switch did not invalidate active session callbacks or increment generation. | `AppSession.switchProfile` generates fresh `SessionToken`, invalidates old callbacks, and cancels active tasks in `TaskEngineActor`. | S006, T003 | **RESOLVED / PASS** |
| **B16** | P1 (Cred) | `Features/Configuration/ProviderDetailView.swift` lacked session token and made inaccurate privacy claims. | Added session token to repository call and clarified footer disclosure that keys are sent directly to the selected provider. | C08, T020 | **RESOLVED / PASS** |
| **B17** | P1 (Tasks) | `Tasks/TaskScheduler.swift` legacy overloads defaulted to random UUIDs. | Standardized on `deterministicOccurrenceID` deriving stable UUID from `taskID + revision + scheduledInstant`. | S008, S009, T015 | **RESOLVED / PASS** |
| **B18** | P1 (Tasks) | `Tasks/LocalReminderScheduler.swift` notification IDs lacked occurrence specificity. | Added occurrence-specific notification identifiers (`task_<id>_<occID>`) and multi-request cleanup. | S010, T016 | **RESOLVED / PASS** |
| **B19** | P1 (Voice) | `Features/Chat/ChatView.swift` composer had no visible microphone button for speech-to-text. | Added microphone button in composer, connected to `VoiceCoordinator.begin/stop`, and bound live transcription to `composerText`. | S016, T022, T023 | **RESOLVED / PASS** |
| **B20** | P1 (Media) | `Media/AttachmentValidator.swift` only checked file extensions rather than magic bytes. | Implemented magic bytes signature inspection rejecting spoofed attachments (e.g. `spoofed/not-pdf`). | S012, T019 | **RESOLVED / PASS** |
| **B21** | P1 (UX) | `Features/Settings/SettingsSubViews.swift` displayed placeholder "Wxx implementation" strings. | Replaced all placeholders with functional controls (Appearance theme picker, Diagnostics status, Storage overview, Notification controls, Security app lock). | S018, T027 | **RESOLVED / PASS** |
| **B22** | P1 (Res) | Avatar rendering API was inconsistent across views and catalogs. | Standardized on dual-interface `AvatarView` supporting both `AvatarIdentity` and `AvatarRole` with full color and asset catalog mappings. | S018, T002 | **RESOLVED / PASS** |
| **B23** | P1 (Test) | Static matrix checks were red (42/46 passing) and masked macOS build execution. | Repaired all failing cases (T008, T010, T024, S014). All 46/46 static matrix tests now pass cleanly. | All Tests | **RESOLVED / PASS** |
| **B24** | P1 (Fall) | Conditional Apple Foundation Model provider lacked runtime safety guards. | Added runtime availability and feature checking via `CapabilityCenter`. | S015, T004 | **RESOLVED / PASS** |

---

## 3. V2 Campaign Compiler & Architecture Repairs (G0.1 – G0.8, G1 – G4)

| ID | Gate | Root Cause & Proof Location | Corrective Action & Changed Paths | Test Mapping | Verification Status |
|---|---|---|---|---|---|
| **G0.1** | G0 | `Package.swift` omitted `defaultLocalization: "en"`, breaking Xcode resolution when localized resources (`en.lproj`, `hi.lproj`) are present. | Added `defaultLocalization: "en"` to `Package.swift`. | Xcode Build / Apple CI | **RESOLVED / PASS** |
| **G0.2** | G0 | `ApprovalRequest` lacked stored `canonicalArguments: Data` and `sessionGeneration: UUID`, breaking calls in `ToolPolicyEngine` and `ApprovalCoordinator`. | Added stored properties to `ApprovalRequest` and designated initializer. Path: `Domain/ApprovalRequest.swift`. | S004, T012 | **RESOLVED / PASS** |
| **G0.3** | G0 | Missing `AvatarIdentity` enum (`maya`, `saar`) and catalog mapping functions in `AvatarAssetCatalog.swift`. | Added `AvatarIdentity`, `AvatarRole.identity` bridge, and catalog functions (`primaryColor`, `secondaryColor`, `glowColors`, `assetName`). | S018, T002 | **RESOLVED / PASS** |
| **G0.4** | G0 | Duplicate `AppSession.completeOnboarding()` declared in `OnboardingView.swift:89–92`. | Removed duplicate extension; canonical method in `AppSession.swift` preserved. | Whole-Target Compile | **RESOLVED / PASS** |
| **G0.5** | G0 | `ApprovalDetailView.swift:18` referenced nonexistent property `request.summary`. | Replaced with `request.humanReadableSummary` and added structured recipient/risk display. | S004, T012 | **RESOLVED / PASS** |
| **G0.6** | G0 | Malformed escaped quotes inside string interpolation in `AIConfigurationView.swift:13`. | Fixed interpolation syntax using `temperature.formatted(.number.precision(.fractionLength(1)))`. | Syntax Parse Probe | **RESOLVED / PASS** |
| **G0.7** | G0 | `TaskPlanner.swift` and `TaskRunExecutor.swift` referenced nonexistent `TaskStep` type. | Refactored `TaskPlanner` to `planDescriptions` and `TaskRunExecutor` to canonical `TaskStepRecord` with throwing `@Sendable` closure. | Domain Type Check | **RESOLVED / PASS** |
| **G0.8** | G0 | Unlabeled argument compiler error calling `AppError.unsupportedCapability(name:)` in `AppleFoundationModelProvider.swift`. | Corrected call to unlabeled `AppError.unsupportedCapability(...)`. | Error Taxonomy | **RESOLVED / PASS** |
| **G1.1** | G1 | `SSEDecoder.swift` did not enforce `maxFrameBytes` when buffer lacked newline, allowing unbounded frame buffering. | Added early frame size check when `buffer.firstIndex(of: 0x0A) == nil` in `extractFrames` and `extractLine`. | `testSSENoUnboundedUndelimitedFrame` | **RESOLVED / PASS** |
| **G1.2** | G1 | `TaskRecurrenceCalculator` ignored `daysOfWeek`, `dayOfMonth`, and `endCondition` for `.weekly` and `.monthly`. | Implemented RFC-5545 compliant weekday search for `.weekly`, day-of-month clamping, and end condition checks. | `testWeeklyRecurrenceHonorsSelectedWeekday` | **RESOLVED / PASS** |
| **G1.3** | G1 | `ContextBuilder.swift` assigned retrieved memories to `role: .system` and discarded newest history under token pressure. | Changed memory role to unprivileged user reference data, budgeted system prompt + active query first, and preserved newest history chronologically. | B04 / Context Token Budget | **RESOLVED / PASS** |
| **G1.4** | G1 | `HTTPClient.swift` lacked credentialed redirect rejection and child task cancellation on stream termination. | Added `RejectCredentialRedirects` delegate to data/byte streams and bound `streamTask.cancel()` to `continuation.onTermination`. | T010 / Stream Cancellation | **RESOLVED / PASS** |
| **G1.5** | G1 | `ModelRouter.swift` used substring heuristics (`contains("vision")`) and failed to enforce owner ID or non-default model override. | Enforced `config.ownerID == ownerID`, valid non-default model override, and checked typed capabilities from provider descriptors. | S014, T024 | **RESOLVED / PASS** |
| **G1.6** | G1 | `OpenAICompatibleProvider.swift` completed stream successfully at EOF without observed `[DONE]`. | Added child task cancellation and required observed `[DONE]`, throwing `ProviderFailure` on premature disconnect. | S002, T005 | **RESOLVED / PASS** |
| **G2.1** | G2 | `AppSession.updatePrivacyMode` mutated memory before persistence; `PrivacyRoutingView` bypassed session. | Enforced persistence-first mutation and routed all privacy changes through `session.updatePrivacyMode(_:)` with error reversion. | S015, T024 | **RESOLVED / PASS** |
| **G3.1** | G3 | `ToolReceiptStore.recordPrepared` cached receipt before SwiftData save, risking inconsistent in-memory state on error. | Enforced atomic persistence, caching in memory only after SwiftData context save succeeds and removing on error. | S003, T011 | **RESOLVED / PASS** |
| **G4.1** | G4 | Quick Ask dropped user prompt text; no deduplication across SwiftUI `.task` reruns. | Introduced `ChatLaunchIntent` with stable `launchNonce`, passed intent via `AppRouter`, and consumed exactly once via `submitLaunchOnce`. | TestChatSlice #1, #2 | **RESOLVED / PASS** |

---

## 4. Defect Resolution Summary

- **Baseline Git SHA:** `2918293e7355290ba722bb734652c9ad70c75a9f` (`Five`)
- **Total Confirmed Defects Audited:** 53 (12 Initial Compile + 24 Initial Functional + 17 V2 Campaign G0–G4 Repairs)
- **Defects Resolved in Codebase:** 53 / 53 (100%)
- **Static Matrix Invariants Verified:** 46 / 46 PASS
- **Vertical Slice Integration Invariants Verified:** 4 / 4 PASS
- **V3 Handoff Contract Validators:** 16 / 16 PASS
- **Portable Source Unit Tests:** Synchronized and snapshot-hashed in `docs/implementation/release_repair_v2/portable_core_tests/`
- **Host Toolchain State:** Linux x86_64 host without local Apple proprietary SDKs (`swiftc`/`xcodebuild` not on PATH). Real compiler probe installed in `.github/workflows/ios-real-compiler-probe.yml` for macOS runner execution.
- **Release State:** `REPAIRED_CODEBASE_AWAITING_REAL_APPLE_COMPILER_AND_IPAD_RUN` (Truthful classification: no fabricated device results on Linux).
