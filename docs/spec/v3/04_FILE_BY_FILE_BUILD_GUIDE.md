# 04 — Exhaustive file-by-file coding guide (266 canonical items)
This is the primary implementation ledger for Claude Sonnet. Every item in the original v1 manifest is covered exactly once. **Do not treat `[NEXT]` as code to ship in V1.** `V1` includes documents and assets, not 221 executable source files. A view/asset receives an exact lifecycle/schema responsibility, not a fictional numerical algorithm. Read `03_ALGORITHM_COOKBOOK.md` for complete implementation state machines and negative cases, `02_CANONICAL_CONTRACTS.md` for stable DTOs. Relative runtime source paths are inside the exported verified app target; docs/tests/cloud sit outside it.

## Global per-file completion definition
1. Implement only the named owner responsibility; reference canonical type definitions, do not duplicate DTOs.
2. Inputs and outputs must be typed, validated, owner-scoped when data-bearing, and failure-representable.
3. Async work uses structured cancellation, injected dependencies and current session generation.
4. No `fatalError`, `try!`, silent `catch {}`, built-in secrets, fake async progress or fake backend data in shipping code.
5. Add or link test evidence; **implementation described != compiled/tested**.


## Project (10 items)

Baseline technique: Match declared deliverable to canonical scope; resolve actual generated Playground manifest instead of fabricating metadata; keep commands and provenance reproducible.

### `PersonalAssistant.swiftpm/[generated app manifest]`  [V1]

**Single responsibility:** Use actual Playgrounds-created project metadata.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Target OS/package/resources inferred from exported template; packaging import/build probe; never hand-invent manifest. MUST be exported from real iPad Playground template or project packaging stays blocked.
Match declared deliverable to canonical scope; resolve actual generated Playground manifest instead of fabricating metadata; keep commands and provenance reproducible.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** File is current with v2 authority hierarchy; W00 evidence attached if packaging-related.

### `PersonalAssistant.swiftpm/README.md`  [V1]

**Single responsibility:** iPad installation, keys, permissions and troubleshooting.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Task-oriented instructions plus verified template import path; test on fresh Playground. Match declared deliverable to canonical scope; resolve actual generated Playground manifest instead of fabricating metadata; keep commands and provenance reproducible.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** File is current with v2 authority hierarchy; W00 evidence attached if packaging-related.

### `Docs/00_PRODUCT_SCOPE.md`  [V1]

**Single responsibility:** Freeze V1 shipped, conditional and later scope.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Requirement IDs and acceptance traceability; no misleading enabled future feature. Match declared deliverable to canonical scope; resolve actual generated Playground manifest instead of fabricating metadata; keep commands and provenance reproducible.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** File is current with v2 authority hierarchy; W00 evidence attached if packaging-related.

### `Docs/01_ARCHITECTURE.md`  [V1]

**Single responsibility:** Dependency rules, diagrams and ownership.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Architecture decision records and dependency audit. Match declared deliverable to canonical scope; resolve actual generated Playground manifest instead of fabricating metadata; keep commands and provenance reproducible.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** File is current with v2 authority hierarchy; W00 evidence attached if packaging-related.

### `Docs/02_API_CONTRACTS.md`  [V1]

**Single responsibility:** Provider and service DTO/interface specifications.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Versioned Codable events + stub/mock compatibility contract tests. Match declared deliverable to canonical scope; resolve actual generated Playground manifest instead of fabricating metadata; keep commands and provenance reproducible.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** File is current with v2 authority hierarchy; W00 evidence attached if packaging-related.

### `Docs/03_PRIVACY_AND_THREAT_MODEL.md`  [V1]

**Single responsibility:** Data-flow and attacker analysis.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** STRIDE + LLM prompt-injection abuse cases; privacy test matrix. Match declared deliverable to canonical scope; resolve actual generated Playground manifest instead of fabricating metadata; keep commands and provenance reproducible.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** File is current with v2 authority hierarchy; W00 evidence attached if packaging-related.

### `Docs/04_DEVICE_TEST_MATRIX.md`  [V1]

**Single responsibility:** iPhone/iPad/OS/language/network cases.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Positive, negative and conditional availability gates. Match declared deliverable to canonical scope; resolve actual generated Playground manifest instead of fabricating metadata; keep commands and provenance reproducible.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** File is current with v2 authority hierarchy; W00 evidence attached if packaging-related.

### `Docs/05_RELEASE_CHECKLIST.md`  [V1]

**Single responsibility:** Repeatable clean install, device build and release gates.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Checkbox evidence links; no unsupported claims of deployment readiness. Match declared deliverable to canonical scope; resolve actual generated Playground manifest instead of fabricating metadata; keep commands and provenance reproducible.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** File is current with v2 authority hierarchy; W00 evidence attached if packaging-related.

### `Docs/06_DEPENDENCY_LOCK.md`  [V1]

**Single responsibility:** Record Apple SDK, package versions and licenses.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Lockfile/hash checks and third-party dependency inventory. Match declared deliverable to canonical scope; resolve actual generated Playground manifest instead of fabricating metadata; keep commands and provenance reproducible.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** File is current with v2 authority hierarchy; W00 evidence attached if packaging-related.

### `Docs/07_DECISION_LOG.md`  [V1]

**Single responsibility:** Record ADRs and architecture changes.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Immutable numbered decisions with reversibility and consequences. Match declared deliverable to canonical scope; resolve actual generated Playground manifest instead of fabricating metadata; keep commands and provenance reproducible.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** File is current with v2 authority hierarchy; W00 evidence attached if packaging-related.


## Resources (14 items)

Baseline technique: Define exact JSON/plist/catalog keys and allowed encodings; verify application target lookup, missing-resource fallback and no embedded credentials.

### `Resources/PrivacyInfo.xcprivacy`  [V1]

**Single responsibility:** Declare collected data and required-reason API use.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Audit imported SDKs + actual device APIs; validate with distribution tooling. Audit precise actual required-reason API use; do not invent declarations or privacy compliance.
Define exact JSON/plist/catalog keys and allowed encodings; verify application target lookup, missing-resource fallback and no embedded credentials.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Asset parses/loads on-device, handles missing asset and contains no secret.

### `Resources/PublicConfig.json`  [V1]

**Single responsibility:** Nonsecret provider base URLs, public flags and catalog TTL.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Strict Decodable schema + allowlisted HTTPS origins; tampered-config test. Define exact JSON/plist/catalog keys and allowed encodings; verify application target lookup, missing-resource fallback and no embedded credentials.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Asset parses/loads on-device, handles missing asset and contains no secret.

### `Resources/Assets.xcassets/Contents.json`  [V1]

**Single responsibility:** Declare the asset catalog namespace.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Apple asset catalog metadata schema; bundled resource validation. Define exact JSON/plist/catalog keys and allowed encodings; verify application target lookup, missing-resource fallback and no embedded credentials.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Asset parses/loads on-device, handles missing asset and contains no secret.

### `Resources/Assets.xcassets/Maya.imageset/Contents.json`  [V1]

**Single responsibility:** Map Maya image asset to actual filenames/scales.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Asset catalog image entry and optimized format validation. Define exact JSON/plist/catalog keys and allowed encodings; verify application target lookup, missing-resource fallback and no embedded credentials.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Asset parses/loads on-device, handles missing asset and contains no secret.

### `Resources/Assets.xcassets/Maya.imageset/maya.png`  [V1]

**Single responsibility:** Bundled female assistant image.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Static visual resource; consistent avatar state mask and licensing. Define exact JSON/plist/catalog keys and allowed encodings; verify application target lookup, missing-resource fallback and no embedded credentials.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Asset parses/loads on-device, handles missing asset and contains no secret.

### `Resources/Assets.xcassets/Saar.imageset/Contents.json`  [V1]

**Single responsibility:** Map Saar image asset to actual filenames/scales.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Asset catalog image entry and optimized format validation. Define exact JSON/plist/catalog keys and allowed encodings; verify application target lookup, missing-resource fallback and no embedded credentials.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Asset parses/loads on-device, handles missing asset and contains no secret.

### `Resources/Assets.xcassets/Saar.imageset/saar.png`  [V1]

**Single responsibility:** Bundled male assistant image.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Static visual resource; consistent avatar state mask and licensing. Define exact JSON/plist/catalog keys and allowed encodings; verify application target lookup, missing-resource fallback and no embedded credentials.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Asset parses/loads on-device, handles missing asset and contains no secret.

### `Resources/Assets.xcassets/AppIcon.appiconset/Contents.json`  [V1]

**Single responsibility:** Map app icon images and appearance variants.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Asset catalog icon metadata validated against supported target. Define exact JSON/plist/catalog keys and allowed encodings; verify application target lookup, missing-resource fallback and no embedded credentials.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Asset parses/loads on-device, handles missing asset and contains no secret.

### `Resources/Assets.xcassets/AppIcon.appiconset/icon-1024.png`  [V1]

**Single responsibility:** Original app icon artwork.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** 1024px master artwork with correct transparency policy at submission. Define exact JSON/plist/catalog keys and allowed encodings; verify application target lookup, missing-resource fallback and no embedded credentials.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Asset parses/loads on-device, handles missing asset and contains no secret.

### `Resources/en.lproj/Localizable.strings`  [V1]

**Single responsibility:** English UI labels, privacy prompts and errors.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Stable localization keys and format argument consistency. Define exact JSON/plist/catalog keys and allowed encodings; verify application target lookup, missing-resource fallback and no embedded credentials.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Asset parses/loads on-device, handles missing asset and contains no secret.

### `Resources/hi.lproj/Localizable.strings`  [V1]

**Single responsibility:** Hindi UI labels with Hinglish-friendly UX option.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Human review, plural/date formatting and mixed-script layout. Define exact JSON/plist/catalog keys and allowed encodings; verify application target lookup, missing-resource fallback and no embedded credentials.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Asset parses/loads on-device, handles missing asset and contains no secret.

### `Resources/ProviderCatalog.json`  [V1]

**Single responsibility:** Bundled known safe default provider capability fallback.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** JSON schema, URLs, no active key or false model availability. Define exact JSON/plist/catalog keys and allowed encodings; verify application target lookup, missing-resource fallback and no embedded credentials.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Asset parses/loads on-device, handles missing asset and contains no secret.

### `Resources/Prompts/assistant_v1.txt`  [V1]

**Single responsibility:** Versioned generic persona/system safety instructions.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** User customization injected as data; prompt regression fixtures. Define exact JSON/plist/catalog keys and allowed encodings; verify application target lookup, missing-resource fallback and no embedded credentials.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Asset parses/loads on-device, handles missing asset and contains no secret.

### `Resources/Prompts/task_planner_v1.txt`  [V1]

**Single responsibility:** Versioned tool-planning and task-extraction instructions.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Strict typed schema response; injection and ambiguity tests. Define exact JSON/plist/catalog keys and allowed encodings; verify application target lookup, missing-resource fallback and no embedded credentials.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Asset parses/loads on-device, handles missing asset and contains no secret.


## App (7 items)

Baseline technique: Define public typed initializer and dependencies; publish state through @MainActor; use typed command/state and reject stale session tokens.

### `App/PersonalAssistantApp.swift`  [V1]

**Single responsibility:** Single SwiftUI @main app entry, scene and model container.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Initialize dependency container once; scene lifecycle/test-launch. Only @main entry, create shared ModelContainer/AppContainer, navigation root; never fire network from initializer.
Define public typed initializer and dependencies; publish state through @MainActor; use typed command/state and reject stale session tokens.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** View/navigation state updates on owner switch and scene lifecycle without leaked old callbacks.

### `App/AppContainer.swift`  [V1]

**Single responsibility:** Dependency composition for all service protocols.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Constructor injection; fake swaps; forbid service construction in views. Define public typed initializer and dependencies; publish state through @MainActor; use typed command/state and reject stale session tokens.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** View/navigation state updates on owner switch and scene lifecycle without leaked old callbacks.

### `App/AppSession.swift`  [V1]

**Single responsibility:** Current user, active assistant, lock state and foreground state.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** MainActor observable source of truth; account-switch isolation test. Define public typed initializer and dependencies; publish state through @MainActor; use typed command/state and reject stale session tokens.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** View/navigation state updates on owner switch and scene lifecycle without leaked old callbacks.

### `App/AppRouter.swift`  [V1]

**Single responsibility:** Global routes, sheets, deep links and tab selection.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Typed enum navigation; restore safe route only; unknown-link rejection. Define public typed initializer and dependencies; publish state through @MainActor; use typed command/state and reject stale session tokens.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** View/navigation state updates on owner switch and scene lifecycle without leaked old callbacks.

### `App/CapabilityCenter.swift`  [V1]

**Single responsibility:** Cache runtime/permission/model/locale readiness.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Async refresh and invalidation; device/locale matrix; no assumed AI eligibility. Gate per actual device/OS/framework/provider/locale and permission; state unknown until probed.
Define public typed initializer and dependencies; publish state through @MainActor; use typed command/state and reject stale session tokens.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** View/navigation state updates on owner switch and scene lifecycle without leaked old callbacks.

### `App/FeatureGate.swift`  [V1]

**Single responsibility:** Present only genuinely supported features.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Capability+release-flag+consent conjunction; disabled-reason snapshot test. Define public typed initializer and dependencies; publish state through @MainActor; use typed command/state and reject stale session tokens.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** View/navigation state updates on owner switch and scene lifecycle without leaked old callbacks.

### `App/ApplicationCommandBus.swift`  [V1]

**Single responsibility:** UI and voice share domain-level entry points.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Typed commands, trace IDs and serial side-effect routing; replay guard. Define public typed initializer and dependencies; publish state through @MainActor; use typed command/state and reject stale session tokens.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** View/navigation state updates on owner switch and scene lifecycle without leaked old callbacks.


