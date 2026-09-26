// Integrations/RemindersAdapter.swift
// COND: EventKit Reminders integration, runtime guarded.
// Per V3 §Integrations/RemindersAdapter.swift blueprint.

import Foundation
#if canImport(EventKit)
import EventKit
#endif

actor RemindersAdapter {
    #if canImport(EventKit)
    private let store = EKEventStore()
    #endif

    func requestAccess() async throws -> Bool {
        #if canImport(EventKit)
        if #available(iOS 17.0, *) {
            return try await store.requestFullAccessToReminders()
        } else {
            return try await store.requestAccess(to: .reminder)
        }
        #else
        return false
        #endif
    }
}
