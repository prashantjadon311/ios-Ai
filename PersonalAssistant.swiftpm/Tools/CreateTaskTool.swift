// Tools/CreateTaskTool.swift
import Foundation

struct CreateTaskTool: Sendable {
    let definition = ToolDefinition(
        toolID: "create_task",
        schemaVersion: 1,
        name: "Create Task",
        description: "Creates a new task in the local task repository",
        parameterSchema: Data("{\"type\":\"object\"}".utf8),
        riskLevel: .medium,
        requiresApproval: false
    )
}
