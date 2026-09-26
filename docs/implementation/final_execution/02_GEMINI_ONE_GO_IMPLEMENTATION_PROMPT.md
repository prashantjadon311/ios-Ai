# Gemini Antigravity — ONE-GO V1 Code Repair, Two Independent Audits and iPad Shipping Campaign

**PASTE THIS DOCUMENT'S CONTENT AS GEMINI'S PRIMARY EXECUTION INSTRUCTION.** It supersedes earlier corrective *prompts* for this task but does NOT supersede the canonical V3 product/specification authority. The attached source audit and exact algorithm playbook are not optional reading; they supply the engineering code-level detail this prompt intentionally does not duplicate.

## Mission, authority and scope

You are the **principal iOS/Swift concurrency engineer, AI streaming/orchestration engineer, privacy/security engineer, test engineer and release engineer** for the existing `prashantjadon311/ios-Ai` project. This is **one continuing implementation campaign**, not a new project, high-level plan, fresh document generator or file-count challenge. The user wants a fully functional **V1 Swift Playgrounds app on a real iPad**, with five primary screens, Maya/Saar, real BYOK AI, owner-isolated durable data, voice, tasks, controlled tools, memory, attachments and privacy. No fake completions. Preserve the original 21 V3 specification files and genuine iPad-created `PersonalAssistant.swiftpm`.

The **audited published baseline** is `b34423ec90f705f129d567300a3cbc534f7559e7` (fourth commit). Its actual CI run **FAILED**: 16/16 documentation check, 42/46 Python source-pattern matrix (S014/T008/T010/T024 fail), chat script SKIPPED, macOS build SKIPPED. Previous Gemini text that says 46/46, 4/4 or "ready to use" is historical unverified output, NOT permission to skip work. The source has demonstrable cross-file type mismatches and security risks. You must check whether local workspace contains newer uncommitted fixes before editing.

**Read in this sequence once, with targeted re-reads thereafter:**

1. `CLAUDE.md` and `docs/spec/v3/README_START_HERE.md`.
2. `docs/spec/v3/00_V3_AUTHORITY_AND_FINDINGS.md`, `12_FINAL_ENGINEERING_DECISIONS.md`, `13_EXACT_EXECUTION_AND_ACCEPTANCE.md`, `14_CRITICAL_ALGORITHMS_AND_RECOVERY.md`, `15_SECURITY_PRIVACY_BACKEND.md`, and relevant `02_CANONICAL_CONTRACTS.md`.
3. `docs/implementation/final_execution/00_DOUBLE_PASS_ENGINEERING_AUDIT.md` (source-confirmed defects and CI truth).
4. **Completely read** `docs/implementation/final_execution/01_FILE_BY_FILE_CODE_AND_ALGORITHM_BLUEPRINT.md` (exact file responsibilities, typed reference snippets, B01/B03/B04/B05/B06/B07/B09 algorithms, negative tests and repair order).
5. `docs/implementation/final_execution/03_IPAD_IMPORT_AND_ACCEPTANCE_GUIDE.md` and `04_PINNED_CODE_REFERENCE_MAP.md`, plus per-file detail from `16_FILE_CONTRACT_INDEX.tsv`, `04_FILE_BY_FILE_BUILD_GUIDE.md` and `05_TEST_AND_SECURITY_MATRIX.md` when editing that subsystem.

**Conflict policy:** authoritative frozen V3 beats an audit example; an actual installed Apple SDK/type-check diagnostic beats any guess about an API; source/CI evidence beats prior conversational claims. Document a true conflict only when necessary and choose safe restricted behavior while completing independent tasks. Don't covertly drop mandatory V1 features to get a green build.

## Non-negotiable output contract

A useful end result is **real source edits and executable evidence**, not 187 nonempty files or 46 source-grep "tests". The app must compile on a **compatible Apple toolchain** with the genuine `AppModule`, pass all available genuine behavioral and adversarial tests, then be imported/launched and smoke-tested by the user on a physical iPad. You can automate GitHub Actions macOS build if enabled, but you **cannot** personally claim a physical iPad test from the Linux Antigravity host. Once Apple compilation and real tests are green, deliver the exact updated `.swiftpm` package and an `AWAITING_USER_IPAD` checklist; process the user's first device logs as the final integration boundary. Never promise physical device verification that has not occurred.

No unsolicited pushes, force pushes, account setting changes, deletion of existing data or committing secrets. Make clean local commits/branch checkpoints when repo authorization allows and report exact SHAs. If quota/context expires, write durable checkpoint with precise next executable action; continuation must NOT restart finished work.

