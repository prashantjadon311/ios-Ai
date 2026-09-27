// Tasks/LocalReminderScheduler.swift
// UserNotifications integration for local task alerts.
// Per V3 §Tasks/LocalReminderScheduler.swift blueprint, T016, S010.

import Foundation
#if canImport(UserNotifications)
import UserNotifications
#endif

protocol NotificationSchedulerBackend: Sendable {
    func isAuthorized() async -> Bool
    func scheduleNotification(identifier: String, title: String, fireDate: Date) async throws
    func cancelNotifications(withIdentifiers identifiers: [String]) async
    func pendingNotificationIdentifiers() async -> [String]
}

#if canImport(UserNotifications)
final class SystemNotificationSchedulerBackend: NotificationSchedulerBackend, @unchecked Sendable {
    func isAuthorized() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
    }

    func scheduleNotification(identifier: String, title: String, fireDate: Date) async throws {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
            throw AppError.permissionDenied(resource: "UserNotifications")
        }

        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = title
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        try await center.add(request)
    }

    func cancelNotifications(withIdentifiers identifiers: [String]) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func pendingNotificationIdentifiers() async -> [String] {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        return pending.map(\.identifier)
    }
}
#endif

actor SimulatedNotificationSchedulerBackend: NotificationSchedulerBackend {
    var authorized: Bool
    private var pending: [String: (title: String, fireDate: Date)] = [:]

    init(authorized: Bool = true) {
        self.authorized = authorized
    }

    func isAuthorized() async -> Bool {
        authorized
    }

    func scheduleNotification(identifier: String, title: String, fireDate: Date) async throws {
        guard authorized else {
            throw AppError.permissionDenied(resource: "UserNotifications")
        }
        pending[identifier] = (title, fireDate)
    }

    func cancelNotifications(withIdentifiers identifiers: [String]) async {
        for id in identifiers {
            pending.removeValue(forKey: id)
        }
    }

    func pendingNotificationIdentifiers() async -> [String] {
        Array(pending.keys)
    }
}

actor LocalReminderScheduler {
    private let backend: any NotificationSchedulerBackend

    init(backend: (any NotificationSchedulerBackend)? = nil) {
        #if canImport(UserNotifications)
        self.backend = backend ?? SystemNotificationSchedulerBackend()
        #else
        self.backend = backend ?? SimulatedNotificationSchedulerBackend()
        #endif
    }

    func isAuthorized() async -> Bool {
        await backend.isAuthorized()
    }

    /// Schedules a local notification reminder if permissions permit.
    /// In accordance with T016, if notifications are denied, throws permissionDenied so
    /// task remains stored and marked unscheduled, without falsely claiming alert was delivered.
    func scheduleReminder(taskID: TaskID, occurrenceID: UUID? = nil, title: String, fireDate: Date) async throws {
        let notifID = occurrenceID.map { "task_\(taskID.rawValue.uuidString)_\($0.uuidString)" } ?? "task_\(taskID.rawValue.uuidString)"
        try await backend.scheduleNotification(identifier: notifID, title: title, fireDate: fireDate)
    }

    /// Cancels any pending notification requests for the task (S010).
    func cancelReminder(taskID: TaskID, occurrenceID: UUID? = nil) async {
        if let occID = occurrenceID {
            await backend.cancelNotifications(withIdentifiers: [
                "task_\(taskID.rawValue.uuidString)_\(occID.uuidString)",
                "task_\(taskID.rawValue.uuidString)"
            ])
        } else {
            let pending = await backend.pendingNotificationIdentifiers()
            let ids = pending.filter { $0.hasPrefix("task_\(taskID.rawValue.uuidString)") }
            await backend.cancelNotifications(withIdentifiers: ids.isEmpty ? ["task_\(taskID.rawValue.uuidString)"] : ids)
        }
    }

    /// Schedules a local notification for a standalone reminder (V7 Phase P07).
    func scheduleStandaloneReminder(reminderID: ReminderID, title: String, fireDate: Date) async throws {
        let notifID = "reminder_\(reminderID.rawValue.uuidString)"
        try await backend.scheduleNotification(identifier: notifID, title: title, fireDate: fireDate)
    }

    /// Cancels any pending notification for a standalone reminder.
    func cancelStandaloneReminder(reminderID: ReminderID) async {
        let notifID = "reminder_\(reminderID.rawValue.uuidString)"
        await backend.cancelNotifications(withIdentifiers: [notifID])
    }

    /// Snoozes a reminder by rescheduling it for a future offset in minutes.
    func snoozeReminder(reminderID: ReminderID, title: String, minutes: Int) async throws -> Date {
        let snoozeDate = Date().addingTimeInterval(Double(minutes * 60))
        try await scheduleStandaloneReminder(reminderID: reminderID, title: title, fireDate: snoozeDate)
        return snoozeDate
    }

    func pendingIdentifiers() async -> [String] {
        await backend.pendingNotificationIdentifiers()
    }
}
