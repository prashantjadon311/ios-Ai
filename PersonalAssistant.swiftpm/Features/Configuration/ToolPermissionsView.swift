// Features/Configuration/ToolPermissionsView.swift
// Security boundary for tool execution permissions.
// All external side-effect tools default to disabled (false) until explicitly enabled by the user.

import SwiftUI

struct ToolPermissionsView: View {
    @Environment(AppContainer.self) private var container
    @Environment(AppSession.self) private var session

    @State private var enableCalendar = false
    @State private var enableReminders = false
    @State private var enableOpenURL = false

    var body: some View {
        Form {
            Section {
                Toggle("Calendar Access", isOn: $enableCalendar)
                Toggle("Reminders Access", isOn: $enableReminders)
                Toggle("Open URLs in Browser", isOn: $enableOpenURL)
            } header: {
                Text("External Side-Effect Tools")
            } footer: {
                Text("External tools are disabled by default. When enabled, any external action or side effect still requires explicit confirmation via the Approvals center prior to execution.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Tool Permissions")
    }
}