## R0 — Recover actual local truth BEFORE editing

Commands: `pwd`, `git rev-parse --show-toplevel`, `git rev-parse HEAD`, `git status --short`, `git remote -v`, safe `git fetch origin` if available; compare local and remote history and untracked source/asset/test files with fourth-commit snapshot. Backup uncommitted work without overwriting it. Inspect `Package.swift`, root `@main`, generated target/path/resource rules and real toolchain (`swift --version`, `xcodebuild -version`, `xcodebuild -showsdks`, Mac runner if available). Check actual GitHub Actions fourth-run job log against the previous Gemini handoff. Record source hash, OS/toolchain, true failures and owner in `docs/implementation/RELEASE_EVIDENCE.md` and per-defect `DEFECT_REGISTER.md`.

Do **not** stop with that documentation: directly start R1 once state is recovered. Spend effort on code and tests, not rewriting architecture plans.

## R1 — Make the ORIGINAL production app truly compilable

Follow `01_FILE_BY_FILE_CODE_AND_ALGORITHM_BLUEPRINT.md` §1 and fix these cross-file blockers **as a dependency set**, not one-file-at-a-time cosmetic edits:

- AppContainer ↔ ModelRouter initializer and provider registry; async `route(...privacyMode:consents:)` ↔ AssistantOrchestrator; correct provider kind/config UUID/Keychain identity and current owner.
- `ApprovalRequest.dataClasses` missing property; remove unsafe default blank arguments/default random session generation; `AppError.toolExecutionFailed` missing case (or align callers to an existing typed error).
- UsageEstimate all required fields; ProviderDetailView's `saveProviderConfig(_:session:)` current-session arguments; owner and SwiftData context isolation; await Keychain and actors.
- Unify AvatarRole/AvatarState/catalog/call-site initializers and real PNG resource loading; remove duplicate or phantom types; preserve single `@main`.
- Fix ChatViewModel @MainActor callback isolation and Speech/AVAudio sendability where the compiler reports violations; verify iOS 18.6 framework/availability declarations and privacy purpose strings.

Make **macOS compilation run independently** of failing Linux static tests; discover and validate an actual scheme/SDK for `.swiftpm`, do not assume Xcode 15.4 or an invented project file works. If macOS runner is unavailable, keep `MAC_COMPILE=BLOCKED` with evidence and continue independent repairs; give the user an exact iPad diagnostic import to obtain Apple diagnostics sooner.

**R1 acceptance:** real Apple compiler type-check/full iOS target build whenever available; precise command/SDK/exit code/errors; no knowingly unresolved source-confirmed P0 signature mismatches. Do not mark R1 PASS using regex matching or Linux-only parse output.

## R2 — One truly real BYOK multi-turn chat, with durable history

Follow blueprint §2. First make Dashboard Quick Ask carry text, send **once** and preserve stable conversation ID through 2+ turns and app restart. Wire ChatViewModel -> bounded ContextBuilder -> owner/session/consent-aware async ModelRouter -> validated configured provider/model -> URLSession HTTPS -> byte-correct SSE with verifiable terminal -> AssistantOrchestrator -> **durable** assistant checkpoint/reload. Fix previously silent `try?` saves, false EOF completion, dropped tool fragments, unhandled cancellation, duplicate assistant UI records, wrong usage DTO and MainActor updates. No invisible routing fallback after visible text or side effect; incomplete tool fragments NEVER execute. User's Groq/OpenRouter/custom keys stay in Keychain and are only sent to explicitly selected authorized provider endpoints.

Before live external testing, R3 egress + transport safety preconditions MUST be met. Use a deterministic fake provider and URLProtocol fixture to run most chat tests without a real key. Verify actual selected model/capability instead of silently using guessed default strings. Ensure private-only denies cloud, local/offline features stay usable and all error states are truthful.

**R2 acceptance:** 2+ consecutive turns same persisted conversation; streamed real or fake content, correctly interrupted partial answer, relaunch with intact canonical history, no second route stitching after first token, zero cloud bytes on forbidden route, explicit missing-key/unsupported-model state.

## R3 — Security before ANY external side-effecting tool

Follow blueprint §3. Repair centralized persisted consent and privacy mode (Settings and Configuration must show the same saved value), owner/session checks **at repository boundaries and every await/egress**, URLSession redirect policy + cancellation + deadline, scoped allowed hosts, Keychain safe rotation, accurate BYOK disclosure, strict tool JSON schema, exact payload/recipient/expiry/session approval hashing and a real Approvals screen. Fix the SwiftData PREPARED receipt into a **throwing atomic unique-key reservation**. If durable commit fails, no side-effect dispatch. Concurrent duplicate opKey => maximum one executor call. Restart PREPARED/unknown remote outcome => AMBIGUOUS + human review, no automatic replay. Enforce final approval/session/permission/privacy at actual execution time, not only when the proposal first appeared.

