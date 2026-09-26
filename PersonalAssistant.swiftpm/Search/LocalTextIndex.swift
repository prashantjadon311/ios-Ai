// Search/LocalTextIndex.swift
// Inverted word index for fast local lexical search.
// Per V3 §Search/LocalTextIndex.swift blueprint.

import Foundation

actor LocalTextIndex {
    private var index: [String: Set<UUID>] = [:]

    func index(text: String, documentID: UUID) {
        let tokens = tokenize(text)
        for token in tokens {
            var set = index[token] ?? Set<UUID>()
            set.insert(documentID)
            index[token] = set
        }
    }

    func search(query: String) -> Set<UUID> {
        let tokens = tokenize(query)
        guard !tokens.isEmpty else { return [] }
        var result: Set<UUID>?
        for token in tokens {
            let hits = index[token] ?? []
            if result == nil {
                result = hits
            } else {
                result = result?.intersection(hits)
            }
        }
        return result ?? []
    }

    func remove(documentID: UUID) {
        for (token, var set) in index {
            if set.contains(documentID) {
                set.remove(documentID)
                index[token] = set
            }
        }
    }

    private func tokenize(_ text: String) -> [String] {
        text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 1 }
    }
}
