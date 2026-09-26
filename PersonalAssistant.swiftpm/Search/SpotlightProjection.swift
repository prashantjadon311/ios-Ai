// Search/SpotlightProjection.swift
// COND: CoreSpotlight indexing, runtime gated and user opt-in only.
// Per V3 §Search/SpotlightProjection.swift blueprint.

import Foundation
#if canImport(CoreSpotlight)
import CoreSpotlight
#endif

final class SpotlightProjection: Sendable {
    func indexEntity(id: UUID, title: String, content: String) {
        #if canImport(CoreSpotlight)
        let item = CSSearchableItem(
            uniqueIdentifier: id.uuidString,
            domainIdentifier: "com.personalassistant.entities",
            attributeSet: {
                let attrs = CSSearchableItemAttributeSet(contentType: .text)
                attrs.title = title
                attrs.contentDescription = content
                return attrs
            }()
        )
        CSSearchableIndex.default().indexSearchableItems([item])
        #endif
    }

    func deleteEntity(id: UUID) {
        #if canImport(CoreSpotlight)
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id.uuidString])
        #endif
    }

    func purgeAll() {
        #if canImport(CoreSpotlight)
        CSSearchableIndex.default().deleteAllSearchableItems()
        #endif
    }
}
