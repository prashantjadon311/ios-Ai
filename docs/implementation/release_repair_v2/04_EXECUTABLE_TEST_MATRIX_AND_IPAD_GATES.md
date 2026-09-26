# 04. Real executable test matrix, CI acceptance and physical iPad handoff

**Pinned baseline:** `2918293e7355290ba722bb734652c9ad70c75a9f`. **Current factual status:** fifth-commit CI failed; documentation 16/16, Python static 45/46 (T010 failed), chat source-pattern test skipped, Xcode failed manifest localization before any Swift type-check, no committed Swift executable tests and no physical iPad evidence. This is the acceptance plan for a *new future repaired SHA*, not evidence that tests have already passed.

## 1. Required distinct proof types

| Proof key | Executed where | Valid evidence | Does NOT prove |
|---|---|---|---|
| `STATIC_SOURCE_PATTERN` | Linux Python | Check name, command, exit, exact source SHA | Swift syntax, link, UI, runtime, security |
| `SWIFT_PARSE_ONLY` | Linux swiftc, if present | Swift parser exit code for pure language snippets | SwiftUI/SwiftData/iOS SDK type correctness |
| `APPLE_BUILD` | Actual compatible Xcode | Toolchain/SDK version, real app target command, exit 0, `.xcresult`, artifact SHA | Runtime behavior, privacy, physical iPad |
| `SWIFT_EXECUTABLE_TEST` | Mac XCTest/Swift Testing | Compiled tests, executable test cases, fake/fault fixtures, real outcomes | Physical microphone/notification delivery |
| `SIMULATOR_SMOKE` | Actual iOS simulator | Launch/video/screenshot, console/crash logs, 5-screen interactions | Physical mic/notification and hardware capabilities |
| `LIVE_BYOK` | Controlled test account / explicit approval | Redacted provider request/response metadata, selected model and no key in logs | Other providers, personal-data safety without security tests |
| `PHYSICAL_IPAD` | User's iPad | Installed Playgrounds version, iPadOS/device, import, actual run, permission and behavior outcomes | Unexecuted scenarios beyond recorded observations |

Every outcome must be explicitly `PASS`, `FAIL`, `BLOCKED` or `NOT_RUN`. No umbrella "46/46 functional PASS" without 46 runnable cases and their actual evidence.

## 2. Apple CI: make the compiler unavoidable

A repaired workflow must have separate, independently runnable jobs: Linux structural checks, genuine Mac app compilation, compiled Swift unit/integration/security tests, and optional simulator smoke. The release aggregation fails if any mandatory job is red or skipped without a documented external blocker. A new repair branch or PR requires user-approved push if the agent's write access is not already authorized.

Capture **before** running the build: `sw_vers`, `xcode-select -p`, `xcodebuild -version`, `xcodebuild -showsdks`, `xcrun --sdk iphonesimulator --show-sdk-version`, package scheme discovery. Verify selected SDK supports the app's declared deployment floor and Playgrounds app product. The first build log on current fifth commit is known to fail in package resolution; after fixing localization, retain every subsequent Swift error and iterate. Do not skip compilation just because Python checks fail. Upload `.xcresult`, full raw build stdout/stderr, generated app bundle resource listing and SHA. Do not upload test API keys.

**Package compatibility:** the checked-in `.swiftpm/Package.swift` is auto-generated. If its app-module scheme cannot be built from a generic `xcodebuild -scheme` invocation, prove the appropriate **supported** Playgrounds/Xcode package workflow or construct a reproducible compatible wrapper that shares the real production source rather than a mock clone. A dummy package build is not evidence for the actual app.

## 3. T001–T028: implement actual compiled cases

This table preserves the canonical scenario IDs from the V3 test matrix. The proposed test names are illustrative and must be implemented using current canonical API contracts and real executable assertions, not substring checks.