## DesignSystem (9 items)

Baseline technique: Declare parameters as immutable value inputs and accessible labels; implement compact/regular layout and all loading/disabled/empty states; honor Dynamic Type and Reduce Motion.

### `DesignSystem/AppTheme.swift`  [V1]

**Single responsibility:** Shared semantic colors, spacing and radii.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Dynamic system appearance and contrast tokens; dark-mode tests. Declare parameters as immutable value inputs and accessible labels; implement compact/regular layout and all loading/disabled/empty states; honor Dynamic Type and Reduce Motion.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Both iPhone/iPad previews, dark/light, high text size and VoiceOver description.

### `DesignSystem/AdaptiveLayout.swift`  [V1]

**Single responsibility:** Compact/regular navigation and split-view decisions.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Size classes + geometry breakpoints; rotation and split-window tests. Declare parameters as immutable value inputs and accessible labels; implement compact/regular layout and all loading/disabled/empty states; honor Dynamic Type and Reduce Motion.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Both iPhone/iPad previews, dark/light, high text size and VoiceOver description.

### `DesignSystem/AccessibleButton.swift`  [V1]

**Single responsibility:** Shared accessible action with loading/disabled states.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** 44-point hit target minimum goal, accessible labels and busy state. Declare parameters as immutable value inputs and accessible labels; implement compact/regular layout and all loading/disabled/empty states; honor Dynamic Type and Reduce Motion.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Both iPhone/iPad previews, dark/light, high text size and VoiceOver description.

### `DesignSystem/AsyncStateView.swift`  [V1]

**Single responsibility:** Loading, empty, retry, permission and error presentations.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Exhaustive async state enum rendering; view snapshot cases. Declare parameters as immutable value inputs and accessible labels; implement compact/regular layout and all loading/disabled/empty states; honor Dynamic Type and Reduce Motion.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Both iPhone/iPad previews, dark/light, high text size and VoiceOver description.

### `DesignSystem/AssistantStatusChip.swift`  [V1]

**Single responsibility:** Visible local/cloud/route/voice/task status.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Derive labels only from confirmed runtime state; no speculative ready state. Declare parameters as immutable value inputs and accessible labels; implement compact/regular layout and all loading/disabled/empty states; honor Dynamic Type and Reduce Motion.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Both iPhone/iPad previews, dark/light, high text size and VoiceOver description.

### `DesignSystem/MarkdownMessageView.swift`  [V1]

**Single responsibility:** Render safe chat Markdown, tables and code.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Allowlisted renderer; reject active HTML/scripts and unsafe links. Declare parameters as immutable value inputs and accessible labels; implement compact/regular layout and all loading/disabled/empty states; honor Dynamic Type and Reduce Motion.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Both iPhone/iPad previews, dark/light, high text size and VoiceOver description.

### `DesignSystem/DateAndRelativeTime.swift`  [V1]

**Single responsibility:** Locale-aware accessible date/times and timezone display.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Foundation DateFormatter/FormatStyle; DST and calendar tests. Declare parameters as immutable value inputs and accessible labels; implement compact/regular layout and all loading/disabled/empty states; honor Dynamic Type and Reduce Motion.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Both iPhone/iPad previews, dark/light, high text size and VoiceOver description.

### `DesignSystem/ConfirmationSheet.swift`  [V1]

**Single responsibility:** Common high-impact action review surface.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Show recipient, data scope, exact parameters, expiry and revoke option. Declare parameters as immutable value inputs and accessible labels; implement compact/regular layout and all loading/disabled/empty states; honor Dynamic Type and Reduce Motion.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Both iPhone/iPad previews, dark/light, high text size and VoiceOver description.

### `DesignSystem/ToastAndBanner.swift`  [V1]

**Single responsibility:** Transient, accessible notifications and undo affordance.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Priority queue/coalescing; do not hide critical failures behind a toast. Declare parameters as immutable value inputs and accessible labels; implement compact/regular layout and all loading/disabled/empty states; honor Dynamic Type and Reduce Motion.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Both iPhone/iPad previews, dark/light, high text size and VoiceOver description.


## Domain (16 items)

Baseline technique: Implement Codable/Sendable value DTO, exact enum cases and a pure validate/transition function; use strong typed UUID wrappers and owner IDs.

### `Domain/Identifiers.swift`  [V1]

**Single responsibility:** Strong typed stable IDs and owner references.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Codable ID wrappers, equality and no cross-entity ID confusion. Implement Codable/Sendable value DTO, exact enum cases and a pure validate/transition function; use strong typed UUID wrappers and owner IDs.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Roundtrip encode/decode; reject missing owner, invalid state and malformed fields.

### `Domain/UserProfile.swift`  [V1]

**Single responsibility:** Local guest/account identity and visibility boundaries.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Immutable owner ID and explicit account-state transitions. Implement Codable/Sendable value DTO, exact enum cases and a pure validate/transition function; use strong typed UUID wrappers and owner IDs.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Roundtrip encode/decode; reject missing owner, invalid state and malformed fields.

### `Domain/AssistantProfile.swift`  [V1]

**Single responsibility:** Maya/Saar user-owned name, avatar, locale and voice.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Validate names, immutable profile ID and per-profile override inheritance. Implement Codable/Sendable value DTO, exact enum cases and a pure validate/transition function; use strong typed UUID wrappers and owner IDs.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Roundtrip encode/decode; reject missing owner, invalid state and malformed fields.

### `Domain/Conversation.swift`  [V1]

**Single responsibility:** Conversation title, assistant and lifecycle.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Archive/delete state machine and last-message timestamp invariant. Implement Codable/Sendable value DTO, exact enum cases and a pure validate/transition function; use strong typed UUID wrappers and owner IDs.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Roundtrip encode/decode; reject missing owner, invalid state and malformed fields.

### `Domain/Message.swift`  [V1]

**Single responsibility:** Typed user/assistant/tool message and content parts.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Stable order/sequence and monotonic delivery-state transitions. Implement Codable/Sendable value DTO, exact enum cases and a pure validate/transition function; use strong typed UUID wrappers and owner IDs.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Roundtrip encode/decode; reject missing owner, invalid state and malformed fields.

### `Domain/Attachment.swift`  [V1]

**Single responsibility:** Attachment references, MIME, sensitivity and size.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Content hash dedup + owner-scoped app-private path, no raw URL injection. Implement Codable/Sendable value DTO, exact enum cases and a pure validate/transition function; use strong typed UUID wrappers and owner IDs.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Roundtrip encode/decode; reject missing owner, invalid state and malformed fields.

### `Domain/TaskDefinition.swift`  [V1]

**Single responsibility:** Immutable versioned task instruction and trigger policy.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Calendar recurrence, executor class and optimistic revision control. Implement Codable/Sendable value DTO, exact enum cases and a pure validate/transition function; use strong typed UUID wrappers and owner IDs.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Roundtrip encode/decode; reject missing owner, invalid state and malformed fields.

### `Domain/TaskRun.swift`  [V1]

**Single responsibility:** Individual execution occurrence and progress.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Formal state machine + stable occurrence/idempotency key. Implement Codable/Sendable value DTO, exact enum cases and a pure validate/transition function; use strong typed UUID wrappers and owner IDs.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Roundtrip encode/decode; reject missing owner, invalid state and malformed fields.

### `Domain/TaskStep.swift`  [V1]

**Single responsibility:** Ordered tool/planning step, receipts and dependencies.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** DAG prerequisites and skip/retry constraints. Implement Codable/Sendable value DTO, exact enum cases and a pure validate/transition function; use strong typed UUID wrappers and owner IDs.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Roundtrip encode/decode; reject missing owner, invalid state and malformed fields.

### `Domain/ApprovalRequest.swift`  [V1]

**Single responsibility:** Exact proposed action, risk, expiry and decision.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Parameter digest binding; expired approvals rejected after edits. Implement Codable/Sendable value DTO, exact enum cases and a pure validate/transition function; use strong typed UUID wrappers and owner IDs.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Roundtrip encode/decode; reject missing owner, invalid state and malformed fields.

### `Domain/MemoryItem.swift`  [V1]

**Single responsibility:** Sourced memories, trust/confidence, TTL and owner.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Revisioned verified vs inferred claims; delete/tombstone lifecycle. Implement Codable/Sendable value DTO, exact enum cases and a pure validate/transition function; use strong typed UUID wrappers and owner IDs.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Roundtrip encode/decode; reject missing owner, invalid state and malformed fields.

### `Domain/AIModelDescriptor.swift`  [V1]

**Single responsibility:** Capabilities, pricing hints, provider and context.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Conservative required capability matching; unknown != true. Implement Codable/Sendable value DTO, exact enum cases and a pure validate/transition function; use strong typed UUID wrappers and owner IDs.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Roundtrip encode/decode; reject missing owner, invalid state and malformed fields.

### `Domain/ProviderConfiguration.swift`  [V1]

**Single responsibility:** Enabled endpoint, model allowlist and secret reference.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Valid HTTPS host and no credential bytes in Codable payloads. Implement Codable/Sendable value DTO, exact enum cases and a pure validate/transition function; use strong typed UUID wrappers and owner IDs.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Roundtrip encode/decode; reject missing owner, invalid state and malformed fields.

### `Domain/PrivacyAndConsent.swift`  [V1]

**Single responsibility:** Privacy class, grants, disclosure and user-facing policies.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Lattice ordering SECRET > SENSITIVE > PERSONAL > PUBLIC. Implement Codable/Sendable value DTO, exact enum cases and a pure validate/transition function; use strong typed UUID wrappers and owner IDs.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Roundtrip encode/decode; reject missing owner, invalid state and malformed fields.

### `Domain/AuditAndUsage.swift`  [V1]

**Single responsibility:** Redacted audit, invocation, token and quota DTOs.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Stable trace linking, optional usage and nonnegative monotonic counters. Implement Codable/Sendable value DTO, exact enum cases and a pure validate/transition function; use strong typed UUID wrappers and owner IDs.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Roundtrip encode/decode; reject missing owner, invalid state and malformed fields.

### `Domain/Errors.swift`  [V1]

**Single responsibility:** Typed user-actionable domain and transport failures.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Categorized retryability, privacy-safe description and recovery action. Implement Codable/Sendable value DTO, exact enum cases and a pure validate/transition function; use strong typed UUID wrappers and owner IDs.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Roundtrip encode/decode; reject missing owner, invalid state and malformed fields.


## Persistence (12 items)

Baseline technique: Use sole @Model declarations in StoreModels; convert DTO via StoreMappers; accept explicit owner ID and current session; isolate ModelContext inside actor/main context; commit atomically or surface recovery.

### `Persistence/SchemaV1.swift`  [V1]

**Single responsibility:** Declare initial @Model classes and VersionedSchema.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Explicit schema version and relationship delete rules; migration rehearsal. Declare ONLY VersionedSchema listing models, never duplicate @Model declarations.
Use sole @Model declarations in StoreModels; convert DTO via StoreMappers; accept explicit owner ID and current session; isolate ModelContext inside actor/main context; commit atomically or surface recovery.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Cold-relaunch persistence, stale-session denial, migration/corrupt store, owner filter.

### `Persistence/AppMigrationPlan.swift`  [V1]

**Single responsibility:** Whitelisted lightweight/custom migrations.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Dry-run from old fixture; backup-before-structural-changes and error recovery. List baseline SchemaV1, no fake migration stage to nonexistent V2; add fixture migration only with real next schema.
Use sole @Model declarations in StoreModels; convert DTO via StoreMappers; accept explicit owner ID and current session; isolate ModelContext inside actor/main context; commit atomically or surface recovery.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Cold-relaunch persistence, stale-session denial, migration/corrupt store, owner filter.

### `Persistence/StoreBootstrap.swift`  [V1]

**Single responsibility:** Create ModelContainer and account-aware contexts.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Fail closed on corrupt store, no silent destructive reset. Use sole @Model declarations in StoreModels; convert DTO via StoreMappers; accept explicit owner ID and current session; isolate ModelContext inside actor/main context; commit atomically or surface recovery.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Cold-relaunch persistence, stale-session denial, migration/corrupt store, owner filter.

### `Persistence/StoreModels.swift`  [V1]

**Single responsibility:** SwiftData persisted shape, separate from domain DTOs.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Explicit owner indexes and uniqueness constraints where supported. Own ALL actual SwiftData @Model entities, relationships and deletion rules; DTOs elsewhere.
Use sole @Model declarations in StoreModels; convert DTO via StoreMappers; accept explicit owner ID and current session; isolate ModelContext inside actor/main context; commit atomically or surface recovery.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Cold-relaunch persistence, stale-session denial, migration/corrupt store, owner filter.

### `Persistence/StoreMappers.swift`  [V1]

**Single responsibility:** SwiftData ↔ Sendable value conversions.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Round-trip equality; no accidental reference/actor escapes. Use sole @Model declarations in StoreModels; convert DTO via StoreMappers; accept explicit owner ID and current session; isolate ModelContext inside actor/main context; commit atomically or surface recovery.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Cold-relaunch persistence, stale-session denial, migration/corrupt store, owner filter.

### `Persistence/ConversationRepository.swift`  [V1]

**Single responsibility:** Message/conversation CRUD and transaction boundary.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Persist state before network requests; pagination and owner predicate. Use sole @Model declarations in StoreModels; convert DTO via StoreMappers; accept explicit owner ID and current session; isolate ModelContext inside actor/main context; commit atomically or surface recovery.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Cold-relaunch persistence, stale-session denial, migration/corrupt store, owner filter.

### `Persistence/TaskRepository.swift`  [V1]

**Single responsibility:** Definitions/runs/steps and unique occurrence records.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Atomic run transitions, receipt-before-retry and crash recovery. Use sole @Model declarations in StoreModels; convert DTO via StoreMappers; accept explicit owner ID and current session; isolate ModelContext inside actor/main context; commit atomically or surface recovery.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Cold-relaunch persistence, stale-session denial, migration/corrupt store, owner filter.

