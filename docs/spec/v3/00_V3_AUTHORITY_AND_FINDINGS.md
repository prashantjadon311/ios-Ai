# V3 authoritative audit, design correction and source hierarchy
**Audit date:** 2026-09-25. **Scope:** the complete 15-file V2 archive, including all 266 canonical ledger entries, its predecessor V1 documents, and public Apple documentation relevant to the engineering assumptions. **Evidence:** inspected files and structural validators; not a compiled app or hardware test. V2 is retained as *implementation reference*, NOT as an override to V3.

## Authority: highest to lowest
1. `00_V3_AUTHORITY_AND_FINDINGS.md` (this document) and `12_FINAL_ENGINEERING_DECISIONS.md` (scope, authority, invariants).
2. `13_EXACT_EXECUTION_AND_ACCEPTANCE.md` (gate-by-gate requirements and acceptance), `14_CRITICAL_ALGORITHMS_AND_RECOVERY.md`, and `15_SECURITY_PRIVACY_BACKEND.md`.
3. `16_FILE_CONTRACT_INDEX.tsv` (exact 266 paths, unique responsibility, phase, input/output category, cross-reference, required verification), `04_FILE_BY_FILE_BUILD_GUIDE.md` (per-file descriptions) and `11_CORE_METHOD_BLUEPRINT.md` (core method detail).
4. Retained V2 files 01, 02, 03, 05, 07, 08, 09 only where consistent with V3. `08_CANONICAL_MANIFEST.tsv` is the *frozen 266-item baseline*. **Additional V3 planning/test deliverables are documentation in this handoff, not implicit app-source inventory additions.**
5. `06_SONNET_ANTIGRAVITY_MASTER_PROMPT.md` is the work instruction to the coding agent. It cannot silently weaken the contracts or release gates.
6. Older V1/V2 prose and unverifiable model catalogs never override checked runtime capabilities or official SDK signatures.

