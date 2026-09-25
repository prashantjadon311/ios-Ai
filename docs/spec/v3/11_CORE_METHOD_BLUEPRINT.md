# 11 — Concrete core-file method blueprint and invariants

**Purpose:** supplement the 266-item ownership guide with method-level entry points for the highest-risk modules. These are **design-level Swift signatures**, not tested compiler output. Sonnet must use local SDK autocomplete/compiler at W00 only to correct platform method spelling; behavior must remain fixed. The 266-file ledger specifies all other files and their tests.

## App / platform composition
### `App/AppContainer.swift`
- `init(store: LocalStore, clock: Clock, idGenerator: IDGenerator, network: HTTPClient, platform: PlatformServices)` wires exactly one repository instance per store and one actor per stateful service. Do not instantiate or launch services in SwiftUI body.
- `makeDashboardViewModel(session:)`, `makeChatViewModel(conversationID:session:)`, `makeTasksViewModel(session:)` inject restricted capability protocols, not raw key vault and provider network into views.
- `makePreviewContainer()` uses in-memory SwiftData, fake clock, mock provider and no actual user secrets. Preview-only method gated to DEBUG.
- Test: two view models share same session/DB, but no view accesses secrets or `ModelContext` directly.

### `App/AppSession.swift`
- `bootstrapLocalProfile()` loads stored active owner or creates new UUID owner; creates two profiles exactly once on empty store.
- `switchProfile(to:) async throws` increments generation first, invokes cancellation coordinator, clears local UI search/index/AI caches, persists active owner, then loads only target owner profiles.
- `captureSession() -> SessionToken`; `requireCurrent(_:) throws` checks owner AND generation. Actor workers check token on suspend/resume and before persistence/network upload.
- `lock()` obfuscates app content and pauses transient work; unlocking through biometric/passcode fallback as configured.

### `App/CapabilityCenter.swift`
- `refresh(_ reason: RefreshReason) async -> CapabilitySnapshot` queries OS/device/framework availability, notifications, speech locale, provider health, connectivity and explicit consents concurrently with bounded timeouts.
- `isAvailable(feature, context) -> FeatureDecision {available, reason, requiredAction}` MUST fail closed for unknown model/tool/permission capabilities.
- Refresh on scene active, provider change, language change, permission/settings return and network path change (debounced). Never infer speech locale availability solely from device language.

## Persistence / user isolation
### `Persistence/StoreModels.swift` & `SchemaV1.swift`
- Only StoreModels defines SwiftData model classes. SchemaV1 declares `versionIdentifier=(1,0,0)` and `models=[...]`; no migration stage until a real V2 exists.
- All user-owned rows contain `ownerID: UUID` indexed where viable; `ModelContext` never passed across actor isolation.
- Preserve stable IDs and `updatedAt` from canonical domain records, never regenerate on upsert. Avoid storing provider secret bytes in `StoredProviderConfiguration`.

### `Persistence/ConversationRepository.swift`
- `createConversation(owner, assistantID)`, `appendPendingUserMessage(owner, conversationID, parts)`, `appendAssistantCheckpoint(traceID, deltas)`, `finishAssistantMessage(traceID, status)`, `pageMessages(owner, conversationID, cursor, limit)`.
- Query owner+conversation in the SAME predicate, order `(createdAt,id)` and bound page 50 default; fail if session changed before write.
- Persist message before sending to provider. Mark incomplete output explicitly when provider fails or user cancels. Do not remove failed invocation for clean-looking history.

### `Persistence/TaskRepository.swift`
- `upsertDefinition(expectedRevision:)` compare-and-set; `reserveOccurrenceKey()` unique run or existing; `transitionRun(from:to:)` validates pure state machine; `recordStepReceipt()` persists before calling tool.
- Race test two same scheduled occurrences on concurrently active tasks: exactly one durable run.

### `Persistence/MemoryRepository.swift`
- `propose(memory, sourceRefs)`, `verify(memoryID,userConfirmation)`, `revise(expectedRevision)`, `expire(now)`, `deleteAndDeindex()`; no model-inferred memory becomes verified automatically.

## AI transport
### `AI/Transport/HTTPClient.swift`
- `send(request: HTTPRequest, deadline: Duration) async throws -> HTTPResponse` and `stream(request:) -> AsyncThrowingStream<Data,Error>` through URLSession; never manually set untrusted `Host` or credentials from user-controlled URLs.
- Support cancellation via `withTaskCancellationHandler`; reject redirects to unapproved host or non-HTTPS; bounded response size and separate connect/idle/overall deadlines.

