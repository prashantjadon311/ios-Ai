# ios-Ai: Source-Audited Engineering Review

**Audit date:** 2026-09-26  
**Remote source:** `prashantjadon311/ios-Ai`, branch `main`, commit `3b1f059eb9306bd5ca3e0825c8c52800f0dfe3b4` (committed 2026-09-25T19:35:13Z).  
**Scope:** GitHub's committed recursive tree; direct inspection of critical app, domain, persistence, AI, tool, security, voice and UI files; docs/spec/v3 execution/testing contracts; docs/implementation artifact inventory; Apple documentation on Playgrounds permissions and current EventKit privacy keys.  
**Important limitation:** This report does not inspect Gemini's unpushed local workspace or compile Apple frameworks. Do not silently equate GitHub `main` with the live Antigravity filesystem. Statements about committed content below are evidence-backed; compiler findings are source-deduced, not actual compiler logs.

## 1. Inventory and the central discrepancy

The committed recursive tree contains 187 `.swift` files, of which **119 are exactly 0 bytes** and **68 have content**. `docs/implementation/IMPLEMENTATION_CHECKPOINT.md` and `docs/implementation/W13_W14_VERIFICATION_AND_HANDOFF.md` are also 0 bytes. Only W00's device/package probe is nonempty. `Resources/PrivacyInfo.xcprivacy`, `ProviderCatalog.json`, `PublicConfig.json`, both assistant image-set `Contents.json` files, both prompt text files and both localization files are 0 bytes; neither avatar image-set contains an actual image. There is no committed executable test suite or CI workflow. The 21 V3 specification documents exist and the canonical manifest lists 266 planned inventory entries; an inventory specification is not evidence those items are implemented.

Committed `.swift` inventory by component:

| Component | Present | Zero-byte | Nonempty |
|---|---:|---:|---:|
| AI | 21 | 16 | 5 |
| App | 6 | 0 | 6 |
| Avatar | 5 | 5 | 0 |
| DesignSystem | 9 | 8 | 1 |
| Domain | 16 | 0 | 16 |
| Features | 52 | 32 | 20 |
| Integrations | 6 | 4 | 2 |
| Media | 7 | 7 | 0 |
| Persistence | 12 | 2 | 10 |
| Search | 5 | 5 | 0 |
| Security | 11 | 9 | 2 |
| Tasks | 13 | 13 | 0 |
| Tools | 13 | 11 | 2 |
| Voice | 8 | 7 | 1 |
| App entry + ContentView | 2 | 0 | 2 |
| **Total** | **187** | **119** | **68** |

Gemini's pasted report claimed 187 implemented files, zero broken references, zero TODOs and successful static verification. The remote tree **does not substantiate those claims**. The local workspace may genuinely contain newer, uncommitted or unpushed code; first reconcile local and remote without overwriting either. A 16/16 Markdown/spec validator does not compile a Swift app or exercise its runtime.

## 2. P0: committed source is not build-ready

1. `MyApp.swift` instantiates `RootNavigationView()`, but no `RootNavigationView.swift` exists in the recursive tree and no reviewed committed source defines it. Verify any alternate definition locally; absent a real definition, the app cannot compile.
2. `AppContainer.makeChatViewModel()` passes `orchestrator:` and `configurationRepository:`, whereas committed `ChatViewModel.init` accepts neither. Resolve to one canonical initializer.
3. `AppSession.completeOnboarding()` is implemented inside `AppSession.swift` and implemented again as an extension in `OnboardingView.swift`: duplicate member.
4. `ModelRouter.swift` defines a `private extension ProviderConfiguration { var id: ProviderConfigID { self.id } }` despite `ProviderConfiguration` already having an `id` property. Delete this duplicate/recursive property.
5. `ModelRouter.route(...)` is synchronous but calls `KeychainVault.hasSecret(...)` on a different actor without `await`. Make route appropriately async and propagate through callers, or prefetch credential availability safely.
6. `CapabilityCenter.swift` references `AVAudioApplication` and `UNUserNotificationCenter` under `#if canImport(...)` without actually importing those modules. `canImport` alone does not import a framework. Add correct guarded imports and verify real SDK signatures.
7. The resource files listed in section 1 are empty. Validate bundle-resource parsing and real capability declarations on the actual Apple target, not with a Markdown checklist.
8. `ConfigurationView.swift` defines placeholder types with names also earmarked for dedicated files (e.g., `ProviderListView`, `AIConfigurationView`, `MemoryBrowserView`). Once those files are populated locally, duplicate declarations are likely. Consolidate one declaration per type.

