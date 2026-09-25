// Integrations/IntegrationRegistry.swift
// Integration service provider and runtime framework capability registry.
// Per V3 §Integrations/IntegrationRegistry.swift blueprint.

import Foundation

struct IntegrationRegistry: Sendable {
    let calendarAdapter = CalendarAdapter()
    let contactsAdapter = ContactsAdapter()
    let remindersAdapter = RemindersAdapter()

    init() {}
}
