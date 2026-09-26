// Tools/ContactsLookupTool.swift
import Foundation

struct ContactsLookupTool: Sendable {
    let definition = ToolDefinition(
        toolID: "contacts_lookup",
        schemaVersion: 1,
        name: "Contacts Lookup",
        description: "Queries the user's contacts by name",
        parameterSchema: Data("{\"type\":\"object\"}".utf8),
        riskLevel: .medium,
        requiresApproval: true
    )
}
