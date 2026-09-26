# Gemini Antigravity: Source Reconciliation → Compile Recovery → Real V1 Execution

**MODE:** Existing project recovery and implementation; no rearchitecture or restart.  
**ROLE:** Senior Swift/iOS engineer + AI streaming/agent-security engineer.  
**Repository:** `prashantjadon311/ios-Ai`. Work in the **actual** Git checkout detected using `git rev-parse --show-toplevel`; do not assume the directory name.  
**Audit basis:** GitHub `main` commit `3b1f059eb9306bd5ca3e0825c8c52800f0dfe3b4` had 187 Swift paths but 119 ZERO-BYTE Swift files, empty implementation checkpoint, empty W13/W14 report and zero-byte shipping resources. Your prior session reported 187 fully implemented local files. Resolve this contradiction first. The remote audit is a snapshot, not proof about current local files.

## NONNEGOTIABLE RULES

- Current local source and Git history are evidence. Read `CLAUDE.md` and `docs/spec/v3/README_START_HERE.md`, then the V3 authority, canonical contracts, exact execution plan, security matrix and relevant per-file instructions. Do not blindly regenerate the planning packet.
- Do not `git reset --hard`, `git clean`, force-pull, wipe or replace uncommitted files, or turn valid local implementations into remote zero-byte placeholders. Do not push secrets. Obtain user approval before any push or destructive repository operation.
- Stop treating Python bracket checks, unknown-symbol regexes, 16/16 document checks, or your previous narrative as Swift compiler, type checker, runtime or device test evidence.
- Do not use subagents to modify overlapping files. Do not invent device test results. Do not automatically replay ambiguous external side effects. Never silently bypass permission checks to make UI demos pass.
- This is implementation work, not another architecture-planning exercise. Produce one coherent verified slice at a time and keep a durable checkpoint after each slice.

## R0: IMMEDIATE FIRST ACTION, BEFORE ANY CODE CHANGES

1. Run and record: `pwd`, `git rev-parse --show-toplevel`, `git rev-parse HEAD`, `git status --porcelain=v1 -uall`, `git branch -vv`, `git remote -v`, `git log -3 --format='%H %cI %s'`. Check whether the actual root is `.../ios` or `.../ios/ios-Ai`.
2. Inventory local source counts (total, nonzero, zero-byte) and resources using `find PersonalAssistant.swiftpm -type f -printf '%s %p\n'`; separately count all `.swift` files. Inspect `docs/implementation` sizes. Compare current local SHA/file sizes to remote GitHub `main` SHA shown above. Do not assume remote reflects your last edit.
3. Read every nonempty local `docs/implementation/*.md`, including your latest checkpoint and W13/W14 verification document. Inspect `git diff` and all untracked local files. If local fully implemented files exist but remote copies are zero, this is a SYNC/COMMIT issue, not proof local implementations are absent.
4. Scan local source, JSON, project settings, ignored/untracked files, commit diff and commit history for API keys, authorization tokens, passwords and user data before proposing any push.
5. Write **`docs/implementation/R0_SOURCE_RECONCILIATION.md`** with the actual local-vs-remote delta, accurate counts, last saved code, outstanding stubs and high-risk dependencies. Snapshot the current state safely on a recovery branch or patch without discarding user modifications. If your local work is newer, make that the implementation candidate; do not merge stale placeholders over it.
6. Update `docs/implementation/IMPLEMENTATION_CHECKPOINT.md`: local HEAD, exact changed paths, what is VERIFIED vs PARTIAL vs STUB vs MISSING vs BLOCKED, and your first exact next action.

## R1: FIRST CODE REPAIR GATE (inspect local copy; only fix if still present)

Inspect these exact source contracts and resolve issues in a dependency-safe order:

- `MyApp.swift`: `RootNavigationView()` must resolve to exactly one real SwiftUI root with functional TabView on iPhone and NavigationSplitView on iPad. The reviewed remote tree had no matching source file.
- `AppContainer.swift` vs `ChatViewModel.swift`: align `makeChatViewModel` factory parameters with the real initializer; inject the live orchestrator and configuration repository.
- `AppSession.swift` and `OnboardingView.swift`: deduplicate `completeOnboarding()` and preserve persisted onboarding behavior.
- `ModelRouter.swift`: remove the duplicate `ProviderConfiguration.id` extension; make Keychain actor access async or explicitly prefetch availability; register providers using one consistent identity; implement capability, privacy, budget and health checks rather than returning the first key-bearing configuration.
- `CapabilityCenter.swift`: correct imports, permission probing, actual connectivity and device/model availability; do not return fake `networkAvailable = true` or assume iOS 26 means Foundation Models works on that device.
- `ConfigurationView.swift` vs the dedicated configuration/memory/assistant files: ensure exactly one declaration per SwiftUI type; remove old stub declarations when replacing them with their real implementations.
- Verify `Package.swift` target `AppModule`, path `.`, iOS 18.6, the single @main declaration, SwiftData model list, actor-isolated ModelContext usage, target resource registration and framework availability. Do not hand-replace the genuine Playgrounds manifest.

Classify compiler problems as confirmed only if actual compiler output exists; otherwise label `SOURCE_INFERRED` and verify on Apple tooling.