### `Persistence/MemoryRepository.swift`  [V1]

**Single responsibility:** Scoped memory CRUD and revision history.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Conflict markers, verification state, TTL and deletion propagation. Use sole @Model declarations in StoreModels; convert DTO via StoreMappers; accept explicit owner ID and current session; isolate ModelContext inside actor/main context; commit atomically or surface recovery.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Cold-relaunch persistence, stale-session denial, migration/corrupt store, owner filter.

### `Persistence/ConfigurationRepository.swift`  [V1]

**Single responsibility:** Assistant profiles, model routes and preferences.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Upsert with owner guard and validation before persistence. Use sole @Model declarations in StoreModels; convert DTO via StoreMappers; accept explicit owner ID and current session; isolate ModelContext inside actor/main context; commit atomically or surface recovery.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Cold-relaunch persistence, stale-session denial, migration/corrupt store, owner filter.

### `Persistence/AuditRepository.swift`  [V1]

**Single responsibility:** Append-only redacted trace/action records.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Monotonic event order and retention pruning; no raw tokens. Use sole @Model declarations in StoreModels; convert DTO via StoreMappers; accept explicit owner ID and current session; isolate ModelContext inside actor/main context; commit atomically or surface recovery.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Cold-relaunch persistence, stale-session denial, migration/corrupt store, owner filter.

### `Persistence/AttachmentRepository.swift`  [V1]

**Single responsibility:** Manage app-private file ownership and cleanup.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Hash references, temp-to-final atomic move, safe garbage collection. Use sole @Model declarations in StoreModels; convert DTO via StoreMappers; accept explicit owner ID and current session; isolate ModelContext inside actor/main context; commit atomically or surface recovery.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Cold-relaunch persistence, stale-session denial, migration/corrupt store, owner filter.

### `Persistence/RepositoryTransaction.swift`  [V1]

**Single responsibility:** Serialize coordinated repository updates.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Actor-confined unit-of-work; rollback on validation/persistence failure. Use sole @Model declarations in StoreModels; convert DTO via StoreMappers; accept explicit owner ID and current session; isolate ModelContext inside actor/main context; commit atomically or surface recovery.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Cold-relaunch persistence, stale-session denial, migration/corrupt store, owner filter.


## Security (12 items)

Baseline technique: Deny by default, require explicit owner and session; classify data and operation; use cryptographic APIs and canonical typed payloads where relevant; redact all diagnostic events.

### `Security/KeychainVault.swift`  [V1]

**Single responsibility:** Create/get/rotate/delete per-user BYOK and session secrets.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Use SecItem, per-user service/account namespace; locked-device tests. Separate user-owned key namespaces, SecItemAdd/CopyMatching/Update/Delete, never log secret.
Deny by default, require explicit owner and session; classify data and operation; use cryptographic APIs and canonical typed payloads where relevant; redact all diagnostic events.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Owner mismatch, revoked permission, stale approval, malicious destination and secrets in logs all fail closed.

### `Security/BiometricGate.swift`  [V1]

**Single responsibility:** Gate sensitive screens and approved high-risk actions.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** LocalAuthentication policy with device-passcode fallback as configured. Deny by default, require explicit owner and session; classify data and operation; use cryptographic APIs and canonical typed payloads where relevant; redact all diagnostic events.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Owner mismatch, revoked permission, stale approval, malicious destination and secrets in logs all fail closed.

### `Security/SessionGuard.swift`  [V1]

**Single responsibility:** Lock/unlock/profile-switch checks for all user-scoped services.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Deny if owner missing or session changes mid-operation. Deny by default, require explicit owner and session; classify data and operation; use cryptographic APIs and canonical typed payloads where relevant; redact all diagnostic events.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Owner mismatch, revoked permission, stale approval, malicious destination and secrets in logs all fail closed.

### `Security/DataClassifier.swift`  [V1]

**Single responsibility:** Classify request, attachments and context by sensitivity.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Highest-class-wins aggregation, explicit user overrides with audit. Deny by default, require explicit owner and session; classify data and operation; use cryptographic APIs and canonical typed payloads where relevant; redact all diagnostic events.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Owner mismatch, revoked permission, stale approval, malicious destination and secrets in logs all fail closed.

### `Security/PermissionCoordinator.swift`  [V1]

**Single responsibility:** Just-in-time microphone, speech, notifications and other grants.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Framework status query → explanation → request; handle denied/restricted. Deny by default, require explicit owner and session; classify data and operation; use cryptographic APIs and canonical typed payloads where relevant; redact all diagnostic events.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Owner mismatch, revoked permission, stale approval, malicious destination and secrets in logs all fail closed.

### `Security/ToolPolicyEngine.swift`  [V1]

**Single responsibility:** Independent authority on proposed model tool calls.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Tool allowlist + schema + scope + source-trust + action risk + budget. Deny by default, require explicit owner and session; classify data and operation; use cryptographic APIs and canonical typed payloads where relevant; redact all diagnostic events.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Owner mismatch, revoked permission, stale approval, malicious destination and secrets in logs all fail closed.

### `Security/ApprovalCoordinator.swift`  [V1]

**Single responsibility:** Generate/expire/resolve sensitive action confirmations.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Exact payload digest + user intent + TTL; edited payload invalidates grant. Deny by default, require explicit owner and session; classify data and operation; use cryptographic APIs and canonical typed payloads where relevant; redact all diagnostic events.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Owner mismatch, revoked permission, stale approval, malicious destination and secrets in logs all fail closed.

### `Security/URLSafety.swift`  [V1]

**Single responsibility:** Validate API, redirect, attachment and outbound-link URLs.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** HTTPS + allowed host + reject local/IP redirect for remote fetch paths. HTTPS allowlisted origin policy, block credentials in URLs, DNS rebinding and private address on external URL fetch, restrict redirects.
Deny by default, require explicit owner and session; classify data and operation; use cryptographic APIs and canonical typed payloads where relevant; redact all diagnostic events.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Owner mismatch, revoked permission, stale approval, malicious destination and secrets in logs all fail closed.

### `Security/Redaction.swift`  [V1]

**Single responsibility:** Remove PII/credentials from logs, error output and telemetry.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Allowlist fields and regex/key-pattern secondary scrub; log fixture tests. Deny by default, require explicit owner and session; classify data and operation; use cryptographic APIs and canonical typed payloads where relevant; redact all diagnostic events.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Owner mismatch, revoked permission, stale approval, malicious destination and secrets in logs all fail closed.

### `Security/CredentialLifecycle.swift`  [V1]

**Single responsibility:** Connect/disconnect/rotate credential references.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Per-owner key namespaces; revoke provider on auth failures. Deny by default, require explicit owner and session; classify data and operation; use cryptographic APIs and canonical typed payloads where relevant; redact all diagnostic events.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Owner mismatch, revoked permission, stale approval, malicious destination and secrets in logs all fail closed.

### `Security/EncryptionService.swift`  [V1]

**Single responsibility:** Optional local export and future backup encryption.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** CryptoKit AES.GCM + HKDF domain separation + authenticated manifest. Deny by default, require explicit owner and session; classify data and operation; use cryptographic APIs and canonical typed payloads where relevant; redact all diagnostic events.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Owner mismatch, revoked permission, stale approval, malicious destination and secrets in logs all fail closed.

### `Security/PrivacyPolicyEngine.swift`  [V1]

**Single responsibility:** Enforce local-only/cloud consent and allowed destination.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Fail closed on unknown processor, unconsented fallback or missing policy. Deny by default, require explicit owner and session; classify data and operation; use cryptographic APIs and canonical typed payloads where relevant; redact all diagnostic events.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Owner mismatch, revoked permission, stale approval, malicious destination and secrets in logs all fail closed.


## AIContracts (7 items)

Baseline technique: Define Sendable normalized events and strict model/tool schemas; unknown support cannot satisfy required capability; no Apple SDK types leak into domain interface.

### `AI/Contracts/AssistantModel.swift`  [V1]

**Single responsibility:** One provider-neutral generate/stream interface.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** AsyncThrowingStream + explicit cancellation; fake-provider conformance. Define Sendable normalized events and strict model/tool schemas; unknown support cannot satisfy required capability; no Apple SDK types leak into domain interface.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Every provider and fake conforms; encode/decode fixtures and unknown field rejection.

### `AI/Contracts/AssistantRequest.swift`  [V1]

**Single responsibility:** Validated multimodal prompt, tools and budgets.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Immutable Sendable DTO and content-part validation. Define Sendable normalized events and strict model/tool schemas; unknown support cannot satisfy required capability; no Apple SDK types leak into domain interface.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Every provider and fake conforms; encode/decode fixtures and unknown field rejection.

### `AI/Contracts/AssistantEvent.swift`  [V1]

**Single responsibility:** Normalized streaming events, completions and tool proposals.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Sequence-indexed deltas, no duplicate completion events. Define Sendable normalized events and strict model/tool schemas; unknown support cannot satisfy required capability; no Apple SDK types leak into domain interface.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Every provider and fake conforms; encode/decode fixtures and unknown field rejection.

### `AI/Contracts/ToolSchema.swift`  [V1]

**Single responsibility:** Strict schema definitions for model-exposed tools.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Name/version, typed parameter decoding and deny unknown fields. Define Sendable normalized events and strict model/tool schemas; unknown support cannot satisfy required capability; no Apple SDK types leak into domain interface.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Every provider and fake conforms; encode/decode fixtures and unknown field rejection.

### `AI/Contracts/ModelCapabilities.swift`  [V1]

**Single responsibility:** Formal modality/tool/privacy/context requirements.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Set-inclusion matching; unknown capabilities fail hard requirements. Define Sendable normalized events and strict model/tool schemas; unknown support cannot satisfy required capability; no Apple SDK types leak into domain interface.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Every provider and fake conforms; encode/decode fixtures and unknown field rejection.

### `AI/Contracts/ProviderError.swift`  [V1]

**Single responsibility:** Provider-independent auth/quota/network/validation errors.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** HTTP and provider mapping; explicit Retry-After support. Define Sendable normalized events and strict model/tool schemas; unknown support cannot satisfy required capability; no Apple SDK types leak into domain interface.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Every provider and fake conforms; encode/decode fixtures and unknown field rejection.

### `AI/Contracts/ModelInvocation.swift`  [V1]

**Single responsibility:** Trace and usage summary for each call.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Prompt version and model identity recorded with no raw sensitive content. Define Sendable normalized events and strict model/tool schemas; unknown support cannot satisfy required capability; no Apple SDK types leak into domain interface.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Every provider and fake conforms; encode/decode fixtures and unknown field rejection.


## AIRouting (7 items)

Baseline technique: Perform strict eligibility filter before stable route choice; snapshot owner+trace; enforce budgets, model-tool max loops, cancellation; reconcile actual usage once.

### `AI/Routing/ModelRegistry.swift`  [V1]

**Single responsibility:** Combine bundled and live model catalogs.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** TTL cache, stale marking, capability merge and manual invalidation. Perform strict eligibility filter before stable route choice; snapshot owner+trace; enforce budgets, model-tool max loops, cancellation; reconcile actual usage once.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Concurrent requests and stale session do not cross streams or double-bill; no privacy downgrade.

### `AI/Routing/IntelligenceRouter.swift`  [V1]

**Single responsibility:** Choose eligible model for each turn or task.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Hard capability/privacy filters → deterministic policy preference/fallback. Implement A02 strict capability/privacy/budget filter and stable preference selection; NO numeric invented model quality scoring.
Perform strict eligibility filter before stable route choice; snapshot owner+trace; enforce budgets, model-tool max loops, cancellation; reconcile actual usage once.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Concurrent requests and stale session do not cross streams or double-bill; no privacy downgrade.

### `AI/Routing/ProviderHealthActor.swift`  [V1]

**Single responsibility:** Track circuit breaker/rate limit per provider.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** CLOSED/OPEN/HALF_OPEN with cooldown and classified failures. Implement A03 breaker states CLOSED/OPEN/HALF_OPEN, Retry-After and 3 failures/5 minutes configurable.
Perform strict eligibility filter before stable route choice; snapshot owner+trace; enforce budgets, model-tool max loops, cancellation; reconcile actual usage once.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Concurrent requests and stale session do not cross streams or double-bill; no privacy downgrade.

### `AI/Routing/ProviderBudgetActor.swift`  [V1]

**Single responsibility:** Track soft local quota/reservations and actual reported usage.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Atomic reservation, release and reconciliation without negative balance. Implement reservation ledger/reconciliation with no negative balance; BYOK limits advisory.
Perform strict eligibility filter before stable route choice; snapshot owner+trace; enforce budgets, model-tool max loops, cancellation; reconcile actual usage once.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Concurrent requests and stale session do not cross streams or double-bill; no privacy downgrade.

### `AI/Routing/AssistantOrchestrator.swift`  [V1]

**Single responsibility:** Coordinate full turn/stream/tool/memory lifecycle.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Bounded model-tool loop, trace, cancellation and final persistence. Implement A04 full transaction sequence, max six continuations and 10 tool requests with owner-generation guard.
Perform strict eligibility filter before stable route choice; snapshot owner+trace; enforce budgets, model-tool max loops, cancellation; reconcile actual usage once.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Concurrent requests and stale session do not cross streams or double-bill; no privacy downgrade.

### `AI/Routing/StreamingAssembler.swift`  [V1]

**Single responsibility:** Construct one UI transcript from delta events.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Sequence check, partial recovery and bounded UI flush/coalescing. Perform strict eligibility filter before stable route choice; snapshot owner+trace; enforce budgets, model-tool max loops, cancellation; reconcile actual usage once.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Concurrent requests and stale session do not cross streams or double-bill; no privacy downgrade.

