// DesignSystem/AdaptiveLayout.swift
// Compact (iPhone TabView) and regular (iPad NavigationSplitView) layout container.
// Per V3 §DesignSystem/AdaptiveLayout.swift blueprint.

import SwiftUI

struct RootNavigationView: View {
    @Environment(AppSession.self) private var session
    @Environment(AppRouter.self) private var router
    @Environment(AppContainer.self) private var container
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if session.requiresOnboarding {
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
            DashboardView(viewModel: container.makeDashboardViewModel())
                .tabItem {
                    Label("Dashboard", systemImage: "sparkles")
                }
                .tag(AppDestination.dashboard)

            TaskDashboardView(viewModel: container.makeTasksViewModel())
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }
                .tag(AppDestination.tasks)

            HistoryView(viewModel: container.makeHistoryViewModel())
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(AppDestination.history)

            ConfigurationView()
                .tabItem {
                    Label("Configure", systemImage: "slider.horizontal.3")
                }
                .tag(AppDestination.configuration)

            SettingsView(viewModel: container.makeSettingsViewModel())
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
            DashboardView(viewModel: container.makeDashboardViewModel())
        case .tasks:
            TaskDashboardView(viewModel: container.makeTasksViewModel())
        case .history:
            HistoryView(viewModel: container.makeHistoryViewModel())
        case .configuration:
            ConfigurationView()
        case .settings:
            SettingsView(viewModel: container.makeSettingsViewModel())
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
