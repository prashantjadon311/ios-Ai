# R2 Current Source Truth & Reality Reconciliation

**Date:** 2026-09-26  
**Host Environment:** Linux x86_64 (Ubuntu)  
**Host Toolchain:** Swift: `NOT_FOUND`, Xcode: `NOT_FOUND`, Apple iOS SDK: `NOT_AVAILABLE`  
**Git Baseline Commit:** `5905602c5c504d1d6f9d3a140edc790b77c2cb2f` (`Third`)  
**Target Package:** `PersonalAssistant.swiftpm` (`AppModule`, iOS 18.6 deployment target)  

---

## 1. Actual Source State at Commit 5905602

An objective physical file audit of commit `5905602` reveals the following ground reality:

### 1.1 Zero-Byte Files Found
Two Swift files in `PersonalAssistant.swiftpm` are physically empty (0 bytes):
1. `PersonalAssistant.swiftpm/AI/Context/ContextBuilder.swift` (0 bytes)
2. `PersonalAssistant.swiftpm/AI/Context/MemoryProposalEngine.swift` (0 bytes)

*(Note: Prior claims of "0 zero-byte files" in historical checkpoints are hereby explicitly corrected).*

### 1.2 Concrete Source Defects Verified
1. **P0-01 (AppContainer/AssistantOrchestrator Initializer Mismatch):** `AppContainer.swift` line 88 passes `configurationRepository: configRepo`, but `AssistantOrchestrator.swift` does not accept this parameter in `init`.
2. **P0-02 (AdaptiveLayout View Constructors Mismatch):** `AdaptiveLayout.swift` calls `DashboardView(viewModel:)`, `TaskDashboardView(viewModel:)`, `HistoryView(viewModel:)`, and `SettingsView(viewModel:)`. None of these views declare such an initializer; each owns its view model via `@State` and creates it from `@Environment(AppContainer.self)`.
3. **P0-03 (ModelRouter Cross-File & Concurrency Defects):**
   - Redeclared `private extension ProviderConfiguration { var id: ProviderConfigID { self.id } }` causes ambiguous symbol collision.
   - Synchronous filter invokes `keychainVault.hasSecret(...)` which is actor-isolated and requires `await`.
   - Provider lookup indexes `providers` dictionary by `config.id.rawValue.uuidString` while providers register with string keys (`"groq"`, `"openRouter"`), causing all lookups to fail.
   - Missing `privacyMode` check.
4. **P0-04 (AssistantOrchestrator Stub):** `AssistantOrchestrator.executeTurn` only emits simulated `.started` and `.completed` without calling `ModelRouter.route`, streaming through providers, assembling context, or persisting messages.
5. **P0-05 (ApprovalCoordinator Contract & Authorization Defects):**
   - References `req.sessionToken`, `req.canonicalArguments`, and `generationID`, none of which are properties on `ApprovalRequest` or `SessionToken` (`SessionToken` uses `generation: UUID`).
   - `approve` uses optional `expectedPayloadHash: Data? = nil` and `currentSession: SessionToken? = nil`, allowing fail-open authorization without verifying payloads or sessions.
6. **P0-06 (In-Memory ToolReceiptStore):** `ToolReceiptStore.swift` stores receipts solely in an in-memory dictionary `[UUID: ToolReceipt]`, which fails Algorithm B05 crash-safety requirements.
7. **P0-07 (Privacy Controls Not Enforced at Transport):** `ModelRouter.swift` and `HTTPClient.swift` do not enforce `privacyMode == .privateOnly` egress boundaries.
8. **P0-08 (AppSession Preference Overwrite):** `AppSession.setActiveAssistant` re-instantiates `AppPreference(ownerID: owner.id, activeAssistantID: assistant.id)`, wiping custom privacy modes, consents, appearance, and locales.
9. **P0-09 (ChatView & Dashboard Input Discard):**
   - `ChatView.swift` passes `conversationID ?? ConversationID()` into `container.makeChatViewModel(...)`, causing new conversations to be treated as existing missing conversations.
   - `DashboardViewModel.onAsk(text:)` creates a conversation and opens chat but discards the entered text.
10. **P0-10 (Provider Setup Failure):** `ProviderDetailView.swift` uses `try?` on Keychain write and announces success without creating or enabling a `ProviderConfiguration`.
11. **P1-01 (Avatar Assets Missing):** `Resources/Assets.xcassets/Maya.imageset` and `Saar.imageset` only have placeholder `Contents.json` without actual image files.
12. **P1-02 (Task Occurrence Identity):** `TaskScheduler.swift` generates random UUIDs for occurrences instead of deterministic composite keys (`taskID` + `definitionRevision` + UTC scheduled instant).
13. **P1-03 (Tool ID Discrepancy):** `ToolRegistry.swift` registers camelCase tool IDs (`createReminder`, `createCalendarEvent`, `openURL`) while concrete tools declare snake_case IDs (`create_reminder`, `calendar_create`, `open_url`).
14. **P1-04 (Attachment Data Loss):** `AttachmentLifecycle.swift` writes to `caches` directory and purges files older than 24h regardless of active message references.

---

## 2. Remediation Strategy & Gate Execution Order

- **Gate R1:** Compilation & Contract Foundations (Resolve P0-01, P0-02, P0-03, P0-05, P0-08, restore `ContextBuilder.swift` and `MemoryProposalEngine.swift`).
- **Gate R2:** Working AI Chat Vertical Slice (Resolve P0-04, P0-07, P0-09, P0-10, implement genuine streaming turn with Algorithm B03).
- **Gate R3:** Security, Storage & Recovery (Resolve P0-06, P1-03, implement durable SwiftData-backed `ToolReceiptStore`, single-use `AuthorizedToolCall`, fail-closed privacy boundary).
- **Gate R4:** Complete Tasks, Voice, Memory & Avatars (Resolve P1-01, P1-02, P1-04, wire `VoiceCoordinator` audio buffer flow, deterministic occurrence keys, durable attachment storage).
- **Gate R5:** Executable Test Suite, CI Workflow & iPad Shipping Package.
