// Features/Settings/AppearanceSettingsView.swift
import SwiftUI

struct AppearanceSettingsView: View {
    @Environment(AppSession.self) private var session
    @State private var appearance: AppearanceMode = .system

    var body: some View {
        Form {
            Section("Theme") {
                Picker("Appearance", selection: $appearance) {
                    Text("System").tag(AppearanceMode.system)
                    Text("Light").tag(AppearanceMode.light)
                    Text("Dark").tag(AppearanceMode.dark)
                }
                .pickerStyle(.inline)
            }
            Section("Information") {
                Text("Adapts typography, contrast, and layout to system Dynamic Type and appearance preferences.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Appearance")
        .onAppear {
            appearance = session.preferences?.appearanceMode ?? .system
        }
    }
}

// Features/Settings/DiagnosticsView.swift
struct DiagnosticsView: View {
    @Environment(AppContainer.self) private var container

    var body: some View {
        Form {
            Section("System Status") {
                LabeledContent("Network Connectivity", value: container.capabilityCenter.snapshot.networkAvailable ? "Connected" : "Offline")
                LabeledContent("App Sandboxing", value: "Enforced")
                LabeledContent("Logging Policy", value: "Zero Credential / Zero Secret")
            }
            Section("Privacy Guarantee") {
                Text("Diagnostics never transmit remote telemetry. Logs and traces remain local to this device.")
                    .font(.caption)
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
            Section("Local Storage") {
                LabeledContent("Engine", value: "SwiftData (Local SQLite)")
                LabeledContent("Cloud Sync", value: "Disabled (Device Only)")
                LabeledContent("Attachments", value: "Sandboxed Local Storage")
            }
            Section("Information") {
                Text("All conversations, memory entries, and scheduled tasks are stored on-device. No external cloud database is used.")
                    .font(.caption)
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
            Section("Local Alerts") {
                LabeledContent("Engine", value: "UserNotifications")
                LabeledContent("Delivery", value: "Local On-Device Alarms")
            }
            Section("System Permissions") {
                Text("Task reminders and scheduled alerts fire locally. Manage system alert permissions in iOS Settings.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button("Open iOS Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
        .navigationTitle("Notifications")
    }
}

// Features/Settings/SecuritySettingsView.swift
struct SecuritySettingsView: View {
    @Environment(AppSession.self) private var session

    var body: some View {
        Form {
            Section("Keychain & Credential Protection") {
                LabeledContent("Protection Class", value: "ThisDeviceOnly")
                LabeledContent("Storage", value: "iOS Secure Enclave / Keychain")
            }
            Section("App Lock") {
                Button(role: .destructive) {
                    session.lock()
                } label: {
                    Label("Lock App Immediately", systemImage: "lock.fill")
                }
            }
            Section("About") {
                Text("API keys and secrets are protected using kSecAttrAccessibleWhenUnlockedThisDeviceOnly and are never included in backups or exported.")
                    .font(.caption)
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