**Not checked by any evidence:** Swift compiler errors, macro expansion, SwiftData model eligibility, Swift 6 actor isolation, iPad Swift Playgrounds import, iPhone install. No BUILD_PASS/DEVICE_PASS status is justified.

## 3. P0: the advertised assistant does not actually run on committed `main`

- `AssistantOrchestrator.executeTurn` explicitly emits `started` and then `completed` without invoking a provider. Its own comment calls it a placeholder.
- `ChatViewModel.send` sleeps and persists a fake/placeholder assistant response instead of invoking the orchestrator or streaming API. `cancel()` cancels a `streamingTask` that `send()` never assigns.
- `OpenAICompatibleProvider.stream` hardcodes `llama3-8b-8192` instead of using selected configuration, passes `tools: nil`, ignores provider tool calls and usage, and does not invoke `SSEDecoder.finish()` at EOF. Its dynamic model-list logic does not make the actual chat model configurable.
- `AppContainer` constructs a `ModelRouter` but registers no providers. `ModelRouter.route` looks up providers by configuration UUID while the adapter's `providerID` is arbitrary and may be a different string; fix the identity contract before declaring routing functional.
- `ModelRouter` currently filters only enabled/key/health, not the documented capability, privacy, context and budget requirements. There is no proved after-first-token fallback invariant in the committed orchestrator.
- `DashboardViewModel.onAsk(text:)` creates a conversation and opens chat but does not pass the entered text. The dashboard quick-ask command silently loses the user's message.

## 4. P0: permissions and tool side effects must remain DISABLED

- `ToolPolicyEngine` contains `proposal.traceID == proposal.traceID`: tautology, not an owner/session check. It only validates that JSON parses, not the declared tool schema, recipient, argument bounds, data sensitivity or execution authorization. The approval summary is generic and its data classification is hardcoded `.personal`.
- The entire committed tool-executor and durable receipt implementation is empty. `ApprovalCenterView` always shows "No Pending Approvals". Do not enable any external side effect until exact approval, durable PREPARED receipt, single-use transition, execution, audit and ambiguous-outcome reconciliation are implemented AND tested.
- Repository `session` parameters are accepted in the committed conversation operations, but the reviewed implementations do not revalidate session generation at their post-`await` write boundaries. `AppSession.switchProfile` swaps tokens but does not cancel outstanding streams, OCR, voice work or downloads. Do not claim cross-profile isolation without concurrent switch tests.
- `MemoryRepository.deleteAndDeindex` tombstones data but contains a TODO for actual index removal; every Search implementation is empty. A privacy-sensitive delete must invalidate retrieval/context caches and indexes before claiming completed deletion.

## 5. P0/P1: transport, secret handling and availability

