# 01. Full-tree source audit and defect register (pinned fifth commit)

**HEAD inspected:** `2918293e7355290ba722bb734652c9ad70c75a9f` (`Five`, 2026-09-26). **Scope:** GitHub's complete 314-entry tree; all 187 nonempty Swift source files fetched and structurally scanned for declarations, empty implementations, optional failure suppression and obsolete symbols; focused cross-file semantic inspection of app composition, every primary screen, AI routing and SSE, domain models, storage, voice, tasks, tools, security, UI and release evidence. All 36 files changed from fourth to fifth were separately compared. Actual CI job output was obtained directly. **Limit:** targeted manual code review and whole-tree structural scan are not an Apple compiler, comprehensive runtime test, full static analyzer or iPad test. Revalidate all line anchors if local HEAD differs.

**File-link prefix:** `https://github.com/prashantjadon311/ios-Ai/blob/2918293e7355290ba722bb734652c9ad70c75a9f/PersonalAssistant.swiftpm/`. Append the exact relative path and `#Lx-Ly` to open any source entry in this report. App workflow links start at repository root.

## 1. Evidence outranks the existing release reports

| Gate | Actual published observation | Release interpretation |
|---|---|---|
| Tree | 314 Git entries, 187 nonempty Swift files; 413,697 bytes of Swift source | File presence only; many files are shells or incomplete integrations. |
| GitHub Actions fifth-commit run [36222465812](https://github.com/prashantjadon311/ios-Ai/actions/runs/36222465812) | Overall **FAILURE** | Not a compiled candidate. |
| `20_VALIDATE_HANDOFF.py` | 16/16 passed | Documentation structure only. |
| `scratch/verify_matrix.py` | **45/46** passed; **T010 failed** | Python substring test only, not runnable Swift behavior. |
| `scratch/test_chat_slice.py` | **SKIPPED** by CI | Local 4/4 claim is not verified on published HEAD, and the script itself is substring inspection. |
| macOS Xcode | Started, fell back from missing `Xcode_16.0.app` to 15.4; `xcodebuild` exit 74 | **Failed before Swift target compilation**: missing `defaultLocalization` with `.lproj` files. |
| Committed Swift XCTest / Swift Testing target | No test files or `Tests/` directory found | No executable Swift integration/security test evidence. |
| Physical iPad | No actual evidence supplied | `NOT_RUN`. |

**Contradicted documents:** `docs/implementation/{FINAL_AUDIT_A,FINAL_AUDIT_B,RELEASE_EVIDENCE,IMPLEMENTATION_CHECKPOINT}.md` declare broad completion / no open defects despite the independent failed CI and the confirmed compile contradictions below. The old reports must be superseded by a dated corrective addendum, not silently treated as current fact.

## 2. Full-tree coverage by subsystem

| Surface | Swift files fetched/scanned | What the second-pass review traced | Observed state |
|---|---:|---|---|
| AI / Context / Providers / Routing / Transport | 21 | ModelConfig → Keychain → router → provider → HTTP/SSE → persisted turn, memory/context | Not end-to-end proven; multiple security/runtime defects |
| App / session / composition | 6 | Bootstrap, session generation, provider registry, preferences, task lifecycle | Integrations incomplete; stale-session and recovery issues |
| Avatar | 5 | Identity type and both view constructors, catalog and resources | Confirmed compile contradictions |
| Content and entry | 2 | `@main`, container init, root route and recovery | Entry point present, device not proven |
| Design system | 9 | Adaptive routing, app lock, avatar theme extension | App theme helper is valid; client UI depends on broken types |
| Domain | 16 | DTO ownership, approvals, tasks and identifiers | Missing ApprovalRequest fields; `TaskStep` name inconsistency |
| Features | 52 | Dashboard/Tasks/History/Configuration/Settings/Chat/Approvals/Memory/Onboarding | Multiple controls locally simulated or disconnected; duplicate member definition |
| Integrations | 6 | Calendar, reminders, URL, contacts, Shortcuts | Some adapters real; no end-to-end dispatch or comprehensive OS proof |
| Media | 7 | Picker → MIME check → file ownership → repository → cleanup | Incomplete owner-bound lifecycle and MIME acceptance |
| Persistence | 12 | SwiftData schema/mappers, context isolation, owner scope, migrations, idempotency | Corruption fallbacks, weak ownership guards, unsafe receipt writes |
| Search | 5 | History queries, local index, Spotlight | Partially title-only; index not tenant-partitioned |
| Security | 11 | Approval, privacy, URL safety, Keychain, session, encryption | Fail-closed assertions unproven; multiple directly insecure paths |
| Tasks | 13 | Definition → schedule/recurrence → occurrence/run → notifications → recovery | Recurrence semantics incomplete; task planner/executor use undefined type |
| Tools | 13 | Registry → schema/policy → approval → receipt → real OS executor | Unsafe if enabled; absent atomic ledger/real model-tool loop |
| Voice | 8 | Permission → audio tap → recognizer → transcription → UI/TTS | Audio buffering/isolation/permission state need correction and on-device evidence |
| Package/CI/resources | 1 manifest + workflow and resources | Manifest resolution, Apple SDK selection, localization, asset and privacy manifests | Actual macOS build failed; resource availability unproven |

### Evidence classification

- **CONFIRMED_SOURCE:** the pinned code directly lacks a definition, ignores data, hardcodes a view, suppresses an exception or provides a mismatched signature.
- **OBSERVED_CI:** the exact published GitHub Actions run confirms failure or a skipped step.
- **HIGH_RISK_UNVERIFIED:** inspection indicates a likely concurrency, OS permission or production risk that requires an actual Apple compiler, simulator or device to decide definitively.
- **FUTURE_OR_CONDITIONAL:** a stub is acceptable only if the frozen V3 scope truly excludes it and all UI and runtime paths gate it off. Presence alone is not evidence of functionality.

## 3. P0 compilation and build blockers (must be repaired first)

**C01 · OBSERVED_CI.** `Package.swift:10–14` omits `defaultLocalization` while `Resources/{en,hi}.lproj/Localizable.strings` exist. The real Xcode job aborts before type-checking. **Repair:** supported effective manifest default localization + reproducible Playgrounds export; do not presume a hand edit to the generated manifest survives re-export. [Official Apple documentation](https://developer.apple.com/documentation/xcode/localizing-package-resources).

**C02 · CONFIRMED_SOURCE.** `Domain/ApprovalRequest.swift:31–83` does not declare or initialize `canonicalArguments: Data` and `sessionGeneration: UUID`; both are passed by `Tools/ToolPolicyEngine.swift:67–81`, and `Security/ApprovalCoordinator.swift:33–57` reads them. **Repair:** modify DTO and all readers/callers together, then persist the exact payload and generation in a versioned approval record. [DTO](https://github.com/prashantjadon311/ios-Ai/blob/2918293e7355290ba722bb734652c9ad70c75a9f/PersonalAssistant.swiftpm/Domain/ApprovalRequest.swift#L31-L83).

**C03 · CONFIRMED_SOURCE.** No `AvatarIdentity` enum or `AvatarRole.identity` bridge was found in the 187-file scan; `Avatar/AvatarView.swift:8–24`, `AvatarPickerView.swift:8–25`, `AvatarStateController.swift:12,29`, `Features/Dashboard/AssistantHeader.swift:6`, and `AssistantProfileView.swift:16` require it. `AvatarAssetCatalog.swift:10–43` has `glowColors(for: AvatarRole)` but not `primaryColor/secondaryColor/glowColors(for: AvatarIdentity)` called by `AvatarView:33,47–48`. **Repair:** one canonical bridge and the missing catalog APIs; verify assets. **Important erratum:** `AvatarRole.themeColor` **already exists** in `DesignSystem/AppTheme.swift:61–67` and must be preserved.

**C04 · CONFIRMED_SOURCE.** Duplicate `AppSession.completeOnboarding()` exists at `App/AppSession.swift:174–176` and `Features/Onboarding/OnboardingView.swift:89–92`. Both have same parameter/result signature. **Repair:** leave one canonical method in `AppSession`, remove the obsolete extension. Verify persistence of onboarding completion rather than just setting a volatile Boolean.

**C05 · CONFIRMED_SOURCE.** `Features/Approvals/ApprovalDetailView.swift:18` calls `Text(request.summary)`; the canonical DTO exposes `humanReadableSummary`, not `summary`. **Repair:** use `request.humanReadableSummary`, and show `request.recipient`, risk and exact approved arguments separately.

**C06 · CONFIRMED_SOURCE + isolated Swift parser probe.** `Features/Configuration/AIConfigurationView.swift:13` escapes the format-string quotes *inside* string interpolation: `String(format: \"%.1f\", temperature)`. An equivalent standalone snippet failed `swiftc -frontend -parse` with unmatched interpolation/unterminated string; the correctly quoted form passed. **Repair:** use `Text("Temperature: " + temperature.formatted(.number.precision(.fractionLength(1))))`; then wire controls to real configuration.

**C07 · CONFIRMED_SOURCE.** `Tasks/TaskPlanner.swift:8–12` and `Tasks/TaskRunExecutor.swift:8–17` construct and mutate `TaskStep`. `Domain/TaskStep.swift:1–9` contains no type and explicitly delegates ownership to `TaskStepRecord` in `Domain/TaskDefinition.swift:209–249`. The complete type scan did not find a `TaskStep` declaration. **Repair:** refactor planner and executor around `TaskStepRecord` with `runID`, `description`, `status` and `completedAt`; never fabricate completion without executing a real step.

**C08 · OBSERVED_CI.** `.github/workflows/ios-build.yml` explicitly falls back to Xcode 15.4 when Xcode 16.0 is absent and hardcodes a guessed scheme. iOS 18.6 target suitability and actual build scheme are not checked before invocation. **Repair:** discover installed SDKs and package schemes; use a compatible runner/toolchain, fail the gate when unavailable, retain `.xcresult` artifacts and all diagnostics. Preserve independence from Python static checks.

**C09 · HIGH_RISK_UNVERIFIED.** `Persistence/{Conversation,Configuration,Task,Memory}Repository.swift` repeatedly return SwiftData `@Model` instances from `MainActor.run` into separate actor contexts before mapping them. The cross-actor transfer of non-Sendable model objects may be rejected or racy under strict concurrency. **Repair:** do all fetch-and-map work in one isolated `ModelContext` executor and return only Sendable domain DTOs. Compile with the installed strict concurrency mode before asserting validity.

**C10 · OBSERVED.** There is no published successful Swift AppModule type-check after C01; independent review cannot certify absence of additional compiler errors. **Repair:** treat subsequent Xcode diagnostics as new defects, not as evidence that code was 'already complete'.

**C11 · CONFIRMED_SOURCE, COMPILER CANDIDATE.** `AI/Providers/AppleFoundationModelProvider.swift:24–26` calls `AppError.unsupportedCapability(name: ...)`, but `Domain/Errors.swift:17` defines `case unsupportedCapability(String)` with an **unlabeled** argument. The conditional provider is included in the AppModule Swift source graph even though runtime-gated. Correct the invocation to `AppError.unsupportedCapability("...")`; do not delete the conditional provider or assume a false runtime flag exempts it from compilation. This was omitted in the previous six-file report.


## 4. AI, transport, BYOK and chat defects

**A01 · CONFIRMED_SOURCE.** `Features/Dashboard/DashboardViewModel.swift:50–59` receives `text` but only creates a conversation and opens the sheet; it never sends the supplied question. Dashboard Quick Ask loses user intent. Wire a unique draft/launch intent through `AppRouter` and `ChatViewModel`, ensuring exactly one stored user message and one provider request.

**A02 · CONFIRMED_SOURCE.** `Features/Configuration/ModelPickerView.swift:4–30` is a static list with local `@State`, never saves the selected `ProviderConfiguration.modelOverride`. `AIConfigurationView.swift:4–18` similarly has local-only token/temperature controls. `ProviderDetailView.swift:88–95` saves a provider config with no selected model; `ModelRouter.swift:89` returns the literal `"default"` when missing. Repair model selection/persistence before live chat.

**A03 · CONFIRMED_SOURCE.** `OpenAICompatibleProvider.swift:73,82,100` has optional ownerID, `models()` returns `[]` if nil, while `AppContainer.swift:71–89` constructs built-in providers without ownerID. An authenticated model catalog cannot work through this path. Create owner/config-aware provider instances or an explicit catalog request owner parameter.

**A04 · CONFIRMED_SOURCE.** `ModelRouter.swift:55` looks up broad `providerKind` strings (with a config UUID fallback) but no per-config factory for custom endpoints; `AppContainer.swift:71–89` registers Groq and OpenRouter only. `ProviderDetailView` permits `custom` but no complete base URL editor and no corresponding registered instance. Either implement distinct custom configuration/credential/URL bindings or mark it unavailable.

**A05 · CONFIRMED_SOURCE.** `ModelRouter.swift:59–72` infers vision/tool capability from substrings in model IDs and does not validate all required metadata (`needsJSON`, minimum context, verified model capabilities or effective request budget). Replace with typed `ModelDescriptor` comparisons where `.unknown` fails required capabilities.

**A06 · CONFIRMED_SOURCE.** `ChatViewModel.swift:111–125` constructs context by mapping currently visible messages. `AI/Context/ContextBuilder.swift:14–93` is not instantiated by the composition root or invoked for the turn: verified memories, budgeted recent history and actual system prompt are missing from the outbound chat path. `ContextBuilder.swift:40–46` additionally elevates retrieved content to role `.system`, a prompt-injection trust-boundary hazard. Repair the single context owner, recent-history ordering, budget reservation and untrusted-memory labeling; avoid duplicating the active user turn.

**A07 · CONFIRMED_SOURCE.** `AssistantOrchestrator.swift:42–43` uses `try?` on preferences and defaults to `.cloudAllowed` on read failure. **Privacy may fail open.** The router checks only a passed mode, not a fresh authorization at network dispatch. Add one central, destination-aware egress gate before `/models`, chat, custom endpoints and optional STT; deny requests on preference-read failures.

**A08 · CONFIRMED_SOURCE.** `AssistantOrchestrator.swift:84–90,109–114,120–126,135–151` suppresses message checkpoint and terminal-status persistence errors with `try?` yet emits UI success/interrupted events. `ConversationRepository.swift:119–138` also silently replaces failed JSON serialization with stale or empty bytes. Make persistence failures explicit; never say a conversation survived restart without successful commit.

**A09 · CONFIRMED_SOURCE.** `OpenAICompatibleProvider.swift:176–219` does not attach stream continuation termination to its inner `Task`; at EOF it emits `.completed` even if no valid terminal `[DONE]` was seen, and `try? decoder.finish()` hides malformed terminal bytes. `HTTPClient.swift:114–149` also lacks a retained cancellable child task / `onTermination`. UI stop (`ChatViewModel.swift:209–214`) clears current text, potentially losing the partial reply. Fix cancellation end-to-end and EOF semantics; T010 currently fails the Python static matrix as well.

**A10 · CONFIRMED_SOURCE.** `HTTPClient.swift:79–109,114–149` uses `URLSession.shared` by default and has **no redirect-blocking delegate**, despite comment at line 88 claiming one. Initial URL check does not guarantee redirect destination safety or header secrecy. Add an actual reject-all redirect delegate for credentialed requests and exact HTTPS origin enforcement; test both `/models` and streaming chat.

**A11 · CONFIRMED_SOURCE.** `HTTPClient.swift:53–56` defaults `allowedHosts` to the empty set, allowing any HTTPS host. `URLSafety.swift:29–90` validates literal strings but does not resolve DNS to reject private destinations for a privileged network fetch. Require a policy-bound verified destination and preserve user-entered custom URL trust boundaries; never forward Authorization on any redirect.

**A12 · CONFIRMED_SOURCE.** `OpenAICompatibleProvider.swift:152–158` sends `tools:nil` while the app advertises tool permissions and approvals. `AssistantOrchestrator.swift:92–93` ignores `.toolProposal`. No provider-to-approval-to-execution loop exists. Keep **all side-effecting tools disabled** until a typed, tested loop is connected; don't claim tool execution in V1 otherwise.

**A13 · CONFIRMED_SOURCE.** `AI/Context/ConversationSummarizer.swift:7–14` merely returns the last N messages. `HistoryRetriever.swift:14–17` reads the first 50 messages and returns their suffix, not the most recent messages of a long chat. Real bounded context requires correct descending pagination and provenance, or an honest recent-N-only behavior without calling it summarization.

**A14 · CONFIRMED_SOURCE.** `OpenAICompatibleProvider.swift:141–148` silently strips non-text context parts while rich attachments may appear in the UI. `AnyEncodable` at 49–64 converts unsupported JSON schema values to descriptions. If vision/tools are unavailable, reject with a typed capability error rather than losing the user's attachment or mangling tool schemas.

## 5. Security, approvals, privacy and storage defects

**S01 · CONFIRMED_SOURCE.** `ToolPolicyEngine.swift:36–40` accepts any parseable JSON rather than matching the exact tool's JSON Schema, required fields, length bounds, destination allowlist and type constraints. `ToolRegistry.swift` publishes tools whose executors are only descriptor shells. Deny unknown/unimplemented tools by default.

**S02 · CONFIRMED_SOURCE.** `ToolPolicyEngine.swift:85–102` computes SHA-256 over owner/generation/tool ID/schema/raw JSON without canonicalizing typed arguments and binding exact recipient/data classification/byte lengths. `ApprovalRequest.recipient` is filled with `definition.name`, not the actual URL/calendar destination (`ToolPolicyEngine.swift:75–79`). Approval summaries are not trustworthy until the arguments are parsed and normalized into a typed intent and hashed once with all security-relevant fields.

**S03 · CONFIRMED_SOURCE.** `ApprovalCoordinator.swift:8–69` keeps pending approvals in memory only; no durable rehydration, owner-bound session fetch, or transactional one-time consumption. `ApprovalViewModel.swift:23–27` just passes `request.payloadHash` back as `expectedPayloadHash` rather than independently deriving trusted execution payload. `ApprovalCenterView.swift:9–22` always shows "No Pending Approvals". Implement a functioning owner-scoped review UI and durable approval state before enabling tools.

**S04 · CONFIRMED_SOURCE.** `ToolReceiptStore.swift:9–15,24–69` accepts `modelContainer:nil` and writes in-memory PREPARED before the optional DB save. `ToolInvocationCoordinator.swift:37–57` awaits `receiptForOperationKey` then separately awaits `recordPrepared`, enabling a concurrent duplicate dispatch window. `StoredToolReceipt.operationKey` (`StoreModels.swift:427`) is not unique. Replace with one database-isolated, unique-key reserve-and-commit operation; forbid in-memory fallback in production.

**S05 · CONFIRMED_SOURCE.** `ToolReceiptStore.swift:74–102,175–195` returns from status updates and startup reconciliation even when fetch/save fails (`try?`). `ToolInvocationCoordinator.swift:59–69` reports executor success while the succeeded receipt may not have reached disk. On ambiguous transport failure, it records `.failed`, not necessarily `.ambiguous`. Require throwing state updates and explicit `needsReview` recovery.

**S06 · CONFIRMED_SOURCE.** `ToolInvocationCoordinator.swift:17–33` defaults `currentSession` to nil and only checks generation *if provided*. It does not recompute the canonical hash, validate owner/tool/config against current active session, or recheck current privacy/tool permissions at dispatch. Never execute on an absent or stale session.

**S07 · CONFIRMED_SOURCE.** `Features/Configuration/ToolPermissionsView.swift:11–27` has three `@State` toggles with **no persistence and no policy enforcement**. The UI asserts explicit confirmation even though the Approvals UI has no real pending queue. Disable the toggles or implement owner-scoped durable permissions and policy-bound execution together.

**S08 · CONFIRMED_SOURCE.** `Features/Settings/PrivacySettingsView.swift:12–19` optimistically changes state and suppresses failed `session.updatePrivacyMode` using `try?`; `PrivacyRoutingView.swift:56–78` saves preferences directly to the repository but does **not update AppSession's in-memory preferences**. `AppSession.swift:146–153` publishes changes before save succeeds. A failed or competing write can leave UI and network policy inconsistent. Use a single transactional preference service, show errors and revoke active streams on privacy tightening.

**S09 · CONFIRMED_SOURCE.** `Domain/PrivacyAndConsent.swift` models destination consent, but `Security/PrivacyPolicyEngine.swift:7–20` only checks mode and forbids `.secret` on cloud. It does **not** inspect `ConsentRecord` or the exact destination. `HTTPClient` cannot inspect user/current consent. Make explicit destination-specific egress authorization mandatory at dispatch.

**S10 · CONFIRMED_SOURCE.** `KeychainVault.swift:38–64,116–124` deletes the old credential before verifying a new secret can be written. `removeAll` lines 128–149 only deletes known provider-kind keys, not arbitrary custom config UUIDs; `hasSecret` lines 153–161 conflates locked and missing. Use a safe update/rotation path; track all owner credential namespaces and propagate typed locked/not-found errors.

**S11 · CONFIRMED_SOURCE.** `MemoryRepository.swift:29–66` mutates memory by ID/revision without ownerID/session validation. `deleteAndDeindex:71–86` tombstones in SwiftData but contains an explicit pending Spotlight deindex TODO. Require owner in all mutation predicates and a resilient cache/Spotlight deletion strategy; test owner A attempting to mutate B's memory.

**S12 · CONFIRMED_SOURCE.** `ConversationRepository.swift:54–92,97–179,207–225` accepts `SessionToken` but never validates its generation or that a target conversation existed/currently belonged to that owner before inserting user messages. `AppSession.swift:96–110` changes profile tokens, but chat callbacks and repositories do not uniformly reject old generations. Bind long-running operations to a current session authority and cancel/ignore stale callbacks.

**S13 · CONFIRMED_SOURCE.** `TaskRepository.swift:53–89,94–163` updates by task ID without owner predicate; `reserveOccurrenceKey` checks only task ID, fabricates `Data()` on encode failure and reconstructs corrupt keys using a **new random UUID**. No unique persisted occurrence-key constraint is shown. Reject corrupt data and owner mismatch; persist a normalized unique identity before scheduling.

**S14 · HIGH_RISK_UNVERIFIED.** `StoredApprovalRequest` (`StoreModels.swift:283–321`) lacks canonical arguments and session generation; `SchemaV1`/`AppMigrationPlan` has no migration stage. Blindly adding fields to an existing shipped V1 store may break users. Confirm whether any real on-device data exists and adopt a versioned migration with a non-destructive fixture before structural changes. `StoreBootstrap.swift:29–39` rightly avoids automatic wipe, but actual migration invocation and recovery UX still need device proof.

**S15 · CONFIRMED_SOURCE.** `AppSession.bootstrapLocalProfile:54–79` treats *any* store read failure as first-run onboarding; it can mask corruption and invites duplicate setup. `AppSession.switchProfile:96–110` replaces session token but never directly cancels network streams/voice/tool work. Errors must open read-only recovery; owner switching must cancel active work and validate tokens upon UI callbacks.

**S16 · CONFIRMED_SOURCE.** `AppLockView` shows a lock overlay, but locking via `AppSession.lock()` does not by itself cancel ongoing HTTP, speech or tool execution. The `BiometricGate` implementation authenticates on unlock; the full app lifecycle, app-switcher privacy overlay and background cancellation are unverified.

## 6. Tasks, voice, media, user interface and completeness

**T01 · CONFIRMED_SOURCE.** `Tasks/TaskRecurrence.swift:28–75` advances one interval but ignores `TaskRecurrence.daysOfWeek`, `dayOfMonth`, `endCondition.afterCount` and `.until`. Its DST fallback matches **only minute** (`DateComponents(minute:)`), potentially choosing a different hour. Implement complete recurrence semantics from the original wall-clock anchor and test DST, end conditions, month-end and leap day.

**T02 · CONFIRMED_SOURCE.** `TaskScheduler.swift:36–43` retains an overload with `occurrenceID: UUID = UUID()` that can reintroduce nondeterminism if used for recurring work. Persist a unique owner/task/revision/UTC occurrence key and prevent duplicate records under concurrency/restart.

**T03 · CONFIRMED_SOURCE.** `Tasks/LocalReminderScheduler.swift:14–39` checks permission but does not request `.notDetermined` from the relevant user action; it uses `Calendar.current` instead of the task's preserved time zone. `TaskEditorView.swift:151–167` swallows scheduling failure after save and dismisses without displaying 'saved but alert not scheduled'; on edit it does not explicitly cancel the old notification set before replacing them. Fix owner-visible notification state and cleanup.

**T04 · CONFIRMED_SOURCE.** `Tasks/TaskEngineActor.swift:10–40` only schedules/cancels a reminder; it never runs the recurring task state machine. `TaskRunExecutor.swift:8–18` previously marked a nonexistent `TaskStep` complete without performing actual work. `ContinuedBackgroundExecutor.swift:13–21` calls `setTaskCompleted(success:true)` immediately; `RemoteTaskSchedulerStub` does nothing. Required V1 is **real local reminder scheduling**, not 24/7 autonomous execution; disable misleading task-executor/background claims until supported.

**T05 · CONFIRMED_SOURCE.** `TaskRepository.swift:141–163` reconstructs TaskRun with omitted persisted `startedAt/completedAt`, so user-visible historical task status may lose timing fields even when storage has them. Correct mapper and roundtrip fixtures.

**V01 · CONFIRMED_SOURCE.** `VoiceCoordinator.swift:53–83` checks an existing voice-capability snapshot before requesting microphone/speech permissions; first-use permission flow may never begin. It starts the audio tap before the speech-recognition request and posts `AVAudioPCMBuffer` across a `Task` actor hop (`75–77`), making early buffer loss and strict-concurrency violations plausible. Own setup/capture/recognition in one verified isolation strategy with explicit permission requests.

**V02 · CONFIRMED_SOURCE.** `LegacySpeechRecognizer.swift:29–47` creates a local `recognitionTask` but never assigns it to its stored property at `:15`. `stopRecognition:53–60` cancels the stored property, so cancellation may not stop the real task. `VoiceCoordinator.stop()` clears state before asynchronous stop finishes and does not invalidate all old callbacks. Test stop/restart, background and denial on an iPad.

**V03 · CONFIRMED_SOURCE.** `Features/Configuration/VoiceConfigurationView.swift:4–18` selects from a hardcoded list in local state only, with no save, available-voice discovery or per-assistant binding. `ChatView.swift:113–121` invents a throwaway conversation UUID for voice before a real conversation exists. Implement persistent per-profile settings and explicit draft/send state.

**U01 · CONFIRMED_SOURCE.** `ApprovalCenterView.swift:9–22` always displays an empty-state message, even if `ApprovalCoordinator` has pending in-memory requests. `ApprovalDetailView` has the compile defect C05. No usable approval interaction exists.

**U02 · CONFIRMED_SOURCE.** `ModelPickerView`, `AIConfigurationView`, `VoiceConfigurationView` and `ToolPermissionsView` show enabled controls that modify **only local SwiftUI state**, with no persisted effect on actual services. `AppearanceSettingsView` also changes local-only `appearance`. Either wire owner-scoped persistent settings and runtime enforcement or disable/honestly label conditional controls.

**U03 · CONFIRMED_SOURCE.** `HistorySearchCoordinator.swift:16–20` searches conversation titles only; `HistoryViewModel.swift:24–31` searches title and `lastMessagePreview`, not full message content or memory provenance. Don't advertise full content search without owner-scoped indexing and deletion/consent tests.

**U04 · CONFIRMED_SOURCE.** `OnboardingView.swift:27–35` finishes onboarding only in memory. `AppSession.bootstrapLocalProfile` treats a nonempty profile list as completed on subsequent launch; verify an interrupted first-run recovery and persisted onboarding state, not mere button navigation.

**U05 · CONFIRMED_SOURCE.** `SettingsSubViews.swift:38–46` states zero credential logging and local-only diagnostics without an executed log/transport policy audit; `SecuritySettingsView:100–115` calls ordinary Keychain storage 'Secure Enclave / Keychain', an imprecise security promise absent evidence of Secure Enclave keys. Replace unverified marketing assertions with accurate, tested disclosures.

**M01 · CONFIRMED_SOURCE.** `Media/AttachmentValidator.swift:36–55` only checks magic bytes for three *claimed* types. Unknown/unsupported MIME labels can pass without positive allowlisting. The 20 MiB data cap does not bound PDF pages/decompression/OCR time. Reject unsupported classes, validate UTType and safe decoding limits, and explicitly gate outbound upload.

**M02 · CONFIRMED_SOURCE.** `AttachmentLifecycle.swift:78–82` accepts any file URL for deletion and does not validate canonical path containment, symlink behavior, owner or whether the referenced file is inside the application's attachments directory. `AttachmentRepository.swift:8–33` exposes only save, not owner-scoped read/delete. Use per-owner paths and a guarded deletion transaction with file-path containment and id validation.

**M03 · CONFIRMED_SOURCE.** `Search/LocalTextIndex.swift:7–32` indexes tokens to bare UUIDs without owner partition. `SpotlightProjection.swift:10–36` uses generic identifiers/domain without owner-scoped consent. They may be safe while unused, but when wired they must filter by owner and support durable delete/deindex; the current memory delete leaves the Spotlight invalidation TODO.

**M04 · HIGH_RISK_UNVERIFIED.** `Package.swift` auto-discovers some Apple resource classes; the presence of `Resources/ProviderCatalog.json`, prompt `.txt` files and `PrivacyInfo.xcprivacy` does not prove all are bundled and loaded correctly by the `.appModule` target. Inspect a genuine built bundle, `Bundle.module` vs main-bundle lookup, localized strings and privacy manifest using Apple tooling.

## 7. Cross-cutting test and process defects

**E01.** The repository contains no committed executable Swift test suite. Every critical actor, service and UI flow needs compiled tests; keep Python static checks only as fast lint-level smoke.

**E02.** `scratch/test_chat_slice.py:27–113` asserts exact snippets of text in Swift files, not runtime behavior. The name 'deterministic behavioral verification' is inaccurate; rename/reclassify accordingly and add real fake-provider Swift tests.

**E03.** `scratch/verify_matrix.py:75–79` says T010 passes only if the code contains the string `streamTask.cancel()` and an 'interrupted' string; fifth-commit CI fails it. Fix the actual cancellation behavior first, then update static tests as supplemental structure checks.

**E04.** The user's current GitHub version includes the older six-file `docs/implementation/final_execution/` handoff but may not include the fifth handoff files locally; inspect filesystem instead of assuming a specific directory or reusing stale line numbers. Put *this* new campaign under a single explicitly selected folder and retire older execution prompts to historical references.

**E05.** Actual toolchain, AppModule scheme, privacy entitlements, device support, visual accessibility, live BYOK key behavior, microphone, notifications, restoration and 24-hour runtime are **not verified**. They are external execution gates; never substitute a source audit for them.

## 8. Overall conclusion and shortest critical path

**Status: `NOT_READY` / `BUILD_BLOCKED`.** Minimum known compile families are C01–C07; the authoritative first diagnostic will likely expose additional strict-concurrency or Apple SDK issues. After a genuinely compiling app exists, implement exactly-once chat and persisted configuration, then enforce a central privacy boundary; do not enable high-risk tools before tested durable idempotency and approvals. Rebuild/test every cohesive group, perform separate security and product audits, and only then transfer a no-production-data candidate to the user's physical iPad. A final human device pass is a non-delegable release gate.

## 9. Audit scope and how to detect an actually complete fix

All 187 Swift files were fetched and structurally scanned in the prior pass, with a deep second pass on selected high-risk cross-file call graphs. That does **not** mean every statement has been independently type-checked. There were no published executable Swift tests and the fifth-commit Apple CI stopped at localization. This updated register adds C11 without claiming all future Apple diagnostics are known.

Source references throughout are **pinned to `2918293e7355290ba722bb734652c9ad70c75a9f`**. When Gemini changes a file, line numbers move; regenerate `rg -n` and cite the new local SHA/diff in every fix.

For each finding maintain `{id, old SHA/line, current SHA/line, reproduction, changed files, failed test before, passed test after, build link, disposition}`. A code comment mentioning the ID is not reproduction.
