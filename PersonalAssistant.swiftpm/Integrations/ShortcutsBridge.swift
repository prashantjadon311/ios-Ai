// Integrations/ShortcutsBridge.swift
// App Intents and Shortcuts integration bridge.
// Per V7 Phase P03, §Integrations/ShortcutsBridge.swift blueprint, and docs/04 Section D.

import Foundation

#if canImport(AppIntents)
import AppIntents

struct TalkToMayaIntent: AppIntent {
    static var title: LocalizedStringResource = "Talk to Maya"
    static var description: IntentDescription = "Opens Personal Assistant with Maya voice ready"
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        ShortcutsBridge.shared.handleLaunch(role: .maya)
        return .result()
    }
}

struct TalkToSaarIntent: AppIntent {
    static var title: LocalizedStringResource = "Talk to Saar"
    static var description: IntentDescription = "Opens Personal Assistant with Saar voice ready"
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        ShortcutsBridge.shared.handleLaunch(role: .saar)
        return .result()
    }
}

struct AssistantShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: TalkToMayaIntent(),
            phrases: [
                "Talk to Maya in \(.applicationName)",
                "Ask Maya with \(.applicationName)"
            ],
            shortTitle: "Talk to Maya",
            systemImageName: "mic.fill"
        )
        AppShortcut(
            intent: TalkToSaarIntent(),
            phrases: [
                "Talk to Saar in \(.applicationName)",
                "Ask Saar with \(.applicationName)"
            ],
            shortTitle: "Talk to Saar",
            systemImageName: "mic.fill"
        )
    }
}
#endif

@MainActor
final class ShortcutsBridge {
    static let shared = ShortcutsBridge()

    private(set) var pendingLaunchRequest: VoiceLaunchRequest?
    private var lastLaunchNonce: UUID?
    private var lastLaunchTimestamp: Date = .distantPast

    init() {}

    func handleLaunch(role: AvatarRole, currentTime: Date = Date()) {
        // Coalesce rapid duplicate taps within 1.0s (Contract D, Prompt 05)
        guard currentTime.timeIntervalSince(lastLaunchTimestamp) > 1.0 else {
            return
        }
        let nonce = UUID()
        lastLaunchNonce = nonce
        lastLaunchTimestamp = currentTime
        pendingLaunchRequest = VoiceLaunchRequest(
            avatarRole: role,
            nonce: nonce,
            createdAt: currentTime,
            source: .shortcut
        )
    }

    /// Consumes the pending launch request if valid, non-expired, and matching session owner.
    /// If owner changed (different account signed in), queued request is cleared and dropped.
    func consumePendingLaunchRequest(
        currentOwner: UserID,
        expectedOwner: UserID,
        currentTime: Date = Date()
    ) -> VoiceLaunchRequest? {
        guard currentOwner == expectedOwner else {
            // Drop queued launch if account switched
            pendingLaunchRequest = nil
            return nil
        }
        guard let request = pendingLaunchRequest else { return nil }
        pendingLaunchRequest = nil

        if request.isExpired(currentTime: currentTime) {
            return nil
        }
        return request
    }

    func clearPendingRequest() {
        pendingLaunchRequest = nil
    }

    static func isShortcutsAvailable() -> Bool {
        #if canImport(AppIntents)
        return true
        #else
        return false
        #endif
    }
}
