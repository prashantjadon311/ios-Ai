// Tools/ToolRiskClassifier.swift
// Classifies risk tier of tool definitions.
// Per V3 §Tools/ToolRiskClassifier.swift blueprint.

import Foundation

struct ToolRiskClassifier: Sendable {
    static func classify(toolID: String) -> ToolRiskLevel {
        switch toolID {
        case "open_url", "search_history", "read_attachment":
            return .low
        case "create_task", "save_note", "contacts_lookup":
            return .medium
        case "create_reminder", "calendar_create":
            return .high
        default:
            return .high
        }
    }
}