- `HTTPClient` defaults to `URLSession.shared`, claims redirect safety, but has no redirect delegate. The initial URL is validated, while an HTTP redirect could forward the Authorization header to an unapproved destination. The default `allowedHosts` is empty. Implement explicit per-provider destination policy and redirect rejection / credential-scoping; prove behavior with mock redirects.
- `HTTPRequest.deadline` is declared but not enforced. `HTTPClient.stream()` allocates and yields a new one-byte `Data` per byte, an unnecessarily expensive transport path. Stream child-task cancellation is not propagated from `AsyncThrowingStream.onTermination` to URLSession.
- `SSEDecoder` is a promising byte-oriented foundation, but no committed executable fixtures prove split UTF-8, incomplete final frames, oversized unterminated lines or fragmented tool arguments. Its provider caller discards EOF decoder output.
- `KeychainVault.setSecret` deletes the previous value before attempting the replacement, risking loss on a failed add. Its `removeAll` enumerates known provider kinds, which cannot exhaustively cover arbitrary custom provider IDs. Validate rotation and deletion under device lock and multiple local profiles.
- `CapabilityCenter.checkNetworkAvailability` returns hardcoded `true`; `checkFoundationModelsAvailability` equates OS version with model/device availability; `availableSpeechLocales` hardcodes English. These signals cannot safely drive runtime routing or voice permissions.

## 6. P1: five screens exist mainly as skeletons

- Maya and Saar `AssistantProfile` domain defaults exist, but all five committed Avatar implementation files are empty and actual avatar images are absent. The dashboard renders a circular initial instead of either avatar.
- `ConfigurationView` contains multiple placeholder subviews; `PrivacySettingsView` changes an in-memory Picker without persisting the preference; `SettingsView` presents "Clear All Data" with an empty destructive confirmation handler.
- All 13 Tasks engine files are empty; task screens currently represent mostly CRUD scaffolding. No verified recurrence, actual reminder scheduling, crash recovery, notification reconciliation or background behavior.
- All 7 Media and 5 Search implementation files are empty. VoiceCoordinator has a `Task.sleep` placeholder and no live microphone/STT/TTS pipeline in the committed tree. Four of six integrations are empty.
- `AboutView` states strong privacy properties; ensure the text describes only implemented, verified behavior rather than planned privacy policies.

## 7. Platform and documentation drift

- Real iPad-exported `.swiftpm/Package.swift` targets iOS 18.6 with `AppModule` path `.`; preserve this template. The Linux environment has no iOS SDK or Xcode and cannot verify iOS compilation.
- `docs/implementation` remote checkpoint and W13/W14 reports are empty. Build evidence and feature statuses must be regenerated from actual commands, not copied from Gemini narrative.
- W00 mentions older `NSCalendarsUsageDescription` and `NSRemindersUsageDescription` keys. For an iOS 18.6 app, request the appropriate modern `NSCalendarsWriteOnlyAccessUsageDescription` or `NSCalendarsFullAccessUsageDescription` and `NSRemindersFullAccessUsageDescription` where EventKit requires them. In Swift Playgrounds, declare needed capabilities and custom purpose strings via App Settings > Capabilities and verify exported bundle behavior. Official Apple references: https://developer.apple.com/documentation/eventkit/accessing-the-event-store and https://developer.apple.com/documentation/swift-playgrounds/project-capabilities.
- `Resources/PrivacyInfo.xcprivacy` is 0 bytes; it is not a valid shipping manifest. Any final declarations must reflect the actual APIs, SDKs and data transfer behavior.
- No GitHub Actions/iOS build job or committed test suite is visible. Pure-domain tests, mock-provider/SSE fixtures, state-machine cases, migration tests and device smoke scripts remain to be proved.

## 8. Recovery order (do not regenerate the entire app)

**R0: Mandatory source reconciliation.** In Antigravity, capture `pwd`, `git status --porcelain=v1 -uall`, `git rev-parse HEAD`, `git branch -vv`, `git remote -v`, `find PersonalAssistant.swiftpm -name '*.swift' -size 0`, sizes and SHA-256 for each modified source. Compare local vs remote commit `3b1f059...`. Check secret exposure before any push. Preserve all uncommitted newer implementations. Report exact local/remote deltas. Do not overwrite nonempty local files with 0-byte remote placeholders.

**R1: Make the source compile-ready.** Resolve the six direct source mismatches above, type ownership, guarded imports and stale placeholder declarations. Validate target resource manifest and app entrypoint. If Apple SDK unavailable, mark compiler validation BLOCKED, not PASS.

