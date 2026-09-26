// Persistence/SchemaV1.swift
// VersionedSchema declaration listing all V1 @Model types.
// Per V3 §Persistence placement: SchemaV1 lists only, no other definitions.

import Foundation
import SwiftData

enum SchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }

    static var models: [any PersistentModel.Type] {
        [
            StoredUserProfile.self,
            StoredAssistantProfile.self,
            StoredConversation.self,
            StoredMessage.self,
            StoredMemoryItem.self,
            StoredTaskDefinition.self,
            StoredTaskRun.self,
            StoredProviderConfiguration.self,
            StoredApprovalRequest.self,
            StoredAuditEvent.self,
            StoredAppPreference.self,
            StoredAttachment.self,
            StoredToolReceipt.self,
        ]
    }
}
