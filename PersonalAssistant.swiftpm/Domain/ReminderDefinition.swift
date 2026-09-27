// Domain/ReminderDefinition.swift
// Standalone or task-linked reminder with timezone and recurrence support.
// Per V7 Phase P07 and V7 §§6, 3.4.

import Foundation

struct ReminderDefinition: Identifiable, Codable, Sendable, Hashable {
    let id: ReminderID
    let ownerID: UserID
    var taskID: TaskID?
    var title: String
    var notes: String?
    var dueDate: Date
    var timezoneIdentifier: String
    var categoryID: TaskCategoryID?
    var isCompleted: Bool
    var completedAt: Date?
    var notificationIdentifier: String?
    var recurrence: TaskRecurrence?
    var revision: Int
    var isArchived: Bool
    let createdAt: Date
    var updatedAt: Date

    init(
        id: ReminderID = ReminderID(),
        ownerID: UserID,
        taskID: TaskID? = nil,
        title: String,
        notes: String? = nil,
        dueDate: Date,
        timezoneIdentifier: String = TimeZone.current.identifier,
        categoryID: TaskCategoryID? = nil,
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        notificationIdentifier: String? = nil,
        recurrence: TaskRecurrence? = nil,
        revision: Int = 1,
        isArchived: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.ownerID = ownerID
        self.taskID = taskID
        self.title = title
        self.notes = notes
        self.dueDate = dueDate
        self.timezoneIdentifier = timezoneIdentifier
        self.categoryID = categoryID
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.notificationIdentifier = notificationIdentifier
        self.recurrence = recurrence
        self.revision = revision
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var timezone: TimeZone? { TimeZone(identifier: timezoneIdentifier) }
}
