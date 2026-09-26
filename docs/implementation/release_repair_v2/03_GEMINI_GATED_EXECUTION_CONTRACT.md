# 03. Gemini Antigravity execution contract: replace the failed "one-go" loop

**This document is a READY-TO-PASTE execution prompt.** It exists to produce **source changes and external proof**, not another self-congratulatory final report. Read the repository files at their actual local paths first. The pinned baseline is public GitHub commit `2918293e7355290ba722bb734652c9ad70c75a9f`; local uncommitted or newer work may already contain valid repairs and must be preserved. Physical iPad tests must be performed on the user's actual device.

---

```text
TASK: RESTORE ENGINEERING TRUTH, COMPILE THE REAL IOS APP, FINISH V1
MODE: BOUNDED AUTONOMOUS IMPLEMENTATION WITH HARD EVIDENCE GATES
ROLE: Principal iOS / Swift 6 Engineer, AI Systems Engineer,
      Security Engineer and Release Verification Owner

THIS IS AN EXISTING PROJECT. DO NOT REGENERATE IT.

SOURCE RECOVERY FIRST
=====================
cd to the existing ios-Ai checkout, then record:
  pwd
  git rev-parse --show-toplevel
  git rev-parse HEAD
  git status --porcelain=v1
  git log -5 --oneline
  git remote -v
  git ls-files 'PersonalAssistant.swiftpm/*.swift' \
               'PersonalAssistant.swiftpm/**/*.swift'

Previously independently audited public SHA:
2918293e7355290ba722bb734652c9ad70c75a9f

Preserve newer valid local changes. Never reset, overwrite, force-push
or delete uncommitted work. If the current working tree differs,
re-anchor every source line and defect to the actual local HEAD.

EXACT MANDATORY NEW CAMPAIGN FILES (eight Markdown files)
======================================================
Location: docs/implementation/release_repair_v2/

1. README_START_HERE.md
   Exact authority hierarchy, placement and evidence rules.

2. 00_SELF_AUDIT_AND_FAILURE_ROOT_CAUSES.md
   Required reading to avoid repeating mistakes in previous assistant
   blueprint and Gemini final-audit reports.

3. 01_FULL_REPOSITORY_ENGINEERING_AUDIT.md
   Complete 187-file structural inventory, cross-file root causes,
   pinned line references, all identified release-blocking defects.

4. 02_COMPILER_FIRST_EXACT_CODE_REPAIR_BLUEPRINT.md
   Your PRIMARY code repair document: exact source paths and lines,
   pinned code snippets, algorithms, caller and persistence changes.

5. 03_GEMINI_GATED_EXECUTION_CONTRACT.md
   THIS execution contract. Obey its gate order and stop rules.

6. 04_EXECUTABLE_TEST_MATRIX_AND_IPAD_GATES.md
   Each executable negative test, required CI/device evidence,
   pass/fail rules and exact human iPad test sequence.

7. 05_EXACT_SWIFT_CODE_AND_CALLER_PATCHES.md
   Your NEW precise Swift edit recipes and cross-file dependency map.
   Read G0 code first, then the appropriate gate's snippets.

8. 06_VSCODE_LINUX_MAC_CI_AND_IPAD.md
   Your actual Ubuntu VS Code build/test setup and Apple CI/Mac route;
   no false assertion that Linux can build the SwiftUI iPad app.

Before edits verify all eight are present, readable and nonempty.
Read only the required material at the current execution boundary:
  BOOT: README, 00 (root causes), 03 (this contract),
        01 sections 1–3, 02 Gate G0, 05 G0 snippets and 06 toolchain.
  G1: 01 AI section, 02 Gate G1, 05 G1 snippets, matching 04 cases.
  G2: 01 security section, 02 Gate G2, 05 G2 snippets, matching 04 cases.
  G3: 01 tools/security findings, 02 Gate G3, 05 G3 snippets, matching 04 cases.
  G4: 01 tasks/voice/UI/media, 02 Gate G4, 05 G4 snippets, matching 04 cases.
  G5: 01 evidence section, 02 Gate G5 and ALL of 04.
Keep a read-coverage ledger: every numbered audit issue and every
blueprint gate must be reconciled before the final two audits.
Do NOT load all prior handoffs and all 21 V3 documents simultaneously.

EXISTING CANONICAL SPEC, NOT OPTIONAL
=====================================
Read CLAUDE.md and the canonical V3 index/authority first; open the
remaining V3 sections when the corresponding gate needs them:
  docs/spec/v3/00_V3_AUTHORITY_AND_FINDINGS.md
  docs/spec/v3/02_CANONICAL_CONTRACTS.md
  docs/spec/v3/05_TEST_AND_SECURITY_MATRIX.md
  docs/spec/v3/12_FINAL_ENGINEERING_DECISIONS.md
  docs/spec/v3/13_EXACT_EXECUTION_AND_ACCEPTANCE.md
  docs/spec/v3/14_CRITICAL_ALGORITHMS_AND_RECOVERY.md
  docs/spec/v3/15_SECURITY_PRIVACY_BACKEND.md
  docs/spec/v3/16_FILE_CONTRACT_INDEX.tsv

At boot read V3 `00`, `02`, `12`, `13`; use `05`, `14`, `15`, `16`
at the relevant security/algorithm/contract gate. Verify local existence.
Do not load unrelated V3 or historical handoff content into context.
Preserve frozen product scope and existing architectural contracts
unless an actual demonstrated defect requires a documented deviation.

Old final_execution/ prompts and latest_fifth_audit/ files, if present,
are HISTORICAL INPUT ONLY. Their code snippets were not Xcode-verified
and their published completion claims are contradicted by CI.
Do not let those snapshots override current source or this campaign.

HARD PROJECT TRUTH
==================
The fifth-commit CI is RED:
https://github.com/prashantjadon311/ios-Ai/actions/runs/36222465812

Actual CI:
  docs structural validation 16/16 PASS
  Python source-pattern checks 45/46; T010 FAIL
  chat source-pattern script SKIPPED
  macOS Xcode FAIL at manifest localization before Swift type-check
  committed Swift tests NOT FOUND
  physical iPad NOT_RUN

Previous FINAL_AUDIT_A/B and RELEASE_EVIDENCE 'all clear' text is NOT
proof. First create a dated provenance correction in the checkpoint.
Never call the public version COMPILED, RELEASED or IPAD_READY.

WORKING RULES
=============
- ACTUAL CODE EDITS before generating any further lengthy report.
- One coherent, dependency-complete integration slice per work package.
  Include all API callers, DTOs, mappers, UI state and tests required
  for that slice. Do not shotgun all 187 files at once.
- After each slice: git diff --check; syntax checks where available;
  run targeted executable Swift tests where possible; Linux portable tests first, Apple executable integration tests on real SDK;
  run the REAL app compiler; inspect exact diagnostics and repair.
- If Xcode is unavailable on the local Linux host, use an authorized
  GitHub Actions PR branch as the compiler loop; if pushing has not
  been authorized, finish independent work and ask for that exact
  action. Do not invent CI jobs, results or installed SDK versions.
- NO production keys or sensitive user records in tests or log files.
- NO external side-effect tools enabled until G3 adversarial tests PASS.
- NEVER modify assertions purely to make a static Python check green.
- Never suppress critical DB/security/privacy exceptions with try?.
- Never provide final sign-off using code comments, documentation,
  source balance checks, or your own unchecked audit assertion.
- Preserve any currently valid user's original files and data.

GATE 0: TRUTH, EFFECTIVE MANIFEST, FIRST APPLE COMPILER
======================================================
1. Verify the complete source inventory, all 187 Swift files, app
   resources, actual manifest generator/template and pending git diff.
2. Correct the localization manifest in a re-export-safe way. Keep
   en and hi assets. Follow G0.1 in file 02.
3. Correct the SEVEN additional confirmed compiler families in G0:
   ApprovalRequest, AvatarIdentity/catalog overloads, duplicate
   completeOnboarding, wrong ApprovalDetailView property, malformed
   AIConfigurationView interpolation, undefined TaskStep consumers,
   wrong unsupportedCapability(name:) in conditional Apple provider.
4. Preserve AvatarRole.themeColor: it already exists.
5. Fix CI runner and SDK discovery; never fall back to incompatible
   Xcode just to satisfy a command name. Discover real package scheme
   or create a reproducible auxiliary Xcode build wrapper while keeping
   the iPad-generated .swiftpm canonical.
6. START ACTUAL APPLE COMPILATION AS SOON AS MANIFEST RESOLVES.
7. Fix newly discovered compiler diagnostics in dependency-complete
   small diffs. Repeat until full AppModule compiles and links.

G0 PASS requires an exact Apple build command, exit code 0, a CI URL
(or genuine local Mac log), full source SHA and evidence of resource
resolution. Linux swiftc -parse does not close G0.
If blocked for external CI authorization, mark G0 BLOCKED_EXTERNAL
and complete independent pure Swift design/tests without lying.

GATE 1: REAL TWO-TURN BYOK CHAT, NOT A WIRED-LOOKING MOCK
========================================================
Implement all G1 sections of file 02 using current canonical types.
Correct Quick Ask delivery exactly once; persistent user/assistant
messages and verified restart; owner-aware provider factory, persistent
model selection, no bogus 'default' model, actual config-specific
custom endpoint; capability filtering without model-name heuristics.

Wire ContextBuilder correctly with untrusted verified memories,
recent chronological history, truthful token budget and ONE active
query. Implement real provider streaming, typed failures, proper SSE
terminal detection, cancellation from UI -> orchestrator -> provider
-> HTTP child task, and no silent fallback after first visible token.

Use one injected fake provider/HTTP transport to prove two-turn,
restart, EOF/cancel/error and message-persistence behavior BEFORE
running one user-authorized low-risk live BYOK smoke test.

G1 PASS: compiled Swift integration tests + Apple app build + no
known P0 chat defect + exact test logs and fake-provider traces.

GATE 2: FAIL-CLOSED NETWORK PRIVACY AND OWNER SESSIONS
=====================================================
Implement G2 in file 02. One authoritative preference mutation path,
commit before publishing, explicit destination consents, no fallbacks
to cloudAllowed on storage failure. Central enforcement AT NETWORK
DISPATCH for chat, model catalog, custom endpoints and optional STT.
Reject credentialed redirects and wrong/changed destination host.
Cancel ongoing requests when privacy tightens and ignore all stale
owner/session callbacks. Typed Keychain locked/absent/rotation outcomes.
Complete owner-filtered storage operations for conversation, memory,
tasks, attachments and search.

G2 PASS: compiled fault-injected security tests prove ZERO HTTP
requests after private-only, failed preference reads, owner switch,
revoked consent and unapproved redirects. Simulator/real network
observability where available. Rebuild the full target.

GATE 3: APPROVALS AND DURABLE SIDE-EFFECT SAFETY
================================================
Implement G3, NOT just the DTO compile patch. Typed strict schemas,
canonical destination-and-payload binding, owner/session/expiry
checks, genuinely persisted pending approvals, real Approval Center,
atomic single-use consumption and validated executor dispatch.

Replace await-check + await-prepare with one non-suspending database
transaction and enforced unique operation key. No executor call if
PREPARED save fails. No automatic retry for ambiguous side effects.
Propagate status-update errors; do not return unpersisted success.
Persist owner-scoped tool-permission toggles and actually enforce them.
Only after this may the provider expose tool schemas and parse its
fragmented tool proposal stream. Never fabricate tool success.

G3 PASS requires real compiled tests: wrong owner, stale generation,
modified recipient/arguments, expired or double approval, two
concurrent same-op requests (executor count exactly ONE), failed DB
save (count ZERO), kill/restart ambiguous op (no auto retry), and
invalid JSON/unknown tool (count ZERO).
If G3 cannot be verified, disable all side-effecting tools,
mark mandatory release scope incomplete, and continue safe independent
features. Do not hide the missing scope in documentation.

GATE 4: REQUIRED PRODUCT FEATURE INTEGRATION
=============================================
Implement G4: five genuine working primary screens; Maya/Saar
independent persisted settings and assets; real local task scheduling,
recurrence including end conditions/DST, permissions and edit/delete
notification cleanup; actual voice capture permission and lifecycle,
editable transcription and per-assistant TTS; owner-scoped memory,
search, attachment security and truthful Settings.

Inspect every ENABLED visible control for persistent effect. Remove
or properly gate local-only fake switches and unfinished actions.
Remote scheduling and Apple Foundation Models remain correctly gated
as conditional/future until real platform support is proven.

G4 PASS: compiled functional tests, simulator smoke where available,
all five screens exercised, no deceptive controls, current app build.

GATE 5: TWO REAL POST-CODE AUDITS, THEN DEVICE HANDOFF
======================================================
A. ENGINEERING AUDIT: re-open EVERY changed file and every caller,
   check exported signatures, concurrency, SwiftData migrations,
   screen navigation, resources, lifecycle and actual build/test logs.
B. ADVERSARIAL RELEASE AUDIT: inspect owner isolation, unexpected
   egress, injection/tool mutation, race/restart, cancellation,
   privacy toggles, task recurrence/DST, media and speech permissions.

Audits must be based on the FINAL SHA and exact executed test outputs,
not on the previous F01-F30 list or on your own newly written claims.
Fix any defect and rerun affected tests and both audits.

Then produce a verified .swiftpm with correct resource bundle,
reproducible Apple build/test logs, SHA, defect register, and precise
physical iPad instructions from file 04.

Physical device has not been available in Antigravity Linux;
stop with COMPILED_TESTED_CANDIDATE_AWAITING_IPAD ONLY after true
Mac compilation and compiled tests pass. The user will perform the
actual import/launch/permission/voice/notification/Keychain tests.
Any compiler/runtime diagnostics sent by the user become the NEXT
repair task, not a new project restart.

CHECKPOINT AND OUTPUT FORMAT FOR EVERY STAGE
=============================================
Update docs/implementation/IMPLEMENTATION_CHECKPOINT.md after each
cohesive slice with:
  gate_id:
  git_HEAD_and_dirty_status:
  verified_file_hashes_or_diff:
  changed_files_with_exact_methods:
  test_category: STATIC|APPLE_BUILD|SWIFT_TEST|SIMULATOR|LIVE|IPAD
  exact_commands_and_exit_codes:
  CI_URL_or_local_build_log:
  actual_test_cases_passed_failed_skipped:
  unresolved_P0_P1_and_new_diagnostics:
  blocked_external_action_if_any:
  NEXT_EXACT_ACTION:

On quota exhaustion, save a durable checkpoint and resume only from
NEXT_EXACT_ACTION. Never repeat completed research or discard an
already demonstrated fix.

RELEASE CLAIM RULES
===================
Until Mac compile: BUILD_BLOCKED.
After Mac compile, before tests: COMPILED_UNTESTED.
After Mac compile and genuine executable tests: COMPILED_TESTED_CANDIDATE.
If physical iPad unavailable: AWAITING_USER_IPAD.
Only after actual iPad acceptance: IPAD_VERIFIED.
If any required V1 feature remains disabled: FEATURE_SCOPE_INCOMPLETE,
not PRODUCTION_READY.

BEGIN NOW: recover actual HEAD, correct the existing false checkpoint,
fix G0 known compiler families and run the real Apple compiler.
Do not output another long plan in place of the first code changes.
```

