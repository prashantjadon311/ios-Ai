// Tools/CreateReminderTool.swift
import Foundation

struct CreateReminderTool: Sendable {
    let definition = ToolDefinition(
        toolID: "create_reminder",
        schemaVersion: 1,
        name: "Create Reminder",
        description: "Creates a reminder alert in the user's reminders",
        parameterSchema: Data("{\"type\":\"object\"}".utf8),
        riskLevel: .high,
        requiresApproval: true
    )
}