| ID | Concrete Swift/instrumented scenario | Observable expected result |
|---|---|---|
| T001 | Boot an empty in-memory test store twice | Exactly one owner and exactly Maya/Saar, no duplicate rows, no phantom onboarding reset. |
| T002 | Change both assistant names, avatars and voices; persist/reopen | Both choices independently restored. |
| T003 | Start delayed model stream for A then switch owner to B | A event cannot mutate B UI/repository; old task cancelled; no cross-owner indexes. |
| T004 | Start offline with fake reachability | Local dashboard, tasks and history usable; cloud action reports offline without phantom success. |
| T005 | Inject fake streaming provider with ordered chunks and one terminal | Exactly ordered text and **one** completed persisted response. |
| T006 | Fragment UTF-8 and SSE CRLF/multiline data at every byte boundary | Decoded once, no partial tool call, frame caps enforced. |
| T007 | HTTP 401 provider response | Credential-reconfiguration state; no blind retry or replacement model stitched into a turn. |
| T008 | HTTP 429 + selected privacy mode | Correct bounded retry advice; no forbidden outbound retry. |
| T009 | Repeated fake 5xx into circuit breaker | Open after threshold, half-open only per actual policy, no infinite retry. |
| T010 | Cancel while fake HTTP stream stalls | URLSession inner child, provider child and orchestrator all terminate; partial reply interrupted/persisted. |
| T011 | Two concurrent identical tool calls + restart with PREPARED row | At most one executor invocation; orphaned operation ambiguous, never auto-replayed. |
| T012 | Change a previously approved payload/recipient/owner/session | Executable count zero, typed mismatch/expired error; recomputed digest from trusted intent. |
| T013 | Credentialed request redirects to hostile HTTPS, localhost or HTTP | Reject navigation and never forward Authorization to target. |
| T014 | Calendar permission denied/unavailable | No calendar event created and a truthful visible permission error. |
| T015 | Daily 02:30 spring DST, weekly weekday, monthly end-of-month, leap day | Documented next-time behavior, strict monotonic UTC occurrence, no duplicated key. |
| T016 | Task saved when notifications not determined/denied | Permission requested only from user action; task persists separately from unscheduled-alert status. |
| T017 | Owner A/B have identical search keywords | B search has zero A messages/memories; UI search and index agree. |
| T018 | Delete a verified memory and immediately rebuild context/search/Spotlight | Deleted data never reappears, stale worker cancelled or tombstone honored. |
| T019 | Spoofed PDF/PNG, unknown MIME, oversize PDF, malformed path | Rejected before storage/remote send, bounded extraction, temp cleanup. |
| T020 | Keychain item not found/locked/rotation write error | Distinct typed outcomes; old working key preserved if replacement fails; owner namespace isolated. |
| T021 | Open existing store under deliberately incompatible schema | No automatic wipe or duplicate first-run onboarding; read-only recovery path. |
| T022 | Inject audio interruption during active voice capture | Tap removed, recognition task cancelled, old transcript cannot arrive after stop. |
| T023 | Fake speech locale list excludes user language | Clear unsupported explanation; no silent cloud STT fallback or incorrect provider claim. |
| T024 | Set Private Only, then attempt chat, `/models`, custom endpoint and optional STT | **Zero external requests**; local UI and tasks continue. |
| T025 | Exceed local cost/token advisory estimate | Warning says estimated, not provider hard cap; blocked-new-request behavior tested if configured. |
| T026 | iPhone compact and iPad regular preview/simulator navigation | Five destinations reachable, sheet composition and owner state stable. |
| T027 | Dynamic Type, VoiceOver labels, keyboard, target sizes | Required actions accessible; minimum tappable target meets V3 rule. |
| T028 | Build real `.swiftpm`, inspect app resources, import on iPad | Genuine Mac build PASS; iPad import/launch kept **separate** until human device evidence. |

## 4. S001–S018: independent adversarial tests

