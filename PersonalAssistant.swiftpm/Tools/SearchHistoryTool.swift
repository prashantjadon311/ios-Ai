// Tools/SearchHistoryTool.swift
import Foundation

struct SearchHistoryTool: Sendable {
    let definition = ToolDefinition(
        toolID: "search_history",
        schemaVersion: 1,
        name: "Search History",
        description: "Searches conversation history for past context",
        parameterSchema: Data("{\"type\":\"object\"}".utf8),
        riskLevel: .low,
        requiresApproval: false
    )
}
