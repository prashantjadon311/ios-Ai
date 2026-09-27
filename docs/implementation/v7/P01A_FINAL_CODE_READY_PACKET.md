# Gate P01-A Final Code-Ready Contract Packet

**Document:** `docs/implementation/v7/P01A_FINAL_CODE_READY_PACKET.md`  
**Status:** FROZEN PRE-IMPLEMENTATION SPECIFICATION  
**Readiness State:** `P01A_CODE_READY`  
**Target Branch (post-approval):** `feature/v7-p01-privacy-receipts` (branched from verified `main` `6d50333ebf401234c609c61b9f33cbe27728b1aa`)  
**Scope Limit:** Gate P01-A ONLY (Fail-Closed Privacy, Explicit Destination Consent & Cloud-Speech Boundaries)  

---

## 1. Exact Production Files to Modify (Zero Fictional Files)

All modifications are strictly confined to the following 5 existing files in `PersonalAssistant.swiftpm/`:

| File Path | Component | Planned Modification |
|---|---|---|
| [`Domain/PrivacyAndConsent.swift`](file:///home/thakur/projects/git/AI-Other/ios/ios-Ai/PersonalAssistant.swiftpm/Domain/PrivacyAndConsent.swift) | Core Domain | Change default `AppPreference.privacyMode` from `.cloudAllowed` to `.privateOnly`. Extend `ConsentRecord` with stable scope (`providerConfigID`, `endpointOrigin`, `scopeKey`). Add atomic consent grant/revoke mutations. |
| [`Domain/ProviderConfiguration.swift`](file:///home/thakur/projects/git/AI-Other/ios/ios-Ai/PersonalAssistant.swiftpm/Domain/ProviderConfiguration.swift) | Domain / Config | Add typed, exhaustive `ProviderKind.egressDestination` mapping. Add `ProviderConfiguration.normalizedEndpointOrigin` helper. |
| [`Security/PrivacyPolicyEngine.swift`](file:///home/thakur/projects/git/AI-Other/ios/ios-Ai/PersonalAssistant.swiftpm/Security/PrivacyPolicyEngine.swift) | Security | Add destination-aware `checkEgressAllowed(destination:privacyMode:dataClass:consents:)`. Enforce fail-closed privateOnly, absolute `.secret` ban, explicit opt-in, revocation, and data classification ceiling. |
| [`Persistence/ConfigurationRepository.swift`](file:///home/thakur/projects/git/AI-Other/ios/ios-Ai/PersonalAssistant.swiftpm/Persistence/ConfigurationRepository.swift) | Persistence | In `preferences(ownerID:)`, return safe default `.privateOnly` on first launch; detect corrupted `privacyModeRaw`, corrupt JSON, and duplicate consent scopes, throwing `AppError.storageRecoveryRequired`. In `savePreferences`, throw `AppError.validationFailed` on encode failure. Add atomic `grantConsent` and `revokeConsent` methods. |
| [`AI/Routing/ModelRouter.swift`](file:///home/thakur/projects/git/AI-Other/ios/ios-Ai/PersonalAssistant.swiftpm/AI/Routing/ModelRouter.swift) | Routing | In `route()`, remove privacy-sensitive default arguments. Require mandatory `privacyMode`, `consents`, and `dataClass`. Enforce `dataClass <= requirements.allowedPrivacy`. Evaluate destination-specific consent for each candidate provider. |
| [`AI/Routing/AssistantOrchestrator.swift`](file:///home/thakur/projects/git/AI-Other/ios/ios-Ai/PersonalAssistant.swiftpm/AI/Routing/AssistantOrchestrator.swift) | Orchestration | Eliminate `try?` on `preferences(ownerID:)`. Fail closed on storage error: emit `TurnUIEvent.failed` and abort turn with 0 provider calls and 0 HTTP requests. Compute request sensitivity and pass mandatory privacy parameters to router. |

---

## 2. Exact Swift Interface Specifications (Internal Access Only)

No `public` modifiers are used. All declarations match the single-module Swift Playgrounds application target (`AppModule`).

### 2.1 `Domain/PrivacyAndConsent.swift`
```swift
// MARK: - ConsentRecord (Endpoint-bound scope)

struct ConsentRecord: Codable, Sendable, Hashable {
    let destination: DataEgressDestination
    var providerConfigID: ProviderConfigID?
    var endpointOrigin: String? // Normalized HTTPS origin: "https://host:port"
    let maximumDataClass: PrivacyClass
    var isGranted: Bool
    var grantedAt: Date?
    var revokedAt: Date?

    var scopeKey: String {
        ConsentRecord.computeScopeKey(
            destination: destination,
            providerConfigID: providerConfigID,
            endpointOrigin: endpointOrigin
        )
    }

    static func computeScopeKey(
        destination: DataEgressDestination,
        providerConfigID: ProviderConfigID? = nil,
        endpointOrigin: String? = nil
    ) -> String {
        var key = destination.rawValue
        if let configID = providerConfigID {
            key += ":\(configID.rawValue.uuidString)"
        }
        if let origin = endpointOrigin {
            key += ":\(origin)"
        }
        return key
    }

    init(
        destination: DataEgressDestination,
        providerConfigID: ProviderConfigID? = nil,
        endpointOrigin: String? = nil,
        maximumDataClass: PrivacyClass,
        isGranted: Bool = false,
        grantedAt: Date? = nil,
        revokedAt: Date? = nil
    ) {
        self.destination = destination
        self.providerConfigID = providerConfigID
        self.endpointOrigin = endpointOrigin
        self.maximumDataClass = maximumDataClass
        self.isGranted = isGranted
        self.grantedAt = grantedAt
        self.revokedAt = revokedAt
    }
}

// MARK: - AppPreference (Fail-Closed Default)

struct AppPreference: Codable, Sendable, Hashable {
    let ownerID: UserID
    var privacyMode: PrivacyMode
    var consents: [String: ConsentRecord] // Keyed by stable scopeKey
    var activeAssistantID: AssistantID?
    var appearanceMode: AppearanceMode
    var localeIdentifier: String?
    var reduceMotion: Bool
    var largeText: Bool
    var updatedAt: Date

    init(ownerID: UserID, activeAssistantID: AssistantID? = nil) {
        self.ownerID = ownerID
        self.privacyMode = .privateOnly // Fail-closed: ZERO external transfer until explicit user opt-in
        self.consents = [:]
        self.activeAssistantID = activeAssistantID
        self.appearanceMode = .system
        self.localeIdentifier = nil
        self.reduceMotion = false
        self.largeText = false
        self.updatedAt = Date()
    }

    func consent(
        for destination: DataEgressDestination,
        providerConfigID: ProviderConfigID? = nil,
        endpointOrigin: String? = nil
    ) -> ConsentRecord? {
        let key = ConsentRecord.computeScopeKey(
            destination: destination,
            providerConfigID: providerConfigID,
            endpointOrigin: endpointOrigin
        )
        return consents[key]
    }

    mutating func grantConsent(
        destination: DataEgressDestination,
        maximumDataClass: PrivacyClass,
        providerConfigID: ProviderConfigID? = nil,
        endpointOrigin: String? = nil,
        at date: Date = Date()
    ) {
        let record = ConsentRecord(
            destination: destination,
            providerConfigID: providerConfigID,
            endpointOrigin: endpointOrigin,
            maximumDataClass: maximumDataClass,
            isGranted: true,
            grantedAt: date,
            revokedAt: nil
        )
        consents[record.scopeKey] = record
        updatedAt = date
    }

    mutating func revokeConsent(
        destination: DataEgressDestination,
        providerConfigID: ProviderConfigID? = nil,
        endpointOrigin: String? = nil,
        at date: Date = Date()
    ) {
        let key = ConsentRecord.computeScopeKey(
            destination: destination,
            providerConfigID: providerConfigID,
            endpointOrigin: endpointOrigin
        )
        if var existing = consents[key] {
            existing.isGranted = false
            existing.revokedAt = date
            consents[key] = existing
            updatedAt = date
        }
    }
}
```

### 2.2 `Domain/ProviderConfiguration.swift`
```swift
// Typed Exhaustive Egress Mapping
extension ProviderKind {
    var egressDestination: DataEgressDestination {
        switch self {
        case .groq:
            return .groqAPI
        case .openRouter:
            return .openRouterAPI
        case .custom:
            return .customEndpoint
        case .appleFoundation:
            return .appleFoundationModel
        case .managedGateway:
            return .managedGateway
        }
    }
}

extension ProviderConfiguration {
    var egressDestination: DataEgressDestination {
        providerKind.egressDestination
    }

    var normalizedEndpointOrigin: String? {
        guard providerKind == .custom,
              let raw = baseURL?.trimmingCharacters(in: .whitespacesAndNewlines),
              let url = URL(string: raw),
              let scheme = url.scheme?.lowercased(),
              let host = url.host?.lowercased()
        else {
            return nil
        }
        if let port = url.port {
            return "\(scheme)://\(host):\(port)"
        }
        return "\(scheme)://\(host)"
    }
}
```

### 2.3 `Security/PrivacyPolicyEngine.swift`
```swift
struct PrivacyPolicyEngine: Sendable {
    static func checkEgressAllowed(
        destination: DataEgressDestination,
        privacyMode: PrivacyMode,
        dataClass: PrivacyClass,
        consent: ConsentRecord?
    ) throws {
        // 1. On-device destinations always permitted
        if destination == .system || destination == .appleFoundationModel {
            return
        }

        // 2. Global privacy mode: Private-only blocks ALL external egress
        guard privacyMode == .cloudAllowed else {
            throw AppError.privacyDenied(route: destination.rawValue, requiredClass: dataClass)
        }

        // 3. Absolute Secret Policy: .secret data is NEVER permitted to leave the device
        guard dataClass < .secret else {
            throw AppError.privacyDenied(route: destination.rawValue, requiredClass: .secret)
        }

        // 4. Explicit Per-Destination Opt-In Consent:
        // Cloud Allowed mode DOES NOT automatically authorize every provider!
        guard let consent = consent, consent.isGranted else {
            throw AppError.privacyDenied(route: destination.rawValue, requiredClass: dataClass)
        }

        // 5. Revocation Check
        if let revokedAt = consent.revokedAt, revokedAt <= Date() {
            throw AppError.privacyDenied(route: destination.rawValue, requiredClass: dataClass)
        }

        // 6. Data Classification Ceiling Check
        guard dataClass <= consent.maximumDataClass else {
            throw AppError.privacyDenied(route: destination.rawValue, requiredClass: dataClass)
        }
    }

    // Retained overload for existing simple string-route callers
    static func checkEgressAllowed(
        route: String,
        privacyMode: PrivacyMode,
        dataClass: PrivacyClass
    ) throws {
        if privacyMode == .privateOnly {
            throw AppError.privacyDenied(route: route, requiredClass: dataClass)
        }
        if privacyMode == .cloudAllowed && dataClass == .secret {
            throw AppError.privacyDenied(route: route, requiredClass: .secret)
        }
    }
}
```

### 2.4 `Persistence/ConfigurationRepository.swift`
```swift
func preferences(ownerID: UserID) async throws -> AppPreference {
    let ownerUUID = ownerID.rawValue
    let stored = try await MainActor.run {
        let descriptor = FetchDescriptor<StoredAppPreference>(
            predicate: #Predicate { $0.ownerID == ownerUUID }
        )
        return try context.fetch(descriptor).first
    }
    
    // Case 1: First launch / missing preference -> clean default (.privateOnly)
    guard let stored else {
        return AppPreference(ownerID: ownerID)
    }
    
    // Case 2: Corrupted privacy mode -> throw typed error, DO NOT default to cloud!
    guard let mode = PrivacyMode(rawValue: stored.privacyModeRaw) else {
        throw AppError.storageRecoveryRequired(
            reason: "Corrupted privacyMode in storage: '\(stored.privacyModeRaw)' for owner \(ownerID.rawValue)"
        )
    }
    
    let appearance = AppearanceMode(rawValue: stored.appearanceModeRaw) ?? .system
    var prefs = AppPreference(ownerID: ownerID, activeAssistantID: stored.activeAssistantIDRaw.map { AssistantID(rawValue: $0) })
    prefs.privacyMode = mode
    prefs.appearanceMode = appearance
    prefs.localeIdentifier = stored.localeIdentifier
    prefs.updatedAt = stored.updatedAt
    
    // Case 3: Decode consents with explicit duplicate detection (NEVER trap with Dictionary(uniqueKeysWithValues:))
    if !stored.consentsData.isEmpty {
        let records: [ConsentRecord]
        do {
            records = try JSONDecoder().decode([ConsentRecord].self, from: stored.consentsData)
        } catch {
            throw AppError.storageRecoveryRequired(
                reason: "Corrupted consent JSON in store for owner \(ownerID.rawValue): \(error.localizedDescription)"
            )
        }
        
        var consentMap: [String: ConsentRecord] = [:]
        for record in records {
            let key = record.scopeKey
            if consentMap[key] != nil {
                throw AppError.storageRecoveryRequired(
                    reason: "Corrupted store: duplicate consent record detected for scope '\(key)'"
                )
            }
            if record.isGranted && record.grantedAt == nil {
                throw AppError.storageRecoveryRequired(
                    reason: "Corrupted store: granted consent missing grantedAt timestamp for '\(key)'"
                )
            }
            consentMap[key] = record
        }
        prefs.consents = consentMap
    }
    return prefs
}

func savePreferences(_ prefs: AppPreference) async throws {
    let ownerUUID = prefs.ownerID.rawValue
    let consentsData: Data
    do {
        consentsData = try JSONEncoder().encode(Array(prefs.consents.values))
    } catch {
        throw AppError.validationFailed(field: "consents", reason: "Failed to encode consent records: \(error.localizedDescription)")
    }
    
    try await MainActor.run {
        let descriptor = FetchDescriptor<StoredAppPreference>(
            predicate: #Predicate { $0.ownerID == ownerUUID }
        )
        if let existing = try context.fetch(descriptor).first {
            existing.privacyModeRaw = prefs.privacyMode.rawValue
            existing.consentsData = consentsData
            existing.activeAssistantIDRaw = prefs.activeAssistantID?.rawValue
            existing.appearanceModeRaw = prefs.appearanceMode.rawValue
            existing.localeIdentifier = prefs.localeIdentifier
            existing.updatedAt = prefs.updatedAt
        } else {
            let stored = StoredAppPreference(
                ownerID: ownerUUID,
                privacyModeRaw: prefs.privacyMode.rawValue,
                consentsData: consentsData,
                activeAssistantIDRaw: prefs.activeAssistantID?.rawValue,
                appearanceModeRaw: prefs.appearanceMode.rawValue,
                localeIdentifier: prefs.localeIdentifier,
                updatedAt: prefs.updatedAt
            )
            context.insert(stored)
        }
        try context.save()
    }
}

// Atomic consent write APIs
func grantConsent(
    ownerID: UserID,
    destination: DataEgressDestination,
    maximumDataClass: PrivacyClass,
    providerConfigID: ProviderConfigID? = nil,
    endpointOrigin: String? = nil
) async throws {
    var prefs = try await preferences(ownerID: ownerID)
    prefs.grantConsent(
        destination: destination,
        maximumDataClass: maximumDataClass,
        providerConfigID: providerConfigID,
        endpointOrigin: endpointOrigin
    )
    try await savePreferences(prefs)
}

func revokeConsent(
    ownerID: UserID,
    destination: DataEgressDestination,
    providerConfigID: ProviderConfigID? = nil,
    endpointOrigin: String? = nil
) async throws {
    var prefs = try await preferences(ownerID: ownerID)
    prefs.revokeConsent(
        destination: destination,
        providerConfigID: providerConfigID,
        endpointOrigin: endpointOrigin
    )
    try await savePreferences(prefs)
}
```

### 2.5 `AI/Routing/ModelRouter.swift`
```swift
// Removed all privacy-sensitive default arguments
func route(
    requirements: CapabilityRequirements,
    ownerID: UserID,
    configs: [ProviderConfiguration],
    privacyMode: PrivacyMode,
    consents: [String: ConsentRecord],
    dataClass: PrivacyClass
) async -> RoutingResult {
    // 1. Enforce requirement privacy ceiling:
    if dataClass > requirements.allowedPrivacy {
        return .noneEligible(
            reason: "Turn sensitivity '\(dataClass)' exceeds allowedPrivacy requirement '\(requirements.allowedPrivacy)'"
        )
    }

    var eligible: [(config: ProviderConfiguration, provider: any AssistantModel, modelID: String)] = []

    for config in configs {
        guard config.ownerID == ownerID, config.isEnabled else { continue }
        guard let raw = config.modelOverride?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty, raw != "default" else { continue }
        let selectedModelID = raw

        let destination = config.egressDestination
        let effectiveConsent: ConsentRecord?
        if config.providerKind == .custom {
            effectiveConsent = consents[ConsentRecord.computeScopeKey(
                destination: .customEndpoint,
                providerConfigID: config.id,
                endpointOrigin: config.normalizedEndpointOrigin
            )]
        } else {
            effectiveConsent = consents[destination.rawValue]
        }

        // Full privacy and consent check:
        do {
            try PrivacyPolicyEngine.checkEgressAllowed(
                destination: destination,
                privacyMode: privacyMode,
                dataClass: dataClass,
                consent: effectiveConsent
            )
        } catch {
            continue // Egress blocked by privacy mode, ceiling, or missing/revoked consent
        }

        guard let provider = providers[config.providerKind.rawValue] ?? providers[config.id.rawValue.uuidString] else {
            continue
        }

        let hasKey = await keychainVault.hasSecret(ownerID: ownerID, providerID: config.providerKind.rawValue)
        guard hasKey else { continue }

        let isHealthy = healthMap[config.providerKind.rawValue] ?? healthMap[config.id.rawValue.uuidString] ?? true
        guard isHealthy else { continue }

        if let availableModels = try? await provider.models() {
            if let descriptor = availableModels.first(where: { $0.id == selectedModelID }) {
                if requirements.needsVision && descriptor.capabilities.vision != .yes { continue }
                if requirements.needsTools && descriptor.capabilities.tools != .yes { continue }
            } else if requirements.needsVision || requirements.needsTools {
                continue
            }
        } else if requirements.needsVision || requirements.needsTools {
            continue
        }

        eligible.append((config, provider, selectedModelID))
    }

    guard let first = eligible.first else {
        return .noneEligible(reason: "No eligible provider matching capabilities, health, and privacy consent found")
    }

    return .selected(provider: first.provider, modelID: first.modelID)
}
```

### 2.6 `AI/Routing/AssistantOrchestrator.swift`
```swift
// In executeTurn:
let configs = try await configurationRepository.providerConfigs(ownerID: ownerID)

let prefs: AppPreference
do {
    prefs = try await configurationRepository.preferences(ownerID: ownerID)
} catch let appErr as AppError {
    // Fail-closed: Immediately emit failure and abort; 0 provider calls, 0 HTTP requests
    await onEvent(.failed(traceID: traceID, error: appErr))
    return
} catch {
    await onEvent(.failed(traceID: traceID, error: .storageRecoveryRequired(reason: "Preference load failure: \(error.localizedDescription)")))
    return
}

let maxSensitivity: PrivacyClass = request.messages.map(\.sensitivity).max() ?? .publicData

let routeResult = await router.route(
    requirements: request.requirements,
    ownerID: ownerID,
    configs: configs,
    privacyMode: prefs.privacyMode,
    consents: prefs.consents,
    dataClass: maxSensitivity
)
```

---

## 3. Privacy State Matrix & Cloud-STT / URL Policies

### 3.1 Privacy State Evaluation Table
| Global `privacyMode` | Destination | Data Class | Consent State | Result | Error Emitted |
|---|---|---|---|---|---|
| `.privateOnly` | Cloud Provider (Groq/OpenRouter/Custom) | Any | Any | **DENY** | `privacyDenied(route, requiredClass)` |
| `.privateOnly` | On-Device (`.system` / `.appleFoundationModel`) | `< .secret` | N/A | **ALLOW** | None |
| `.cloudAllowed` | Cloud Provider | `.secret` | Granted | **DENY** | `privacyDenied(route, .secret)` |
| `.cloudAllowed` | Cloud Provider | `.personal` | None / Missing | **DENY** | `privacyDenied(route, .personal)` |
| `.cloudAllowed` | Cloud Provider | `.personal` | `isGranted: false` / `revokedAt <= Date()` | **DENY** | `privacyDenied(route, .personal)` |
| `.cloudAllowed` | Custom Endpoint B | `.personal` | Granted for Custom Endpoint A only | **DENY** | `privacyDenied("customEndpoint", .personal)` |
| `.cloudAllowed` | Custom Endpoint A (URL changed) | `.personal` | Granted for original URL origin | **DENY** | `privacyDenied("customEndpoint", .personal)` |
| `.cloudAllowed` | Groq API | `.sensitive` | Granted with `maximumDataClass = .personal` | **DENY** | `privacyDenied("groqAPI", .sensitive)` |
| `.cloudAllowed` | Groq API | `.personal` | Granted with `maximumDataClass = .sensitive` | **ALLOW** | None |

### 3.2 Cloud Speech / STT Contract (`Voice/LegacySpeechRecognizer.swift`)
- **Private Only:**
  `requiresOnDeviceRecognition` is set to `true`.
  If `SFSpeechRecognizer.supportsOnDeviceRecognition == false` for the active locale, speech recognition **FAILS CLOSED** and throws `AppError.unsupportedCapability("On-device speech recognition unsupported for locale in Private-Only mode")`.
- **Cloud Allowed:**
  Cloud audio streaming requires explicit, separate `ConsentRecord` for `DataEgressDestination.appleSTT`.
  Microphone authorization alone is strictly an OS permission and **DOES NOT** authorize cloud STT.
  If `.appleSTT` consent is absent or revoked, the recognizer must enforce `requiresOnDeviceRecognition = true`. If on-device is unsupported, it throws `AppError.privacyDenied(route: "appleSTT", requiredClass: .sensitive)`.

### 3.3 External URL Policy (`OpenURLTool.swift`)
- **Authoritative Decision (from V3 §S005 and V7 Errata):**
  User-directed browser opening via `OpenURLTool` is **ALLOWED** in Private-Only mode **ONLY as an explicitly user-approved system action**.
  - `OpenURLTool` defines `requiresApproval: true` and `riskLevel: .medium`.
  - The model proposes the URL; the UI prompts the user via `ApprovalCoordinator`.
  - Upon explicit user confirmation, `URLSafetyValidator.validateDestination(url)` checks schemes and blocked hosts.
  - `URLLauncher.openURL` calls `UIApplication.shared.open`.
  - **Zero conversation context is egressed by the app.** The app does not perform background web fetching.

---

## 4. Test Harness Architecture & Testability Strategy

### 4.1 Testability Strategy for `AssistantOrchestrator`
**Decision: Option A — Real in-memory SwiftData corruption fixture.**
- No protocol seams or architectural indirection introduced into `AssistantOrchestrator`.
- The production initializer accepts the concrete `ConfigurationRepository`.
- Tests initialize an in-memory `ModelContainer(for: StoredAppPreference.self, ...)` with `isStoredInMemoryOnly: true`.
- Inserting a `StoredAppPreference` with `privacyModeRaw = "invalid_corrupt"` drives the concrete repository failure path naturally.
- The test asserts:
  `TurnUIEvent.failed` emitted $\to$ mock provider `.stream()` call count == 0 $\to$ HTTP transport call count == 0.

### 4.2 Portable Test Source-Sync Specification (`docs/implementation/release_repair_v2/scripts/sync_portable_sources.py`)
To execute pure Swift privacy tests on Linux without Xcode, the source-sync script is extended to copy the 5-file minimal Foundation dependency closure:
1. `Domain/Identifiers.swift`
2. `Domain/Errors.swift`
3. `Domain/PrivacyAndConsent.swift`
4. `Domain/ProviderConfiguration.swift`
5. `Security/PrivacyPolicyEngine.swift`

All 5 files import only `Foundation`. SHA-256 evidence is recorded in `SNAPSHOT_SHA256.json`.

### 4.3 Apple Integration Test Harness (`docs/implementation/v7/apple_integration_tests/`)
For tests requiring SwiftData (`ConfigurationRepository` persistence, duplicate consent detection) and Keychain:
- Standalone SPM package `apple_integration_tests/Package.swift` targeting iOS 18.2 SDK.
- References production sources via deterministic source-snapshot.
- Executed on GitHub Actions `macos-15` runner:
  ```bash
  xcodebuild test \
    -package-path docs/implementation/v7/apple_integration_tests \
    -scheme AppUnderTestTests \
    -destination "platform=iOS Simulator,name=iPhone 16,OS=18.3.1" \
    CODE_SIGNING_ALLOWED=NO
  ```

---

## 5. Complete 24-Scenario Executable Test Matrix

| # | Scenario Description | Expected Outcome | Execution Tier |
|---|---|---|---|
| 1 | `AppPreference` fresh initialization defaults to `.privateOnly` | `privacyMode == .privateOnly`, `consents.isEmpty` | `PORTABLE_EXECUTABLE` |
| 2 | Missing preference record in storage | Returns safe default `.privateOnly` | `APPLE_SIMULATOR_EXECUTABLE` |
| 3 | Invalid `privacyModeRaw` in store | Throws `AppError.storageRecoveryRequired` | `APPLE_SIMULATOR_EXECUTABLE` |
| 4 | Corrupted consent JSON in store | Throws `AppError.storageRecoveryRequired` | `APPLE_SIMULATOR_EXECUTABLE` |
| 5 | Duplicate consent scopes in store array | Throws `AppError.storageRecoveryRequired` (no trap) | `APPLE_SIMULATOR_EXECUTABLE` |
| 6 | `.privateOnly` blocks cloud AI provider | Router returns `.noneEligible` / throws `privacyDenied` | `PORTABLE_EXECUTABLE` |
| 7 | `.cloudAllowed` without destination consent blocks | Router returns `.noneEligible` / throws `privacyDenied` | `PORTABLE_EXECUTABLE` |
| 8 | Revoked consent (`revokedAt <= Date()`) blocks | Throws `privacyDenied` | `PORTABLE_EXECUTABLE` |
| 9 | Consent for Provider A does not authorize Provider B | Provider B rejected; returns `.noneEligible` | `PORTABLE_EXECUTABLE` |
| 10 | Custom endpoint consent does not authorize changed URL | Origin mismatch; returns `.noneEligible` | `PORTABLE_EXECUTABLE` |
| 11 | Data class sensitivity exceeds consent ceiling | Sensitivity `.sensitive` vs ceiling `.personal` throws `privacyDenied` | `PORTABLE_EXECUTABLE` |
| 12 | Data class sensitivity exceeds `requirements.allowedPrivacy` | Router returns `.noneEligible` | `PORTABLE_EXECUTABLE` |
| 13 | Absolute `.secret` data class ban | Throws `privacyDenied` regardless of cloud mode/consent | `PORTABLE_EXECUTABLE` |
| 14 | Local/system destinations permitted in `.privateOnly` | `.system` and `.appleFoundationModel` succeed | `PORTABLE_EXECUTABLE` |
| 15 | Preference read failure causes 0 provider/HTTP calls | Emits `TurnUIEvent.failed`; provider invocation == 0 | `APPLE_SIMULATOR_EXECUTABLE` |
| 16 | `AppSession.bootstrapLocalProfile` does not hide corruption | Surfaces `storeRecoveryRequired == true` | `APPLE_SIMULATOR_EXECUTABLE` |
| 17 | `AppSession.switchProfile` does not hide corruption | Surfaces `storeRecoveryRequired == true` | `APPLE_SIMULATOR_EXECUTABLE` |
| 18 | UI fallback state never synthesizes `.cloudAllowed` | Views initialize/fallback to `.privateOnly` | `STATIC_ONLY` |
| 19 | Private-Only speech requires on-device recognition | Sets `requiresOnDeviceRecognition = true` | `APPLE_SIMULATOR_EXECUTABLE` |
| 20 | Unsupported on-device speech in Private-Only fails closed | Recognizer throws `unsupportedCapability` | `APPLE_SIMULATOR_EXECUTABLE` |
| 21 | Cloud STT without `.appleSTT` consent blocks | Enforces on-device or throws `privacyDenied` | `APPLE_SIMULATOR_EXECUTABLE` |
| 22 | Revoked cloud-STT consent blocks | Enforces on-device or throws `privacyDenied` | `APPLE_SIMULATOR_EXECUTABLE` |
| 23 | Valid cloud-STT consent allows network recognition | Dispatches network recognition request | `APPLE_SIMULATOR_EXECUTABLE` |
| 24 | External URL opening requires approval and destination check | `requiresApproval == true`, validates scheme/host | `PORTABLE_EXECUTABLE` |

---

## 6. CI Commands & Acceptance Gates

### 6.1 Local Verification (Ubuntu 26.04)
```bash
# 1. Sync portable sources and run portable unit tests
python3 docs/implementation/release_repair_v2/scripts/sync_portable_sources.py .
/home/thakur/.local/share/swiftly/bin/swift test --package-path docs/implementation/release_repair_v2/portable_core_tests

# 2. Syntax pre-flight all 187 Swift source files
export PATH="/home/thakur/.local/share/swiftly/bin:$PATH"
bash scripts/swift-prepush.sh .

# 3. Contract & Matrix checkers
python3 docs/spec/v3/20_VALIDATE_HANDOFF.py && python3 scratch/verify_matrix.py

# 4. Immutable kit check
bash docs/IOS_AI_GEMINI_V7_2_COMPLETE_KIT/scripts/verify-kit.sh
```

### 6.2 Remote GitHub Actions Acceptance Gate (`macos-15`)
On push of the single bounded PR commit for Gate P01-A:
1. `ios-real-compiler-probe`:
   - `Apple iOS App Build`: Must exit 0 (`** BUILD SUCCEEDED **`, Xcode 16.3).
   - `Apple Swift Compiler (Mac Catalyst)`: Must exit 0.
   - `Portable Swift Core Tests`: Must exit 0.
   - `Static Contract & Schema Verification`: Must exit 0.
2. `iOS Build & Verify`:
   - `Xcode iOS Build Verification`: Must exit 0.

---

## 7. Unresolved Blockers & Readiness State

- **Blockers:** ZERO unresolved technical blockers.
- **Readiness State:** `P01A_CODE_READY`