---

## Why this contract is different

This is *not* a promise that sufficiently detailed prose automatically makes correct code. It forces exactly the missing feedback: first real Apple compilation; coherent caller/DTO/mapper changes; executable Swift behavior tests; negative tests for security; verified CI provenance; then a human-owned iPad gate. If the agent cannot access a required tool, the contract tells it what it may finish independently and when it must stop instead of fabricating success.


## V2 supplemental execution guard

The whole ready-to-paste prompt above is controlling **only when combined with** `05_EXACT_SWIFT_CODE_AND_CALLER_PATCHES.md` and `06_VSCODE_LINUX_MAC_CI_AND_IPAD.md`. The verified actual source is the local checkout, not this document's example patches. In VS Code on Ubuntu, perform `swiftc -frontend -parse` and the optional portable-source `swift test`; **do not run** `swift build` inside the original `.swiftpm` on Linux and interpret the predictable `AppleProductTypes`/SwiftUI failure as an app compile.

Apple build route priority: an already available Mac (VS Code Remote SSH), otherwise an authorized push of an explicit repair branch to a GitHub Actions macOS runner. The Mac/CI must prove its checkout SHA matches the tested artifact. If no authorized push or Mac is available, save `BLOCKED_EXTERNAL_APPLE_TOOLCHAIN` and deliver an accurate dependency request after finishing local independent work. Do not fabricate a Mac build.

A conditional (disabled) feature may remain a named V3 `COND/NEXT` stub, but **every compiled file must still type-check**. Required V1 features cannot be replaced by disabled UI controls to manufacture a release pass. The immediate useful milestone is a buildable, importable, safe iPad candidate; only real device evidence closes release.