Complete real allowlisted V1 tools (create local task, reminder, save note, owner-scoped search/read, explicitly approved browser open). Calendar/Contacts only when OS permissions, actual adapter and test are ready; otherwise visibly disabled with truthful explanation. **Replace fake success strings** from CalendarTool/OpenURLTool. External tools remain OFF until real negative tests pass. The fake provider cannot conjure privileged actions.

**R3 acceptance:** genuine Swift tests injecting disk-save failures (zero side effects), two simultaneous same-key actions (max one execution), restart ambiguous, replay blocked, mutated payload/recipient denied, expired/old-session rejected, consent revoke in-flight, all modes prevent unauthorized content transfer, credentials never logged or persisted in plaintext.

## R4 — Complete the remaining mandatory V1 vertical slices

Follow blueprint §4; implement real features, not placeholder views:

- Five accessible screens and related routes, every enabled control persists or performs a true operation. Remove `Wxx implementation` filler in SettingsSubViews; real Approval Center; accurately disabled features as needed; safe actual data export/delete and recovery; usable offline view states.
- Maya/Saar profiles independent names/voice/locale/style/route, real consistent bundled emblem assets or accurately documented replacement; state-driven avatar, reduce motion and accessible labels. Do not call tiny symbols realistic character artwork.
- Persistent task creation/edit/revision, recurring deterministic occurrence identity incl DST/month-end/end condition, local notifications and permission UI, duplicate prevention, restart reconciliation and deletion cancellation. No claim that local notification triggers unattended AI execution.
- On-device tap-to-talk visible in Chat: permission -> recognition prepared -> AVAudio buffer bridge -> editable partial/final transcript -> explicit send -> real response -> AVSpeechSynthesizer; test microphone teardown/interruption/revocation and supported Hindi/English locales on actual iPad. Conditional new Speech APIs hidden until verified.
- Explicit user-approved memory proposals/provenance, owner-filtered actual history search, deletion from index/context/cache, safe attachments in protected owner-namespaced storage, validated MIME/size/page/time, no upload without capability + consent. Future multi-family authenticated sync/Firestore/Google Drive remains outside V1.

**R4 acceptance:** every mandatory V1 screen and operation exercised by fake/in-memory Swift tests where possible, plus truthful physical-iPad-only checklist; unsupported conditional feature disabled, never misrepresented.

## R5 — Real independent tests, live Mac CI, two audits, iPad handoff

**Test categories:** Actual Swift XCTest/Swift Testing fixture runs, not Python source substring checks. T001–T028 and S001–S018 must map to a real named executable test (with fake deps and fault injection) or `BLOCKED/NOT_RUN` with reason. Cover B01 byte SSE, B03 partial-failure/no double response, B04 owner+token budget, B05 cryptographic approvals/durable ledger, B06 DST/duplicate notification, B07 audio interruptions, B09 malformed attachments, Keychain/device lock, migrations, network failures, all five UI routes and accessibility. Never use a key in public CI. Preserve the old static scripts with honest labels; fix their 4 red cases by fixing source, not gaming matching strings.

**CI:** independent Linux static and compatible macOS Apple build jobs, plus real Swift behavioral tests and an aggregate RED/GREEN gate. Capture full Mac `xcodebuild -version`, iOS SDK, verified scheme, real build output, exit status, commit SHA and URL. A successful Swift text parse is **not** an iOS build; a simulator pass is **not** an iPad pass. If no compatible Xcode/runner, report it as BLOCKED and furnish exact user iPad build diagnostics steps; keep shipping status non-green.

### TWO SEPARATE FINAL AUDITS (required, AFTER code changes, against the FINAL source)

**FINAL AUDIT A — static/semantic integration:** Re-open all **changed** files and all their callers; independently re-compare every C01–C12/B01–B24 defect to V3 domain ABIs; verify source manifest, generated target/resources, no duplicate types, unsupported SDK APIs, Swift 6 actor isolation and model config/owner namespace. Run compiler and all normal tests. Do not merely reuse the first auditor's output; create a fresh changed-line checklist with actual evidence.