### `AI/Routing/PromptRegistry.swift`  [V1]

**Single responsibility:** Versioned assistant/planner/memory prompt templates.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Immutable prompt ID and selected assistant customization as user data. Perform strict eligibility filter before stable route choice; snapshot owner+trace; enforce budgets, model-tool max loops, cancellation; reconcile actual usage once.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Concurrent requests and stale session do not cross streams or double-bill; no privacy downgrade.


## AIProviders (7 items)

Baseline technique: Delegate HTTP/SSE to shared transport; map provider wire model metadata/events/errors to canonical DTOs; never perform iOS tools here; version-specific SDK import guarded.

### `AI/Providers/OpenAICompatibleProvider.swift`  [V1]

**Single responsibility:** Shared HTTPS chat/streaming for conforming endpoints.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Endpoint normalization, strict SSE framing and tool-call JSON decoding. Implement stream event translation and index-specific partial tool argument assembly; generic protocol core.
Delegate HTTP/SSE to shared transport; map provider wire model metadata/events/errors to canonical DTOs; never perform iOS tools here; version-specific SDK import guarded.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Fixture and live BYOK tests for valid stream, auth, 429, corrupt JSON and cancellation.

### `AI/Providers/GroqProvider.swift`  [V1]

**Single responsibility:** Groq-specific auth, catalog and error mapping.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Adapt OpenAI-compatible wire format without duplicating HTTP core. Delegate HTTP/SSE to shared transport; map provider wire model metadata/events/errors to canonical DTOs; never perform iOS tools here; version-specific SDK import guarded.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Fixture and live BYOK tests for valid stream, auth, 429, corrupt JSON and cancellation.

### `AI/Providers/OpenRouterProvider.swift`  [V1]

**Single responsibility:** OpenRouter headers, availability, model catalogs and usage.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Normalize provider metadata; never assume free model always available. Delegate HTTP/SSE to shared transport; map provider wire model metadata/events/errors to canonical DTOs; never perform iOS tools here; version-specific SDK import guarded.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Fixture and live BYOK tests for valid stream, auth, 429, corrupt JSON and cancellation.

### `AI/Providers/AppleFoundationModelProvider.swift`  [COND]

**Single responsibility:** Use on-device Apple models on eligible OS/hardware.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** #available guards, SystemLanguageModel availability/locale/context checks. Conditional compile+runtime availability; probe language/hardware/model availability; no mandatory fallback assumption.
Delegate HTTP/SSE to shared transport; map provider wire model metadata/events/errors to canonical DTOs; never perform iOS tools here; version-specific SDK import guarded.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Fixture and live BYOK tests for valid stream, auth, 429, corrupt JSON and cancellation.

### `AI/Providers/CustomEndpointProvider.swift`  [V1]

**Single responsibility:** User-configured OpenAI-compatible model endpoint.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** TLS-only, explicit endpoint consent, limited redirect and model test. Delegate HTTP/SSE to shared transport; map provider wire model metadata/events/errors to canonical DTOs; never perform iOS tools here; version-specific SDK import guarded.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Fixture and live BYOK tests for valid stream, auth, 429, corrupt JSON and cancellation.

### `AI/Providers/ManagedGatewayProvider.swift`  [NEXT]

**Single responsibility:** Use future authenticated gateway instead of distributing app-owned secrets.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Ephemeral user JWT + scoped server budgets and opaque provider key storage. Delegate HTTP/SSE to shared transport; map provider wire model metadata/events/errors to canonical DTOs; never perform iOS tools here; version-specific SDK import guarded.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Fixture and live BYOK tests for valid stream, auth, 429, corrupt JSON and cancellation.

### `AI/Providers/SmallAIProvider.swift`  [NEXT]

**Single responsibility:** Future Small AI runtime/HTTPS adapter.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Capability negotiation and shared stream events; no pretend local LLM. Delegate HTTP/SSE to shared transport; map provider wire model metadata/events/errors to canonical DTOs; never perform iOS tools here; version-specific SDK import guarded.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Fixture and live BYOK tests for valid stream, auth, 429, corrupt JSON and cancellation.


## AITransport (5 items)

Baseline technique: Use URLSession with safe HTTPS destination, cancellation, bounded bytes and timeouts; parse incremental bytes rather than chunk-as-line; preserve provider-specific sentinels in adapter.

### `AI/Transport/HTTPClient.swift`  [V1]

**Single responsibility:** Native URLSession request, timeout and auth boundary.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Ephemeral headers, deadline/cancellation and sanitized error mapping. Use URLSession with safe HTTPS destination, cancellation, bounded bytes and timeouts; parse incremental bytes rather than chunk-as-line; preserve provider-specific sentinels in adapter.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Split-frame/UTF-8/CRLF tests, redirect policy, offline, timeout, partial text.

### `AI/Transport/SSEDecoder.swift`  [V1]

**Single responsibility:** Parse multiline data/event/id/retry frames and [DONE].

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Incremental bounded UTF-8 line state machine; split-chunk fixtures. Implement byte incremental frame decoder from A01, preserve split UTF-8 and CRLF; enforce 1 MiB per event and bounded response.
Use URLSession with safe HTTPS destination, cancellation, bounded bytes and timeouts; parse incremental bytes rather than chunk-as-line; preserve provider-specific sentinels in adapter.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Split-frame/UTF-8/CRLF tests, redirect policy, offline, timeout, partial text.

### `AI/Transport/ConnectivityMonitor.swift`  [V1]

**Single responsibility:** Distinguish offline/transient/provider-specific outage.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** NWPathMonitor as hint, not oracle; avoid polling storm. Use URLSession with safe HTTPS destination, cancellation, bounded bytes and timeouts; parse incremental bytes rather than chunk-as-line; preserve provider-specific sentinels in adapter.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Split-frame/UTF-8/CRLF tests, redirect policy, offline, timeout, partial text.

### `AI/Transport/RetryPolicy.swift`  [V1]

**Single responsibility:** Backoff for safe model requests only.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Retry-After + exponential jitter + max attempts; idempotency rule. Use URLSession with safe HTTPS destination, cancellation, bounded bytes and timeouts; parse incremental bytes rather than chunk-as-line; preserve provider-specific sentinels in adapter.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Split-frame/UTF-8/CRLF tests, redirect policy, offline, timeout, partial text.

### `AI/Transport/ModelCatalogClient.swift`  [V1]

**Single responsibility:** Retrieve provider-advertised models with safe pagination.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Validate JSON schema/size, TTL/ETag, preserve local fallback catalog. Use URLSession with safe HTTPS destination, cancellation, bounded bytes and timeouts; parse incremental bytes rather than chunk-as-line; preserve provider-specific sentinels in adapter.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Split-frame/UTF-8/CRLF tests, redirect policy, offline, timeout, partial text.


## ContextMemory (9 items)

Baseline technique: Select permitted owner-scoped source-tagged facts within conservative token budget; distinguish verified vs inferred; expire and reconcile contradictory facts; treat fetched text as untrusted.

### `AI/Context/ContextBuilder.swift`  [V1]

**Single responsibility:** Assemble just-enough owner-scoped conversation context.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Trust-ordered sections, citation metadata and reserve output budget. A05 bounded trusted context sections and source tags; no raw unrelated owner data.
Select permitted owner-scoped source-tagged facts within conservative token budget; distinguish verified vs inferred; expire and reconcile contradictory facts; treat fetched text as untrusted.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Secrets excluded from external context, deterministic selection, correct source links and delete propagation.

### `AI/Context/TokenBudget.swift`  [V1]

**Single responsibility:** Enforce prompt/window/response reserve.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Exact token count when API provided, conservative estimate otherwise. Select permitted owner-scoped source-tagged facts within conservative token budget; distinguish verified vs inferred; expire and reconcile contradictory facts; treat fetched text as untrusted.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Secrets excluded from external context, deterministic selection, correct source links and delete propagation.

### `AI/Context/HistoryRetriever.swift`  [V1]

**Single responsibility:** Fetch last turns and related local history for active user.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Recent-window plus bounded ranked retrieval with owner filtering. Select permitted owner-scoped source-tagged facts within conservative token budget; distinguish verified vs inferred; expire and reconcile contradictory facts; treat fetched text as untrusted.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Secrets excluded from external context, deterministic selection, correct source links and delete propagation.

### `AI/Context/MemoryRetriever.swift`  [V1]

**Single responsibility:** Fetch verified/relevant memories by privacy+recency.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Relevance + confidence tie-break, deterministic dedup; no unsupported claims. Select permitted owner-scoped source-tagged facts within conservative token budget; distinguish verified vs inferred; expire and reconcile contradictory facts; treat fetched text as untrusted.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Secrets excluded from external context, deterministic selection, correct source links and delete propagation.

### `AI/Context/MemoryProposalEngine.swift`  [V1]

**Single responsibility:** Generate candidate memories from explicit/selected user content.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Source-tagged proposals, default unverified and user review gating. Default inferred memories proposed/unverified, present approval before active use.
Select permitted owner-scoped source-tagged facts within conservative token budget; distinguish verified vs inferred; expire and reconcile contradictory facts; treat fetched text as untrusted.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Secrets excluded from external context, deterministic selection, correct source links and delete propagation.

### `AI/Context/MemoryConflictResolver.swift`  [V1]

**Single responsibility:** Compare old/new facts and prevent silent overwrite.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Verified-first, version/date comparison; unresolved conflict record. Select permitted owner-scoped source-tagged facts within conservative token budget; distinguish verified vs inferred; expire and reconcile contradictory facts; treat fetched text as untrusted.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Secrets excluded from external context, deterministic selection, correct source links and delete propagation.

### `AI/Context/ConversationSummarizer.swift`  [V1]

**Single responsibility:** Compress older turns while retaining sources.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Rolling summary with source IDs and summary revisions; bounded regeneration. Select permitted owner-scoped source-tagged facts within conservative token budget; distinguish verified vs inferred; expire and reconcile contradictory facts; treat fetched text as untrusted.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Secrets excluded from external context, deterministic selection, correct source links and delete propagation.

### `AI/Context/ContextProvenance.swift`  [V1]

**Single responsibility:** Mark user, system, tool, document and web source authority.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Trust ordering is enforced by code, not prompt wording alone. Select permitted owner-scoped source-tagged facts within conservative token budget; distinguish verified vs inferred; expire and reconcile contradictory facts; treat fetched text as untrusted.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Secrets excluded from external context, deterministic selection, correct source links and delete propagation.

### `AI/Context/MemoryRetentionWorker.swift`  [V1]

**Single responsibility:** Expire/delete memory and trigger index cleanup.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** TTL scans on foreground maintenance, tombstone not silent resurrection. Select permitted owner-scoped source-tagged facts within conservative token budget; distinguish verified vs inferred; expire and reconcile contradictory facts; treat fetched text as untrusted.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Secrets excluded from external context, deterministic selection, correct source links and delete propagation.


## Voice (8 items)

Baseline technique: Explicitly request microphone; select supported locale/transcriber with legacy fallback; sequence transcripts by session and cancel on interruption; avoid ambient recording.

### `Voice/VoiceCoordinator.swift`  [V1]

**Single responsibility:** Own microphone/transcribe/generate/speak conversational session.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Explicit state machine and cancellation child tasks; no always-on capture. Explicitly request microphone; select supported locale/transcriber with legacy fallback; sequence transcripts by session and cancel on interruption; avoid ambient recording.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Authorized/denied locale, stale partial transcript, mid-speech interruption and cleanup.

### `Voice/MicrophoneCapture.swift`  [V1]

**Single responsibility:** AVAudioEngine frames and audio session setup.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Bounded ring buffer, interruptions and permission-sensitive shutdown. Explicitly request microphone; select supported locale/transcriber with legacy fallback; sequence transcripts by session and cancel on interruption; avoid ambient recording.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Authorized/denied locale, stale partial transcript, mid-speech interruption and cleanup.

### `Voice/SpeechRecognizerProtocol.swift`  [V1]

**Single responsibility:** Common transcript/session/locale interface.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Normalized interim/final sequence and device capability negotiation. Explicitly request microphone; select supported locale/transcriber with legacy fallback; sequence transcripts by session and cancel on interruption; avoid ambient recording.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Authorized/denied locale, stale partial transcript, mid-speech interruption and cleanup.

### `Voice/LegacySpeechRecognizer.swift`  [V1]

**Single responsibility:** Fallback SFSpeechRecognizer for older supported OSes.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Request authorization; locale availability; cancel-on-stop. Explicitly request microphone; select supported locale/transcriber with legacy fallback; sequence transcripts by session and cancel on interruption; avoid ambient recording.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Authorized/denied locale, stale partial transcript, mid-speech interruption and cleanup.

### `Voice/ModernSpeechTranscriber.swift`  [COND]

**Single responsibility:** Newer Apple SpeechTranscriber where available.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Installed/supported locale probe; asset installation if supported and approved. Conditional only and use installed SDK spelling confirmed in W00; selected locale asset and support gate.
Explicitly request microphone; select supported locale/transcriber with legacy fallback; sequence transcripts by session and cancel on interruption; avoid ambient recording.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Authorized/denied locale, stale partial transcript, mid-speech interruption and cleanup.

### `Voice/AppleSpeechSynthesizer.swift`  [V1]

**Single responsibility:** Voice list, playback, stop and rate controls.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** AVSpeechSynthesizer delegate-to-async state and interruption cleanup. Explicitly request microphone; select supported locale/transcriber with legacy fallback; sequence transcripts by session and cancel on interruption; avoid ambient recording.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Authorized/denied locale, stale partial transcript, mid-speech interruption and cleanup.

### `Voice/VoiceLocalePolicy.swift`  [V1]

