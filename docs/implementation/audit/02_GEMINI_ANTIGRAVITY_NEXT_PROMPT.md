# Gemini Antigravity: Source Truth, Compile Recovery and Functional V1

**Mode:** Direct implementation in the EXISTING repository, not another design/documentation cycle.  
**Role:** Principal iOS/Swift 6 engineer, AI runtime engineer, adversarial security reviewer, test engineer.  
**Working directory:** `/home/thakur/projects/git/AI-Other/ios`  
**Audited remote base:** `37d30503e59513c3063a6309f9ceb711ce7c96ba` (`Second`, 2026-09-26). 

## 0. Authority and preservation

Read `CLAUDE.md`, `docs/spec/v3/00_V3_AUTHORITY_AND_FINDINGS.md`, `docs/spec/v3/02_CANONICAL_CONTRACTS.md`, `docs/spec/v3/05_TEST_AND_SECURITY_MATRIX.md`, `docs/spec/v3/13_EXACT_EXECUTION_AND_ACCEPTANCE.md`, `docs/implementation/IMPLEMENTATION_CHECKPOINT.md`, and the new `docs/implementation/audit/01_ENGINEERING_REAUDIT.md`. Read specialized V3 documents only when the matching module is being repaired. The new audit is source-specific defect evidence, not permission to rewrite accepted product architecture. Existing local code may be newer than the remote snapshot: preserve it.

**No false green checks.** Previous handoff reported 46/46 tests passed, but remote `scratch/verify_matrix.py` is empty, there are no committed test suites, and source still contains compile-blocking contradictions. Reclassify unsupported PASS assertions as `NOT_RUN`, `BLOCKED`, `STATIC_CHECK_ONLY`, or `FAIL` with exact evidence. Do not rewrite the historical reports to conceal this; create a dated correction.

Never push credentials, sign into unapproved external services, overwrite uncommitted code, change migration schema destructively, or claim iOS build success without Apple-platform build evidence. Do not rerun code-generation scripts to overwrite manually repaired source. Do not declare anything complete merely because the file is nonempty.

## R0 — Establish the actual local source truth (first mandatory action)

Run and record the exact output of:

```
pwd
git remote -v
git branch --show-current
git rev-parse HEAD
git fetch origin main
git rev-parse origin/main
git status --short
git diff --stat
git diff --name-status origin/main...HEAD
find PersonalAssistant.swiftpm -name '*.swift' -type f -size 0 -print
find docs/implementation scratch -type f -size 0 -print
```

If local files are newer, inspect and preserve their contents. Make a dated local worktree backup or safe checkpoint before invasive changes; do not auto-reset, auto-clean or force-push. Compare actual source against the attached 37d audit, marking findings `STILL_PRESENT`, `ALREADY_FIXED`, `REGRESSION`, `NEW`, or `NOT_CHECKED`. Capture files' actual blob identities and test artifacts where possible.

Write `docs/implementation/R1_SOURCE_TRUTH_AUDIT.md` containing local SHA, remote SHA, status of all known P0 issues, exact test/tool evidence, owner of each cross-file contract, and the first unfixed dependency. Update `IMPLEMENTATION_CHECKPOINT.md` with truthful statuses. Preserve original iPad-exported `Package.swift` and original zip backup.

## R1 — Compile-correctness gate (NO new product features until addressed)

Read canonical `Domain/` contracts as the single source of types. Resolve the following known current-remote contradictions *in dependency order*:

