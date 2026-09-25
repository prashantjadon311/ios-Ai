# V3 security, privacy, auth, backup, and external-service contracts

## 1. Threat actors and trust zones
Trust zones: user foreground gesture; app UI and local domain state; imported files/web/tool responses (untrusted); local OS protected capabilities; Keychain; user BYOK external providers; optional future managed gateway; optional future authenticated Firestore and encrypted Google Drive backups. A model's proposed tool arguments are untrusted suggestions even if the model is hosted locally. OS permission grants do not replace app-level action approval. The local device's passcode/Face ID protects physical access, not cloud identity or family data isolation.

## 2. Data egress matrix
| Data | Device UI / SwiftData | Third-party model | Cloud STT | Spotlight | Future backup |
|---|---|---|---|---|---|
| Public prompt | yes | when user selected provider | only audio with separate opt-in | no default | opt-in |
| Personal chat/task | owner-scoped | minimum necessary with visible mode/consent | only transcript/audio when separate consent | off default; approved excerpt only | opt-in encrypted |
| Contact/calendar data | permission-scoped read | only for explicit task and separate disclosure | no | no | opt-in scoped |
| Sensitive private files | protected local storage | opt-in explicit per action and policy | no | no | opt-in encrypted |
| API keys | Keychain only | passed only as HTTP auth to that exact user-owned provider endpoint | no | never | never plaintext |
| Model provider reasoning | do not store | provider-specific only | no | never | no |
| Analytics/logs | redacted events only | no raw user content | no | no | opt-in redacted diagnostics |

Private-only mode means zero outbound prompt/audio/file/content transmission to any provider or telemetry. Network availability checks and user-directed external link opening are separately labeled and require deliberate action. Hosted open-weight models are still third-party cloud data processors; 'open source model' does not imply local or confidential inference.

## 3. Input and network security
Do not permit a model to fetch arbitrary URLs through a privileged service. For a future server-side fetcher: HTTPS-only; DNS resolution and final destination checked against public IP allowlist, rebinding protected, redirects revalidated, maximum hops/content type/bytes/time, no credentials in URL or logs. For the iOS `openURL` tool: only validated https/app-approved schemes, prohibit javascript/file/data/private intent patterns, show parsed host/scheme before user-triggered navigation. Deep links and callback URLs enter as untrusted input and cannot enact account mutation or external sending without new validation. JSON/SSE decoders enforce size/depth limits; downloads are quarantined until type validated.

## 4. Agent-specific policy
Prompt/document/OCR/tool-output text is always data, never an authority upgrade. Tool calls must match a fixed registry version and strict type schema. High-risk actions require human approval containing displayed recipient/resource, exact side effects and sensitive data classes; revocation invalidates pending approval. Approved calls are reauthorized immediately before effect; persist exact operation key and receipt. No implicit email sending or contact export in V1. Return minimal result context to model to reduce private exposure. Rate limit model continuations and tool calls per TaskRun/turn.

## 5. BYOK provider setup
API keys typed/pasted only into secure editable field; never log field content or copy raw key to SwiftData/preferences. Keychain stored as generic password with namespace by local profile and provider. Never embed developer-owned keys in bundle; if distributable managed mode is needed later, use authenticated server-side gateway and per-user quota. Provider response may include request IDs and actual token usage; store only redacted IDs and usage. Any hard spend cap must be enforced by provider or server, not described as guaranteed based on local counters. Provider service region/retention and privacy terms require pre-release review.

## 6. Multi-user future architecture, clearly out of V1
The future cloud design preserves the earlier chosen direction: Sign in with Apple primarily, optional email/password recovery where required, Firestore scoped by authenticated `request.auth.uid`, no iCloud/CloudKit, encrypted Google Drive only for opt-in backup/audit export. Every Firestore collection path and document has immutable owner ID checked by Security Rules, not merely by UI filtering; rules deny unauthenticated and cross-user reads/writes. Server-stored Google Drive refresh tokens require a secure backend; never expose another user's drive resources. Document key derivation, recovery and revocation before promising end-to-end encryption. Account deletion revokes tokens, cancels tasks, propagates tombstones, deletes index/cache/server state as contract allows and discloses residual third-party provider retention.

## 7. Operational privacy and supply chain
PrivacyInfo.xcprivacy must enumerate *actual* collected data and required-reason APIs when final binary dependencies are known. Add privacy policy and contact URL before App Store submission. Review license and integrity/SHA256 for avatar assets, audio, and every third-party package. Prefer native Apple frameworks; lock exact third-party dependency versions. Disable remote crash/analytics by default in a BYOK private build; if introduced, make redacted event collection explicitly configurable and separately disclosed. Error messages must not include request body, raw provider credentials, OCR content or private contact identifiers.

## 8. Abuse and failure acceptance
Minimum injection corpus: poisoned webpage, OCR-instruction inside receipt, adversarial PDF metadata, modified tool result, fake assistant/system role delimiters, Unicode host confusion, repeated network timeout after remote write, file URL traversal, cross-profile stale stream, fake task-completed notification, speech session replay and permissions revoked mid-request. Record exact redacted trace and expected outcome for each. Any unauthorized private disclosure, secret in logs, account boundary failure, unapproved side effect or duplicate sensitive external action blocks release.
