// Tasks/LocalReminderScheduler.swift
// UserNotifications integration for local task alerts.
// Per V3 §Tasks/LocalReminderScheduler.swift blueprint, T016, S010.

import Foundation
#if canImport(UserNotifications)
import UserNotifications
#endif

actor LocalReminderScheduler {
    /// Schedules a local notification reminder if permissions permit.
    /// In accordance with T016, if notifications are denied, throws permissionDenied so
    /// task remains stored and marked unscheduled, without falsely claiming alert was delivered.
    func scheduleReminder(taskID: TaskID, title: String, fireDate: Date) async throws {
        #if canImport(UserNotifications)
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
            identifier: "task_\(taskID.rawValue.uuidString)",
            content: content,
            trigger: trigger
        )
        try await center.add(request)
        #endif
    }

    /// Cancels any pending notification requests for the task (S010).
    func cancelReminder(taskID: TaskID) async {
        #if canImport(UserNotifications)
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["task_\(taskID.rawValue.uuidString)"])
        #endif
    }
}