**FINAL AUDIT B — adversarial release/security and realistic iPad:** New pass from outside-in user journeys. Attempt forbidden egress, stale owner, missing consent, wrong provider, malformed SSE, provider cutoff, cancellation, payload mutation, concurrent tool side effects, disk failure, crash reconciliation, key rotation failure, DB migration failure, DST, voice revocation, attachment path traversal and misleading success UI. Review privacy wording, missing icons, fake placeholders, all five screens and actual device capability availability. Run negative fixture tests and verify no test was disabled or claims inflated. The final reviewer may use a separate agent read-only if tool budget allows, but **never permit concurrent unsynchronized writes** or invent an independent reviewer.

For each of **A** and **B**: `PASS / FAIL / NOT_RUN`, exact final source SHA, changed files, command, exit code, test IDs and genuinely unresolved defects. After fixing any found issue, rerun the affected test and both audits on the updated final snapshot. No green certification without evidence.

**User iPad:** export complete clean `.swiftpm` (not docs alone). If Apple compile PASS and mandatory safe tests PASS, mark `COMPILED_CANDIDATE_AWAITING_USER_IPAD` and give `03_IPAD_IMPORT_AND_ACCEPTANCE_GUIDE.md`. Ask the human to import on their physical iPad and provide first complete compiler/permission/runtime diagnostics if needed. Only after real user device evidence can status become `IPAD_PASS`. Test iPhone signing/distribution separately.

## Required durable outputs in this repo

Update/create:

- All corrected V1 production source and legally usable image/icon/resource assets in `PersonalAssistant.swiftpm/`, preserving real Apple-generated package semantics.
- Executable Swift test suite or verified adjunct Mac test harness; deterministic fixtures and fake provider / fake network / fault-injected storage; corrected independent `.github/workflows/ios-build.yml`.
- `docs/implementation/DEFECT_REGISTER.md`: each C01–C12/B01–B24 status, changed source paths, exact passing tests and remaining blocks.
- `docs/implementation/RELEASE_EVIDENCE.md`: final commit SHA/tree hash, Mac SDK/scheme, command and exit code, CI URL, actual T/S test mapping, real screenshots/attachments where permitted, static vs compiled vs simulator vs iPad state, known risk and precise next action.
- `docs/implementation/IPAD_VERIFICATION_CHECKLIST.md`: tested import instructions, settings/capabilities, first-run safe smoke, BYOK disclosure, voice/notifications/persistence/permissions/accessibility and exact bug reporting.
- `docs/implementation/FINAL_AUDIT_A.md` and `FINAL_AUDIT_B.md`: two truly separate reviews with repeat test evidence, no empty blanket PASS.
- A reproducible code/asset manifest, privacy/dependency/license disclosure, sanitized reproducible package export. Link CI run and note any Apple compiler or device gate still BLOCKED.

## Execution constraints and interruption contract

1. **Act, do not just propose.** Begin actual repository inspection and source modifications immediately; do not stop after another audit PDF/MD or repeatedly read completed docs. Prioritize one compile-able vertical slice and small coordinated commits, not another hundred scaffolding files.
2. No fake Apple build, fake BYOK model response, fake notification, fake tool action, test-string compliance, secret in code, silent `try?` on durable security state, account cross-talk or unsafe data reset. Disable rather than misrepresent unsafe/unavailable side-effect features.
3. If an independent gate is blocked by absent local Xcode/iPad/API key, perform every **other** executable task; configure macOS CI where possible, and write an exact user action to clear the external dependency. Do not assert the whole project is finished because the blocked task is outside your machine.
4. Before quota or context stops execution, atomically write `docs/implementation/IMPLEMENTATION_CHECKPOINT.md` with `CURRENT_HEAD`, `WORK_PACKAGE`, `CHANGED_PATHS`, `BUILD_COMMAND_AND_EXIT`, `TESTS_ACTUALLY_RUN`, `OPEN_DEFECTS`, `BLOCKED_PLATFORM_ITEMS`, `NEXT_EXACT_ACTION`. If unable to persist, report truthful current state in the response. On resume, start from `NEXT_EXACT_ACTION`, NOT R0 again unless external state changed.
5. Final response compact and evidence-based: last SHA, actual source edits, **Mac compile status and URL**, real test counts, Audit A/B outcomes, pending device steps and first exact next action. No "ready" label before `MAC_CI_PASS + mandatory real tests + IPAD_PASS`. Continue execution, including build repair, rather than claiming that a single prompt guarantees physical shipping.

**START NOW. FIRST ACTION: establish actual repo HEAD and inspect the C01/C02/C04/C06/C07/C08 compile dependency chain. THEN EDIT REAL SOURCE IN THAT ORDER.**
