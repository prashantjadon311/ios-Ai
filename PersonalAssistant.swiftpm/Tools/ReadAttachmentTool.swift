// Tools/ReadAttachmentTool.swift
import Foundation

struct ReadAttachmentTool: Sendable {
    let definition = ToolDefinition(
        toolID: "read_attachment",
        schemaVersion: 1,
        name: "Read Attachment",
        description: "Reads text from an attachment",
        parameterSchema: Data("{\"type\":\"object\"}".utf8),
        riskLevel: .low,
        requiresApproval: false
    )
}
