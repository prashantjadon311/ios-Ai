// DesignSystem/AdaptiveLayout.swift
// Compact (iPhone TabView) and regular (iPad NavigationSplitView) layout container.
// Per V3 §DesignSystem/AdaptiveLayout.swift blueprint.
// Views retrieve dependencies via Environment, matching parameterless view initializers.

import SwiftUI

struct RootNavigationView: View {
    @Environment(AppSession.self) private var session
    @Environment(AppRouter.self) private var router
    @Environment(AppContainer.self) private var container
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if session.isLocked {
                AppLockView()
            } else if session.requiresOnboarding {
                OnboardingView()
            } else if horizontalSizeClass == .compact {
                compactTabView
            } else {
                regularSplitView
            }
        }
        .sheet(item: Bindable(router).presentedSheet) { sheet in
            sheetDestination(for: sheet)
        }
    }

    // MARK: - iPhone Compact TabView

    @ViewBuilder
    private var compactTabView: some View {
        TabView(selection: Bindable(router).selectedDestination) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "sparkles")
                }
                .tag(AppDestination.dashboard)

            TaskDashboardView()
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }
                .tag(AppDestination.tasks)

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(AppDestination.history)

            ConfigurationView()
                .tabItem {
                    Label("Configure", systemImage: "slider.horizontal.3")
                }
                .tag(AppDestination.configuration)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(AppDestination.settings)
        }
    }

    // MARK: - iPad Regular SplitView

    @ViewBuilder
    private var regularSplitView: some View {
        NavigationSplitView {
            List(selection: Bindable(router).selectedDestination) {
                Section("Assistant") {
                    NavigationLink(value: AppDestination.dashboard) {
                        Label("Dashboard", systemImage: "sparkles")
                    }
                    NavigationLink(value: AppDestination.tasks) {
                        Label("Tasks", systemImage: "checklist")
                    }
                    NavigationLink(value: AppDestination.history) {
                        Label("History", systemImage: "clock.arrow.circlepath")
                    }
                }
                Section("Preferences") {
                    NavigationLink(value: AppDestination.configuration) {
                        Label("Configuration", systemImage: "slider.horizontal.3")
                    }
                    NavigationLink(value: AppDestination.settings) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Assistant")
        } detail: {
            destinationView(for: router.selectedDestination)
        }
    }

    @ViewBuilder
    private func destinationView(for destination: AppDestination) -> some View {
        switch destination {
        case .dashboard:
            DashboardView()
        case .tasks:
            TaskDashboardView()
        case .history:
            HistoryView()
        case .configuration:
            ConfigurationView()
        case .settings:
            SettingsView()
        }
    }

    @ViewBuilder
    private func sheetDestination(for sheet: AppSheet) -> some View {
        NavigationStack {
            switch sheet {
            case .chat(let id):
                ChatView(conversationID: id)
            case .newConversation:
                ChatView(conversationID: nil)
            case .approvals:
                ApprovalCenterView()
            case .onboarding:
                OnboardingView()
            case .taskEditor(let id):
                TaskEditorView(taskID: id)
            case .assistantSelector:
                AssistantSwitcher()
            case .storeRecovery(let reason):
                StoreRecoveryView(reason: reason, storeURL: nil)
            }
        }
    }
}

// MARK: - AppLockView

struct AppLockView: View {
    @Environment(AppSession.self) private var session
    @State private var unlockError: String?

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "lock.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.accentColor)

            Text("Personal Assistant is Locked")
                .font(.title2)
                .bold()

            if let error = unlockError {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button {
                Task {
                    let gate = BiometricGate()
                    do {
                        let success = try await gate.authenticate()
                        if success {
                            session.unlock()
                        } else {
                            unlockError = "Authentication failed. Passcode required."
                        }
                    } catch {
                        unlockError = error.localizedDescription
                    }
                }
            } label: {
                Label("Unlock", systemImage: "faceid")
                    .frame(minWidth: 160)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}
