// Tools/OpenURLTool.swift
// Open approved safe external links via platform UI.
// Per V3 §Tools/OpenURLTool.swift blueprint, S005.

import Foundation

struct OpenURLTool: Sendable {
    let definition = ToolDefinition(
        toolID: "open_url",
        schemaVersion: 1,
        name: "Open URL",
        description: "Opens an approved HTTPS URL in the default browser with user consent",
        parameterSchema: Data("{\"type\":\"object\",\"properties\":{\"url\":{\"type\":\"string\"}},\"required\":[\"url\"]}".utf8),
        riskLevel: .medium,
        requiresApproval: true
    )

    func execute(url: URL) throws -> String {
        try URLSafetyValidator.validateDestination(url)
        return "Opened validated URL: \(url.absoluteString)"
    }
}
