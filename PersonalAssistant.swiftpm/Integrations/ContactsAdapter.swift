// Integrations/ContactsAdapter.swift
// COND: Contacts framework integration, runtime guarded.
// Per V3 §Integrations/ContactsAdapter.swift blueprint.

import Foundation
#if canImport(Contacts)
import Contacts
#endif

actor ContactsAdapter {
    func requestAccess() async throws -> Bool {
        #if canImport(Contacts)
        let store = CNContactStore()
        return try await store.requestAccess(for: .contacts)
        #else
        return false
        #endif
    }
}
