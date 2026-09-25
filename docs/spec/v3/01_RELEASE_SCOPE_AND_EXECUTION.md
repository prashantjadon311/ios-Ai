# 01 — Release scope, build sequence and checkpoints

## Product contract
Five primary destinations: Dashboard, Tasks, History, Configuration, Settings. Supporting routes: Chat, Assistant Profile, Task Edit/Detail, Action/Approval Center, Memory Review, Provider Setup, Permission Details, Diagnostics and Onboarding. Maya and Saar are two independently renameable profiles (names are defaults only), each storing avatar, voice, locale, style and optional route override. iPhone uses adaptive bottom navigation and sheets; iPad uses sidebar + detail navigation and keyboard support. App runs offline for local tasks/history/configuration.

## Delivery truth table
| Slice | MUST ship V1 | Conditional V1 | Out of first-release scope |
|---|---|---|---|
| UI | 5 real tabs, supporting views, both avatar assets/profiles, rename/switch, Dynamic Type, accessible states | Reduced Motion animation if device supports | 3D/lip-synced avatars |
| AI | BYOK Groq and OpenRouter adapters + manually configured compatible endpoint, actual streamed chat, per-user provider registry, deterministic fallback, cancellation, typed tool proposal | Apple Foundation Models on eligible SDK/device/locale and proven Playground compilation | Managed gateway; actual Small AI model |
| Data | SwiftData + migrations, per-local-profile scoping, history, source-tagged memory CRUD, schema-safe exports | Opt-in Spotlight non-sensitive indexing | Cross-device cloud sync / encrypted Drive restore |
| Voice | Tap-to-talk; Speech framework fallback; AVSpeechSynthesizer; voice+avatar state | New SpeechTranscriber on available hardware/locale | Always-listening wake word or guaranteed perfect Hinglish |
| Tasks | Task definitions/runs, one-shot + repeat local notification, active foreground jobs, manual recovery/approval and progress | System-backed continued processing after separately verified entitlement/API | Guaranteed server recurring autonomous AI jobs |
| Tools | CreateTask, reminder, save local note, history search, open approved URL; scoped permission/approval/audit | Calendar and contacts with permission and capability checks | Unrestricted app control, auto email sending |
| Media | Local photo/file pick, safe limit, text extraction where API works, provider modality gate | Vision OCR where SDK permits | Arbitrary cloud document processing |
| Security | BYOK Keychain, account/session generation guard, redaction, explicit send consent and no unaudited data transfer | Face ID if enrolled/device supports | Dev-owned secret in distributed client |

## One implementation campaign, 15 mandatory commit gates
| Gate | Inputs | Write set | Exit condition |
|---|---|---|---|
| W00 | Exported actual blank `.swiftpm` (from user's Playgrounds), available Xcode SDK | evidence log, package shell | Record exact target/resource layout and minimum deployment; compile 6 tiny framework probes. If missing, build portable source but mark Playground packaging unverified. |
| W01 | W00 | Domain, typed AI/tool protocols, security DTOs | Compile contracts and run validation/transition tests before clients. |
| W02 | W01 | StoreModels, versioning, repository actors, vault, SessionGuard | Relaunch persistence, deny unscoped queries, no destructive migration fallback. |
| W03 | W01/W02 | design tokens, root app, five views and navigation | No blank destinations; iPhone/iPad adaptive previews. |
| W04 | W02/W03 | Maya/Saar avatars and profiles | Independent changes survive relaunch; animation state follows real service state. |
| W05 | W01/W02 | URLSession, SSE, Groq/OpenRouter/custom adapters | Stream works with fixture and one actual BYOK key; all 401/429/5xx/cancel paths. |
| W06 | W02/W05 | registry, router, budget, context, orchestrator | Real text chat, no cross-owner context, no privacy-weakening fallback. |
| W07 | W04/W06 | VoiceCoordinator, adapters, Chat UI | Tap-to-talk → text → model → audio on actual iPad; interrupts cleanly. |
| W08 | W02/W03 | task model/scheduler/run/UI | Reminder fires while app inactive; no false background-agent claim. |
| W09 | W06/W08 | ToolRegistry, ToolPolicy, approvals and receipts | Exact approved-payload match, no duplicate side effect after timeout. |
| W10 | W02/W06/W09 | memory/context/history search | Retrieved results source-tagged, owner-filtered and consent-checked. |
| W11 | W06/W09 | attachments + Apple integration adapters | Reject malformed/oversized input; permissions denial handled. |
| W12 | W04–W11 | Settings/Config/provider UI/diagnostics | Every enabled toggle actually changes runtime behavior. |
| W13 | W01–W12 | regression tests, threat fixtures, localization | Zero blocker/high security defects; all failure-injection tests pass with evidence. |
| W14 | W13 | deployment artifact, onboarding, checksum, release notes | Clean actual `.swiftpm` import on iPad and real-device smoke test; iPhone separate distribution gate. |

## Non-negotiable engineering procedure
- Create protocol/DTO before implementation, implement pure functions before actors, actors before views, tests before claiming done.
- Keep one single composition root; do not call live providers in previews or app launch.
- Each gate includes source hash, exact files changed, compile output, test output, screenshot/manual evidence where appropriate, failures and next action.
- For missing iPad template: do not invent package metadata; mark W00 BLOCKED and continue portable Swift source in an Xcode-compatible tree; do NOT claim runnable in iPad Playgrounds.
- A future feature may have a compiling protocol but must not be enabled or shown as working until an actual adapter exists.
- Stop only on blockers to the current gate; continue independent work. Escalate ABI/interface uncertainty rather than making incompatible duplicates.
- Explicitly mark which tests were run and which are specified but not run. Agent cannot truthfully certify device functions without the device.

## File ownership
Each listed file is owned by one subsystem; all shared changes require updating contracts and tests. No duplicate versioned `*2.swift`, hardcoded keys, sample-only view replacing application flow, or silent replacement of verified package scaffolding.
