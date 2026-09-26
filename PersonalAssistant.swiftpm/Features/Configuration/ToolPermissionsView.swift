// Features/Configuration/ToolPermissionsView.swift
import SwiftUI

struct ToolPermissionsView: View {
    @State private var enableCalendar = true
    @State private var enableReminders = true
    @State private var enableOpenURL = true

    var body: some View {
        Form {
            Section("Permitted Actions") {
                Toggle("Calendar Access", isOn: $enableCalendar)
                Toggle("Reminders Access", isOn: $enableReminders)
                Toggle("Open URLs in Browser", isOn: $enableOpenURL)
            }
        }
        .navigationTitle("Tool Permissions")
    }
}
