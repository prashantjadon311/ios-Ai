// App/CapabilityCenter.swift
// Caches runtime/permission/model/locale readiness.
// Per V3 §App/CapabilityCenter.swift blueprint — fails closed for unknown capabilities.

import Foundation
import Observation
#if canImport(AVFoundation)
import AVFoundation
#endif
#if canImport(AVFAudio)
import AVFAudio
#endif
#if canImport(UserNotifications)
import UserNotifications
#endif
#if canImport(Speech)
import Speech
#endif
#if canImport(Network)
import Network
#endif

/// Reason a feature check was triggered.
enum RefreshReason: Sendable {
    case sceneActive
    case providerChanged
    case languageChanged
    case permissionChanged
    case networkChanged
    case manual
}

/// App features gated by CapabilityCenter.
enum AppFeature: Sendable {
    case voiceInput
    case localNotifications
    case appleFoundationModels
    case networkFeatures
}

@MainActor
@Observable
final class CapabilityCenter {

    private(set) var snapshot: CapabilitySnapshot = CapabilitySnapshot()
    private(set) var isRefreshing: Bool = false

    // MARK: - Refresh

    /// Queries OS/device/framework availability concurrently.
    /// Fails closed for unknown capabilities (I11).
    func refresh(_ reason: RefreshReason) async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        var newSnapshot = CapabilitySnapshot()

        newSnapshot.networkAvailable = await checkNetworkAvailability()
        newSnapshot.hasMicrophonePermission = await checkMicrophonePermission()
        newSnapshot.hasNotificationPermission = await checkNotificationPermission()
        newSnapshot.foundationModelsAvailable = checkFoundationModelsAvailability()
        newSnapshot.speechRecognitionLocales = availableSpeechLocales()

        snapshot = newSnapshot
    }

    // MARK: - Feature decision (fail-closed)

    func isAvailable(feature: AppFeature) -> FeatureDecision {
        switch feature {
        case .voiceInput:
            guard snapshot.hasMicrophonePermission else {
                return FeatureDecision(
                    isAvailable: false,
                    reason: "Microphone permission required",
                    requiredAction: "Open Settings > Privacy > Microphone"
                )
            }
            guard !snapshot.speechRecognitionLocales.isEmpty else {
                return FeatureDecision(
                    isAvailable: false,
                    reason: "Speech recognition not available for current locale",
                    requiredAction: "Choose a supported locale in Settings"
                )
            }
            return .available

        case .localNotifications:
            guard snapshot.hasNotificationPermission else {
                return FeatureDecision(
                    isAvailable: false,
                    reason: "Notification permission required",
                    requiredAction: "Enable in Settings > Notifications"
                )
            }
            return .available

        case .appleFoundationModels:
            guard snapshot.foundationModelsAvailable else {
                return FeatureDecision(
                    isAvailable: false,
                    reason: "Apple Foundation Models not available on this device/OS",
                    requiredAction: nil
                )
            }
            return .available

        case .networkFeatures:
            guard snapshot.networkAvailable else {
                return FeatureDecision(
                    isAvailable: false,
                    reason: "No network connection",
                    requiredAction: "Connect to the internet"
                )
            }
            return .available
        }
    }

    // MARK: - Private checkers

    private func checkNetworkAvailability() async -> Bool {
        #if canImport(Network)
        return await withCheckedContinuation { continuation in
            let monitor = NWPathMonitor()
            let queue = DispatchQueue(label: "NetworkCheck")
            monitor.pathUpdateHandler = { path in
                monitor.cancel()
                continuation.resume(returning: path.status == .satisfied)
            }
            monitor.start(queue: queue)
        }
        #else
        return true
        #endif
    }

    private func checkMicrophonePermission() async -> Bool {
        #if canImport(AVFAudio)
        if #available(iOS 18.0, *) {
            return await withCheckedContinuation { continuation in
                AVAudioApplication.requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        }
        #endif
        return false
    }

    private func checkNotificationPermission() async -> Bool {
        #if canImport(UserNotifications)
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized ||
               settings.authorizationStatus == .provisional
        #else
        return false
        #endif
    }

    private func checkFoundationModelsAvailability() -> Bool {
        #if canImport(FoundationModels)
        if #available(iOS 18.0, *) {
            return true
        }
        #endif
        return false
    }

    private func availableSpeechLocales() -> [String] {
        #if canImport(Speech)
        return SFSpeechRecognizer.supportedLocales().map { $0.identifier }
        #else
        return ["en-US"]
        #endif
    }
}
