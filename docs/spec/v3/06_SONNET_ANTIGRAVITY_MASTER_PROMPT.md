# V3 copy/paste master instruction for Claude Sonnet in Antigravity / VS Code

ROLE: Implementer. Build the fully usable native Swift/SwiftUI personal assistant described by this packet. All architecture, trust boundaries, feature scope, domain contracts, persistence roles, streaming algorithms, task state/recovery and UI ownership are frozen. Your job is to WRITE AND TEST CODE, not brainstorm an alternate architecture or silently delete difficult features.

SOURCE ORDER (mandatory): `README_START_HERE.md` -> `00_V3_AUTHORITY_AND_FINDINGS.md` -> `12_FINAL_ENGINEERING_DECISIONS.md` -> `13_EXACT_EXECUTION_AND_ACCEPTANCE.md` -> `14_CRITICAL_ALGORITHMS_AND_RECOVERY.md` -> `15_SECURITY_PRIVACY_BACKEND.md` -> `02_CANONICAL_CONTRACTS.md` -> `11_CORE_METHOD_BLUEPRINT.md` -> `03_ALGORITHM_COOKBOOK.md` -> `16_FILE_CONTRACT_INDEX.tsv` -> `04_FILE_BY_FILE_BUILD_GUIDE.md` -> `08_CANONICAL_MANIFEST.tsv` -> `07_CANONICAL_FILE_TREE.txt` -> `05_TEST_AND_SECURITY_MATRIX.md`. If conflict, V3 overrides V2. Other documents are implementation aids.

TARGET: A `PersonalAssistant.swiftpm` from actual iPad Swift Playgrounds template, iPhone/iPad adaptive UI, Dashboard/Tasks/History/Configuration/Settings, full Chat and Approvals routes, Maya+Saar original selectable renameable identities, streaming BYOK Groq/OpenRouter and custom adapter, typed tool proposal with approvals, persisted history/memory/tasks/reminders, native tap-to-talk/TTS, Keychain, diagnostic and privacy policy UI, safe deletion and offline local features. No developer-owned API secret in client. Cross-device Firestore/Drive/managed gateway/real Small AI are FUTURE modules, not falsely enabled V1 features. Conditional Apple AI/Speech/Spotlight functionality only after local compilation/runtime tests.

FIRST ACTION: Inspect workspace, iOS toolchain and any exported iPad `.swiftpm`. W00 must record exact generated app manifest, resource conventions, Capabilities settings and compiler feature probes. Do not invent a manifest. If template absent, continue portable Swift code, pure contract/test work and Xcode wrapper if macOS available; keep W00 physical Playground import BLOCKED. No more general market research unless a versioned API spelling differs from installed SDK.

EXECUTION LOOP: Work through W01–W14 from `13_EXACT_EXECUTION_AND_ACCEPTANCE.md`. Within each gate: implement typed domain/protocol -> pure algorithms -> actor/service -> persistence -> view model -> SwiftUI view -> negative tests -> compile/probe -> update gate evidence. Commit/change-log after each coherent gate. Continue independent work around a specific missing device/key; never claim a test not run. No fake splash screen/demo stub counts as a working feature. Use exact 266-item baseline inventory; only V1 runtime/resources/tests need implementation for shipping, COND capability-gated, NEXT excluded. App source must compile cleanly, but complete delivery is defined by working behavior and test evidence, not file count.

TOP INVARIANTS: Owner scoping and session-generation checks before every read, write, network disclosure, index and tool call. SwiftData @Model classes have a single owner; other layers use immutable Sendable DTOs. No hardcoded credentials, generic catches, `fatalError` replacing recoverable paths, fake async progress, direct URLSession in Views, hidden external transfer or silent provider fallback after partial streamed output. Provider tool JSON fragments are not executable. Approval is exact single-use payload with expiry and reauthorization. Durable PREPARED receipt before external side effect; ambiguous write outcome never auto-retried. Local notifications cannot perform unattended arbitrary AI jobs. Never store hidden model reasoning.

MUST RUN (when environment allows): executable fixture tests for per-byte SSE slicing, fragmented provider tool calls, 401/429/5xx/cancel/after-partial fallback, corrupt database migrations, DST recurrence, stale account/session events, voice interruption, owner-separated history, untrusted attachment prompt injection, exact tool approval and no duplicate side effects, privacy-only mode blocking all cloud content. Complete T001–T028 and S001–S018. iPad/physical-iPhone tests require actual device; a Swift or Linux compile is not an iOS build. Capture exact command+exit code, not fabricated success.

PROGRESS RECORD after every gate:
```
WORK_PACKAGE: Wxx
CHANGED_FILES: exact paths
SHA256: current source tree hash or manifest path
BUILD: exact command, OS/toolchain, exit code (or NOT_RUN with reason)
TESTS: named tests and outcomes
STATUS: PASS | FAIL | BLOCKED | NOT_RUN
P0_P1: open defects
NEXT_EXACT_ACTION: one precise implementation action
```

REQUIRED FINAL HANDOFF: actual app source and assets, verified template or clearly unverified portability caveat, implementation status ledger, exact tests/evidence, defect register, dependency/license manifest, privacy disclosure checklist, model/endpoint configuration guide, SHA256 manifest and iPad import/iPhone distribution steps. Call the project 'iPad verified' only after real iPad import/build/run, and 'iPhone verified' only after a real installed smoke test.

NO DESIGN CLARIFICATION LOOP: The provided documents settle product decisions. Escalate only a material unsupported SDK contract or mutually contradictory requirement; select the safe constrained fallback already specified and continue other gates. Implement immediately from W00.
