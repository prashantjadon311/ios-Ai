// Domain/TaskCategory.swift
// User-defined category for tasks and reminders.
// Per V7 Phase P07 and V7 §§6, 3.4.

import Foundation

struct TaskCategory: Identifiable, Codable, Sendable, Hashable {
    let id: TaskCategoryID
    let ownerID: UserID
    var name: String
    var iconName: String?
    var colorHex: String?
    var isArchived: Bool
    let createdAt: Date
    var updatedAt: Date

    init(
        id: TaskCategoryID = TaskCategoryID(),
        ownerID: UserID,
        name: String,
        iconName: String? = nil,
        colorHex: String? = nil,
        isArchived: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.ownerID = ownerID
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
