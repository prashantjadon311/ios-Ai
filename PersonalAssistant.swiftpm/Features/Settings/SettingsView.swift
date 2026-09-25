// Features/Settings/SettingsView.swift
// Settings screen — lock, privacy, appearance, permissions, diagnostics, clear data.

import SwiftUI

struct SettingsView: View {
    @Environment(AppContainer.self) private var container
    @Environment(AppSession.self) private var session
    @State private var viewModel: SettingsViewModel?
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    settingsForm(vm)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Settings")
            .task {
                let vm = container.makeSettingsViewModel()
                viewModel = vm
                await vm.load()
            }
        }
    }

    @ViewBuilder
    private func settingsForm(_ vm: SettingsViewModel) -> some View {
        Form {
            // Account
            Section("Account") {
                if let profile = session.currentProfile {
                    LabeledContent("Name", value: profile.displayName)
                }
                Button(role: .destructive) {
                    vm.onLock()
                } label: {
                    Label("Lock App", systemImage: "lock.fill")
                }
                .accessibilityLabel("Lock the app")
            }

            // Privacy
            Section("Privacy") {
                LabeledContent("Mode") {
                    Text(vm.currentPrivacyMode == .privateOnly ? "Private Only" : "Cloud Allowed")
                        .foregroundStyle(vm.currentPrivacyMode == .privateOnly ? .orange : .secondary)
                }
                NavigationLink("Privacy Settings") {
                    PrivacySettingsView()
                }
            }

            // Appearance
            Section("Appearance") {
                LabeledContent("Theme") {
                    Text(vm.currentAppearance.rawValue.capitalized)
                }
                NavigationLink("Appearance") {
                    AppearanceSettingsView()
                }
            }

            // Permissions
            Section("Permissions") {
                NavigationLink("App Permissions") {
                    PermissionsView()
                }
            }

            // Diagnostics
            Section("Diagnostics") {
                NavigationLink("Diagnostics") {
                    DiagnosticsView()
                }
            }

            // Data
            Section("Data") {
                NavigationLink("Storage") {
                    StorageSettingsView()
                }
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Label("Clear All Data", systemImage: "trash.fill")
                }
                .accessibilityLabel("Clear all app data")
            }

            // About
            Section("About") {
                NavigationLink("About") {
                    AboutView()
                }
            }
        }
        .alert("Clear All Data?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                // W12 — full data deletion implementation
            }
        } message: {
            Text("This will permanently delete all conversations, tasks, memories and settings. API keys must be re-entered.")
        }
    }
}