1. Restore the correct `@Observable` application-container environment contract. A class injected with `.environment(container)` and retrieved with `@Environment(AppContainer.self)` must meet SwiftUI's Observable constraint. Reconcile `AppContainer`, `MyApp.swift` and `RootNavigationView`.
2. Eliminate duplicate top-level SwiftUI views: `ConfigurationView.swift` still includes nine placeholder definitions duplicating dedicated files. Remove only duplicate declarations and wire real screen destinations, preserving independently implemented real views.
3. Reconcile all five primary-screen constructors with `AdaptiveLayout.swift`; one consistent DI pattern, no invisible default-initializer assumptions or permanently recreated view models.
4. Fix `AppContainer.makeChatViewModel` to match `ChatViewModel` and install a real shared `AssistantOrchestrator`, `ModelRouter`, `HTTPClient`, provider registry and configuration repository, with clear owner/session lifecycle.
5. Update `ContextBuilder`, `ChatViewModel` and any consumers to canonical `ContextMessage(role, parts, source, sensitivity)`, `ContentPart.toolResult` with two values, and mandatory `MessageRecord` fields. Do not silently weaken the domain contract to fit generated callsites.
6. Replace invalid `AssistantProfile.avatarType/name/voiceIdentifier`, `PrivacyMode.standard`, `TaskDefinition.scheduleTime/recurrenceRule`, `RecurrenceRule`, `MemoryItem.scope`, incorrect AppError labels, and `ToolReceiptStatus.completed` using the existing canonical domain types. The same rule applies repo-wide: identify each symbol declaration before editing references.
7. Reconcile `AttachmentValidator` argument label, `StoredAttachment` availability, and `SchemaV1`/migration. Do not add an incompatible persisted entity without a migration decision; defer an unready attachment repository with a visible capability gate if necessary.
8. Remove recursive `ProviderConfiguration.id` extension and incorrect synchronous Keychain calls from `ModelRouter`. Standardize provider registration keys, per-owner configuration ID and model identifiers.
9. Check imported Apple frameworks and strict Swift concurrency/actor rules for `VisionTextRecognizer`, AVAudio, SwiftData ModelActor/repositories, `@MainActor` callbacks and `AsyncThrowingStream` task cancellation.
10. Fix first-conversation lifecycle: `ChatView` must not fabricate a non-persisted ConversationID; pending user messages must reference an existing owner-scoped conversation. Persist and preserve the dashboard quick-ask text.

**Verification:** Run a genuine Swift source parser/typechecker where possible. Linux parser output is `STATIC_PARSE` only; it cannot establish SwiftUI, SwiftData or iOS build status. For a genuine iOS compile, import the unmodified real `.swiftpm` on iPad or use a verified macOS/Xcode build approach and attach full logs, target/version, exact command and exit code. If Apple hardware is unavailable, record `IOS_COMPILE: BLOCKED` and continue only independently testable work. Avoid 100 invented compatibility shims that mask core defects.

## R2 — ONE actual working chat vertical slice (the first functionality gate)

Implement, connect and verify this exact path:

```
Dashboard quick ask / Chat composer
 → persisted owner-scoped conversation and pending user message
 → captured current session generation & selected active assistant
 → real persisted provider config and Keychain BYOK key
 → privacy/consent/data-class egress check
 → capability/model selection + context builder with bounded context
 → real OpenAI-compatible HTTP request through redirect-safe transport
 → byte-correct SSE text deltas / usage / terminal reason
 → persisted streaming assistant checkpoint and final status
 → UI updates only if session and trace still match
 → cancellation propagates to child HTTP task and marks partial result correctly.
```

Do not emit fake completion or canned model text. Remove the placeholder body from `AssistantOrchestrator` after replacing it with a true pipeline. Register a real Groq and OpenRouter provider configured for the current owner; pass actual selected model, not hardcoded model ID. Provider catalog is an advisory local fallback, not automatic proof a model still exists. Respect 401, 429 Retry-After, 5xx, timeout, truncated stream, offline, and invalid JSON. Fallback only when consent-compatible and before the first visible token; after a token, preserve partial output as interrupted and offer an explicit restart. Never silently duplicate tool side effects.

Supply a deterministic **fake-provider test** that drives one complete and one interrupted streaming turn with exact expected saved message order. Real cloud API smoke test is a separate `NOT_RUN` until the user supplies their own key and approves it; never embed a testing key in source, CI, fixtures or reports.

## R3 — Security and privacy enforcement before enabling AI tools

Maintain ALL external side-effect tools disabled in UI and model exposure until this gate actually passes.

- Fix `PrivacyRoutingView` / `PrivacySettingsView`: use canonical privacy enum, persist owner preferences and per-channel consents, and enforce before *every* outgoing AI, STT, custom-URL, file-upload and tool operation.
- Guarantee current session checks at the start and after every suspend point before UI mutation or persistence, plus cancellation on local user switch, lock and logout. Never use a captured token as a self-verifying authority.
- Fix `ProviderDetailView`: report Keychain errors, never indicate success after `try?`, preserve previous credential on rotation failure, disable provider on known-invalid auth.
- Implement a complete tool registry with matching IDs and strict JSON schema validation, data classification, capability/grant check, actual recipient preview, TTL, current-session verification, and an exact hash bound to invocation ID, owner, session, recipient, tool version and canonicalized arguments. `ApprovalCoordinator` must issue a single-use `AuthorizedToolCall`, not merely return a mutable `ApprovalRequest`.
- Persist PREPARED tool receipts transactionally to SwiftData or another proven durable store **before** any external side effect. Enforce unique operation key across relaunches. On timeout, crash, cancellation or uncertain outcome, enter `ambiguous` and require reconciliation/human review; NEVER automatically replay.
- Use a dedicated redirect-safe `URLSession` configuration/delegate and tested host policy for BYOK and custom endpoint headers. No insecure redirect carrying Authorization. Treat SSRF/DNS rebinding as a real threat; no security claims from partial prefix checks.
- Make lock screen actually block protected app UI and tool execution; unsupported biometric path must not silently authorize.

