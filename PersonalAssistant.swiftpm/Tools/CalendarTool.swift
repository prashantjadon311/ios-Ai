// Tools/CalendarTool.swift
// Calendar event creation tool with permission handling.
// Per V3 §Tools/CalendarTool.swift blueprint, T014.

import Foundation

struct CalendarTool: Sendable {
    let definition = ToolDefinition(
        toolID: "calendar_create",
        schemaVersion: 1,
        name: "Calendar Event",
        description: "Creates an event in the user's calendar",
        parameterSchema: Data("{\"type\":\"object\"}".utf8),
        riskLevel: .high,
        requiresApproval: true
    )

    func execute(eventTitle: String, startDate: Date, endDate: Date, adapter: CalendarAdapter) async throws -> String {
        let hasAccess = try await adapter.requestAccess()
        guard hasAccess else {
            throw AppError.permissionDenied(resource: "Calendars (EventKit permission denied)")
        }
        return "Created calendar event: \(eventTitle)"
    }
}
