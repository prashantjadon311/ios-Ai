# ios-Ai — iPad Import, First Build and Acceptance Guide

**Status at audited fourth commit `b34423ec`: DIAGNOSTIC IMPORT ONLY.** Its GitHub CI failed static checks and skipped macOS compilation. This document provides (A) a safe early iPad compiler probe and (B) the full acceptance route after Gemini's corrected Mac build and tests. A Linux-hosted agent cannot truthfully report your physical iPad passed.

## A. Optional diagnostic import NOW, without personal data or API keys

**Before starting:** use a disposable copy of the repository. Do not overwrite an existing working playground or delete real saved data. Check your iPad's Settings > General > About for model/iPadOS version. The current genuine generated package declares **iOS/iPadOS 18.6 minimum**; if the device is older, update if eligible or stop. Install/update **Swift Playgrounds** from the App Store and check the version shown in its App Store entry or iPad Settings. Avoid claiming a universal fixed Playgrounds version; verify against the actual device.

1. On your iPad, visit https://github.com/prashantjadon311/ios-Ai and use **Code > Download ZIP**, or use a clean export supplied by Gemini once new changes are committed. Verify the ZIP/commit SHA matches the version you intend to test. GitHub's default-branch ZIP may contain additional documentation; only the **complete `PersonalAssistant.swiftpm` package** and all its nested files/resources are needed for the app, not the entire repository as an app project.
2. Files app > Downloads > tap the ZIP to extract it. Open the extracted repository folder; locate `PersonalAssistant.swiftpm`. If Files treats it as an ordinary folder instead of a package, don't change or rebuild `Package.swift` blindly. Document the exact recognition error.
3. Launch Swift Playgrounds. From its welcome screen, use **Browse** to locate a playground received from another source. Navigate to the extracted `PersonalAssistant.swiftpm` and open it. If Files offers **Share/Open in Swift Playgrounds**, that is also an option when your actual iPadOS presents it; avoid assuming menu names not present on your device.
4. If it opens, first check whether the original app target, all Swift sources, Resources (Maya/Saar assets) and App Settings/capabilities are recognized. Tap **Run App**. Capture the **entire** displayed issue list, first error and file/line numbers. An iPad syntax/compile error here is useful engineering evidence, not failure of your device.
5. Do **not** enter Groq/OpenRouter credentials, personal documents, family data or authorize tools on this fourth-commit diagnostic build. Its actual code-level privacy, receipt durability and provider routing haven't passed mandatory tests. If the app unexpectedly launches, restrict checks to screens/navigation and a synthetic local task; don't treat launch as proof of secure operation.