**R2: Deliver one real vertical slice.** Fresh app startup → Maya/Saar persisted → save user's BYOK key → provider/model discovery → real selected-model streaming chat → durable history → cancellation → recovery. Use mock provider fixtures before live key testing. No fake replies.

**R3: Task/voice/safety slice.** Complete task creation with genuine local notifications and device permission flows, tap-to-talk STT/TTS on supported locale, and policy/approval/receipt pipeline. Keep unimplemented external tools off until fully tested. Add memory delete/search correctness and data egress controls.

**R4: Verification.** Turn T001–T028 and S001–S018 into executable tests where possible; record NOT_RUN separately for hardware/manual cases. Preserve original Playgrounds metadata. Obtain actual iPad import/build/run and iPhone installation evidence before release claims.

**R5: Durable handoff.** Commit source and checkpoint after scanning for secrets. Update `docs/implementation/IMPLEMENTATION_CHECKPOINT.md` and `W13_W14_VERIFICATION_AND_HANDOFF.md` with completed actions, exact commands/outputs, SHA, known blockers and first exact next action. Push only after reconciliation, appropriate review and user authorization.

## 9. Evidence references (immutable commit)

- Tree snapshot: https://github.com/prashantjadon311/ios-Ai/tree/3b1f059eb9306bd5ca3e0825c8c52800f0dfe3b4
- AI orchestration: https://github.com/prashantjadon311/ios-Ai/blob/3b1f059eb9306bd5ca3e0825c8c52800f0dfe3b4/PersonalAssistant.swiftpm/AI/Routing/AssistantOrchestrator.swift
- Chat view model: https://github.com/prashantjadon311/ios-Ai/blob/3b1f059eb9306bd5ca3e0825c8c52800f0dfe3b4/PersonalAssistant.swiftpm/Features/Chat/ChatViewModel.swift
- AI provider: https://github.com/prashantjadon311/ios-Ai/blob/3b1f059eb9306bd5ca3e0825c8c52800f0dfe3b4/PersonalAssistant.swiftpm/AI/Providers/OpenAICompatibleProvider.swift
- Router: https://github.com/prashantjadon311/ios-Ai/blob/3b1f059eb9306bd5ca3e0825c8c52800f0dfe3b4/PersonalAssistant.swiftpm/AI/Routing/ModelRouter.swift
- HTTP client: https://github.com/prashantjadon311/ios-Ai/blob/3b1f059eb9306bd5ca3e0825c8c52800f0dfe3b4/PersonalAssistant.swiftpm/AI/Transport/HTTPClient.swift
- Tool policy: https://github.com/prashantjadon311/ios-Ai/blob/3b1f059eb9306bd5ca3e0825c8c52800f0dfe3b4/PersonalAssistant.swiftpm/Tools/ToolPolicyEngine.swift
- App composition: https://github.com/prashantjadon311/ios-Ai/blob/3b1f059eb9306bd5ca3e0825c8c52800f0dfe3b4/PersonalAssistant.swiftpm/App/AppContainer.swift
- UI configuration stubs: https://github.com/prashantjadon311/ios-Ai/blob/3b1f059eb9306bd5ca3e0825c8c52800f0dfe3b4/PersonalAssistant.swiftpm/Features/Configuration/ConfigurationView.swift
- Implementation W00: https://github.com/prashantjadon311/ios-Ai/blob/3b1f059eb9306bd5ca3e0825c8c52800f0dfe3b4/docs/implementation/W00_DEVICE_AND_PACKAGE_PROBE.md
- Execution acceptance: https://github.com/prashantjadon311/ios-Ai/blob/3b1f059eb9306bd5ca3e0825c8c52800f0dfe3b4/docs/spec/v3/13_EXACT_EXECUTION_AND_ACCEPTANCE.md

**Audit result:** Committed remote `main` is not a working, compiled, complete V1. Source recovery and local/remote reconciliation take precedence over new code generation. A newer local workspace may be materially further ahead and must be checked before any repair.
