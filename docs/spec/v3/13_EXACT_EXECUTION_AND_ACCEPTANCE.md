# V3 deterministic execution plan and acceptance contract

## Required evidence schema for every gate
`gate_id`, `revision_SHA256`, `changed_paths`, `environment_OS`, `toolchain_version`, `command_exact`, `exit_code`, `test_case_IDs`, `actual_result`, `status` PASS/FAIL/BLOCKED/NOT_RUN, `remaining_P0_P1`, `next_exact_action`. Screenshot or screen recording for UI/hardware assertions, with private content redacted. A code review is not equivalent to a compile. No agent may change any entry to PASS without evidence.

## Stage order, concrete writes and exit tests
| Gate | Exact action | Completion evidence / blockers |
|---|---|---|
| W00 | Capture `swift --version`, SDK availability, blank iPad-exported `.swiftpm` actual tree/manifest, app capabilities and resource resolution. Independently probe SwiftData/Speech/UserNotifications/AVFoundation/Keychain/URLSession/PhotosUI/available FoundationModels symbols. | Real iPad template and on-device fresh import or separately BLOCKED. Create `Docs/W00_DEVICE_AND_PACKAGE_PROBE.md` with each framework's actual availability. |
| W01 | Freeze typed models/protocols/errors/event grammar and five destinations, compile pure Swift contracts with strict concurrency. | Test strongly typed IDs, Sendable, exhaustive state transitions, invalid schemas/owner mismatches; no duplicate DTO definitions. |
| W02 | Implement sole SwiftData @Model owner, schema version, typed mappers, repository actor, Keychain namespace, session generations, protected files. | Cold launch, relaunch persistence, migration fixture non-destructive, isolation tests and vault locked/not-found tests. |
| W03 | CompositionRoot, routing, five usable SwiftUI views, adaptive tabs/sidebar, design tokens. | Each destination navigable on iPhone compact and iPad Split View with accessible labels, real empty/loading/error/offline states. |
| W04 | Maya/Saar original assets, independent rename/avatar selection/voice/style prefs, view-model and animation state. | Both saved profiles survive relaunch, asset fallback works and static asset shown for Reduce Motion. |
| W05 | HTTP URLSession transport, byte-safe SSE, JSON event decoder, tool-fragment assembly and provider-specific fixtures. Groq/OpenRouter/custom adapter. | UTF-8 boundaries, CRLF, multiline `data:`, incomplete JSON/tool and event size limits pass; real provider smoke only with supplied user-owned key. |
| W06 | ContextBuilder, routing/privacy/capability filters, cost advice, stateful orchestrator, streaming Chat view. | Complete one real turn, deterministic test fake, 401/429/5xx/timeouts, offline, cancellation, partial-stream route recovery and privacy policy tests. |
| W07 | Voice audio-state owner, legacy Speech, AVSpeechSynthesizer, separate cloud STT consent, avatar observability. | Actual on-device tap-to-talk/send/play, permission denial and interruption stop; unavailable locale clearly explained. |
| W08 | TaskDefinition/TaskRun persist, calendar recurrence and pending notifications reconciliation, task UI. | DST/midnight fixture, fresh reboot recovery, notification denied, edit/delete cancellation; no local push claiming AI execution. |
| W09 | Tool registry/schema, policy, approval hash/TTL, prepare-before-execute ledger, idempotency audit. | Untrusted injection rejected, changed payload fails, concurrent approvals only once, timeout ambiguous/no replay, revocation and account switch safe. |
| W10 | Explicit memory CRUD/provenance, deterministic context selection, owner-filtered lexical history search, optional Spotlight guarded. | Delete memory removes context/cache/index; owner cross-search returns zero; overflow fails honestly. |
| W11 | Photo/file ingest, MIME-sniff+size/page/time limits, safe temporary lifecycle, permitted local APIs. | Reject spoofed MIME, zip bombs/oversize PDF, malicious file URL; iOS permission denial; no unauthorized upload. |
| W12 | Provider BYOK setup/test and model capability UI, configuration, privacy modes, settings, budget warning, diagnostics. | Every enabled control updates actual persisted service; invalid key never retained as 'working'; reset/delete/export tests. |
| W13 | Run all `05_TEST_AND_SECURITY_MATRIX.md` T001–T028 plus V3 cases S001–S018 below; dependency and privacy-manifest audit. | Zero unresolved P0/P1 in shipping path, reproducible actual command logs and test fixtures. Conditional unavailable features stay disabled. |
| W14 | Merge portable source into verified `.swiftpm`, attach original legally usable assets, import on fresh iPad, on-device smoke, optional iPhone signed distribution/smoke. | Only mark `.swiftpm` VERIFIED with actual iPad build; iPhone independently VERIFIED only after install and core smoke. Produce final hash, status and defect register. |