**Single responsibility:** Choose Hindi/English locale or declare Hinglish fallback.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Exact supported locale probe; ask before cloud STT disclosure. Explicitly request microphone; select supported locale/transcriber with legacy fallback; sequence transcripts by session and cancel on interruption; avoid ambient recording.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Authorized/denied locale, stale partial transcript, mid-speech interruption and cleanup.

### `Voice/AudioInterruptionHandler.swift`  [V1]

**Single responsibility:** React to route changes, phone calls and app lifecycle.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Pause/resume only with user intent; release AVAudioSession correctly. Explicitly request microphone; select supported locale/transcriber with legacy fallback; sequence transcripts by session and cancel on interruption; avoid ambient recording.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Authorized/denied locale, stale partial transcript, mid-speech interruption and cleanup.


## Avatar (5 items)

Baseline technique: Map active assistant IDs to replaceable assets, independently chosen voices and finite activity states; MainActor updates honor Reduce Motion.

### `Avatar/AvatarState.swift`  [V1]

**Single responsibility:** Canonical idle/listening/thinking/speaking/working/error model.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Exhaustive finite-state transition mapping. Map active assistant IDs to replaceable assets, independently chosen voices and finite activity states; MainActor updates honor Reduce Motion.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Switch/rename both avatars persists; no state animation claims an action before service reports it.

### `Avatar/AvatarStateController.swift`  [V1]

**Single responsibility:** Map orchestrator/voice/task events to visible animation state.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** MainActor state projection; stale-event sequence suppression. Map active assistant IDs to replaceable assets, independently chosen voices and finite activity states; MainActor updates honor Reduce Motion.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Switch/rename both avatars persists; no state animation claims an action before service reports it.

### `Avatar/AvatarView.swift`  [V1]

**Single responsibility:** Display male/female image/animation and accessible alternative.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Lightweight SwiftUI animation honoring Reduce Motion. Map active assistant IDs to replaceable assets, independently chosen voices and finite activity states; MainActor updates honor Reduce Motion.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Switch/rename both avatars persists; no state animation claims an action before service reports it.

### `Avatar/AvatarAssetCatalog.swift`  [V1]

**Single responsibility:** Resolve installed built-in and user-selected avatar assets.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Stable asset ID fallback; don't couple avatar gender with voice gender. Map active assistant IDs to replaceable assets, independently chosen voices and finite activity states; MainActor updates honor Reduce Motion.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Switch/rename both avatars persists; no state animation claims an action before service reports it.

### `Avatar/AvatarPickerView.swift`  [V1]

**Single responsibility:** Preview, switch and assign avatar independently of assistant name.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Persist selection atomically to active owner's assistant profile. Map active assistant IDs to replaceable assets, independently chosen voices and finite activity states; MainActor updates honor Reduce Motion.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Switch/rename both avatars persists; no state animation claims an action before service reports it.


## TaskEngine (13 items)

Baseline technique: Enforce TaskDefinition/TaskRun boundary, calendar recurrence, atomic state transition and idempotency receipt; use notification-only background semantics.

### `Tasks/TaskStateMachine.swift`  [V1]

**Single responsibility:** Single canonical set of transitions for tasks and runs.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Validate queued→running→waiting/completed/failed/cancelled; reject impossible moves. Enforce TaskDefinition/TaskRun boundary, calendar recurrence, atomic state transition and idempotency receipt; use notification-only background semantics.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** DST fixture, canceled run, crash after PREPARED, duplicate occurrence and denied notification.

### `Tasks/TaskScheduler.swift`  [V1]

**Single responsibility:** Resolve one-shot and recurring next occurrences.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Calendar+timezone components and unique occurrence key; DST tests. Calendar recurrence with IANA timezone, DST/nonexistent/ambiguous time policies in A07.
Enforce TaskDefinition/TaskRun boundary, calendar recurrence, atomic state transition and idempotency receipt; use notification-only background semantics.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** DST fixture, canceled run, crash after PREPARED, duplicate occurrence and denied notification.

### `Tasks/TaskEngineActor.swift`  [V1]

**Single responsibility:** Create runs, queue, resume, cancel and finalize.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Actor serialization, run budget and interruption recovery. Enforce TaskDefinition/TaskRun boundary, calendar recurrence, atomic state transition and idempotency receipt; use notification-only background semantics.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** DST fixture, canceled run, crash after PREPARED, duplicate occurrence and denied notification.

### `Tasks/TaskPlanner.swift`  [V1]

**Single responsibility:** Convert approved user intent into typed bounded task plan.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Dependency DAG validation, cycle detection and step budget. Enforce TaskDefinition/TaskRun boundary, calendar recurrence, atomic state transition and idempotency receipt; use notification-only background semantics.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** DST fixture, canceled run, crash after PREPARED, duplicate occurrence and denied notification.

### `Tasks/TaskRunExecutor.swift`  [V1]

**Single responsibility:** Execute authorized task steps and report progress.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Topological ready-step selection; checkpoint before side effects. Enforce TaskDefinition/TaskRun boundary, calendar recurrence, atomic state transition and idempotency receipt; use notification-only background semantics.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** DST fixture, canceled run, crash after PREPARED, duplicate occurrence and denied notification.

### `Tasks/TaskRecovery.swift`  [V1]

**Single responsibility:** Reconcile persisted interrupted work at cold start.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Check receipts and idempotency; ambiguous writes require review. After crash, never blindly repeat AMBIGUOUS writes; move to review.
Enforce TaskDefinition/TaskRun boundary, calendar recurrence, atomic state transition and idempotency receipt; use notification-only background semantics.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** DST fixture, canceled run, crash after PREPARED, duplicate occurrence and denied notification.

### `Tasks/LocalReminderScheduler.swift`  [V1]

**Single responsibility:** Map reminder definitions to UserNotifications requests.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Persist notification ID; reconcile add/update/cancel; authorization state. Use UserNotifications calendar schedule, not AI runtime task in background; persist/reconcile request ID.
Enforce TaskDefinition/TaskRun boundary, calendar recurrence, atomic state transition and idempotency receipt; use notification-only background semantics.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** DST fixture, canceled run, crash after PREPARED, duplicate occurrence and denied notification.

### `Tasks/ForegroundExecutor.swift`  [V1]

**Single responsibility:** Run in-app AI jobs without background promises.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Bounded child tasks, cancellation and progress event stream. Enforce TaskDefinition/TaskRun boundary, calendar recurrence, atomic state transition and idempotency receipt; use notification-only background semantics.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** DST fixture, canceled run, crash after PREPARED, duplicate occurrence and denied notification.

### `Tasks/TaskProgress.swift`  [V1]

**Single responsibility:** Compute meaningful percentage/status for UI.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Completed weighted steps / planned work, unknown if work size unknowable. Enforce TaskDefinition/TaskRun boundary, calendar recurrence, atomic state transition and idempotency receipt; use notification-only background semantics.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** DST fixture, canceled run, crash after PREPARED, duplicate occurrence and denied notification.

### `Tasks/TaskRecurrence.swift`  [V1]

**Single responsibility:** Parse/edit daily/weekly/monthly and custom calendar recurrences.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Wall-clock semantics, timezone changes and missed-run policy. Enforce TaskDefinition/TaskRun boundary, calendar recurrence, atomic state transition and idempotency receipt; use notification-only background semantics.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** DST fixture, canceled run, crash after PREPARED, duplicate occurrence and denied notification.

### `Tasks/TaskIdempotency.swift`  [V1]

**Single responsibility:** Reserve occurrence/tool keys and dedupe retries.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Persistent unique operation key and compare-and-set status. Enforce TaskDefinition/TaskRun boundary, calendar recurrence, atomic state transition and idempotency receipt; use notification-only background semantics.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** DST fixture, canceled run, crash after PREPARED, duplicate occurrence and denied notification.

### `Tasks/RemoteTaskScheduler.swift`  [NEXT]

**Single responsibility:** Future backend execution for guaranteed schedules.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Authenticated enqueue/receipt/poll/webhook contract, no local fake guarantee. Enforce TaskDefinition/TaskRun boundary, calendar recurrence, atomic state transition and idempotency receipt; use notification-only background semantics.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** DST fixture, canceled run, crash after PREPARED, duplicate occurrence and denied notification.

### `Tasks/ContinuedBackgroundExecutor.swift`  [COND]

**Single responsibility:** Optional user-initiated BGContinuedProcessingTask support.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Platform availability check; Progress updates and early termination handling. Only after SDK and target entitlement support verified; foreground-initiated task, progress and termination recovery.
Enforce TaskDefinition/TaskRun boundary, calendar recurrence, atomic state transition and idempotency receipt; use notification-only background semantics.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** DST fixture, canceled run, crash after PREPARED, duplicate occurrence and denied notification.


## Tools (12 items)

Baseline technique: Parse strict tool arguments, use ToolPolicyEngine and exact approval digest, reserve receipt before side effect; return structured result and never retry ambiguous external mutations.

### `Tools/ToolRegistry.swift`  [V1]

**Single responsibility:** Catalog approved typed tools and their capability requirements.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Immutable name/version dispatch, deny unknown/disabled tools. Parse strict tool arguments, use ToolPolicyEngine and exact approval digest, reserve receipt before side effect; return structured result and never retry ambiguous external mutations.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Prompt injection, approval edit, replay and permission-denied tests.

### `Tools/ToolInvocationCoordinator.swift`  [V1]

**Single responsibility:** Authorize, reserve, execute and record tool calls.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Prepare→policy→approval→execute→receipt durable workflow. Exact hash approval, session recheck and PREPARED receipt precede platform side effect.
Parse strict tool arguments, use ToolPolicyEngine and exact approval digest, reserve receipt before side effect; return structured result and never retry ambiguous external mutations.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Prompt injection, approval edit, replay and permission-denied tests.

### `Tools/ToolReceiptStore.swift`  [V1]

**Single responsibility:** Prevent duplicate side effects when a network call times out.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** PREPARED/CONFIRMED/AMBIGUOUS persisted idempotency state. Unique operation key, PREPARED/SUCCEEDED/FAILED/AMBIGUOUS; transaction before external execution.
Parse strict tool arguments, use ToolPolicyEngine and exact approval digest, reserve receipt before side effect; return structured result and never retry ambiguous external mutations.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Prompt injection, approval edit, replay and permission-denied tests.

### `Tools/CreateTaskTool.swift`  [V1]

**Single responsibility:** AI-created local task after proper authorization.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Schema decode, user review if schedule/side effects ambiguous. Parse strict tool arguments, use ToolPolicyEngine and exact approval digest, reserve receipt before side effect; return structured result and never retry ambiguous external mutations.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Prompt injection, approval edit, replay and permission-denied tests.

### `Tools/CreateReminderTool.swift`  [V1]

**Single responsibility:** Create/schedule local reminder notifications.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Resolve natural-language date, validate timezone and confirm. Parse strict tool arguments, use ToolPolicyEngine and exact approval digest, reserve receipt before side effect; return structured result and never retry ambiguous external mutations.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Prompt injection, approval edit, replay and permission-denied tests.

### `Tools/SearchHistoryTool.swift`  [V1]

**Single responsibility:** Provide narrowly scoped history search to model.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Owner-bound safe result excerpts and sensitivity-filtered citations. Parse strict tool arguments, use ToolPolicyEngine and exact approval digest, reserve receipt before side effect; return structured result and never retry ambiguous external mutations.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Prompt injection, approval edit, replay and permission-denied tests.

### `Tools/SaveNoteTool.swift`  [V1]

**Single responsibility:** Persist a user-requested note/memory draft.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Write policy and provenance, explicit save vs learned inference. Parse strict tool arguments, use ToolPolicyEngine and exact approval digest, reserve receipt before side effect; return structured result and never retry ambiguous external mutations.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Prompt injection, approval edit, replay and permission-denied tests.

### `Tools/OpenURLTool.swift`  [V1]

**Single responsibility:** Open approved safe external links via platform UI.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** URL scheme/host validation; no invisible cross-app automation. Parse strict tool arguments, use ToolPolicyEngine and exact approval digest, reserve receipt before side effect; return structured result and never retry ambiguous external mutations.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Prompt injection, approval edit, replay and permission-denied tests.

### `Tools/ReadAttachmentTool.swift`  [V1]

**Single responsibility:** Extract permitted snippets from user-selected attachment.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** MIME/size/owner/sensitivity guards and controlled text exposure. Parse strict tool arguments, use ToolPolicyEngine and exact approval digest, reserve receipt before side effect; return structured result and never retry ambiguous external mutations.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Prompt injection, approval edit, replay and permission-denied tests.

### `Tools/CalendarTool.swift`  [V1]

**Single responsibility:** Optional read/create EventKit operations after capability check.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Least-privilege permission, event ID receipts and explicit create confirmation. Parse strict tool arguments, use ToolPolicyEngine and exact approval digest, reserve receipt before side effect; return structured result and never retry ambiguous external mutations.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Prompt injection, approval edit, replay and permission-denied tests.

### `Tools/ContactsLookupTool.swift`  [V1]

**Single responsibility:** Optional narrow user-authorized contact search.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** No contact bulk export; minimum fields and destination preview. Parse strict tool arguments, use ToolPolicyEngine and exact approval digest, reserve receipt before side effect; return structured result and never retry ambiguous external mutations.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Prompt injection, approval edit, replay and permission-denied tests.

### `Tools/ToolRiskClassifier.swift`  [V1]

**Single responsibility:** Map tool+arguments to read/write/external-send/destructive risk.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Destination-aware content scope and consent decision matrix. Parse strict tool arguments, use ToolPolicyEngine and exact approval digest, reserve receipt before side effect; return structured result and never retry ambiguous external mutations.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Prompt injection, approval edit, replay and permission-denied tests.


## Media (7 items)

Baseline technique: Validate real bytes/MIME/size, scoped secure file copy, SHA256 owner-local dedup, bounded document extraction/vision and consent before upload.