Write executable tests for approval tampering, double-approval races, expiration, user switching, crash recovery, ambiguous side effects, privacy-denied egress, and secret-redacted diagnostics. Fail closed rather than inventing success.

## R4 — Bring actual V1 features to acceptance (after R1/R2; security-sensitive after R3)

**Tasks:** fix canonical scheduling types, timezone/wall-clock recurrence, persistent stable occurrence key and run state, task editor existing-ID/revision handling, local notification permission/reconciliation/edit/delete, and real Task Dashboard statuses. No false guarantee of background AI execution.

**Voice:** wire actual AVAudioEngine buffers to SFSpeechAudioBufferRecognitionRequest, Speech permissions, partial/final transcript handling, cancellation, interruptions, TTS and Maya/Saar preferences. `ModernSpeechTranscriber` is conditional and must be labeled fallback-only until real SDK support/device tests. Hindi/Hinglish require actual locale/device verification, not hardcoded marketing claims.

**Avatars/UI:** fix independent rename persistence, real Maya/Saar image assets with provenance and resource references or clearly label SF Symbol fallbacks; Reduce Motion, Dynamic Type and iPad split/rotation. Connect all main and supporting screens to real repositories and models; remove duplicate placeholder views. Every settings toggle must persist and affect runtime behavior or be visibly disabled. The Clear All Data handler must actually perform a confirmed owner-scoped deletion/Keychain cleanup or be disabled; never leave an active deceptive button.

**Memory/search/media:** only user-verified active owner-scoped memories enter context; fix `MemoryItem` tombstone constructor and owner data isolation. Implement owner-filtered persisted/rehydratable lexical search and verified deindex behavior, not merely title filtering. Add attachment type/size/path/text-extraction limits, owner-isolated storage, temporary-file cleanup, correct SwiftData migration and explicit cloud-upload consent; do not claim PDF bomb resistance from four magic bytes.

**Apple models/Playgrounds:** Apple local-model option is CONDITIONAL on OS and device eligibility plus actual `SystemLanguageModel.default.availability` and real SDK compilation; avoid returning true from `canImport` alone. Verify Playground app capabilities, purpose strings, resource bundling and asset images on a real exported/imported package.

## R5 — Honest automated and device verification, in small increments

Implement actual test code and deterministic fixtures for T001–T028 and S001–S018. A pattern-matching static script MAY establish `STATIC_CHECK_ONLY`, never runtime `PASS`. The committed `scratch/verify_matrix.py` is zero bytes and previous `46/46 PASS` claims must be corrected in a dated addendum. Add real unit tests and a test target/framework that is actually supported by the chosen toolchain; iPad-specific manual scenarios require dated device screenshots/logs and reproducible steps. If macOS CI/Xcode project mirror is added, preserve the canonical Playgrounds package and prove the mirror corresponds to identical source revision.

Required release evidence: user can launch on iPad; all five main screens navigate; Maya and Saar can be renamed and survive relaunch; BYOK one real request works; assistant response streams, persists and cancels; local task/reminder fires; verified owner isolation; private-only emits no prohibited network traffic; microphone/STT/TTS works on one tested locale; external tool execution is disabled until its full security suite passes; no unresolved shipping-path P0/P1. iPhone installation is a separate gate from iPad Playground import.

## Execute now; do not just produce another plan

1. Complete R0 report and correct unsupported historical completion claims.
2. Implement R1 source fixes directly, small file batches with exact before/after state; build if Apple toolchain available.
3. Implement and test R2 real streaming chat vertical slice.
4. Proceed to R3/R4 independently where their prerequisites permit. Keep unavailable future features explicitly disabled.
5. After each coherent batch, update `docs/implementation/IMPLEMENTATION_CHECKPOINT.md` with: `HEAD`, changed paths, exact commands, exit codes, test IDs, actual observed results, `PASS/FAIL/BLOCKED/NOT_RUN/STATIC_CHECK_ONLY`, remaining P0/P1 and the exact next action. Do not invent test outputs.

**On interruption:** write an exact, durable checkpoint. **On source conflict:** prefer the canonical V3 contract plus demonstrated existing data compatibility; escalate one precise interface conflict, not a broad architecture restart. **On missing Apple SDK:** keep doing demonstrably independent work without claiming iOS build success. Begin with `git status`/`git rev-parse HEAD`, not new boilerplate.
