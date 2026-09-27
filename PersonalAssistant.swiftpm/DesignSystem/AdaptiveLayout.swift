// DesignSystem/AdaptiveLayout.swift
// Unified V5 adaptive layout container (No bottom TabView; one top-right profile drawer).
// Per V5 design specification and tokens.

import SwiftUI

struct RootNavigationView: View {
    @Environment(AppSession.self) private var session
    @Environment(AppRouter.self) private var router
    @Environment(AppContainer.self) private var container
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly

    var body: some View {
        Group {
            if session.isLocked {
                AppLockView()
            } else if session.requiresOnboarding {
                OnboardingView()
            } else {
                rootContent
            }
        }
        .preferredColorScheme(session.preferredColorScheme)
        .sheet(item: Bindable(router).presentedSheet) { sheet in
            sheetDestination(for: sheet)
                .preferredColorScheme(session.preferredColorScheme)
        }
    }

    @ViewBuilder
    private var rootContent: some View {
        ZStack {
            if horizontalSizeClass == .regular {
                // iPad V5: Initial sidebar hidden, toggled via drawer or toolbar
                NavigationSplitView(columnVisibility: $columnVisibility) {
                    sidebarList
                } detail: {
                    destinationView(for: router.selectedDestination)
                }
                .navigationSplitViewStyle(.balanced)
            } else {
                // iPhone V5: No TabView bottom navigation bar
                destinationView(for: router.selectedDestination)
            }

            // Unified right-side profile and navigation drawer
            ProfileNavigationDrawerView()
        }
    }

    // MARK: - iPad Sidebar List (Optional pinned sidebar controlled from inside drawer)

    @ViewBuilder
    private var sidebarList: some View {
        List(selection: Binding<AppDestination?>(
            get: { router.selectedDestination },
            set: { if let destination = $0 { router.selectedDestination = destination } }
        )) {
            Section("Assistant") {
                NavigationLink(value: AppDestination.dashboard) {
                    Label("Dashboard", systemImage: "sparkles")
                }
                NavigationLink(value: AppDestination.history) {
                    Label("Conversations", systemImage: "bubble.left.and.bubble.right")
                }
                NavigationLink(value: AppDestination.tasks) {
                    Label("Tasks & Projects", systemImage: "checklist")
                }
                NavigationLink(value: AppDestination.reminders) {
                    Label("Reminders", systemImage: "bell")
                }
                NavigationLink(value: AppDestination.memory) {
                    Label("Memory", systemImage: "brain")
                }
            }
            Section("Preferences") {
                NavigationLink(value: AppDestination.assistants) {
                    Label("Assistants", systemImage: "person.2")
                }
                NavigationLink(value: AppDestination.configuration) {
                    Label("AI Providers", systemImage: "cpu")
                }
                NavigationLink(value: AppDestination.settings) {
                    Label("Settings", systemImage: "gearshape")
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Personal Assistant")
    }

    // MARK: - Destination View

    @ViewBuilder
    private func destinationView(for destination: AppDestination) -> some View {
        switch destination {
        case .dashboard:
            DashboardView()
        case .history:
            HistoryView()
        case .tasks:
            TaskDashboardView()
        case .reminders:
            RemindersView()
        case .memory:
            MemoryBrowserView()
        case .assistants:
            AssistantProfileView()
        case .configuration:
            ConfigurationView()
        case .settings:
            SettingsView()
        case .profile:
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