### `Media/AttachmentPicker.swift`  [V1]

**Single responsibility:** SwiftUI Files and Photos selection with proper scoped URL lifecycle.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** fileImporter/PhotosPicker; bookmark or copy to app-private storage. Validate real bytes/MIME/size, scoped secure file copy, SHA256 owner-local dedup, bounded document extraction/vision and consent before upload.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Spoofed MIME, overlimit, invalid bookmark, cancelled OCR and cleanup on delete.

### `Media/AttachmentValidator.swift`  [V1]

**Single responsibility:** Reject unsupported types, oversized and malicious payloads.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** UTType+magic/size/hash validation; filename canonicalization. Validate real bytes/MIME/size, scoped secure file copy, SHA256 owner-local dedup, bounded document extraction/vision and consent before upload.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Spoofed MIME, overlimit, invalid bookmark, cancelled OCR and cleanup on delete.

### `Media/AttachmentProcessor.swift`  [V1]

**Single responsibility:** Create canonical typed input for supported model modality.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Bounded text extraction, fallback unsupported-file notice. Validate real bytes/MIME/size, scoped secure file copy, SHA256 owner-local dedup, bounded document extraction/vision and consent before upload.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Spoofed MIME, overlimit, invalid bookmark, cancelled OCR and cleanup on delete.

### `Media/ImageOptimizer.swift`  [V1]

**Single responsibility:** Resize/strip unneeded metadata and make thumbnails.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Pixel-count and byte budgets with aspect-preserving scale. Validate real bytes/MIME/size, scoped secure file copy, SHA256 owner-local dedup, bounded document extraction/vision and consent before upload.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Spoofed MIME, overlimit, invalid bookmark, cancelled OCR and cleanup on delete.

### `Media/DocumentTextExtractor.swift`  [V1]

**Single responsibility:** Use supported local text/PDF extraction, no silent raw upload.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Page caps, Unicode normalization and page/source provenance. Validate real bytes/MIME/size, scoped secure file copy, SHA256 owner-local dedup, bounded document extraction/vision and consent before upload.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Spoofed MIME, overlimit, invalid bookmark, cancelled OCR and cleanup on delete.

### `Media/VisionTextRecognizer.swift`  [V1]

**Single responsibility:** On-device Vision OCR for selected images.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Bounding box/text confidence; user review for low-confidence OCR. Validate real bytes/MIME/size, scoped secure file copy, SHA256 owner-local dedup, bounded document extraction/vision and consent before upload.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Spoofed MIME, overlimit, invalid bookmark, cancelled OCR and cleanup on delete.

### `Media/AttachmentLifecycle.swift`  [V1]

**Single responsibility:** Delete temp files and revoke sandbox security scopes.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** TTL, reference counts, temp-file cleanup on crash recovery. Validate real bytes/MIME/size, scoped secure file copy, SHA256 owner-local dedup, bounded document extraction/vision and consent before upload.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Spoofed MIME, overlimit, invalid bookmark, cancelled OCR and cleanup on delete.


## Search (5 items)

Baseline technique: Filter owner and deletion before lexical ranking; deterministic score and pagination; optional opt-in Spotlight projection with revalidation at result open.

### `Search/HistorySearchCoordinator.swift`  [V1]

**Single responsibility:** Unified conversations/tasks/actions/memory search.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Owner-scope first; optional derived Spotlight rank blend. Filter owner and deletion before lexical ranking; deterministic score and pagination; optional opt-in Spotlight projection with revalidation at result open.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Owner leakage impossible, stale index treated as miss, delete purge and deterministic scores.

### `Search/LocalTextIndex.swift`  [V1]

**Single responsibility:** Portable deterministic local keyword search fallback.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Case/diacritic folding, bounded token matching, stable pagination. Filter owner and deletion before lexical ranking; deterministic score and pagination; optional opt-in Spotlight projection with revalidation at result open.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Owner leakage impossible, stale index treated as miss, delete purge and deterministic scores.

### `Search/SpotlightProjection.swift`  [COND]

**Single responsibility:** Private optional Core Spotlight entries for allowed snippets.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Opt-in indexed-only fields, differential upsert and account purge. Explicit user opt-in; index only allowed non-sensitive content; purge on logout and delete.
Filter owner and deletion before lexical ranking; deterministic score and pagination; optional opt-in Spotlight projection with revalidation at result open.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Owner leakage impossible, stale index treated as miss, delete purge and deterministic scores.

### `Search/SearchRanking.swift`  [V1]

**Single responsibility:** Rank exact phrase, field match, recency and optional semantic hits.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Transparent deterministic tie-breaks and per-type pagination. Filter owner and deletion before lexical ranking; deterministic score and pagination; optional opt-in Spotlight projection with revalidation at result open.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Owner leakage impossible, stale index treated as miss, delete purge and deterministic scores.

### `Search/IndexMaintenance.swift`  [V1]

**Single responsibility:** Keep derived indexes consistent with canonical SwiftData.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Outbox update, deletion tombstones, cold-start reconciliation. Filter owner and deletion before lexical ranking; deterministic score and pagination; optional opt-in Spotlight projection with revalidation at result open.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Owner leakage impossible, stale index treated as miss, delete purge and deterministic scores.


## DashboardUI (6 items)

Baseline technique: Subscribe to verified assistant/session/tasks streams, show avatar/command, needs-attention and quick actions; bind all taps to typed commands.

### `Features/Dashboard/DashboardView.swift`  [V1]

**Single responsibility:** Primary avatar, composer, quick actions, today and status dashboard.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Adaptive VStack/grid composition with accessibility reading order. Subscribe to verified assistant/session/tasks streams, show avatar/command, needs-attention and quick actions; bind all taps to typed commands.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Both assistant modes, offline status and genuine task counters on compact/regular device.

### `Features/Dashboard/DashboardViewModel.swift`  [V1]

**Single responsibility:** Owner-scoped summary projections and primary actions.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Combine async repo snapshots, no duplicate task or AI requests. Subscribe to verified assistant/session/tasks streams, show avatar/command, needs-attention and quick actions; bind all taps to typed commands.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Both assistant modes, offline status and genuine task counters on compact/regular device.

### `Features/Dashboard/TodayTaskCard.swift`  [V1]

**Single responsibility:** Count and preview pending/completed user tasks.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Calendar day boundaries in user timezone and accessible progress. Subscribe to verified assistant/session/tasks streams, show avatar/command, needs-attention and quick actions; bind all taps to typed commands.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Both assistant modes, offline status and genuine task counters on compact/regular device.

### `Features/Dashboard/QuickActionGrid.swift`  [V1]

**Single responsibility:** Editable compact actions and route dispatch.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Stable action IDs, owner-specific ordering and enabled-state checks. Subscribe to verified assistant/session/tasks streams, show avatar/command, needs-attention and quick actions; bind all taps to typed commands.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Both assistant modes, offline status and genuine task counters on compact/regular device.

### `Features/Dashboard/AttentionSummary.swift`  [V1]

**Single responsibility:** High-priority actionable approvals/failures preview.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Sort unresolved severity/age with explicit acknowledge flow. Subscribe to verified assistant/session/tasks streams, show avatar/command, needs-attention and quick actions; bind all taps to typed commands.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Both assistant modes, offline status and genuine task counters on compact/regular device.

### `Features/Dashboard/AssistantHeader.swift`  [V1]

**Single responsibility:** Current assistant name, avatar and operating mode.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Derive status from session not guessed provider readiness. Subscribe to verified assistant/session/tasks streams, show avatar/command, needs-attention and quick actions; bind all taps to typed commands.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Both assistant modes, offline status and genuine task counters on compact/regular device.


## ChatUI (8 items)

Baseline technique: Use paginated owner-scoped message view state and stable IDs; stream partial deltas; send/stop/retry through orchestrator; attachment UI respects capability and privacy.

### `Features/Chat/ChatView.swift`  [V1]

**Single responsibility:** Conversation transcript and composer, streaming text and file actions.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Virtualized LazyVStack, stable message IDs and scroll intent handling. Accessible stable-ID bubble list, text/attachments/voice/stop and actual streamed status; no raw HTML injection.
Use paginated owner-scoped message view state and stable IDs; stream partial deltas; send/stop/retry through orchestrator; attachment UI respects capability and privacy.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Real provider stream, cancel, stale-conversation response suppression and VoiceOver.

### `Features/Chat/ChatViewModel.swift`  [V1]

**Single responsibility:** Turn submission, streaming buffer, voice and cancel UI.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** MainActor reducer of normalized events; avoid UI update each byte. Use paginated owner-scoped message view state and stable IDs; stream partial deltas; send/stop/retry through orchestrator; attachment UI respects capability and privacy.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Real provider stream, cancel, stale-conversation response suppression and VoiceOver.

### `Features/Chat/ChatComposer.swift`  [V1]

**Single responsibility:** Text, voice, image, document and send controls.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Disable sending empty or unsafe payload, attachment readiness state. Use paginated owner-scoped message view state and stable IDs; stream partial deltas; send/stop/retry through orchestrator; attachment UI respects capability and privacy.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Real provider stream, cancel, stale-conversation response suppression and VoiceOver.

### `Features/Chat/MessageBubble.swift`  [V1]

**Single responsibility:** Accessible distinct user/assistant/tool messages.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Role-based rendering, timestamps and provenance/status marker. Use paginated owner-scoped message view state and stable IDs; stream partial deltas; send/stop/retry through orchestrator; attachment UI respects capability and privacy.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Real provider stream, cancel, stale-conversation response suppression and VoiceOver.

### `Features/Chat/ConversationListView.swift`  [V1]

**Single responsibility:** Create, search, pin, archive and resume conversations.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Paginated owner-scoped query and last activity ordering. Use paginated owner-scoped message view state and stable IDs; stream partial deltas; send/stop/retry through orchestrator; attachment UI respects capability and privacy.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Real provider stream, cancel, stale-conversation response suppression and VoiceOver.

### `Features/Chat/ChatAttachmentStrip.swift`  [V1]

**Single responsibility:** File previews, privacy destination and remove-before-send.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Bounded thumbnail rendering and metadata-only previews. Use paginated owner-scoped message view state and stable IDs; stream partial deltas; send/stop/retry through orchestrator; attachment UI respects capability and privacy.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Real provider stream, cancel, stale-conversation response suppression and VoiceOver.

### `Features/Chat/ToolActionCard.swift`  [V1]

**Single responsibility:** Review proposed tool actions and precise execution receipt.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Typed fields, confirmation button and expired-action disable. Use paginated owner-scoped message view state and stable IDs; stream partial deltas; send/stop/retry through orchestrator; attachment UI respects capability and privacy.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Real provider stream, cancel, stale-conversation response suppression and VoiceOver.

### `Features/Chat/StreamingStatusView.swift`  [V1]

**Single responsibility:** Present text-stream, reasoning summary, rate limit and retry states.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** State-driven visibility; distinguish error/partial/finished. Use paginated owner-scoped message view state and stable IDs; stream partial deltas; send/stop/retry through orchestrator; attachment UI respects capability and privacy.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Real provider stream, cancel, stale-conversation response suppression and VoiceOver.


## TasksUI (7 items)

Baseline technique: Expose distinct definition and occurrence data, schedule editor and execution history; show truthful foreground/background status; review before destructive edits.

### `Features/Tasks/TaskDashboardView.swift`  [V1]

**Single responsibility:** Filter today/upcoming/running/completed/failed and approvals.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Responsive list and detail split; segmented status projections. Expose distinct definition and occurrence data, schedule editor and execution history; show truthful foreground/background status; review before destructive edits.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Recurring task creates separate runs and accurate next date; no fake progress.

### `Features/Tasks/TaskDashboardViewModel.swift`  [V1]

**Single responsibility:** Task state aggregation and safe action handlers.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Owner-scoped query, stable sorting, cancellation and dedupe. Expose distinct definition and occurrence data, schedule editor and execution history; show truthful foreground/background status; review before destructive edits.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Recurring task creates separate runs and accurate next date; no fake progress.

### `Features/Tasks/TaskEditorView.swift`  [V1]

**Single responsibility:** Create/edit title, action, priority, trigger, recurrence and consent.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Form validation and next-fire preview before save. Expose distinct definition and occurrence data, schedule editor and execution history; show truthful foreground/background status; review before destructive edits.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Recurring task creates separate runs and accurate next date; no fake progress.

### `Features/Tasks/TaskDetailView.swift`  [V1]

**Single responsibility:** Task definition, each run timeline, logs and artifacts.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Immutable audit event chronology and reversible available actions. Expose distinct definition and occurrence data, schedule editor and execution history; show truthful foreground/background status; review before destructive edits.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Recurring task creates separate runs and accurate next date; no fake progress.

### `Features/Tasks/TaskRunCard.swift`  [V1]

**Single responsibility:** Running/progress/paused/waiting result visualization.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Never invent percentage for unknown-duration external tasks. Expose distinct definition and occurrence data, schedule editor and execution history; show truthful foreground/background status; review before destructive edits.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Recurring task creates separate runs and accurate next date; no fake progress.

### `Features/Tasks/SchedulePicker.swift`  [V1]

**Single responsibility:** Locale-aware date/time/timezone/recurrence UI.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Calendar previews at DST boundaries and recurrence dedupe. Expose distinct definition and occurrence data, schedule editor and execution history; show truthful foreground/background status; review before destructive edits.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Recurring task creates separate runs and accurate next date; no fake progress.

### `Features/Tasks/TaskApprovalStrip.swift`  [V1]

**Single responsibility:** Show pending authorizations and ambiguous recovery cases.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Policy-approved exact action digest and expiry label. Expose distinct definition and occurrence data, schedule editor and execution history; show truthful foreground/background status; review before destructive edits.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Recurring task creates separate runs and accurate next date; no fake progress.