| ID | Failure injection or adversarial input | Fail-closed assertion |
|---|---|---|
| S001 | Provider drops after first visible token | Persist partial `.interrupted`; no silent second provider splice. |
| S002 | Disconnect halfway through fragmented tool JSON | No completed proposal, no pending approval and zero executor calls. |
| S003 | Timeout after possible calendar/URL side effect, then restart | Ambiguous/needs-review durable receipt; never auto-retry. |
| S004 | Unicode normalization, sorted-key reordering, recipient swap, stale hash | Recompute canonical digest and exact purpose; altered intent rejected. |
| S005 | User opens link while Private Only from untrusted content | No automatic HTTP/previews; only separately disclosed explicit OS navigation if allowed under frozen policy. |
| S006 | Switch owner while OCR/audio/HTTP callback is pending | Old generation cannot touch new owner UI/DB/cache/index. |
| S007 | Provider omits usage but local advisory limit reached | No false actual usage/cost claim; new outgoing requests follow configured advisory rule. |
| S008 | Nonexistent 02:30 on spring DST transition | Deterministic next valid clock time using original schedule zone. |
| S009 | Fall DST duplicated 01:30 | One occurrence/notification ID per intended wall-clock event. |
| S010 | Delete or edit task while notification pending | Old pending notification IDs actually removed, no recreation by stale worker. |
| S011 | Existing store incompatible migration | No reset; unmodified original recoverable; diagnostic shown. |
| S012 | Adversarial file with disguised MIME, symlink or malicious path | No ingest/extract/delete outside approved owner directory. |
| S013 | Device locks during Keychain read | Distinct locked outcome, no treating as empty secret or rotating blindly. |
| S014 | Required vision/tool support unknown or explicitly unsupported | Router excludes model without weakening request. |
| S015 | Offline and all provider endpoints fail | Local features still usable, no fabricated completed cloud task. |
| S016 | Revoke mic during capture / speech errors / stop-restart race | Release tap/task/buffers, clear stale callbacks, user-visible state. |
| S017 | Device restore/reinstall removes device-only Keychain item | Local data recovery where possible; provider asks user to reenter a key without fake saved-secret state. |
| S018 | Dark mode, very large type, VoiceOver, hardware keyboard, avatar assets | All mandatory navigation/approval controls reachable and correctly labeled. |

## 5. Additional contract tests the previous packets missed

These are additive, not substitutions for V3 T/S cases.

**X01:** Compile negative fixture for missing `ApprovalRequest.canonicalArguments/sessionGeneration`; positive roundtrip persisted approval using versioned model. **X02:** Compile both avatar constructor families, every caller, actual asset lookup and fallback. **X03:** Whole-target compile catches duplicate `completeOnboarding()` and `request.summary` mismatch. **X04:** Isolated Swift parser rejects the malformed `AIConfigurationView` escaped string; corrected file parses. **X05:** Task planner/executor compile with the *real* `TaskStepRecord`; throwing injected operation never marks a step completed. **X06:** True Quick Ask initialText delivered exactly once after forced SwiftUI `.task` rerun. **X07:** `ContextBuilder` never duplicates active turn or upgrades memory to trusted system policy. **X08:** Saved provider configuration selects exact model/endpoint/owner and survives restart; custom distinct configuration uses distinct Keychain ID. **X09:** PREPARED insertion failure leaves no cache state/executor call; status save failure cannot report durable success. **X10:** Old versioned SwiftData fixture migrates without data loss or shows read-only recovery. **X11:** Privacy tightening immediately cancels in-flight streams and is rechecked at the HTTP boundary. **X12:** Actual build bundle contains English/Hindi localization, both avatars, prompt resources, provider catalog, privacy manifest, and no API secrets.

## 6. Evidence format for every genuine pass

```yaml
gate_id: G0
source_git_sha: <actual 40-character SHA>
source_dirty: <git status --porcelain output>
platform: macos-<actual image> / iPadOS-<actual device>
xcode_version: <actual xcodebuild -version>
ios_sdk_version: <actual xcrun --sdk iphonesimulator --show-sdk-version>
exact_command: <literal executed command>
exit_code: <actual exit code>
result_bundle: <CI artifact URL / local path>
real_test_cases_passed: [T001, X01]
real_test_cases_failed: []
real_test_cases_skipped: [T016]
static_checks_passed: [docs validator]
remaining_defects: [C09]
status: PASS | FAIL | BLOCKED | NOT_RUN
next_exact_action: <one actually unfinished dependency>
```

Place executable tests in a compatible Apple Swift test target; if the iPad-generated package cannot safely declare tests, use a reproducible test wrapper sharing actual production files/source references, and separately build the real AppModule. A fake-only isolated package that never imports production code fails acceptance.

## 7. Physical iPad acceptance: when and how

**Preflight required:** compatible macOS AppModule build PASS on the exact candidate SHA; compiled Swift tests PASS including privacy and tool-negative tests; independent audits A/B on the final SHA; no known release-blocking P0/P1; versioned package, assets and privacy settings proven bundled. On a *separate test iPad or disposable test installation*, optionally perform a **no-key diagnostic import earlier**, but never confuse that with release approval.

