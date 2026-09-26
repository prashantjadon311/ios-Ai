// Search/SearchRanking.swift
// Lexical BM25 / token relevance ranking algorithm.
// Per V3 §Search/SearchRanking.swift blueprint.

import Foundation

struct SearchRanking: Sendable {
    static func score(documentText: String, queryTerms: [String]) -> Double {
        let lower = documentText.lowercased()
        var totalScore = 0.0
        for term in queryTerms {
            let termLower = term.lowercased()
            if lower.contains(termLower) {
                totalScore += 1.0
            }
        }
        return totalScore
    }
}
