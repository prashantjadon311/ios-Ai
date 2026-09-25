// Features/Settings/AppearanceSettingsView.swift
import SwiftUI
struct AppearanceSettingsView: View {
    var body: some View {
        Form {
            Section("Theme") {
                Text("Appearance settings — W03/W12 implementation")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Appearance")
    }
}

// Features/Settings/DiagnosticsView.swift
struct DiagnosticsView: View {
    var body: some View {
        Form {
            Section("Diagnostics") {
                Text("Redacted diagnostic logs — W13 implementation")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Diagnostics")
    }
}

// Features/Settings/StorageSettingsView.swift
struct StorageSettingsView: View {
    var body: some View {
        Form {
            Section("Storage") {
                Text("Storage info and management — W12 implementation")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Storage")
    }
}

// Features/Settings/NotificationSettingsView.swift
struct NotificationSettingsView: View {
    var body: some View {
        Form {
            Section("Notifications") {
                Text("Notification preferences — W08 implementation")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Notifications")
    }
}

// Features/Settings/SecuritySettingsView.swift
struct SecuritySettingsView: View {
    var body: some View {
        Form {
            Section("Security") {
                Text("Biometric lock settings — W02 implementation")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Security")
    }
}

// Features/Settings/AboutView.swift
struct AboutView: View {
    var body: some View {
        Form {
            Section("Personal Assistant") {
                LabeledContent("Version", value: "1.0 (V1)")
                LabeledContent("Build", value: "1")
                LabeledContent("iOS Target", value: "18.6+")
            }
            Section("Open Source") {
                Text("This app uses only Apple SDK frameworks. No third-party networking libraries.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Section("Privacy") {
                Text("No telemetry. No analytics. Your data stays on your device unless you explicitly choose otherwise.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("About")
    }
}

// Features/Settings/PermissionsView.swift (via navigation link)
struct PermissionsView: View {
    var body: some View {
        List {
            Section("Required") {
                PermissionRow(name: "Microphone", icon: "mic.fill", note: "For voice input")
                PermissionRow(name: "Notifications", icon: "bell.fill", note: "For task reminders")
            }
            Section("Optional") {
                PermissionRow(name: "Speech Recognition", icon: "waveform", note: "For voice-to-text")
                PermissionRow(name: "Calendar", icon: "calendar", note: "For calendar tool")
                PermissionRow(name: "Contacts", icon: "person.crop.circle", note: "For contacts lookup")
                PermissionRow(name: "Photos", icon: "photo.fill", note: "For image attachments")
                PermissionRow(name: "Reminders", icon: "checklist", note: "For reminders tool")
            }
            Section {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
        .navigationTitle("Permissions")
    }
}

struct PermissionRow: View {
    let name: String
    let icon: String
    let note: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 28)
                .foregroundStyle(.accent)
            VStack(alignment: .leading) {
                Text(name).font(.subheadline)
                Text(note).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
