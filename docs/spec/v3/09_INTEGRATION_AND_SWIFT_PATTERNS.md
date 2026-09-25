# 09 — Cross-module implementation wiring and Swift pattern guide

## Bootstrap and injection
`PersonalAssistantApp` constructs `StoreBootstrap`, then `AppContainer(store, clock, randomID, keychain, http, platformAdapters)`. `AppSession` is the single observable `@MainActor` source of active owner/assistant and lock state. Scene uses Environment of typed view models, not mutable global `shared` singletons. No network request or microphone permission in `init`.

## Domain → data → views dependency direction
- Domain contains only value DTOs and pure validation, no `SwiftUI`, `SwiftData`, `URLSession` or `AVFoundation` imports.
- Persistence knows Domain and SwiftData, never SwiftUI. Repositories map into domain values before actors/threads exchange data.
- Security knows Domain and platform local authentication/Keychain adapter; policy checks are pure whenever possible.
- AI contracts know Domain only. Providers depend on contracts + HTTP transport, never SwiftUI or Tools executor.
- Orchestrator composes AI routing, context, Tools policy, repository and voice output event sink; it never imports provider-specific wire JSON.
- UI view models invoke `ApplicationCommandBus`, owner-scoped repositories and event streams. Views contain layout, accessibility and user actions only.

## Exact app commands
`startConversation(assistantID, ownerID)`, `sendMessage(conversationID, text, attachments)`, `cancelTurn(traceID)`, `switchAssistant(assistantID)`, `createTask(definitionDraft)`, `approveAction(approvalID, decision)`, `renameAssistant(assistantID, name)`, `changeProvider(configuration)`, `startVoice(locale)`, `stopVoice()`, `exportLocalData()`; all dispatch from active `AppSession` generation.

## Chat transaction boundaries
Create pending user message in DB; no outgoing provider call until commit success. Reserve AI budget, store invocation trace, begin async event stream. UI displays events only if current trace + user + conversation. On network failure persist status and partial response; retry generates a NEW trace retaining original failed event for audit. On account switch all old pending callbacks fail session generation validation even if cancellation is late.

## Schema records and relationships
Only StoreModels defines `@Model` classes for LocalUser, StoredAssistant, StoredConversation, StoredMessage, StoredAttachment, StoredTaskDefinition, StoredTaskRun, StoredTaskStep, StoredApproval, StoredMemory, StoredProviderConfig, StoredToolReceipt, StoredAuditEvent. Each has stable UUID/string owner and timestamps. Relationships use explicit deletion rules and guarded deletion transactions; do not cascade deletion into another owner; avoid tight cyclic SwiftData relationships. Keychain material has opaque reference ID only in StoredProviderConfig.

## Adaptive screen view models
`DashboardViewModel`: active assistant and real avatar status, today task query and approvals count, latest histories. `ChatViewModel`: paginated transcript, send/cancel, attachment picker state and streaming partial, stable conversation ID. `TaskDashboardViewModel`: aggregate pending/running/needsApproval/completed states from run repository, draft editor and details. `HistoryViewModel`: lexical owner-filtered search and categorized results. `ConfigurationViewModel`: provider test, model capabilities, routing and assistant profile overrides. `SettingsViewModel`: permissions from platform, local profile lock and retention, diagnostics and privacy indicators. Don't fetch all account data for Dashboard just to count tasks; repository supports bounded aggregate query.

## Error and empty states
Every remote action starts disabled until credentials/capabilities available; every async screen renders loading, ready, empty, offline, permissionRequired or typed error. Missing permission must show exact settings path/action available to user rather than a blank screen. A selected assistant’s unsupported locale/voice should fall back to user-selectable installed voice rather than silently invent a voice ID.

## Asset schema
`Resources/Assets.xcassets` contains two distinct built-in avatar image sets and a default app icon from actual artwork under appropriate rights. Avatar ID is a stable logical string and not identical to gender or speech voice; users may rename freely. Localizations `en.lproj` and `hi.lproj` cover main navigation, privacy consent, error descriptions and VoiceOver names. Prompt templates remain plain text resources with IDs/versions and exclude users' personal data.

## Future backend boundary
V1 ships local-only independent users; no inference that login or cloud sync exists. Define protocol in separate future/cloud target: `authenticateWithApple`, `pullChanges(cursor)`, `pushChanges(batch)`, `uploadEncryptedBackup(archive)`, `getBudget()`; actual Firestore rules use authenticated UID matching user namespace and emulator tests, actual Google Drive backup must be encrypted independently of server. These futures never become compile dependencies for the V1 Swift Playground target.
