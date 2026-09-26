# R1 Source Truth Audit — Commit 37d30503 Baseline

**Date:** 2026-09-26  
**Auditor / Engineer:** Principal iOS/Swift 6 and AI Systems Engineer  
**Workspace:** `/home/thakur/projects/git/AI-Other/ios/ios-Ai`  
**Git HEAD:** `37d30503e59513c3063a6309f9ceb711ce7c96ba` (`Second`)  
**Remote origin/main:** `37d30503e59513c3063a6309f9ceb711ce7c96ba`  
**Host Environment:** Linux x86_64, Swift `NOT_FOUND`, Xcode `NOT_FOUND`  

---

## 1. R0 Mandatory Baseline Command Execution

```bash
$ pwd
/home/thakur/projects/git/AI-Other/ios/ios-Ai

$ git remote -v
origin  git@github.com:prashantjadon311/ios-Ai.git (fetch)
origin  git@github.com:prashantjadon311/ios-Ai.git (push)

$ git branch --show-current
main

$ git rev-parse HEAD
37d30503e59513c3063a6309f9ceb711ce7c96ba

$ git rev-parse origin/main
37d30503e59513c3063a6309f9ceb711ce7c96ba

$ git status --short
?? docs/implementation/audit/01_ENGINEERING_REAUDIT.md
?? docs/implementation/audit/02_GEMINI_ANTIGRAVITY_NEXT_PROMPT.md

$ find PersonalAssistant.swiftpm -name '*.swift' -type f -size 0 -print
PersonalAssistant.swiftpm/AI/Context/TokenBudget.swift
PersonalAssistant.swiftpm/AI/Transport/RetryPolicy.swift

$ find docs/implementation scratch -type f -size 0 -print
docs/implementation/R0_SOURCE_RECONCILIATION.md
scratch/verify_matrix.py
```

### Physical File Inventory at HEAD `37d30503`
- Total Swift files: 187
- Non-empty Swift files: 185
- **Zero-byte Swift files (2):**
  - `PersonalAssistant.swiftpm/AI/Context/TokenBudget.swift`
  - `PersonalAssistant.swiftpm/AI/Transport/RetryPolicy.swift`
- **Zero-byte documentation/tool files (2):**
  - `docs/implementation/R0_SOURCE_RECONCILIATION.md`
  - `scratch/verify_matrix.py`

---

## 2. Re-Audit Finding Matrix (Comparing Source at `37d30503` to `01_ENGINEERING_REAUDIT.md`)

