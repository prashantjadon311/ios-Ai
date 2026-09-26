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
        do {
            let eventID = try await adapter.createEvent(title: eventTitle, startDate: startDate, endDate: endDate)
            return "Created calendar event: \(eventTitle) (id: \(eventID))"
        } catch let appErr as AppError {
            throw appErr
        } catch {
            throw AppError.permissionDenied(resource: "Calendars (EventKit permission denied)")
        }
    }
}