**User-side transfer:** obtain the exact `.swiftpm` candidate artifact (do not reconstruct from a screenshot or link to an unverified branch). Transfer via Files, iCloud Drive or an actual compatible Apple AirDrop sender; a Linux laptop does not natively provide AirDrop. Uncompress only if it preserves `PersonalAssistant.swiftpm/` directory structure. Open the app playground in a compatible current Swift Playgrounds version on a supported iPad; match the iPadOS and device requirements shown by Playgrounds, rather than promising every iPad supports the same APIs.

**Actual iPad check sequence:**

1. Import exact artifact; open its source package; press Run. Capture first compile issue or clean launch, app version, iPad model, iPadOS and Playgrounds version. Do not add production BYOK key until basic security verified.
2. Cold onboarding: exactly one local owner and two independent Maya/Saar profiles; force-quit/relaunch; preferences and avatar images remain.
3. Navigate all five primary screens in portrait/landscape; verify very large text, VoiceOver touch controls and hardware keyboard.
4. Use a disposable, limited-permission test API key with a chosen supported provider/model. Test Quick Ask exactly once, visible streaming two-turn same-conversation, stop mid-stream, history and restart persistence. Do not paste API key into screenshots/logs.
5. Toggle Private Only; attempt chat/model catalog/custom destination while observing trusted local debug request counter or validated test network harness. No outbound request. Restore permitted mode and explicit destination consent.
6. Tap mic from explicit user action, accept/deny OS permissions in distinct runs, verify editable transcript and that no speech leaks after stop/background/assistant switch. Test Maya and Saar speech playback only for voices actually installed.
7. Create a task + 5-minute notification, verify iPadOS authorization, actual delivery on device, edit/timezone change and pending-alert deletion. Don't promise autonomous background LLM execution.
8. If, and only if G3 compiled security tests passed, use **disposable calendar/test data** to verify an approval summary, explicit confirm, exactly one event, wrong/expired approval rejection and restart reconciliation. Never test irreversible actions on production data.
9. Test file picker with safe disposable media, unsupported MIME rejection, remove attachment, force-quit/relaunch; verify per-owner visibility and data lifecycle.
10. Save evidence: `IPAD_PASS`/`FAIL` per step with screenshot or redacted diagnostic, exact candidate SHA and first failing compiler/runtime issue. Device failures go back into the same G0–G5 repair loop.

**Release language:** `BUILD_BLOCKED` now; `COMPILED_UNTESTED` after the actual Mac build; `COMPILED_TESTED_CANDIDATE_AWAITING_IPAD` after real compiled tests and audits; `IPAD_VERIFIED` only after the user executes and records this device checklist. A genuinely failed mandatory V1 feature remains `FEATURE_SCOPE_INCOMPLETE` and forbids a production-ready claim.


## 8. V2 local and remote toolchain classification

| Executed command | Platform | Legitimate evidence only |
|---|---|---|
| `swiftc -frontend -parse` on **all actual** 187 Swift source files | Ubuntu/VS Code | Swift parser accepted source grammar only; no imports/type checking |
| `scripts/sync_portable_sources.py` then `swift test --package-path portable_core_tests` | Ubuntu/VS Code | Compiled XCTest of **copied production Foundation-only files** (`Identifiers.swift`, `TaskDefinition.swift`, `SSEDecoder.swift`, `TaskRecurrence.swift`); intentionally negative tests may fail before correction |
| Actual `xcodebuild ... build` on the generated app/wrapper with the same `AppModule` source | macOS or GitHub Actions macOS | iOS SDK typechecking, linking, resources for a precisely recorded source SHA |
| Actual compiled Swift target `xcodebuild ... test` with source-linked production logic | macOS or GitHub Actions macOS | Executed actor, SwiftData, transport and security behavior; separate simulator UI tests where supported |
| Open exact `.swiftpm` artifact, press Run, exercise real device | iPad | Physical import, actual OS permissions, microphones, notifications, device UX |

A green **portable** suite never substitutes for Apple compilation. A failing **red test** is useful diagnostic evidence, not a reason to delete the test. In particular, the UTF-8 SSE and weekly recurrence/DST negative tests are intended to expose defects in the current fifth-commit implementation. All snippets in the revised 05 document must be checked against the exact local canonical DTOs before Gemini applies them.