## New mandatory test cases (in addition to V2 T001–T028)
| ID | Scenario | Exact expected outcome |
|---|---|---|
| S001 | Provider drops stream after visible text and fails over automatically | No silent stitching with a second model; partial message marked interrupted; explicit restart offered. |
| S002 | Stream tool fragment arrives then connection dies | Incomplete fragment discarded; no tool proposal and no side effect. |
| S003 | Retry after ambiguous external operation | Ledger blocks automatic retry; needsReview until reconciled or user explicitly chooses a new operation. |
| S004 | Approval payload mutated in Unicode canonicalization/field order/recipient | Approval bound to exact canonicalized data; changed semantic payload rejected. |
| S005 | Private-only mode but user taps 'Open link' from remote content | No automatic remote fetch; user-visible disclosed navigation requires separate deliberate action. |
| S006 | Switch local profile while OCR/voice/network response pending | Old callbacks cancelled/ignored; no old temporary files/index hits exposed in new profile. |
| S007 | Direct BYOK app-side budget reached while provider usage unknown | UI says estimated/advisory; stop outgoing *new* requests locally without claiming provider hard cap. |
| S008 | Calendar time 02:30 during spring forward | Deterministic documented 'next valid wall-clock time' behavior with fixture. |
| S009 | Calendar time 01:30 during fall-back overlap | One occurrence with first repeated time, one notification ID, no duplicate TaskRun. |
| S010 | Delete task while local notification pending | Pending notification removed and verified absent when permissions permit; tombstone prevents re-creation. |
| S011 | Existing store opens under incompatible migration | No destructive empty reset, prompt recovery/export; original files preserved. |
| S012 | Attachment disguised as PDF or photo using extension | File signature/MIME inspection rejects; zero remote transfer; temp cleanup. |
| S013 | Device locks during Keychain read | Typed locked error; never replace missing/locked secret with empty credentials. |
| S014 | Route capability unknown or wrong for vision/tools | Route excluded; if no eligible model, show explanation without silently stripping required feature. |
| S015 | All requests fail in offline mode | Local core app works and deferred *non-sensitive, safe* actions recorded; no phantom completed cloud task. |
| S016 | Voice permission revoked mid-session | Capture stops, buffers are released, user sees correct status, no automatic cloud fallback. |
| S017 | Reinstall / device restore loses BYOK Keychain entry | Account recovers locally where possible; provider prompts for own key; no placeholder/embedded key. |
| S018 | Dark/large text/VoiceOver/iPad keyboard/test identity assets | All five navigation entries reachable; assistant selection and tool approval accessible. |

## Gate-specific stop conditions
A security defect in W09 may block tool shipping but should not automatically block independent UI work. A missing W00 template blocks *verified direct Playground package* status only; it does not block pure Swift source, Xcode wrapper, docs, assets or fake-provider unit tests. Explicitly distinguish implemented, unit-tested, simulator-tested, iPad-tested, iPhone-tested and publicly distributable. Do not silently remove V1 required features to force a green build.

## Release checklist
Required: five functional screens, two durable assistant identities, user-owned live provider chat, fallback policy implemented, safe tap-to-talk path on tested supported locale/device, voice playback, saved task and local notification, approvals and audit, local history and selected memories, Keychain, privacy settings, real permissions, accessibility smoke, no P0/P1, reproducible build logs. Future cloud/auth or unsupported Apple features cannot be represented as fully available. Explicit unresolved blockers are acceptable for source handoff, but not for a 'production-ready iPad/iPhone app' claim.
