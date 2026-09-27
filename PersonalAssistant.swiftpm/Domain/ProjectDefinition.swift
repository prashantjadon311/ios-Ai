// Domain/ProjectDefinition.swift
// Owner-scoped project container for grouped tasks and progress tracking.
// Per V7 Phase P07 and V7 §§6, 3.4.

import Foundation

struct ProjectDefinition: Identifiable, Codable, Sendable, Hashable {
    let id: ProjectID
    let ownerID: UserID
    var title: String
    var projectDescription: String
    var categoryID: TaskCategoryID?
    var colorHex: String?
    var isArchived: Bool
    var revision: Int
    let createdAt: Date
    var updatedAt: Date

    init(
        id: ProjectID = ProjectID(),
        ownerID: UserID,
        title: String,
        projectDescription: String = "",
        categoryID: TaskCategoryID? = nil,
        colorHex: String? = nil,
        isArchived: Bool = false,
        revision: Int = 1,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.ownerID = ownerID
        self.title = title
        self.projectDescription = projectDescription
        self.categoryID = categoryID
        self.colorHex = colorHex
        self.isArchived = isArchived
        self.revision = revision
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
