// Security/PermissionCoordinator.swift
// Coordinates unified OS permission requests across frameworks.
// Per V3 §Security/PermissionCoordinator.swift blueprint.

import Foundation
#if canImport(UserNotifications)
import UserNotifications
#endif

actor PermissionCoordinator {
    func requestNotifications() async -> Bool {
        #if canImport(UserNotifications)
        do {
            let center = UNUserNotificationCenter.current()
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
        #else
        return false
        #endif
    }
}