### `AI/Transport/SSEDecoder.swift`
- `mutating func feed(_ bytes: Data) throws -> [SSEFrame]` supports `\r\n`, `\n`, comments, multiline `data:`, `event`, `id`, `retry`; cap frame 1MiB and buffer total 2MiB by configurable values.
- `mutating func finish() throws -> [SSEFrame]` must handle terminal incomplete last line according to protocol, not silently emit malformed UTF-8.
- Parser does not understand OpenAI wire JSON. Provider adapter owns `[DONE]` interpretation.

### `AI/Providers/OpenAICompatibleProvider.swift`
- `models()` uses configured catalog endpoint where supported, validates model IDs as data, and caches for 24h default or provider cache TTL.
- `stream(_:)` emits `.started`, monotonic `.textDelta`, complete `.toolProposal`, `.usage`, `.completed`; tool fragments assembled by `(choiceIndex,toolIndex)` dictionary with max 64KiB arguments per tool default.
- For provider requests lacking stream/tool support, capability registry must mark those features unavailable; don't send unrecognized parameters.

### `AI/Routing/ModelRegistry.swift`
- `refreshIfStale(providerID, forced)` reads current known catalog with ETag; bundles safe empty/unknown fallback metadata, never claims model supports vision/tool because its name looks familiar.
- `selectableModels(requirements)` returns capability filters plus reason to disable each incompatible discovered model.

### `AI/Routing/IntelligenceRouter.swift`
- `select(request, accountPolicies, candidates, health, remainingBudget)` hard filters by model tools/vision/context, privacy route and consent, budget, availability; then applies explicit user preference, deterministic provider order; no invented quality score.
- `eligibleFallback(failedRoute, sameRequest)` repeats all hard filters and blocks any endpoint with weaker privacy disclosure class.

### `AI/Routing/AssistantOrchestrator.swift`
- `startTurn(messageDraft,session) -> AsyncThrowingStream<TurnUIEvent,Error>` persists user message, computes context, reserves budget, chooses model, streams deltas and handles proposals via ToolInvocationCoordinator. At most six model continuations, ten tool calls; limit can be lowered in policy but never silently raised by model text.
- `cancelTurn(traceID)` signals root task cancellation, speech, provider URLSession and child safe tools; partial transcript marked canceled; committed side effects stay audited.
- `finishTurn(traceID)` reconciles usage once; persist provider/model/prompt versions and private minimal invocation metadata.

## Security and tools
### `Security/ToolPolicyEngine.swift`
- `evaluate(proposal:session:context:) -> ToolDecision` validates exact schema and owner, rejects tool calls derived solely from untrusted source instruction, enforces scope/data destination, classifies risk and requests exact-hash approval.
- `reauthorize(approvedCall,currentSession:)` recomputes payload hash, expiry, permission and privacy before side effect; changing any parameter invalidates approval.

### `Security/ApprovalCoordinator.swift`
- `create(toolProposal,risk) -> ApprovalRequest`, `approve(approvalID,canonicalPayloadHash,now) -> AuthorizedCall`, `reject`, `expire`; atomic single-use transition (pending→approved/rejected/expired) guarded against double-tap.
- Show exact recipient URL/account/category, sensitive data classes, and action effects in UI, not merely friendly task title.

### `Tools/ToolInvocationCoordinator.swift`
- `execute(AuthorizedCall)`: ensure session current → reserve `operationKey` → persist PREPARED → call one executor → persist SUCCEEDED/FAILED/AMBIGUOUS → append redacted AuditEvent → return receipt.
- Read-only retry may be allowed only if safe per tool type; external writes and ambiguous timeouts cannot auto-repeat. The assistant never directly constructs executor objects.

### `Security/KeychainVault.swift`
- `setSecret(owner,provider,value)`, `copySecret(owner,provider)`, `rotateSecret`, `removeSecret`, `removeAll(owner)`. `SecItem` query key composite stable namespace and provider; avoid plaintext UserDefaults, request logs, screenshots and crash breadcrumbs.
- Distinguish `errSecItemNotFound` from device locked/user cancellation. Explicitly inform if migration to another device requires manual key reentry.