## Audit findings, including items missed in V2
| ID | Severity | Defect or omission | Binding V3 correction |
|---|---|---|---|
| A01 | P0 process | The extracted working folder lacked `07_CANONICAL_FILE_TREE.txt` and `08_CANONICAL_MANIFEST.tsv`, although the V2 ZIP contained both. | V3 includes both as files AND archive members; structural validator compares archived and extracted hashes. Do not mislabel the V2 ZIP itself as missing them. |
| A02 | P1 | V2 README repeats `11` in the reading order; broad file recipes are copy/paste templates, not unique algorithms. | Exact ordered reading list; `16_FILE_CONTRACT_INDEX.tsv` links each file to an authoritative pattern/negative test; core algorithm pseudocode extended in 14. |
| A03 | P0 | Swift Playground import, resources, entitlements, distribution and iPhone install were conflated in completion rhetoric. | Independently gated source compile, Xcode simulator, physical iPad Playground import/capabilities, and installed iPhone smoke test. Each may be BLOCKED/NOT_RUN. |
| A04 | P0 | Account semantics ambiguous: separate *local profiles* do not provide true independent cross-device family accounts. | V1 single-owner local-first or explicitly local profiles only; multi-person synchronization requires Sign in with Apple, authenticated backend and Firestore isolation tests. Never call local profiles secure accounts. |
| A05 | P0 | There was no explicit encryption-at-rest threat model or rollback-safe storage key lifecycle. | OS Data Protection and Keychain for device-local storage; no blanket 'E2EE' claim; keychain accessibility, backup exclusion, lock state and restore failures specified in 15. |
| A06 | P0 | Tool approval digest omitted exact encoding/normalization rules and execution-time data/source revalidation. | RFC 8785-like deterministic canonicalization only if implemented/tested; otherwise typed deterministic binary encoding. Include tool/version/account/permission scope/destination/arguments/expiry, compare authenticated bytes; mandatory final authorization before side effect. |
| A07 | P0 | A tool timeout after remote success remains unknown; retry/orchestrator continuation could inadvertently duplicate it. | Durable operation ledger and explicit AMBIGUOUS outcome; no automatic replay of non-idempotent writes; request user verification or server idempotency contract. |
| A08 | P1 | Stream fallback could duplicate partial model text or execute tools proposed by a failed model after route switch. | No fallback after user-visible partial response or side effects without an explicit restart/new trace; discard all incomplete tool fragments on failed route. |
| A09 | P1 | Provider 'compatibility' hides distinct chat, tools, stream, usage and model discovery formats. | Adapter-level capability probes, tolerant read/strict write, tested fixtures per provider; no guessed parameters or model IDs. |
| A10 | P1 | Privacy mode was not specified for every data exit: telemetry, URL opening, external STT, thumbnails, backups and index. | One central destination-aware data egress decision with per-channel consent; private-only blocks all external content transfer, not merely AI chat. |
| A11 | P1 | Language handling 'Hindi/Hinglish' lacked script/locale UX, partial transcripts and fallback policy. | Explicit locale chooser + auto preference with confidence disclosure; offline support determined at runtime; cloud STT opt-in separately consented. |
| A12 | P1 | Recurrence across DST, clock changes, app force-close and notification delivery was not operationalized. | Calendar-wall-clock recurrence; persist last materialized occurrence ID; reconcile scheduled notification IDs; notification-fired != AI job executed. |
| A13 | P1 | SwiftData actor/model isolation, migration test fixtures and failed-store recovery were insufficient. | One storage actor owns ModelContext and mapping; non-destructive migration fixtures; read-only recovery/export path, no automatic empty-store reset. |
| A14 | P1 | Deletion did not exhaustively cover caches, temporary files, indices, memory context snapshots, provider copies or future cloud replicas. | Immediate local tombstone and purge queue; indexed/cached/temp cleanup; separate provider retention disclosure and future remote deletion protocol. |
| A15 | P1 | Task failure, device termination and account switch had no single exact recovery ownership. | On launch: persisted `running` becomes `interrupted`; PREPARED external calls become `needsReview`; read-only steps resumable, side effects never auto-retried. |
| A16 | P1 | Cost limits could look like hard caps while direct BYOK sends bypass the app or provider billing. | Client budget is advisory unless provider account/gateway imposes a hard cap; cancel/settlement accounting and unknown usage labeled estimated. |
| A17 | P1 | URL scheme security, SSRF, unsafe file URLs and deep-link injection not strictly separated. | Only HTTPS/approved platform schemes, parse with URLComponents, no embedded credentials, IP/private networks blocked on server fetch, user-initiated open; callback links treated as untrusted. |
| A18 | P1 | Current Foundation Models claims may exceed installed SDK/device support. | Apple AI is conditional; check compile availability and runtime supported state; never promise API or model/locale support on every iOS 18+ device. |
| A19 | P1 | Asset licensing, visual identity ownership and app icon/provisioning handoff unspecified. | Require original/cleared Maya and Saar assets with light/dark/reduce motion/static variants; no borrowed branded characters; resource load and fallback tests. |
| A20 | P1 | No dependency/software supply-chain gate, provider terms review, privacy declarations and crash observability policy. | Lock dependencies, create SBOM/license review, audit privacy manifest for actual shipping APIs, redact structured diagnostics and forbid raw conversation telemetry. |
| A21 | P1 | 221 `V1` entries include docs/assets; full scope is too large for an unchecked single output. | One release campaign, staged compile checkpoints; pass criteria not number of files; do not mark feature PASS merely because a type or view exists. |
| A22 | P1 | Tests measure architecture promises but lack robust test data/fixtures and expected exact outcomes. | Test fixtures for chunked SSE, partial JSON, DST, fake clock, midstream privacy changes, duplicate callbacks, store migration and release traceability. |
| A23 | P2 | Core Spotlight opt-in semantic search accuracy/availability differs across OS/device, and indexing private items can leak to system UI. | Local lexical search guaranteed; Spotlight only for explicitly selected non-sensitive projections with delete/account purge and capability probe. |
| A24 | P2 | iPad Split View, external keyboard, VoiceOver, localization, RTL and Reduce Motion underspecified. | Matrix-based UI accessibility test and localized format/date/number; iPhone/iPad orientation and keyboard focus paths. |
| A25 | P0 process | No evidence supports five *working app* audit PASSes. | Five document/contract/security/traceability/package passes documented in `18_FIVE_PASS_AUDIT_REPORT.md`, with actual app build and device gates explicitly NOT_RUN. |

## Mandatory invariants
I01 owner-scoped read/write; I02 newest-session-generation checks; I03 no secret in source/config/log/export; I04 no undisclosed external data egress; I05 no model-initiated side effect absent typed validation+policy+approval where needed; I06 durable prepared receipt before side effect; I07 no blind retry of ambiguous writes; I08 no false completion; I09 no private model reasoning storage; I10 no remote job guarantee from a local notification; I11 fail-closed unknown model capabilities; I12 no unsupported platform claim; I13 one source-of-truth for each entity; I14 all available button actions are real or visibly disabled; I15 evidence-backed acceptance only.

## Source citations for platform assumptions
- https://developer.apple.com/documentation/swift-playgrounds
- https://developer.apple.com/documentation/swift-playgrounds/add-a-swift-package
- https://developer.apple.com/documentation/swift-playgrounds/project-capabilities
- https://developer.apple.com/documentation/xcode/building-swift-packages-or-swift-playground-app-projects-with-xcode-cloud
- https://developer.apple.com/documentation/swiftdata/modelactor
- https://developer.apple.com/documentation/swiftdata/schema
- https://developer.apple.com/documentation/FoundationModels/
- https://developer.apple.com/documentation/backgroundtasks/bgcontinuedprocessingtask
