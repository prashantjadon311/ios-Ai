// Tools/ToolRegistry.swift
// Registers all V1 tool definitions and their policy/risk/approval requirements.
// Per V3 §Tools/ToolRegistry.swift blueprint and Algorithm B05.

import Foundation

// MARK: - Tool registry

/// Singleton-style registry of all declared tool definitions.
/// Views and approvals read ToolDefinition from here, never from provider wire DTOs directly.
struct ToolRegistry: Sendable {

    // MARK: - V1 tool IDs (canonical snake_case constants with camelCase aliases)

    enum ToolID {
        static let createReminder = "create_reminder"
        static let calendarCreate = "calendar_create"
        static let openURL = "open_url"
        static let contactsLookup = "contacts_lookup"
        static let createTask = "create_task"
        static let saveNote = "save_note"
        static let searchHistory = "search_history"
        static let readAttachment = "read_attachment"

        // Aliases for compatibility
        static let legacyCreateReminder = "createReminder"
        static let legacyCalendarCreate = "createCalendarEvent"
        static let legacyOpenURL = "openURL"
        static let legacyContactsLookup = "searchContacts"
        static let legacyCreateTask = "createTaskNote"
    }

    // MARK: - Tool definitions

    static let all: [ToolDefinition] = [
        ToolDefinition(
            toolID: ToolID.createReminder,
            schemaVersion: 1,
            name: "create_reminder",
            description: "Create a local reminder for the user with title and optional due date",
            parameterSchema: """
            {"type":"object","properties":{"title":{"type":"string"},"dueDate":{"type":"string","format":"date-time"}},"required":["title"]}
            """.data(using: .utf8)!,
            riskLevel: .high,
            requiresApproval: true
        ),
        ToolDefinition(
            toolID: ToolID.calendarCreate,
            schemaVersion: 1,
            name: "calendar_create",
            description: "Create an event in the user's calendar",
            parameterSchema: """
            {"type":"object","properties":{"title":{"type":"string"},"startDate":{"type":"string","format":"date-time"},"endDate":{"type":"string","format":"date-time"}},"required":["title","startDate"]}
            """.data(using: .utf8)!,
            riskLevel: .high,
            requiresApproval: true
        ),
        ToolDefinition(
            toolID: ToolID.openURL,
            schemaVersion: 1,
            name: "open_url",
            description: "Open an approved HTTPS URL in Safari",
            parameterSchema: """
            {"type":"object","properties":{"url":{"type":"string","format":"uri"}},"required":["url"]}
            """.data(using: .utf8)!,
            riskLevel: .high,
            requiresApproval: true
        ),
        ToolDefinition(
            toolID: ToolID.contactsLookup,
            schemaVersion: 1,
            name: "contacts_lookup",
            description: "Queries the user's contacts by name with permission gating",
            parameterSchema: """
            {"type":"object","properties":{"query":{"type":"string"}},"required":["query"]}
            """.data(using: .utf8)!,
            riskLevel: .medium,
            requiresApproval: true
        ),
        ToolDefinition(
            toolID: ToolID.createTask,
            schemaVersion: 1,
            name: "create_task",
            description: "Create a local task in the app",
            parameterSchema: """
            {"type":"object","properties":{"title":{"type":"string"},"notes":{"type":"string"}},"required":["title"]}
            """.data(using: .utf8)!,
            riskLevel: .medium,
            requiresApproval: false
        ),
        ToolDefinition(
            toolID: ToolID.saveNote,
            schemaVersion: 1,
            name: "save_note",
            description: "Saves a note to the assistant's memory",
            parameterSchema: """
            {"type":"object","properties":{"content":{"type":"string"},"category":{"type":"string"}},"required":["content"]}
            """.data(using: .utf8)!,
            riskLevel: .medium,
            requiresApproval: false
        ),
        ToolDefinition(
            toolID: ToolID.searchHistory,
            schemaVersion: 1,
            name: "search_history",
            description: "Searches conversation history for past context",
            parameterSchema: """
            {"type":"object","properties":{"query":{"type":"string"}},"required":["query"]}
            """.data(using: .utf8)!,
            riskLevel: .low,
            requiresApproval: false
        ),
        ToolDefinition(
            toolID: ToolID.readAttachment,
            schemaVersion: 1,
            name: "read_attachment",
            description: "Reads content or extracted text of an attachment",
            parameterSchema: """
            {"type":"object","properties":{"attachmentID":{"type":"string"}},"required":["attachmentID"]}
            """.data(using: .utf8)!,
            riskLevel: .low,
            requiresApproval: false
        )
    ]

    static func definition(for toolID: String) -> ToolDefinition? {
        let normalized = normalize(toolID)
        return all.first { $0.toolID == toolID || normalize($0.toolID) == normalized }
    }

    private static func normalize(_ id: String) -> String {
        switch id {
        case "createReminder", "create_reminder": return "create_reminder"
        case "createCalendarEvent", "calendar_create", "calendarCreate": return "calendar_create"
        case "openURL", "open_url", "openUrl": return "open_url"
        case "searchContacts", "contacts_lookup", "contactsLookup": return "contacts_lookup"
        case "createTaskNote", "create_task", "createTask": return "create_task"
        case "saveNote", "save_note": return "save_note"
        case "searchHistory", "search_history": return "search_history"
        case "readAttachment", "read_attachment": return "read_attachment"
        default: return id
        }
    }
}