## Task scheduling and execution
### `Tasks/TaskScheduler.swift`
- `nextOccurrence(after:definition,calendar,timezone)` uses `Calendar.nextDate`, local components and stable occurrence identity; skip nonexistent time forward, use first repeated time on DST, preserve user's target timezone until changed.
- Return `nil` if ended after `until` or `count`. Test last day of month, leap day, India timezone, DST and edit while occurrence queued.

### `Tasks/TaskEngineActor.swift`
- `schedule`, `beginRun`, `cancel`, `reconcileInterrupted`, `currentProgress`. Only foreground/user-started eligible jobs execute locally. Recurring unattended AI task remains `waitingForApp` or `waitingForServer` if configured.
- Each run has hard max model/tool calls/time and persisted step events; progress unknown rather than fictitious if denominator unknown.

### `Tasks/LocalReminderScheduler.swift`
- `schedule(owner,definition)` translates calendar schedule into UNCalendarNotificationTrigger with exact locale-aware title; request authorization just in time, save notification identifier and reconcile pending IDs after edit/delete.
- On denied authorization keep definition stored but show `notificationsUnavailable`; never equate queued local notification with executed AI work.

## Voice and avatar
### `Voice/VoiceCoordinator.swift`
- `begin(locale)`, `stop()`, `submitFinalTranscript(sessionID,text)`, `speak(text,voiceID)`, `interrupt()`. One root session state machine, `VoiceSessionID` monotonically changes on restart; stale partial and callbacks ignored.
- Tap-to-talk only; release `AVAudioSession` on interruption/background/stop. Model answer text may be spoken in bounded sentence chunks if user-enabled; stop TTS before accepting new microphone frames.

### `Avatar/AvatarStateController.swift`
- Subscribe to voice/orchestrator/task events and project to `.idle/.listening/.thinking/.acting/.speaking/.error`. Only display state evidenced by actual source event; ignore older session generation. Honor Reduce Motion and provide text alternatives.

## Search / memory
### `Search/HistorySearchCoordinator.swift`
- `search(owner,query,filters,cursor)` normalizes query and tokenizes safely, runs owner+nondeleted filtered store fetch, scores exact title/phrase/token overlap/recency, paginates and optionally merges opt-in Spotlight results after DB revalidation.
- Sensitive messages are not Spotlight indexed by default; purge on user deletion and account switch.

### `AI/Context/ContextBuilder.swift`
- `build(turn,owner,route,maxContext)` subtracts response reserve+overhead; emits trusted policy and user turn first; adds owner-scoped permitted history/memories ordered deterministically; untrusted retrieved content serialized as data with IDs, never role="system".
- Use conservative UTF8/3 token estimate if tokenizer unavailable. If required content alone exceeds budget, fail with explicit contextTooLarge rather than trimming current user command silently.

## UI screens and expected event handlers
- Dashboard: `onAsk(text)->openChat+send`, `onVoice->VoiceCoordinator.begin`, `onSwitchAssistant->AppSession`, `onApprovalCard->Approvals`, `onTaskCard->TaskDetail`.
- Tasks: `onCreate->TaskEditor`, `onSave->TaskRepository`, `onCancelRun->TaskEngineActor`, `onReview->ApprovalCoordinator`, `onSchedule->TaskScheduler`.
- History: `onSearch->HistorySearchCoordinator`, `onOpenConversation->Chat`, `onDelete->confirmed repository delete + optional deindex`, `onExport->validated owner-scoped local export`.
- Configuration: `onProviderKey->KeychainVault`, `onTestProvider->bounded catalog/chat capability probe`, `onPrivacyMode->PrivacyPolicyEngine`, `onVoiceChoice->capability-based voice ID check`, `onMemoryApproval->MemoryRepository`.
- Settings: `onLock->BiometricGate`, `onPermission->OS permission status or settings link`, `onClearData->confirmed deletion`, `onDiagnostics->redacted logs`, `onAppearance->AppStorage`.

## Strict rejection of implementation shortcuts
No `fatalError()` replacing recoverable errors, single giant `App.swift`, hardcoded demo account/provider secrets, sample mock chat in shipping app, `try?` swallowed errors on DB writes, generic retry surrounding Apple actions, `Task.detached` work outside cancellation tree, or unsupported API shim that always returns true. A method spec is complete only when its negative tests and integration path are also implemented.