## HistoryUI (5 items)

Baseline technique: Owner-filter history query, separate chat/task/action categories, display provenance/time, require confirmation for permanent deletion.

### `Features/History/HistoryView.swift`  [V1]

**Single responsibility:** Search/filter conversation, task-run, audit and attachment activity.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Tabs/chips and one shared search coordinator. Owner-filter history query, separate chat/task/action categories, display provenance/time, require confirmation for permanent deletion.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Search excludes other users; audit text redacted, deleted content absent.

### `Features/History/HistoryViewModel.swift`  [V1]

**Single responsibility:** Debounced query and stable result pagination.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Task cancellation for stale queries and per-type filtering. Owner-filter history query, separate chat/task/action categories, display provenance/time, require confirmation for permanent deletion.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Search excludes other users; audit text redacted, deleted content absent.

### `Features/History/HistoryResultRow.swift`  [V1]

**Single responsibility:** Source/date/type/trust snippets and open target.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Highlight matched ranges and distinguish AI summaries. Owner-filter history query, separate chat/task/action categories, display provenance/time, require confirmation for permanent deletion.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Search excludes other users; audit text redacted, deleted content absent.

### `Features/History/ActionTimelineView.swift`  [V1]

**Single responsibility:** User-readable safe audit chronology of AI/tool decisions.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Join by traceID without exposing secrets or hidden reasoning. Owner-filter history query, separate chat/task/action categories, display provenance/time, require confirmation for permanent deletion.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Search excludes other users; audit text redacted, deleted content absent.

### `Features/History/HistoryFilterSheet.swift`  [V1]

**Single responsibility:** Date, assistant, type, privacy and provider filters.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Validate ranges, persist UI-only selections and reset control. Owner-filter history query, separate chat/task/action categories, display provenance/time, require confirmation for permanent deletion.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Search excludes other users; audit text redacted, deleted content absent.


## ConfigUI (8 items)

Baseline technique: Bind providers, models, voices, routing and permissions to typed persisted settings; show capability/reason for unavailable options.

### `Features/Configuration/ConfigurationView.swift`  [V1]

**Single responsibility:** Hub for assistant, AI, provider, voice, memory, tools and privacy.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Grouped navigation by behavior rather than app device controls. Bind providers, models, voices, routing and permissions to typed persisted settings; show capability/reason for unavailable options.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Every enabled switch changes actual settings and survives restart; errors visible.

### `Features/Configuration/AIConfigurationView.swift`  [V1]

**Single responsibility:** Fast/Balanced/Deep/Custom mode, preferences and budgets.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Display effective route eligibility and enforce model limits. Bind providers, models, voices, routing and permissions to typed persisted settings; show capability/reason for unavailable options.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Every enabled switch changes actual settings and survives restart; errors visible.

### `Features/Configuration/ProviderListView.swift`  [V1]

**Single responsibility:** Connect/remove BYOK providers, test and display status.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Credential reference only; test call requires explicit user action. Bind providers, models, voices, routing and permissions to typed persisted settings; show capability/reason for unavailable options.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Every enabled switch changes actual settings and survives restart; errors visible.

### `Features/Configuration/ProviderDetailView.swift`  [V1]

**Single responsibility:** Endpoint/model list/usage/secret rotation and diagnostics.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Form HTTPS validation, Keychain write and health-state display. Bind providers, models, voices, routing and permissions to typed persisted settings; show capability/reason for unavailable options.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Every enabled switch changes actual settings and survives restart; errors visible.

### `Features/Configuration/ModelPickerView.swift`  [V1]

**Single responsibility:** Search installed/remote supported models with capability badges.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Filter by hard request features and show stale catalog warning. Bind providers, models, voices, routing and permissions to typed persisted settings; show capability/reason for unavailable options.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Every enabled switch changes actual settings and survives restart; errors visible.

### `Features/Configuration/PrivacyRoutingView.swift`  [V1]

**Single responsibility:** Private/Balanced/Cloud-permitted routing modes.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Show exact data leaving device and explicit cloud consent. Bind providers, models, voices, routing and permissions to typed persisted settings; show capability/reason for unavailable options.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Every enabled switch changes actual settings and survives restart; errors visible.

### `Features/Configuration/VoiceConfigurationView.swift`  [V1]

**Single responsibility:** Assign language, voice, speed and auto-speak per assistant.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Enumerate installed options and preview cancellable playback. Bind providers, models, voices, routing and permissions to typed persisted settings; show capability/reason for unavailable options.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Every enabled switch changes actual settings and survives restart; errors visible.

### `Features/Configuration/ToolPermissionsView.swift`  [V1]

**Single responsibility:** Read/write tool scopes and default approval policy.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Granular permission grant/revoke with consequences preview. Bind providers, models, voices, routing and permissions to typed persisted settings; show capability/reason for unavailable options.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Every enabled switch changes actual settings and survives restart; errors visible.


## SettingsUI (8 items)

Baseline technique: Persist appearance, security, data retention and diagnostic settings; use actual iOS permission state instead of guessed booleans.

### `Features/Settings/SettingsView.swift`  [V1]

**Single responsibility:** Navigate application, device and account settings.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Group security/storage/appearance/permissions/accessibility/about. Persist appearance, security, data retention and diagnostic settings; use actual iOS permission state instead of guessed booleans.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Revoke/regrant flows, relaunch persistence and no user data in logs.

### `Features/Settings/AppearanceSettingsView.swift`  [V1]

**Single responsibility:** Appearance, text scaling and motion preference.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Honor system high contrast, Dynamic Type and Reduce Motion. Persist appearance, security, data retention and diagnostic settings; use actual iOS permission state instead of guessed booleans.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Revoke/regrant flows, relaunch persistence and no user data in logs.

### `Features/Settings/NotificationSettingsView.swift`  [V1]

**Single responsibility:** Notification authorization and per-category choices.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Explain OS denial; open system Settings without nag loops. Persist appearance, security, data retention and diagnostic settings; use actual iOS permission state instead of guessed booleans.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Revoke/regrant flows, relaunch persistence and no user data in logs.

### `Features/Settings/PrivacySettingsView.swift`  [V1]

**Single responsibility:** Review system permissions, cloud disclosure and deletion.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Single-source-of-truth effective policy and revoke controls. Persist appearance, security, data retention and diagnostic settings; use actual iOS permission state instead of guessed booleans.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Revoke/regrant flows, relaunch persistence and no user data in logs.

### `Features/Settings/SecuritySettingsView.swift`  [V1]

**Single responsibility:** App lock, authentication preference and sensitive previews.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Always request LAContext at use site, avoid unprotected screenshots. Persist appearance, security, data retention and diagnostic settings; use actual iOS permission state instead of guessed booleans.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Revoke/regrant flows, relaunch persistence and no user data in logs.

### `Features/Settings/StorageSettingsView.swift`  [V1]

**Single responsibility:** Data counts, retention, exports, safe deletion and index rebuild.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Reference-counted storage inspection, confirmation for destructive actions. Persist appearance, security, data retention and diagnostic settings; use actual iOS permission state instead of guessed booleans.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Revoke/regrant flows, relaunch persistence and no user data in logs.

### `Features/Settings/DiagnosticsView.swift`  [V1]

**Single responsibility:** Connectivity, model, permissions, failures and redacted traces.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Opt-in export and copy sanitized diagnostic bundle. Persist appearance, security, data retention and diagnostic settings; use actual iOS permission state instead of guessed booleans.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Revoke/regrant flows, relaunch persistence and no user data in logs.

### `Features/Settings/AboutView.swift`  [V1]

**Single responsibility:** Version, open-source licenses, privacy policy and legal notices.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Bundle metadata and dependency notices, no unsupported claims. Persist appearance, security, data retention and diagnostic settings; use actual iOS permission state instead of guessed booleans.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Revoke/regrant flows, relaunch persistence and no user data in logs.


## AssistantUI (4 items)

Baseline technique: Create separate Maya/Saar profile editors with validated names, avatar IDs, voice locale and optional routing defaults; transactional saves.

### `Features/Assistant/AssistantProfileView.swift`  [V1]

**Single responsibility:** Edit the independent Maya/Saar identity and behavior.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Validated user-owned fields, per-assistant override scope. Create separate Maya/Saar profile editors with validated names, avatar IDs, voice locale and optional routing defaults; transactional saves.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Rename/switch independently, persist, reject empty/overlong names and owner switch.

### `Features/Assistant/AssistantSwitcher.swift`  [V1]

**Single responsibility:** Switch active assistant from dashboard and chat.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Atomic active ID switch; preserve per-conversation assistant identity. Create separate Maya/Saar profile editors with validated names, avatar IDs, voice locale and optional routing defaults; transactional saves.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Rename/switch independently, persist, reject empty/overlong names and owner switch.

### `Features/Assistant/AssistantNameEditor.swift`  [V1]

**Single responsibility:** Rename either assistant with accessible error messages.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Trim, grapheme-length limit, case preserving and duplicate policy. Create separate Maya/Saar profile editors with validated names, avatar IDs, voice locale and optional routing defaults; transactional saves.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Rename/switch independently, persist, reject empty/overlong names and owner switch.

### `Features/Assistant/AssistantVoicePreview.swift`  [V1]

**Single responsibility:** Preview selected voice without recording microphone.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Speak cancellable sample with per-profile rate and locale. Create separate Maya/Saar profile editors with validated names, avatar IDs, voice locale and optional routing defaults; transactional saves.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Rename/switch independently, persist, reject empty/overlong names and owner switch.


## MemoryUI (4 items)

Baseline technique: Display source, confidence and verification on each memory; require user confirmation before active AI-derived memory, provide edit/delete/conflict resolution.

### `Features/Memory/MemoryBrowserView.swift`  [V1]

**Single responsibility:** Browse saved, inferred, stale, pinned and conflicting facts.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Owner-scoped sections; editable provenance and delete. Display source, confidence and verification on each memory; require user confirmation before active AI-derived memory, provide edit/delete/conflict resolution.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Expired/deleted memories disappear from context and optional index immediately.

### `Features/Memory/MemoryEditorView.swift`  [V1]

**Single responsibility:** Add, verify, correct or expire an individual memory.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Optimistic revision and user-verified promotion. Display source, confidence and verification on each memory; require user confirmation before active AI-derived memory, provide edit/delete/conflict resolution.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Expired/deleted memories disappear from context and optional index immediately.

### `Features/Memory/MemorySourceView.swift`  [V1]

**Single responsibility:** Display source conversation/time/privacy and confidence limitations.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Citation-like source references; mark unavailable/deleted sources. Display source, confidence and verification on each memory; require user confirmation before active AI-derived memory, provide edit/delete/conflict resolution.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Expired/deleted memories disappear from context and optional index immediately.

### `Features/Memory/MemoryReviewQueue.swift`  [V1]

**Single responsibility:** Approve/reject AI-proposed memories.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Default deny auto-admission for sensitive/inferred claims. Display source, confidence and verification on each memory; require user confirmation before active AI-derived memory, provide edit/delete/conflict resolution.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Expired/deleted memories disappear from context and optional index immediately.


## ApprovalsUI (3 items)

Baseline technique: Render exact typed operation, recipient, classified payload summary and expiration, support accept/reject/cancel; no approval on changed digest.

### `Features/Approvals/ApprovalCenterView.swift`  [V1]

**Single responsibility:** Review pending actions and unknown outcomes.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Separate pending, expired, rejected, ambiguous tabs. Render exact typed operation, recipient, classified payload summary and expiration, support accept/reject/cancel; no approval on changed digest.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Approval expires, edits invalidate approval, duplicate tap executes once.

### `Features/Approvals/ApprovalDetailView.swift`  [V1]

**Single responsibility:** Exact destination/scope/payload preview before authorization.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Bind consent to immutable parameter digest and TTL. Render exact typed operation, recipient, classified payload summary and expiration, support accept/reject/cancel; no approval on changed digest.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Approval expires, edits invalidate approval, duplicate tap executes once.

### `Features/Approvals/ApprovalViewModel.swift`  [V1]

**Single responsibility:** Refresh outstanding approvals and resolve decisions.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Serialize decision persistence; reject stale task revisions. Render exact typed operation, recipient, classified payload summary and expiration, support accept/reject/cancel; no approval on changed digest.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Approval expires, edits invalidate approval, duplicate tap executes once.


## OnboardingUI (4 items)

Baseline technique: Seed device-local profile and independent Maya/Saar choices; request privacy/system permissions just-in-time; guide BYOK without storing plaintext outside Keychain.

### `Features/Onboarding/OnboardingView.swift`  [V1]

**Single responsibility:** First-launch assistant, locale, privacy and provider walkthrough.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Skippable advanced setup, honest offline/core capability description. Seed device-local profile and independent Maya/Saar choices; request privacy/system permissions just-in-time; guide BYOK without storing plaintext outside Keychain.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Skip optional provider and still launch offline; onboarding resumable after force quit.

### `Features/Onboarding/LocalProfileSetup.swift`  [V1]

**Single responsibility:** Create one local individual profile on device.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Random stable ID and separate data namespace, no fake cloud account. Seed device-local profile and independent Maya/Saar choices; request privacy/system permissions just-in-time; guide BYOK without storing plaintext outside Keychain.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Skip optional provider and still launch offline; onboarding resumable after force quit.

### `Features/Onboarding/ProviderSetupView.swift`  [V1]

**Single responsibility:** Add personal BYOK credentials or continue local-only.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Use Keychain; explicit endpoint and external-data disclosure. Seed device-local profile and independent Maya/Saar choices; request privacy/system permissions just-in-time; guide BYOK without storing plaintext outside Keychain.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Skip optional provider and still launch offline; onboarding resumable after force quit.

### `Features/Onboarding/PermissionEducationView.swift`  [V1]

