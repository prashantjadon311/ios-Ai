# ios-Ai verified repair campaign: START HERE

**Active baseline:** published GitHub `main` SHA `2918293e7355290ba722bb734652c9ad70c75a9f` (`Five`, 2026-09-26). This is a **review and implementation handoff**, not edited production code or a compiled release. The public GitHub Actions run [36222465812](https://github.com/prashantjadon311/ios-Ai/actions/runs/36222465812) **failed**: `defaultLocalization` missing, source-pattern 45/46, chat source-pattern script skipped, no real Swift tests, no iPad evidence. The first compilation step is mandatory.

## 1. Place precisely these eight Markdown files and the optional verification kit

Extract the ZIP. Put all eight Markdown documents and optional portable tests/scripts directly under this **new** repo folder:

```text
ios-Ai/
  docs/
    implementation/
      release_repair_v2/
        README_START_HERE.md
        00_SELF_AUDIT_AND_FAILURE_ROOT_CAUSES.md
        01_FULL_REPOSITORY_ENGINEERING_AUDIT.md
        02_COMPILER_FIRST_EXACT_CODE_REPAIR_BLUEPRINT.md
        03_GEMINI_GATED_EXECUTION_CONTRACT.md
        04_EXECUTABLE_TEST_MATRIX_AND_IPAD_GATES.md
        05_EXACT_SWIFT_CODE_AND_CALLER_PATCHES.md
        06_VSCODE_LINUX_MAC_CI_AND_IPAD.md
        scripts/
        portable_core_tests/
        vscode_templates/
```

**Do not put the ZIP into git.** Keep the old `final_execution/` documents and `latest_fifth_audit/` materials as historical references; do not replace or modify the canonical `docs/spec/v3/` files. This package deliberately supersedes the *execution instructions* and *current audit conclusions* in those older handoffs, not the frozen product specification.

## 2. Source/authority precedence

1. The **actual current local Git HEAD and uncommitted files**, once safely inventoried and reconciled. Do not overwrite a genuine newer fix to match old snippets.
2. Frozen V3 contract and actual iPad-exported `.swiftpm` project/template, verified for the installed supported Apple SDK.
3. The **independently observed fifth-commit CI failure** and this UPDATED campaign's pinned source-backed defect register, refreshed after every new commit.
4. The current gate's code/algorithm blueprint and **executed** new Swift test evidence.
5. Old implementation reports/prompts solely for historical context. Prior self-asserted PASS claims do not outrank CI logs.

## 3. Reading schedule (prevents context-exhaustion mistakes)

| When | Required reading | Action |
|---|---|---|
| Boot | THIS README, `00_*`, `03_*`, executive/build of `01_*`, G0 of `02_*`, V3 `00`, `02`, `12`, `13` | Verify SHA/status, correct falsified checkpoint, start actual G0 edits. |
| Compiler gate | `01_*` C01–C11, `02_*` G0, `05_*` G0 snippets, corresponding V3 contract index, CI file and raw job logs | Repair coordinated symbols, build real app until Apple compiler/link pass. |
| Chat | `01_*` A01–A14, `02_*` G1, `05_*` chat snippets, applicable `04_*` tests and V3 B01/B03/B04 | Make real two-turn persisted chat and correct model/transport behavior. |
| Privacy | `01_*` S findings, `02_*` G2, `05_*` privacy/Keychain, relevant V3 privacy docs, `04_*` negative cases | Central fail-closed egress and owner/session enforcement. |
| Tools | `01_*` S01–S07 and tool sections, `02_*` G3, `05_*` ledger, V3 B05, relevant `04_*` cases | Atomic durable receipts, actual pending approval UI, no unsafe side effects. |
| Product | `01_*` T/V/U/M sections, `02_*` G4, `05_*` source edits, V3 UI/task/voice/media contracts, `04_*` cases | Complete mandatory screens, tasks, voice, media, owner isolation. |
| Final | ALL sections of `01_*`, ALL gates of `02_*`, entirety of `04_*`, `05_*`, `06_*`, final current source/diff | Two fresh independent audits on final SHA, genuine Mac evidence, user iPad handoff. |

Maintain a small **read-coverage ledger** alongside the implementation checkpoint. Every audit finding must have status `FIXED + TESTED`, `ALREADY_FIXED + TESTED`, `CONDITIONAL_DISABLED`, or `BLOCKED` with evidence. This is more reliable than dumping every historical prompt into one context window.

## 4. First exact command for Gemini

Use the whole updated `03_GEMINI_GATED_EXECUTION_CONTRACT.md` as the instruction. Your first actual commands must be `git rev-parse HEAD`, `git status --porcelain`, verified file inventory and a correction to the prior false release checkpoint. Then G0: fix the effective manifest and confirmed compile contradictions and **run the Apple compiler** as soon as CI access is available. Do not generate `FINAL_AUDIT_*` before any build.

**If your agent cannot push to GitHub without permission:** request an explicitly approved repair branch/PR push or have the user push it, then fetch actual macOS job logs. Continue safe independent code work while waiting. **The user must run the physical iPad tests**; Antigravity Linux cannot claim them.

## 5. What changed in this package relative to previous reports

A full published-tree scan surfaced **additional independently observed compiler blockers** missed in the fifth handoff: duplicate `AppSession.completeOnboarding()`, nonexistent `ApprovalRequest.summary`, malformed Swift string interpolation, undefined `TaskStep`, alongside the known missing manifest localization, missing approval fields and missing AvatarIdentity. It also corrected the earlier mistaken suspicion that `AvatarRole.themeColor` did not exist: it does. These corrections are described and pinned in `00_*`, `01_*` and `02_*`.

## 6. Real release decision

**Present state:** `BUILD_BLOCKED`, **not ready** for personal data, actual production BYOK keys or authorized external actions on the user's iPad. A disposable no-key diagnostic import is optional after correcting package import blockers; it does not certify safety. Accept `COMPILED_TESTED_CANDIDATE_AWAITING_IPAD` only after genuine Xcode build + compiled behavioral/security tests + two current-source audits. Accept `IPAD_VERIFIED` only with actual user-run device evidence. No prompt can substitute for the missing execution proof.

## 7. V2 correction: workstation and executable verification

This superseding package adds `05_EXACT_SWIFT_CODE_AND_CALLER_PATCHES.md` (source-linked, compile-oriented Swift edits and caller maps) and `06_VSCODE_LINUX_MAC_CI_AND_IPAD.md` (the real Linux VS Code / Swift compiler / GitHub-hosted Apple CI / physical iPad sequence). `scripts/` and `portable_core_tests/` are **optional verification tools**, not production replacements.

**The crucial distinction:** VS Code + the official Swift extension on Ubuntu parses, edits, debugs and runs **Linux-compatible Swift**, not SwiftUI/SwiftData/UIKit/iPad apps. Only a compatible Apple SDK (Mac/Apple hosted runner) and finally the real iPad can validate the shipping app. Installing an extension cannot provide Apple frameworks on Linux. The remote Mac must have the exact candidate source, not a stale `git pull` masquerading as a successful build.

**Previous six documents are corrected rather than silently retained:** see `00_*` section 4 for individually identified gaps, `02_*` G0.8 for a previously omitted compiler defect, and `05_*` for revised code. This package replaces the old six documents as the active execution instruction but is itself pinned to the fifth public SHA until the local working tree is reconciled.
