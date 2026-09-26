// Integrations/CalendarAdapter.swift
// COND: EventKit Calendar integration, runtime guarded.
// Per V3 §Integrations/CalendarAdapter.swift blueprint.

import Foundation
#if canImport(EventKit)
import EventKit
#endif

actor CalendarAdapter {
    #if canImport(EventKit)
    private let store = EKEventStore()
    #endif

    func requestAccess() async throws -> Bool {
        #if canImport(EventKit)
        if #available(iOS 17.0, *) {
            return try await store.requestFullAccessToEvents()
        } else {
            return try await store.requestAccess(to: .event)
        }
        #else
        return false
        #endif
    }

    func createEvent(title: String, startDate: Date, endDate: Date) async throws -> String {
        #if canImport(EventKit)
        let hasAccess = try await requestAccess()
        guard hasAccess else {
            throw AppError.permissionDenied(resource: "Calendars (EventKit permission denied)")
        }
        let event = EKEvent(eventStore: store)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = store.defaultCalendarForNewEvents
        try store.save(event, span: .thisEvent)
        return event.eventIdentifier ?? UUID().uuidString
        #else
        throw AppError.permissionDenied(resource: "EventKit unavailable on this platform")
        #endif
    }
}
