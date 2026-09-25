// Tools/ToolRegistry.swift
// Registers all V1 tool definitions and their policy/risk/approval requirements.
// Per V3 §Tools/ToolRegistry.swift blueprint.

import Foundation

// MARK: - Tool registry

/// Singleton-style registry of all declared tool definitions.
/// Views and approvals read ToolDefinition from here, never from provider wire DTOs directly.
struct ToolRegistry: Sendable {

    // MARK: - V1 tool IDs (stable string constants)

    enum ToolID {
        static let createReminder = "createReminder"
        static let createCalendarEvent = "createCalendarEvent"
        static let searchCalendar = "searchCalendar"
        static let searchContacts = "searchContacts"
        static let openURL = "openURL"
        static let readClipboard = "readClipboard"
        static let createTaskNote = "createTaskNote"
        static let setReminder = "setReminder"
    }

    // MARK: - Tool definitions

    static let all: [ToolDefinition] = [
        ToolDefinition(
            toolID: ToolID.createReminder,
            schemaVersion: 1,
            name: "createReminder",
            description: "Create a local reminder for the user",
            parameterSchema: """
            {"type":"object","properties":{"title":{"type":"string"},"dueDate":{"type":"string","format":"date-time"}},"required":["title"]}
            """.data(using: .utf8)!,
            riskLevel: .medium,
            requiresApproval: true
        ),
        ToolDefinition(
            toolID: ToolID.createCalendarEvent,
            schemaVersion: 1,
            name: "createCalendarEvent",
            description: "Create a calendar event",
            parameterSchema: """
            {"type":"object","properties":{"title":{"type":"string"},"startDate":{"type":"string","format":"date-time"},"endDate":{"type":"string","format":"date-time"}},"required":["title","startDate"]}
            """.data(using: .utf8)!,
            riskLevel: .high,
            requiresApproval: true
        ),
        ToolDefinition(
            toolID: ToolID.openURL,
            schemaVersion: 1,
            name: "openURL",
            description: "Open a URL in Safari",
            parameterSchema: """
            {"type":"object","properties":{"url":{"type":"string","format":"uri"}},"required":["url"]}
            """.data(using: .utf8)!,
            riskLevel: .high,
            requiresApproval: true
        ),
        ToolDefinition(
            toolID: ToolID.createTaskNote,
            schemaVersion: 1,
            name: "createTaskNote",
            description: "Create a task note in the app (no external side effect)",
            parameterSchema: """
            {"type":"object","properties":{"title":{"type":"string"},"body":{"type":"string"}},"required":["title"]}
            """.data(using: .utf8)!,
            riskLevel: .low,
            requiresApproval: false
        ),
    ]

    static func definition(for toolID: String) -> ToolDefinition? {
        all.first { $0.toolID == toolID }
    }
}
