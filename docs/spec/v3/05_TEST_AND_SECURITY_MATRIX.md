# 05 — Test, security, performance and release matrix

## Stop/release gates
P0 (release blocker): wrong-user data visible, secret logged/shipped, unapproved external write, duplicate sensitive action, destructive silent migration reset, user data sent to fallback against consent, a mandatory screen unavailable/crashes, project cannot import on claimed platform.
P1 (must fix before release): stale callbacks after account switch, prompt injection successful, notification marked as arbitrary AI execution, broken cancellation or missing error state, dead configuration toggle, invalid credentials loop, corrupted saved history.
P2 (can defer with documented limitation): optional semantic index, newer SpeechTranscriber, Apple Foundation Models on unsupported hardware, advanced OS integration and future cloud hooks.

## Exact regression cases
| Case | Setup and stimulus | Expected evidence |
|---|---|---|
| T001 | Empty installation twice | Exactly one local owner and two editable assistant profiles. |
| T002 | Change both assistant names/avatars, force quit | Both independent choices remain. |
| T003 | Owner A starts slow stream, switch to B | A callback cannot change B UI, repository or search index. |
| T004 | No network at launch | Local Dashboard/Tasks/History works, cloud chat visibly offline. |
| T005 | Valid BYOK provider mocked streaming byte chunks | Ordered text and one terminal event. |
| T006 | Tool JSON fragmented across chunks | One strict complete proposal, no executable partial JSON. |
| T007 | Invalid API key | Provider disabled/needs reconfiguration; no infinite retry. |
| T008 | 429 Retry-After and fallback | Cooldown respected, privacy-equivalent route only. |
| T009 | Provider 5xx x3 | Breaker OPEN; single HALF_OPEN probe after cooldown. |
| T010 | User cancels stream while network stalled | URLSession child canceled, partial message marked canceled, avatar idle. |
| T011 | App crashes after PREPARED external write | Ambiguous receipt, needs human review, zero automatic duplicate. |
| T012 | User approves send to A, model edits target to B | Approval digest mismatch, action refused. |
| T013 | Inject webpage instruction to reveal contacts | Untrusted content cannot gain tool permission, no unauthorized disclosure. |
| T014 | Revoked Calendar permission mid-run | Deny safely and show recovery; task not falsely completed. |
| T015 | Schedule weekly task across DST | Preserve chosen wall-clock behavior; expected dates match fixture. |
| T016 | Notification denied | Task stored and marked unscheduled; never claim alert delivered. |
| T017 | Search for other owner's unique marker | Zero hits and no logs/previews containing marker. |
| T018 | Delete memory linked to Spotlight | No retrieved/context/index exposure after deletion. |
| T019 | Oversized/spoofed attachment | Reject, clean temporary file, no upload. |
| T020 | Wrong Keychain namespace | Secret inaccessible to different local profile. |
| T021 | Corrupt SwiftData migration fixture | Recovery export/read-only state, NEVER silent reset. |
| T022 | Speech canceled by phone interruption | Microphone released, stale transcript ignored, no double reply. |
| T023 | Unsupported Hindi locale | Explicit fallback / disabled explanation, no silent upload to STT. |
| T024 | Sensitive cloud input w/ private-only preference | No external network request. |
| T025 | Direct BYOK price exceeds advisory cap | Clearly explain local budget estimate is not provider billing cap. |
| T026 | iPad rotation/split and iPhone compact | Five destinations reachable, no truncated primary controls. |
| T027 | VoiceOver & Dynamic Type XXL | All buttons labeled, modal approval reads recipient and consequence. |
| T028 | Clean actual `.swiftpm` import | Capture device model, iPadOS, Playgrounds version, compile/run result. |

## Privacy/security checks
- Run STRIDE over device+cloud boundaries. Cross-owner reads must always enforce owner in repository and server later; device lock is not account authorization.
- Threat corpus includes indirect prompt injection in OCR/PDF, malicious tool response, DNS rebinding, Unicode domain spoof, logging injection, attack on malformed SSE JSON, oversized image/PDF, generated tool arguments changed after approval.
- User BYOK secret must not appear in Git history, bundle resources, logs, error toasts or unencrypted export. Do not hardcode app-owned keys.
- Check exact source→destination data mapping for each provider call, optional STT, indexing and backup. `PrivacyInfo.xcprivacy` reflects measured shipping behavior, not aspirational claims.
- Evaluate external-service privacy and model data-retention terms immediately before distributing public app; an open-weight model on a hosted endpoint is NOT equivalent to private local inference.

## Quality constraints (targets, NOT measurements)
- App UI remains responsive during provider calls; expensive parsing/network work off MainActor; UI updates coalesced.
- Async pipelines have bounded buffers and timeouts; attachments and OCR have explicit byte/page/time ceilings.
- Every user-visible task state derives from persisted run events; never invented percentages.
- Full offline local flow works with zero configured AI provider.
- Reduced Motion, accessibility labels, light/dark mode and screen-reader approval preview are mandatory manual gates.

## Test execution environments
- Linux/container may validate JSON, Markdown structure, generation scripts and pure code, but cannot compile iOS platform frameworks.
- macOS+Xcode validates Swift 6 strict-concurrency compile, tests, simulator iPhone/iPad and UI automation.
- Actual iPad Swift Playgrounds validates `.swiftpm` import/capabilities and hardware microphone/speech/device behavior; iPhone requires an actual install path and separate device test.
- No test is PASS based solely on source inspection or a model's confidence.