**Single responsibility:** Explain just-in-time microphone/speech/notification usage.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** No blanket permission prompt; configure OS capabilities on first use. Seed device-local profile and independent Maya/Saar choices; request privacy/system permissions just-in-time; guide BYOK without storing plaintext outside Keychain.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Skip optional provider and still launch offline; onboarding resumable after force quit.


## Integrations (6 items)

Baseline technique: Check runtime API and per-entity permissions; encapsulate EventKit/Contacts/URL launches behind protocols and ToolPolicy; never assume availability.

### `Integrations/IntegrationRegistry.swift`  [V1]

**Single responsibility:** List native and future cloud integrations by capability.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Installed/permissioned/connected effective-state query. Check runtime API and per-entity permissions; encapsulate EventKit/Contacts/URL launches behind protocols and ToolPolicy; never assume availability.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Denied access, revoked mid-task, duplicate write and unsupported framework paths.

### `Integrations/CalendarAdapter.swift`  [V1]

**Single responsibility:** Bridge EventKit event create/read/delete permission checks.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Typed EventKit conversion and durable event IDs. Check runtime API and per-entity permissions; encapsulate EventKit/Contacts/URL launches behind protocols and ToolPolicy; never assume availability.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Denied access, revoked mid-task, duplicate write and unsupported framework paths.

### `Integrations/ContactsAdapter.swift`  [V1]

**Single responsibility:** Read only narrowly requested local contact fields.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Minimum-field request and private-data disclosure policy. Check runtime API and per-entity permissions; encapsulate EventKit/Contacts/URL launches behind protocols and ToolPolicy; never assume availability.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Denied access, revoked mid-task, duplicate write and unsupported framework paths.

### `Integrations/RemindersAdapter.swift`  [V1]

**Single responsibility:** Bridge EventKit Reminders when enabled, separate from local notifications.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Per-item unique IDs and authorization status. Check runtime API and per-entity permissions; encapsulate EventKit/Contacts/URL launches behind protocols and ToolPolicy; never assume availability.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Denied access, revoked mid-task, duplicate write and unsupported framework paths.

### `Integrations/ShortcutsBridge.swift`  [V1]

**Single responsibility:** Represent reusable app actions for future App Intents.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** No assumption Shortcuts registration works in .swiftpm; app command reuse. Check runtime API and per-entity permissions; encapsulate EventKit/Contacts/URL launches behind protocols and ToolPolicy; never assume availability.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Denied access, revoked mid-task, duplicate write and unsupported framework paths.

### `Integrations/URLLauncher.swift`  [V1]

**Single responsibility:** Dispatch allowlisted URLs to system app handlers.

**Inputs/outputs and dependencies:** Inputs: owner/session, repository state, user action or platform event as appropriate. Outputs: typed result/state or recoverable error. Domain types; AppContainer-provided protocols; native Apple framework only inside adapter.

**Required algorithm/design:** Can-open check + explicit UI initiation; do not assert app takeover. Check runtime API and per-entity permissions; encapsulate EventKit/Contacts/URL launches behind protocols and ToolPolicy; never assume availability.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Denied access, revoked mid-task, duplicate write and unsupported framework paths.


## CloudFuture (10 items)

Baseline technique: Do not compile or enable in V1 runtime. Define versioned Auth, Firestore owner scoping, encrypted Drive backup or authenticated gateway contract; server validation is separate.

### `Cloud/Auth/AppleSignInClient.swift`  [NEXT]

**Single responsibility:** Later Sign in with Apple account identity handoff.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Nonce/state and token verifier on backend; not trust client-supplied UID. Do not compile or enable in V1 runtime. Define versioned Auth, Firestore owner scoping, encrypted Drive backup or authenticated gateway contract; server validation is separate.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Future-specific integration tests specified; V1 gate ensures no enabled dead UI and no secret shipping.

### `Cloud/Auth/AccountSession.swift`  [NEXT]

**Single responsibility:** Server-verified user session and reauthentication state.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Expiring token refresh and secure cross-account invalidation. Do not compile or enable in V1 runtime. Define versioned Auth, Firestore owner scoping, encrypted Drive backup or authenticated gateway contract; server validation is separate.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Future-specific integration tests specified; V1 gate ensures no enabled dead UI and no secret shipping.

### `Cloud/Sync/SyncService.swift`  [NEXT]

**Single responsibility:** Interface for account-scoped outbox and cursor changes.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Retry-safe upsert, revisions, tombstones and conflict record. Do not compile or enable in V1 runtime. Define versioned Auth, Firestore owner scoping, encrypted Drive backup or authenticated gateway contract; server validation is separate.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Future-specific integration tests specified; V1 gate ensures no enabled dead UI and no secret shipping.

### `Cloud/Sync/FirestoreSyncAdapter.swift`  [NEXT]

**Single responsibility:** Per-user encrypted/authorized document sync.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Enforce authenticated uid and narrow security rules, not local owner alone. Do not compile or enable in V1 runtime. Define versioned Auth, Firestore owner scoping, encrypted Drive backup or authenticated gateway contract; server validation is separate.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Future-specific integration tests specified; V1 gate ensures no enabled dead UI and no secret shipping.

### `Cloud/Sync/ConflictResolver.swift`  [NEXT]

**Single responsibility:** Resolve immutable messages and mutable task/settings conflicts.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Per-entity merge policy, tombstones, user review for destructive conflict. Do not compile or enable in V1 runtime. Define versioned Auth, Firestore owner scoping, encrypted Drive backup or authenticated gateway contract; server validation is separate.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Future-specific integration tests specified; V1 gate ensures no enabled dead UI and no secret shipping.

### `Cloud/Backup/GoogleDriveBackup.swift`  [NEXT]

**Single responsibility:** AppDataFolder ciphertext upload/download only.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** OAuth PKCE drive.appdata, versioned archive and checksum. Do not compile or enable in V1 runtime. Define versioned Auth, Firestore owner scoping, encrypted Drive backup or authenticated gateway contract; server validation is separate.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Future-specific integration tests specified; V1 gate ensures no enabled dead UI and no secret shipping.

### `Cloud/Backup/BackupArchive.swift`  [NEXT]

**Single responsibility:** Cross-device encrypted export manifest and restore dry run.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Random portable recovery key, AES-GCM + authenticated schema/version. Do not compile or enable in V1 runtime. Define versioned Auth, Firestore owner scoping, encrypted Drive backup or authenticated gateway contract; server validation is separate.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Future-specific integration tests specified; V1 gate ensures no enabled dead UI and no secret shipping.

### `Cloud/Gateway/ManagedGatewayClient.swift`  [NEXT]

**Single responsibility:** Authenticate client to future secret-holding gateway.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** User-bound short-lived token, quotas and provider-independent HTTP contract. Do not compile or enable in V1 runtime. Define versioned Auth, Firestore owner scoping, encrypted Drive backup or authenticated gateway contract; server validation is separate.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Future-specific integration tests specified; V1 gate ensures no enabled dead UI and no secret shipping.

### `Cloud/Gateway/WorkerPolicy.ts`  [NEXT]

**Single responsibility:** Optional Cloudflare Worker authentication, abuse protection and quota.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Verify bearer token server-side, per-user budget and egress allowlist. Do not compile or enable in V1 runtime. Define versioned Auth, Firestore owner scoping, encrypted Drive backup or authenticated gateway contract; server validation is separate.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Future-specific integration tests specified; V1 gate ensures no enabled dead UI and no secret shipping.

### `Cloud/Gateway/GatewayDeployment.md`  [NEXT]

**Single responsibility:** Manual deployment and rollback instructions.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Secrets never committed; isolate dev/prod routes and audit logging. Do not compile or enable in V1 runtime. Define versioned Auth, Firestore owner scoping, encrypted Drive backup or authenticated gateway contract; server validation is separate.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Future-specific integration tests specified; V1 gate ensures no enabled dead UI and no secret shipping.


## Tests (28 items)

Baseline technique: Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

### `Tests/Unit/DomainStateMachineTests.swift`  [TEST]

**Single responsibility:** Verify legal/illegal task, conversation and approval transitions.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Property/table-driven state transition fixtures. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/Unit/RouterPolicyTests.swift`  [TEST]

**Single responsibility:** Check capability, privacy, offline, budget and fallback filters.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Exhaustive policy matrix including zero eligible routes. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/Unit/SSEDecoderTests.swift`  [TEST]

**Single responsibility:** Test streaming split-chunk parsing and tool delta reconstruction.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Random chunk boundaries, multiline SSE and truncated EOF. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/Unit/ContextBudgetTests.swift`  [TEST]

**Single responsibility:** Verify source order, dedup, no cross-owner memory and reserves.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Boundary tests for provider context and false token metadata. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/Unit/MemoryConflictTests.swift`  [TEST]

**Single responsibility:** Verified/unverified, TTL and contradictory memory rules.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Version precedence, expiry and provenance preservation. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/Unit/TaskSchedulerTests.swift`  [TEST]

**Single responsibility:** Recurrence/DST/timezone/missed-execution behavior.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Fixed calendar fixtures including ambiguous/nonexistent clock times. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/Unit/ToolPolicyTests.swift`  [TEST]

**Single responsibility:** Authorize/disallow granular tool scopes and prompt injection.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Untrusted-document malicious instruction fixture. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/Unit/KeychainVaultTests.swift`  [TEST]

**Single responsibility:** Store/read/delete/rotation and account namespace isolation.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Device-keychain integration tests with cleanup. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/Unit/AttachmentValidationTests.swift`  [TEST]

**Single responsibility:** Reject oversize, spoofed MIME and unsafe filenames.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Corrupt image, PDF and pathological archive fixtures. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/Unit/VoiceStateTests.swift`  [TEST]

**Single responsibility:** Test interruptions and stale transcript suppression.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Synthetic interim/final sequence and stop races. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/Unit/SearchRankingTests.swift`  [TEST]

**Single responsibility:** Rank exact/recency results and enforce owner scope.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Deterministic search fixtures and deleted-item exclusion. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/Unit/CryptoBackupTests.swift`  [TEST]

**Single responsibility:** AES-GCM encrypt/verify/wrong key/modified data.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Golden fixture and cross-device recovery round trip. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/Integration/MockProviderFlowTests.swift`  [TEST]

**Single responsibility:** Full streaming chat with fake provider and cancellation.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Exact event order, partial output and final storage. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/Integration/ProviderFailureTests.swift`  [TEST]

**Single responsibility:** 401/429/5xx/offline, breaker and no privacy-leaking fallback.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Recorded mock HTTP responses and Retry-After assertions. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/Integration/TaskCrashRecoveryTests.swift`  [TEST]

**Single responsibility:** App interrupted after PREPARED external action.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** No duplicate execution; ambiguous outcome routed to review. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/Integration/AccountIsolationTests.swift`  [TEST]

**Single responsibility:** Switch account while search/AI/task is in flight.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Abort stale work and assert zero other-user data in UI/index. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/Integration/StoreMigrationTests.swift`  [TEST]

**Single responsibility:** Migrate preserved old database fixture.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** No data loss, rollback and readable recovery export. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/Integration/PermissionMatrixTests.swift`  [TEST]

**Single responsibility:** Denied/authorized/restricted/revoked system capabilities.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Mock services and manual device permission revocation. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/Integration/MemoryPersistenceTests.swift`  [TEST]

**Single responsibility:** Verify memory source editing/deletion and search index removal.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** CRUD-to-index reconciliation under failure. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/Integration/AccessibilityTests.swift`  [TEST]

**Single responsibility:** Dynamic Type, VoiceOver labels and Reduce Motion.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** UI test cases on phone/tablet with manual screen reader pass. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/E2E/ManualDeviceChecklist.md`  [TEST]

**Single responsibility:** Script actual iPad Playground import and iPhone distribution test.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Record hardware/OS/Playgrounds versions and evidenced results. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/E2E/HindiHinglishVoiceCorpus.md`  [TEST]

**Single responsibility:** Human-recorded consented Hindi/Hinglish/English commands.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Locale-specific recognition/error and playback comprehension rubric. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/E2E/ThreatAndPrivacyChecklist.md`  [TEST]

**Single responsibility:** Prompt injection, exfiltration, secret logs and deletion audit.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Manual red team plus test fixtures; record negative evidence. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/E2E/ReleaseAcceptance.md`  [TEST]

**Single responsibility:** All release criteria, blockers and bug severity gates.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Check with build/device evidence; no fabricated passes. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/Fixtures/MockProviderEvents.jsonl`  [TEST]

**Single responsibility:** Deterministic mixed text/tool/usage/SSE error streams.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Versioned fixtures for unit/integration suite. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/Fixtures/MigrationV1Fixture.json`  [TEST]

**Single responsibility:** Known populated baseline DB generation metadata.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Cross-version expected record counts and relationships. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/Fixtures/PromptInjectionSamples.txt`  [TEST]

**Single responsibility:** Untrusted web/document/email attack snippets.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Assert tools cannot inherit authority from source text. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.

### `Tests/Fixtures/TaskSchedulingCases.json`  [TEST]

**Single responsibility:** DST, timezone, leap date and multiple recurrence cases.

**Inputs/outputs and dependencies:** Inputs: v2 canonical contracts and fixtures. Output: independent documentation, test evidence, or post-V1 interface only. The versioned canonical schema/contract; do not duplicate ownership in another file.

**Required algorithm/design:** Expected UTC instants and nonexistence handling. Build mock clock/UUID/HTTP/store fixtures and assert exact observable state and errors; manual device cases record evidence, never fabricate PASS.

**Negative paths:** Deny unsupported capability and invalid state; surface typed error, preserve previous durable data and avoid leaking prior owner information. For non-executable artifacts verify schema/path/resources instead.

**Proof/acceptance:** Case runs independently; expected/actual evidence captured; zero unexplained skips on release blockers.
