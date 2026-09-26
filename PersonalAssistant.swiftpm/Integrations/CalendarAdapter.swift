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
}
