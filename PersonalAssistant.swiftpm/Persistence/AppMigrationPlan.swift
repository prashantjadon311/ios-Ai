// Persistence/AppMigrationPlan.swift
// Migration plan — no migrations until V2 schema exists.
// Per V3 §Persistence/StoreModels.swift: no migration stage until a real V2 exists.

import Foundation
import SwiftData

/// V1 has no migration stages — single-version schema.
/// When V2 is needed, add a MigrationStage here with fromVersion: SchemaV1.
enum AppMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [SchemaV1.self] }
    static var stages: [MigrationStage] { [] }  // No migrations yet
}