**Official Apple reading:** [Manage playgrounds / Browse](https://support.apple.com/guide/playgrounds-ipad/itc106ff9caf/ipados), [Run your app](https://support.apple.com/guide/playgrounds-ipad/itc650868b1f/ipados), [Add Swift files and images](https://support.apple.com/guide/playgrounds-ipad/itc18b7bce9d/ipados), [Swift Playgrounds app capabilities](https://developer.apple.com/documentation/swift-playgrounds/project-capabilities).

## B. Required preflight BEFORE regular iPad use

Only consider live sensitive use once the corrected final commit has all the following **actual evidence**, not merely source-grep successes:

| Gate | Required evidence | Current fourth-commit state |
|---|---|---|
| G1 Docs/manifest | V3 validator; release SHA and complete resources | 16/16 structural PASS; *does not verify code* |
| G2 Apple compile | Apple compiler full target build in a compatible macOS/Xcode SDK; first failure fixed, reproducible job URL/log | NOT_RUN (skipped in failed Actions workflow) |
| G3 Real tests | Executable Swift fake-provider, SwiftData, routing/privacy, receipt save-failure/concurrency, recurrence and cancellation fixture tests | NOT_VERIFIED; existing Python tests are source scans |
| G4 Security preflight | Explicit owner/session/consent, safe transport, non-destructive key rotation, no real external tool until durable approval tests pass | NOT_VERIFIED; known blockers at audited SHA |
| G5 Physical iPad | Import/build/run, permissions, offline, task notification, voice, two assistants, relaunch | NOT_RUN |

If G2–G4 are missing, iPad use remains **diagnostic only**. Live API key preflight should use a throwaway/user-owned key with a spending limit configured at the provider where offered; application-side budgets are advisory.

## C. Post-fix iPad acceptance sequence (perform in order)

1. **Import exact release:** Gemini provides an immutable final commit SHA plus a ZIP/export containing `PersonalAssistant.swiftpm`, real assets, localization and vetted app settings. In Files import/open that exact package; take a screenshot showing project identity. Make a *backup copy* before modifying package locally. If compiler issues appear, stop at compilation and share logs rather than trying random edits to 187 files on-device.
2. **First launch, no key:** confirm initial onboarding, single local owner semantics and both Maya/Saar profiles, all five sidebar/tab destinations, usable empty/offline/error states, supported orientation and VoiceOver focus. Check title/icon are accurate; ensure disabled unsupported capabilities state their reason.
3. **Local persistence first:** rename Maya and Saar independently and change each voice/style, create synthetic local task and fake note, close and force-quit the app, reopen and confirm changes/history survive. Confirm switching assistants **does not** reset privacy/provider settings. There are no authenticated family accounts in V1; don't confuse two assistant profiles with separate human users.
4. **Permission/capability checks:** check whether microphone, Speech, notifications, Photos/files and any conditional Calendar/Contacts permissions have correct human-readable App Settings purpose strings. Test denied state before granted state. Denial should show a meaningful error, not pretend success. Not every locale supports on-device speech/offline recognition.
5. **Privacy-first network tests:** choose Private Only in Settings and verify Configuration shows exactly the same saved choice. On a controlled test build with an injected network spy or equivalent simulator fixture, verify **zero outbound content requests** for chat, model catalog, remote STT, attachments and link previews; the physical iPad UI alone cannot prove absence of all network bytes. Change to Cloud Allowed and give explicit relevant destination/data consent before any live request.
6. **Disposable BYOK:** choose one enabled Groq or OpenRouter provider, add a personal **test key** to Keychain, verify selected model is genuinely supported and model capability known. A normal BYOK call sends the credential to the **selected provider**; it is not magically serverless. Send an innocuous prompt. Verify a **real streaming reply** and no hidden fallbacks. Stop halfway through another long response; ensure interrupted state and no appended second-model output. Verify 401 invalid key and 429 cooldown with synthetic/test fixtures; don't intentionally consume money just to test billing errors.
7. **Two-turn/relaunch history:** send a second message to the same conversation, open History, force-quit/relaunch and confirm both user and assistant records are present with correct order/role/status. Verify the Dashboard Quick Ask prompt is actually sent **once**, not silently dropped or duplicated.
8. **Task/notification:** schedule a disposable task a few minutes ahead, grant notifications, put the app in background and verify a real notification appears. Edit or delete another pending task and confirm obsolete alert doesn't fire. Repeating tasks have per-occurrence identifiers; receiving a notification does **not** prove a background AI agent executed.
9. **Tap-to-talk and TTS:** tap the actual visible mic button, permit microphone/Speech, choose a supported locale, speak a nonprivate test message, inspect partial/final transcript and manually Send; after real provider completion, use available system TTS. Interrupt mid-capture, revoke permission in Settings and verify the audio tap stops. Check English and Hindi only where this iPad's actual Speech/TTS voices are available; Hinglish perfection is not guaranteed.
10. **Approved tools and attachments only AFTER G4:** attempt changed recipient/payload/expired approval with a **fake executor**, observe denial. Real local tool should create an actual synthetic task/note/reminder with durable receipt. Verify pending list and result. Pick a disposable image/PDF, inspect local import/provenance/owner boundary, cancel upload and confirm temp cleanup. Keep Calendar/Contacts and external URLs disabled until their separate permission/execution tests pass.
11. **Accessibility/recovery:** dark/light appearance, large Dynamic Type, Reduce Motion, VoiceOver, keyboard, portrait/landscape, offline toggling, on-device relaunch and permission denial. No original private data in screenshots or public GitHub Actions artifacts.

## D. Exact issue-reporting form for Gemini (copy and fill)

```text
IOS_AI_IPAD_TEST_REPORT
TESTED_COMMIT_SHA: <exact git commit / release artifact SHA>
APP_PACKAGE_SHA256: <from release manifest, not invented>
IPAD_MODEL: <Settings > General > About>
IPADOS_VERSION: <exact>
SWIFT_PLAYGROUNDS_VERSION: <exact>
STEP: <A diagnostic step or C acceptance step>
RESULT: PASS | FAIL | BLOCKED | NOT_RUN
FIRST_ERROR: <verbatim, include filename and line>
COMPLETE_ISSUE_LIST: <screenshots/text, remove secrets>
APP_LAUNCHED: yes/no
PERMISSIONS_GRANTED: <non-sensitive description only>
TEST_DATA: synthetic only
SCREENSHOT_OR_REDACTED_LOG: <filename>
REPRODUCTION: <numbered taps/inputs>
NEXT_EXACT_ACTION_REQUESTED: Fix the first verified compiler/runtime defect while preserving V3.
```

**Evidence rules:** compiler failure must remain FAIL until a newer committed release is actually built and re-tested. Gemini may claim `MAC_CI_PASS` only with a real Mac log; `IPAD_PASS` only after **you** provide actual device proof. Passing iPad import or App Preview is not proof of a signed distributable iPhone release.
