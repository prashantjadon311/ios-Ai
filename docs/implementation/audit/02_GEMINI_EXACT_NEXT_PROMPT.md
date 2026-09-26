# Gemini Antigravity: source-truth repair and real V1 implementation

**Paste this entire prompt into Gemini in the existing VS Code workspace.** The full independent audit is `01_LATEST_REAUDIT.md` alongside this file. Preserve all existing user work.

```text
ROLE: Principal iOS/Swift 6 Engineer, AI Systems Engineer, Security and Test Lead.
MODE: IMPLEMENT AND VERIFY. NOT another planning-only session.
PROJECT: existing ios-Ai repository, PersonalAssistant.swiftpm.
AUDITED GITHUB BASELINE: 5905602c5c504d1d6f9d3a140edc790b77c2cb2f (Third).

This is a continuation, NOT a new project. The previous 46/46 source-presence PASS and 4/4 chat-slice PASS claims do not establish a working app. The committed source contradicts them. Do not regenerate the project or rerun scratch/gen_*.py.

DISCOVER THE REAL REPOSITORY ROOT with `git rev-parse --show-toplevel`. The historical documents disagree about whether the root directory is /home/thakur/projects/git/AI-Other/ios or /home/thakur/projects/git/AI-Other/ios/ios-Ai. Do not assume either.

READ IN THIS ORDER:
- CLAUDE.md
- docs/spec/v3/00_V3_AUTHORITY_AND_FINDINGS.md
- docs/spec/v3/02_CANONICAL_CONTRACTS.md
- docs/spec/v3/13_EXACT_EXECUTION_AND_ACCEPTANCE.md
- docs/implementation/audit/01_LATEST_REAUDIT.md
- Relevant original V3 algorithm and file-contract docs only when working on a component.

SOURCE TRUTH:
1. Actual local files and real build/test evidence.
2. Latest confirmed Git commit; audited reference is 5905602.
3. Canonical V3 requirements/architecture unless contradicted by an established defect.
4. Old generated checklists and historical reports are evidence of claims, not proof.
Never erase previous reports; append a dated superseding checkpoint with corrected status.

R0: RECOVER AND PRESERVE, THEN IMMEDIATELY REPAIR
- Run pwd; git rev-parse --show-toplevel; git status --short; git branch --show-current; git rev-parse HEAD; git rev-parse origin/main; git diff --stat; git diff --check.
- List all *.swift, empty *.swift, root package config, actual asset filenames, docs/implementation and test sources; check for uncommitted/untracked changes before edits. Do not reset, force-pull, overwrite local changes, or push unrequested commits.
- Diff local files against audited 5905602; if newer valid fixes exist, preserve them. Check specifically whether the local AssistantOrchestrator and ModelRouter are newer than GitHub. Verify source, not comments.
- Create docs/implementation/R2_CURRENT_SOURCE_TRUTH.md with the current SHA, dirty state, actual empty files, exact source defects and next dependency. Correct any '0 empty' and functional PASS claims contradicted by the actual files.

R1: COMPILATION-CONTRACT REPAIR. FIX THE FIRST BROKEN DEPENDENCY BEFORE MORE FEATURES.
- Reconcile AppContainer / AssistantOrchestrator initializer (AppContainer passes configurationRepository but committed orchestrator does not accept it); register providers deterministically, not using unawaited startup Tasks. Create shared services once.
- Reconcile AdaptiveLayout with actual DashboardView, TaskDashboardView, SettingsView constructors; preserve the five-tab iPhone + sidebar iPad UX and only one @main.
- Remove recursive ProviderConfiguration.id extension and perform KeychainVault actor calls with correct asynchronous isolation. Route by providerKind / providerID rather than configuration UUID; assert there is no first-request registration race.
- Fix ApprovalCoordinator against canonical ApprovalRequest and SessionToken. The committed ApprovalRequest has no sessionToken/canonicalArguments and SessionToken has `generation`, not `generationID`. Do NOT make security checks optional as a shortcut. Model-produced request must be bound to the immutable canonical payload, owner, current session generation, trace ID, tool schema version and approval TTL. Expire/reject on any mismatch.
- Check all enum labels, DTO initializers, @MainActor/Sendable boundaries, SwiftData ModelContext confinement, availability guards and Apple API imports. Do not silence type errors with force casts, try? or @unchecked Sendable.
- Third commit accidentally erased ContextBuilder.swift and MemoryProposalEngine.swift; recover their correct contracts and implement from spec if actually in V1. Never regenerate them with stale constructors.
- Check Swift Playgrounds package target `AppModule`, iOS 18.6 floor and resource/capability handling. The FoundationModels conditional route must be disabled on unsupported OS/hardware; check SystemLanguageModel availability on a supported runtime, not just canImport.
- If Linux has no suitable Swift/Apple SDK, mark iOS BUILD NOT_RUN, create device-specific build instructions, but fix every directly demonstrable cross-file contradiction through source review. If a Swift Linux compiler is available, compile a PURE-SWIFT extracted domain target separately without claiming that equals an iOS build.

R2: REAL CHAT VERTICAL SLICE (FIRST FUNCTIONAL TARGET)
End-to-end target: configure user-owned Groq/OpenRouter key -> save in Keychain with an honestly reported result -> create and ENABLE matching ProviderConfiguration -> model selected and persisted -> send user prompt -> route by privacy/capabilities/health/budget with correct provider ID -> HTTPS/SSE -> render real text delta -> persist exactly one assistant response -> reopen history -> verify content survives relaunch.
- The current AssistantOrchestrator only emits fake started/completed. Implement actual ModelRouter.route, provider.stream, context assembly, terminal events, cancellation, timeout, error classification and message checkpoint persistence. No fallback after first visible token. A truncated stream without [DONE] / validated finish must be interrupted, never completed. Never fabricate assistant text.
- Fix ChatView nil/new-conversation handling; don't replace nil with random ConversationID when a conversation hasn't been created. Dashboard's quick-ask text must be inserted as the actual first user message (no lost typed input). Ensure the first conversation is visible in history.
- Use canonical source/sensitivity fields in ContextMessage, provenance-preserving system/history/memory ordering, bounded context and owner filtering. Do not turn untrusted retrieved text into system authority. MemoryProposalEngine must only PROPOSE memories, never silently verify them.
- Provider catalog/UI and protocol contracts must match; OpenAICompatibleProvider must consume request.modelOverride, encode supported tools only when permitted, strictly assemble streamed tool-call fragments if implementing tools, and never falsely claim successful completion after abrupt EOF.
- For V1 text chat, keep external tools disabled until R3; no need to implement full agent actions before proving secure text streaming.
- Keep user message and partial assistant message durable, with traceID, owner and one terminal state. Check captured SessionToken at every async UI mutation and persistence boundary. Handle cancellation without stale callback updates after switching profiles.
- Create deterministic Swift mock HTTP/SSE/provider tests for fragmented UTF-8, ordered deltas, missing DONE, HTTP 401/429/5xx, cancellation, duplicate terminal event, exactly-once persistence, privacy-only rejection and account switch during slow response. Python substring checks are not replacements. If Apple toolchain unavailable, mark tests NOT_RUN and supply exact iPad test instructions.

R3: SECURITY, PRIVACY, TOOLS (DO NOT ACTIVATE BEFORE EVIDENCE)
- Centralize egress decisions at every actual outgoing network path, including model listing, provider calls, link previews, attachments, cloud STT, custom endpoints and browser links as the policy defines. Private Only means block external content transmission, not just change a button label. Persist privacy mode and keep live AppSession synchronized; Maya/Saar switching must preserve all unrelated preference fields. Use deny-by-default consent for sensitive classes.
- Build immutable exact approval requests with canonical arguments, verified digest, current-session binding, expiration and one-time consumption. Verify approved arguments AGAIN immediately before dispatch, not only in the UI. Tool registry IDs, concrete tool IDs and schema versions must agree. Prevent prompt-injected tool calls from inheriting user authority.
- Replace in-memory ToolReceiptStore with real durable SwiftData-backed PREPARED transaction, unique operation key and startup reconciliation. Never replay an ambiguous side effect after a crash or timeout. Execution step must return a real OS/provider result; don't tell a user a calendar event or URL opened if the executor only checked permission or parsed a URL.
- Audit HTTPClient redirects and custom endpoint configuration; add destination/HTTPS validation and safe redirect handling. Do not log or expose Authorization headers, secrets or private data. Be explicit about which protection properties are verified versus design-only.
- Require actual permission grants and confirmation for calendar/reminders/contacts and enforce app lock in root navigation. Tool permission toggle values must persist and be observed by the policy engine. Keep potentially destructive actions disabled until complete tests exist.
- Validate with runtime Swift tests/mock adapters: expired approval, missing digest/session, changed recipient/arguments, duplicate invocation, crash after PREPARED, ambiguous timeout, private IP/redirect attempt, private-only egress attempt and cross-owner access. Static assertions do NOT count.

R4: ONE COMPLETE TASK AND ONE COMPLETE VOICE FLOW
- Fix TaskScheduler occurrence ID stability: derive deterministic key from task ID + definition revision + scheduled instant in UTC (or equivalently persisted stable occurrence identity), with DB uniqueness and transactional reserve. Honor TaskSchedule.timezoneIdentifier in wall-clock and DST calculations, and store/communicate delivery status when local notifications are denied. Test cancel/reschedule/restart without duplicates.
- Make ONE local task + notification work end-to-end before generalizing to autonomous recurring tasks. iOS does not guarantee arbitrary unattended on-device job execution; don't label a scheduled AI task as guaranteed without server scheduling.
- Wire VoiceCoordinator into actual dashboard/chat UI with a real user-initiated permission flow and audio session, mic -> SFSpeechRecognizer -> transcript -> text chat -> AVSpeechSynthesizer. Test stop/interrupt/deny/rerequest and stale callbacks. Implement correct actor and buffer ownership rather than silencing concurrency errors.
- Preserve user-owned attachments in persistent Application Support, never purge referenced content based solely on age. Keep file-size/MIME validation, bounded PDF/OCR and cleanup of orphan-only temp files.
- Add actual Maya/Saar avatar image assets or label SF Symbol visuals as temporary; ensure user can rename both and updates survive relaunch.

R5: REAL EVIDENCE, NO PHANTOM GREEN
- Make test sources portable: scratch/test_chat_slice.py currently hardcodes an absolute local path. Replace SOURCE substring checks with actual deterministic Swift XCTest/Swift Testing cases or classify remaining Python source checks as STATIC_PATTERN_ONLY. Run `python3 scratch/test_chat_slice.py` and `python3 scratch/verify_matrix.py` and capture RAW output; don't claim 4/4 or 46/46 if failing. Keep the documentation validator as DOCUMENTATION_ONLY.
- No CI workflow is currently committed. Add suitable pure-domain automated tests on a supported Swift compiler and, where available, macOS/iOS-target compile jobs. Apple-SDK compilation and iPad Playgrounds import must remain NOT_RUN until truly executed on Apple tools/hardware.
- Obtain real compiler diagnostics from iPad Swift Playgrounds or macOS/Xcode early. Stop blind mass editing; resolve compile errors by dependency group. In the user-facing handoff, list reproducible iPad import/build commands/steps, exact SDK and package constraints, required capabilities and privacy purpose strings. Apple Foundation Models must be gated behind suitable OS/device/model availability.
- Update `docs/implementation/IMPLEMENTATION_CHECKPOINT.md` with exact file identities, test command outputs, discovered defects, PASS/FAIL/NOT_RUN per gate, and NEXT_EXACT_ACTION. Keep the 187-path inventory reconciled; zero-byte files alone are not the metric.

OPERATIONAL RULES:
- No code generators over existing manually repaired files.
- No unrequested git reset, rebase, delete of user changes, or force push.
- No hardcoded developer-owned API keys. BYOK secrets stay in Keychain.
- No silent failure suppression that yields green UI, no fake success responses, no broken placeholder declarations that collide with real views.
- Use dependency-ordered, reviewable commits if the user has authorized Git changes; otherwise leave local diff and report exactly what to commit.
- At any quota/context boundary, save a SHORT durable checkpoint with the exact last completed file/test and first unfinished action, not another 20-page aspirational status report.
- Report the current compiler/build status accurately. If Linux lacks Apple SDK, iOS compile is NOT_RUN, not VERIFIED STATIC.

FIRST EXECUTION NOW: R0 snapshot + inspect actual current source, then fix R1 blockers, then proceed immediately to R2 real streaming conversation. Do not stop at an audit-only response.
```
