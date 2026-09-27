// Features/Dashboard/DashboardView.swift
// Primary Dashboard screen — active assistant, quick ask, recent conversations, today's tasks.

import SwiftUI

struct DashboardView: View {
    @Environment(AppSession.self) private var session
    @Environment(AppRouter.self) private var router
    @Environment(AppContainer.self) private var container
    @State private var viewModel: DashboardViewModel?
    @State private var quickAskText: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // Central AI Voice Visual (V5: pearl orb in light, warm amber waveform in dark)
                        AIVoiceCenterVisual(state: .idle, size: 100)
                            .padding(.top, AppTheme.Spacing.sm)

                        // Active assistant header
                        assistantHeader

                        // Recent conversations
                        if let vm = viewModel, !vm.recentConversations.isEmpty {
                            recentConversationsSection(vm)
                        }

                        // Today's tasks
                        if let vm = viewModel, !vm.todayTasks.isEmpty {
                            todayTasksSection(vm)
                        }

                        // Empty state when no content
                        if let vm = viewModel, vm.recentConversations.isEmpty && vm.todayTasks.isEmpty && !vm.isLoading {
                            emptyState
                        }
                    }
                    .padding(AppTheme.Spacing.md)
                }

                Divider()
                    .overlay(AppTheme.Color.border)

                // Shared bottom composer anchored above safe area (V5)
                quickAskBar
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.Color.nav)
            }
            .background(AppTheme.Color.canvas)
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    TopRightAvatarNavButton()
                }
            }
            .task {
                let vm = container.makeDashboardViewModel()
                viewModel = vm
                await vm.load()
            }
            .refreshable {
                await viewModel?.load()
            }
        }
    }

    // MARK: - Assistant header

    @ViewBuilder
    private var assistantHeader: some View {
        if let assistant = session.activeAssistant {
            HStack(spacing: AppTheme.Spacing.md) {
                // Avatar placeholder (real asset loaded in W04)
                Circle()
                    .fill(Color(assistant.avatarRole.themeColor))
                    .frame(width: 56, height: 56)
                    .overlay {
                        Text(String(assistant.displayName.prefix(1)))
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                    }
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(assistant.displayName)
                        .font(.title3.bold())
                    Text("Ready to help")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()

                Button {
                    router.openAssistantSelector()
                } label: {
                    Image(systemName: "chevron.down.circle")
                        .imageScale(.large)
                }
                .accessibilityLabel("Switch between assistants")
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Color.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
        }
    }

    // MARK: - Quick ask

    private var quickAskBar: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            TextField("Ask something…", text: $quickAskText)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.send)
                .onSubmit { submitQuickAsk() }
                .accessibilityLabel("Quick ask field")

            Button {
                submitQuickAsk()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .imageScale(.large)
                    .foregroundStyle(AppTheme.Color.accent)
            }
            .disabled(quickAskText.trimmingCharacters(in: .whitespaces).isEmpty)
            .frame(minWidth: AppTheme.minimumTapTarget, minHeight: AppTheme.minimumTapTarget)
            .accessibilityLabel("Send message")

            Button {
                viewModel.map { vm in
                    Task { await vm.onVoice() }
                }
            } label: {
                Image(systemName: "mic.circle.fill")
                    .imageScale(.large)
                    .foregroundStyle(.secondary)
            }
            .frame(minWidth: AppTheme.minimumTapTarget, minHeight: AppTheme.minimumTapTarget)
            .accessibilityLabel("Voice input")
        }
    }

    private func submitQuickAsk() {
        let text = quickAskText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, let vm = viewModel else { return }
        quickAskText = ""
        Task { await vm.onAsk(text: text) }
    }

    // MARK: - Recent conversations

    @ViewBuilder
    private func recentConversationsSection(_ vm: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Recent")
                .font(.headline)
                .padding(.horizontal, AppTheme.Spacing.xs)

            ForEach(vm.recentConversations) { conv in
                Button {
                    vm.onOpenConversation(conv)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(conv.title)
                                .font(.subheadline.bold())
                                .lineLimit(1)
                            if let preview = conv.lastMessagePreview {
                                Text(preview)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .imageScale(.small)
                            .foregroundStyle(.secondary)
                    }
                    .padding(AppTheme.Spacing.md)
                    .background(AppTheme.Color.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open conversation: \(conv.title)")
            }
        }
    }

    // MARK: - Today's tasks

    @ViewBuilder
    private func todayTasksSection(_ vm: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Tasks")
                .font(.headline)
                .padding(.horizontal, AppTheme.Spacing.xs)

            ForEach(Array(vm.todayTasks.prefix(3))) { task in
                Button {
                    vm.onTaskCard(task)
                } label: {
                    HStack {
                        Image(systemName: "circle")
                            .foregroundStyle(.secondary)
                        Text(task.title)
                            .font(.subheadline)
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .imageScale(.small)
                            .foregroundStyle(.secondary)
                    }
                    .padding(AppTheme.Spacing.md)
                    .background(AppTheme.Color.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Task: \(task.title)")
            }
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Start a conversation", systemImage: "message.fill")
        } description: {
            Text("Ask your assistant anything using the field above.")
        }
        .padding(.top, AppTheme.Spacing.xl)
    }
}
