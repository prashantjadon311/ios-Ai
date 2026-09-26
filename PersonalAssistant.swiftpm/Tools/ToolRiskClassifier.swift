// Tools/ToolRiskClassifier.swift
// Classifies risk tier of tool definitions.
// Per V3 §Tools/ToolRiskClassifier.swift blueprint.

import Foundation

struct ToolRiskClassifier: Sendable {
    static func classify(toolID: String) -> ToolRiskLevel {
        switch toolID {
        case "search_history", "searchHistory", "read_attachment", "readAttachment":
            return .low
        case "create_task", "createTask", "createTaskNote", "save_note", "saveNote", "contacts_lookup", "searchContacts":
            return .medium
        case "open_url", "openURL", "create_reminder", "createReminder", "calendar_create", "createCalendarEvent":
            return .high
        default:
            return .high
        }
    }
}
