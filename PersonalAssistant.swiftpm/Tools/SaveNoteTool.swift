// Tools/SaveNoteTool.swift
import Foundation

struct SaveNoteTool: Sendable {
    let definition = ToolDefinition(
        toolID: "save_note",
        schemaVersion: 1,
        name: "Save Note",
        description: "Saves a note to the assistant's memory",
        parameterSchema: Data("{\"type\":\"object\"}".utf8),
        riskLevel: .medium,
        requiresApproval: false
    )
}
