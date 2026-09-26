// Persistence/RepositoryTransaction.swift
// Actor-confined atomic transaction helper for SwiftData mutations.
// Per V3 §Persistence/RepositoryTransaction.swift blueprint.

import Foundation
import SwiftData

struct RepositoryTransaction: Sendable {
    static func perform<T>(on context: ModelContext, action: () throws -> T) throws -> T {
        let result = try action()
        try context.save()
        return result
    }
}