| Defect # | Category | Summary Description | Status | Evidence in Code |
|---|---|---|---|---|
| **P0-01** | Architecture / SwiftUI | `AppContainer` removed `@Observable` while injected with `.environment(container)` | **STILL_PRESENT** | `AppContainer.swift:9` has `@MainActor final class AppContainer` without `@Observable` |
| **P0-02** | DI / AppContainer | `makeChatViewModel` parameter mismatch and missing orchestrator/router instances | **STILL_PRESENT** | `AppContainer.swift:58-66` passes 5 args; no `AssistantOrchestrator` or `ModelRouter` in container |
| **P0-03** | Compilation / Symbols | Duplicate global SwiftUI views in `ConfigurationView.swift` colliding with dedicated files | **STILL_PRESENT** | `ConfigurationView.swift:72-120` declares `PrivacyRoutingView`, `ProviderListView`, etc. |
| **P0-04** | Compilation / Navigation | `AdaptiveLayout.swift` instantiates `View(viewModel:)` on views with parameterless inits | **STILL_PRESENT** | `AdaptiveLayout.swift:33,39,45,57` calls `DashboardView(viewModel:)`, but `DashboardView.swift:10` has `@State private var viewModel: DashboardViewModel?` |
| **P0-05** | Domain DTO Alignment | `ContextMessage(provenanceHash:)`, `toolResult` 3 args, `MessageRecord` missing fields | **STILL_PRESENT** | `ContextBuilder.swift:20,30,45,53` pass `provenanceHash: nil`; `ChatViewModel.swift:150-157` missing `source` and `sequenceNumber` |
| **P0-06** | Domain Symbols | `AssistantProfile.avatarType/name/voiceIdentifier`, `PrivacyMode.standard` | **STILL_PRESENT** | `AssistantProfileView.swift:13,15,17` uses `.avatarType`, `.name`, `.voiceIdentifier`; `PrivacyRoutingView.swift:5` uses `.standard` |
| **P0-07** | Task Model Divergence | `TaskDefinition.scheduleTime`, `TaskScheduler.recurrenceRule`, String occurrence key | **STILL_PRESENT** | `TaskEngineActor.swift:31` uses `.scheduleTime`; `TaskScheduler.swift:18` uses `.recurrenceRule` and returns `String` key |
| **P0-08** | Tool & Error Enum | `ToolReceiptStatus.completed`, `AppError.sideEffectAmbiguous(operation:)`, `privacyDenied(reason:)` | **STILL_PRESENT** | `ToolInvocationCoordinator.swift:33,37` writes `.completed` and calls `sideEffectAmbiguous(operation:)`; `LegacySpeechRecognizer.swift:20` calls `unsupportedCapability(name:)` |
| **P0-09** | Media / Persistence | `AttachmentValidator.validate(expectedMime:)`, `StoredAttachment` absent from `StoreModels` | **STILL_PRESENT** | `AttachmentProcessor.swift:9` calls `expectedMime:`; `AttachmentRepository.swift:19` references undeclared `StoredAttachment` |
| **P0-10** | Domain Symbols | `MemoryProposalEngine.swift` passes nonexistent `scope: .general` to `MemoryItem` | **STILL_PRESENT** | `MemoryProposalEngine.swift:14` passes `scope: .general`; `MemoryItem.swift:45` hardcoded `self.isDeleted = false` (now fixed) |
| **P0-11** | AI Execution | `AssistantOrchestrator.swift` is a placeholder emitting fake immediate completion | **STILL_PRESENT** | `AssistantOrchestrator.swift:33-42` yields dummy `.started` and `.completed` without streaming or routing |
| **P0-12** | Model Routing | Recursive `ProviderConfiguration.id` extension & synchronous Keychain actor access | **STILL_PRESENT** | `ModelRouter.swift:36-40` has synchronous `keychainVault.hasSecret` call and recursive extension |
| **P0-13** | Provider / BYOK | Hardcoded model strings, unpersisted model picker, unparsed tool fragments | **STILL_PRESENT** | `OpenAICompatibleProvider.swift:150` hardcodes `"llama-3.3-70b-versatile"` |
| **P0-14** | Tool Durability | In-memory `ToolReceiptStore`, non-durable receipt across restarts | **STILL_PRESENT** | `ToolReceiptStore.swift:8` has `private var receipts: [UUID: ToolReceipt] = [:]` in memory only |
| **P0-15** | Approvals | `ApprovalCoordinator` returns `ApprovalRequest` not `AuthorizedToolCall`, lacks TTL/expiry | **STILL_PRESENT** | `ApprovalCoordinator.swift:14` returns `ApprovalRequest` without issuing scoped `AuthorizedToolCall` |
| **P0-16** | Privacy Boundary | `PrivacyRoutingView` changes only local `@State`; no persistent egress check | **STILL_PRESENT** | `PrivacyRoutingView.swift:5` binds local state only; `PrivacyPolicyEngine.swift:12` references `.standard` |
| **P0-17** | Session Isolation | Repositories accept `SessionToken` without checking current generation | **STILL_PRESENT** | Async calls across views do not re-verify generation on resumption |
| **P0-18** | BYOK Vault | `ProviderDetailView` hides Keychain write errors behind `try?` | **STILL_PRESENT** | `ProviderDetailView.swift` displays "Key saved securely" without checking write result |
| **P0-19** | Transport Security | Minimal IP prefix checks, no redirect Authorization header stripping | **STILL_PRESENT** | `URLSafety.swift` checks only 5 literal IPs and 2 prefixes; `HTTPClient` lacks redirect delegate |
| **P0-20** | Biometrics / Lock | `BiometricGate` returns `true` on unsupported platform; `isLocked` unenforced | **STILL_PRESENT** | `BiometricGate.swift:20` returns `true` in `#else` fallback; `RootNavigationView` does not gate on `session.isLocked` |

---

## 3. Correction of Previous Status & PASS Claims

The previous implementation checkpoint claimed 46/46 PASS based on a pattern-matching script that was never committed (it remained a zero-byte file in commit `37d30503`).
- **Correction:** Those 46 cases are formally reclassified as:
  - **STATIC_CHECK_ONLY:** Syntax, bracket balancing, and documentation validation.
  - **SOURCE_INFERRED / NOT_RUN:** Logic requiring real Swift type checking, SwiftUI rendering, SwiftData runtime, or hardware audio engine.
  - **FAIL:** Contracts with confirmed compiler-blocking symbol mismatches (P0-01 through P0-10).

---

## 4. First Unfixed Dependency & Execution Roadmap

The first unfixed dependency is **Gate R1: Compile-Correctness Gate**.
No product features or vertical slice runs can succeed while the core dependency root (`AppContainer`), navigation (`AdaptiveLayout`), and domain DTO references contain type-incompatible signatures.

**R1 Immediate Action Order:**
1. Restore `@Observable` to `AppContainer.swift` and construct/expose `httpClient`, `modelRouter`, `assistantOrchestrator`.
2. Fix `AppContainer.makeChatViewModel` to inject live orchestrator and configuration repository.
3. Remove duplicate placeholder SwiftUI views from `ConfigurationView.swift`.
4. Reconcile primary screen constructors in `AdaptiveLayout.swift` with parameterless `View()` initializers.
5. Align `ContextMessage`, `ContentPart.toolResult`, and `MessageRecord` across `ContextBuilder.swift` and `ChatViewModel.swift`.
6. Fix invalid symbols in `AssistantProfileView.swift`, `PrivacyRoutingView.swift`, and `PrivacyPolicyEngine.swift`.
7. Align task models in `TaskEngineActor.swift`, `TaskScheduler.swift`, `TaskRecurrence.swift`, and `TaskDetailView.swift`.
8. Align tool and error enums in `ToolInvocationCoordinator.swift`, `ToolReceiptStatus`, and `LegacySpeechRecognizer.swift`.
9. Reconcile `AttachmentValidator` argument label and `AttachmentRepository`.
10. Populate 0-byte files `AI/Context/TokenBudget.swift` and `AI/Transport/RetryPolicy.swift`.