## R2: TURN CHAT INTO A REAL, TESTABLE VERTICAL SLICE

- Wire `DashboardViewModel.onAsk(text:)` through a new conversation to the actual Chat composer; no lost first message.
- Wire `ChatViewModel.send()` into the actual `AssistantOrchestrator.executeTurn()`; remove sleeps/fake completed replies. Persist user message first, stream assistant deltas, persist safe checkpoints, and handle terminal failure/interrupt/cancel truthfully.
- Register actual Groq/OpenRouter/custom providers; respect user BYOK Keychain credentials and selected model; no hardcoded stale model ID. Dynamic `/models` output should not be treated as verified vision/tool capability.
- In `OpenAICompatibleProvider`, implement provider-normalized SSE text + tool-call fragments + usage, `SSEDecoder.finish()` handling, size limits, model selection and deterministic error propagation.
- Fix HTTP redirect and Authorization scoping before live credentials: no cross-origin secret forwarding, validated HTTPS destination, secure custom URL policy, mock 30x tests and genuine AsyncThrowingStream cancellation through URLSession. Enforce the request deadline and use efficient chunk batching.
- Implement deterministic fixture tests for split UTF-8, CRLF, tool fragments, bad JSON, 401, 429 Retry-After, 5xx, network failures, first-token interruption, cancellation and account switch. Provider fallback is allowed only before any visible output and only with the same privacy allowance.
- Implement a single mocked complete conversation without external credentials, then do an optional real BYOK smoke with a key entered by the user locally. Record redacted exact status and evidence.

## R3: SHIP REAL TASKS, VOICE AND SECURITY RATHER THAN EMPTY FILES

- Task engine: TaskDefinition vs TaskRun, recurrence, timezone/DST policy, one occurrence key, notification scheduling + cancellation + reboot reconciliation, accurate Needs Attention/failed/ambiguous states. A stored reminder is not automatically executing an AI job.
- Voice: permission-gated tap-to-talk, locale availability, microphone lifecycle, Apple Speech transcription, native synthesis, interruption handling, stale-session cancellation. Don't claim Hindi/Hinglish support from a hardcoded `en-US` locale list.
- Tool security: no external tool may be callable until owner/session check, strict JSON schema, recipient+parameter preview, explicit confirmation, digest binding, PREPARED durable receipt, single-use execution, timeout reconciliation and audit are implemented and tested. The remote tautology `proposal.traceID == proposal.traceID` must never be treated as authorization.
- Storage & privacy: enforce session generation on async write boundaries; cancel outstanding old-profile tasks before data becomes visible to the new profile. Memory deletion must invalidate caches/indexes. Make Privacy Only an enforced data-egress policy, not just a Picker label. Disable unfinished tool actions and dangerous UI rather than showing fictional success.
- Finish real media/search integrations only according to the canonical V1 scope. Keep conditional iOS 26, Spotlight, Shortcuts and server-side features behind honest availability/feature gates.

## R4: TEST MATRIX AND DEVICE VALIDATION

- Turn `docs/spec/v3/05_TEST_AND_SECURITY_MATRIX.md` T001–T028 and `docs/spec/v3/13_EXACT_EXECUTION_AND_ACCEPTANCE.md` S001–S018 into executable tests/fixtures where practical. Report PASS/FAIL/BLOCKED/NOT_RUN for each case, including exact command, environment and captured output.
- Reconcile `Resources/Assets.xcassets`, Maya/Saar real image assets and valid Contents.json, prompts, both localizations, ProviderCatalog.json, PublicConfig.json and PrivacyInfo.xcprivacy. Do not call a zero-byte resource complete.
- For target iOS 18.6, use modern EventKit privacy keys: `NSCalendarsFullAccessUsageDescription` or write-only equivalent according to need, and `NSRemindersFullAccessUsageDescription`. In actual Swift Playgrounds configure Capabilities and explicit purpose strings; confirm app bundle resolves them. Do not invent `NSUserNotificationsUsageDescription` as a requirement.
- Linux does not compile SwiftUI, SwiftData or other iOS-only frameworks. If macOS/Xcode is accessible, run actual iPhone/iPad simulator builds and tests; otherwise provide a reproducible iPad Playground import/build smoke checklist, save exact device compile diagnostics from the user, fix those diagnostics, and keep statuses BLOCKED or NOT_RUN until then.
- Run privacy/security review on deployed code and remove empty shipping resources, fake tool results, ineffective destructive buttons and misleading success/status claims.

## R5: SAVE HARD EVIDENCE AND HAND OFF

Update `docs/implementation/IMPLEMENTATION_CHECKPOINT.md` and `docs/implementation/W13_W14_VERIFICATION_AND_HANDOFF.md` with: source commit and SHA-256, real code changed, tested method/case IDs, exact commands + actual output + exit codes, remaining P0/P1, iPad/iPhone status, and `NEXT_EXACT_ACTION`. Maintain a defect register with file path, reproducible evidence, severity, owner and test status. Fix reproducible P0 first. Don't claim V1 completion because the V3 documentation validator says 16/16 PASS.

**START NOW WITH R0.** After reconciling the actual local files, proceed directly to R1 and R2. Do not pause for another generic plan. At execution limit write a durable checkpoint and stop retrying quota failures.
