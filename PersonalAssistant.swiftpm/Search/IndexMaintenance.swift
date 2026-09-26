// Search/IndexMaintenance.swift
// Prunes deleted documents and maintains local search index hygiene.
// Per V3 §Search/IndexMaintenance.swift blueprint.

import Foundation

actor IndexMaintenanceWorker {
    private let index: LocalTextIndex

    init(index: LocalTextIndex) {
        self.index = index
    }

    func purgeDeleted(ids: [UUID]) async {
        for id in ids {
            await index.remove(documentID: id)
        }
    }
}
