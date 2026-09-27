// Features/Tasks/TaskDashboardView.swift
// Tasks and projects screen with real progress tracking, categories, and owner-isolated views.
// Per V7 Phase P07 and V5 Unified Navigation Drawer.

import SwiftUI

struct TaskDashboardView: View {
    @Environment(AppContainer.self) private var container
    @Environment(AppRouter.self) private var router
    @State private var viewModel: TaskDashboardViewModel?
    @State private var showCreateProjectSheet = false
    @State private var newProjectTitle = ""
    @State private var newProjectDescription = ""

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    dashboardContent(vm)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle(viewModel?.selectedTab == .tasks ? "Tasks" : "Projects")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        if viewModel?.selectedTab == .tasks {
                            Button {
                                viewModel?.onCreate()
                            } label: {
                                Label("New Task", systemImage: "plus")
                            }
                            .accessibilityLabel("Create new task")
                        } else {
                            Button {
                                showCreateProjectSheet = true
                            } label: {
                                Label("New Project", systemImage: "plus")
                            }
                            .accessibilityLabel("Create new project")
                        }

                        TopRightAvatarNavButton()
                    }
                }
            }
            .task {
                let vm = container.makeTasksViewModel()
                viewModel = vm
                await vm.load()
            }
            .refreshable { await viewModel?.load() }
            .sheet(isPresented: $showCreateProjectSheet) {
                createProjectSheet
            }
        }
    }

    @ViewBuilder
    private func dashboardContent(_ vm: TaskDashboardViewModel) -> some View {
        VStack(spacing: 0) {
            Picker("View Mode", selection: Bindable(vm).selectedTab) {
                ForEach(TaskDashboardViewModel.DashboardTab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)

            if vm.selectedTab == .tasks {
                tasksView(vm)
            } else {
                projectsView(vm)
            }
        }
    }

    // MARK: - Tasks Tab View

    @ViewBuilder
    private func tasksView(_ vm: TaskDashboardViewModel) -> some View {
        if !vm.categories.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Button {
                        vm.selectedCategoryID = nil
                    } label: {
                        Text("All")
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(vm.selectedCategoryID == nil ? AppTheme.Color.accent : Color(.secondarySystemBackground))
                            .foregroundStyle(vm.selectedCategoryID == nil ? .white : AppTheme.Color.textPrimary)
                            .clipShape(Capsule())
                    }

                    ForEach(vm.categories) { cat in
                        Button {
                            vm.selectedCategoryID = (vm.selectedCategoryID == cat.id) ? nil : cat.id
                        } label: {
                            HStack(spacing: 4) {
                                if let icon = cat.iconName {
                                    Image(systemName: icon)
                                        .font(.caption2)
                                }
                                Text(cat.name)
                                    .font(.caption.bold())
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(vm.selectedCategoryID == cat.id ? AppTheme.Color.accent : Color(.secondarySystemBackground))
                            .foregroundStyle(vm.selectedCategoryID == cat.id ? .white : AppTheme.Color.textPrimary)
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
            Divider()
        }

        if vm.isLoading {
            Spacer()
            ProgressView("Loading tasks…")
            Spacer()
        } else if vm.filteredTasks.isEmpty {
            Spacer()
            ContentUnavailableView {
                Label("No Tasks", systemImage: "checkmark.circle")
            } description: {
                Text("Tap + to create your first task.")
            } actions: {
                Button("Create Task") { vm.onCreate() }
                    .buttonStyle(.borderedProminent)
            }
            Spacer()
        } else {
            List {
                ForEach(vm.filteredTasks) { task in
                    taskRow(task, vm: vm)
                }
                .onDelete { indexSet in
                    for i in indexSet {
                        let task = vm.filteredTasks[i]
                        Task { await vm.onDelete(task) }
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    @ViewBuilder
    private func taskRow(_ task: TaskDefinition, vm: TaskDashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.subheadline.bold())

                    if !task.taskDescription.isEmpty {
                        Text(task.taskDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    HStack(spacing: AppTheme.Spacing.xs) {
                        if let schedule = task.schedule {
                            Label(schedule.fireDate.formatted(.dateTime.month().day().hour().minute()), systemImage: "clock")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        if let catID = task.categoryID, let cat = vm.categories.first(where: { $0.id == catID }) {
                            Text("•")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(cat.name)
                                .font(.caption2.bold())
                                .foregroundStyle(AppTheme.Color.accent)
                        }

                        if let projID = task.projectID, let proj = vm.projects.first(where: { $0.id == projID }) {
                            Text("•")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(proj.title)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                Button {
                    vm.onEdit(task)
                } label: {
                    Image(systemName: "pencil.circle")
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
                .frame(minWidth: AppTheme.minimumTapTarget, minHeight: AppTheme.minimumTapTarget)
                .accessibilityLabel("Edit task \(task.title)")
            }

            // Quick completion percent selector (0%, 25%, 50%, 75%, 100%)
            HStack(spacing: AppTheme.Spacing.xs) {
                Text("Progress: \(task.completionPercent.map { "\($0)%" } ?? "Unset")")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Spacer()

                ForEach([0, 50, 100], id: \.self) { pct in
                    Button {
                        Task { await vm.updateCompletion(task, percent: pct) }
                    } label: {
                        Text("\(pct)%")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(task.completionPercent == pct ? AppTheme.Color.accent : Color(.tertiarySystemFill))
                            .foregroundStyle(task.completionPercent == pct ? .white : AppTheme.Color.textPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 2)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Projects Tab View

    @ViewBuilder
    private func projectsView(_ vm: TaskDashboardViewModel) -> some View {
        if vm.isLoading {
            Spacer()
            ProgressView("Loading projects…")
            Spacer()
        } else if vm.projects.isEmpty {
            Spacer()
            ContentUnavailableView {
                Label("No Projects", systemImage: "folder")
            } description: {
                Text("Group tasks into projects with aggregated progress tracking.")
            } actions: {
                Button("Create Project") { showCreateProjectSheet = true }
                    .buttonStyle(.borderedProminent)
            }
            Spacer()
        } else {
            List {
                ForEach(vm.projects) { project in
                    projectCard(project, vm: vm)
                }
                .onDelete { indexSet in
                    for i in indexSet {
                        let project = vm.projects[i]
                        Task { await vm.deleteProject(project) }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }

    @ViewBuilder
    private func projectCard(_ project: ProjectDefinition, vm: TaskDashboardViewModel) -> some View {
        let progress = vm.progress(for: project)

        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(project.title)
                        .font(.headline)

                    if !project.projectDescription.isEmpty {
                        Text(project.projectDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()

                if let avg = progress.averageCompletionPercent {
                    Text("\(Int(round(avg)))%")
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.Color.accent)
                } else {
                    Text("—")
                        .font(.title3.bold())
                        .foregroundStyle(.secondary)
                }
            }

            // Progress bar
            ProgressView(value: progress.averageCompletionPercent ?? 0.0, total: 100.0)
                .tint(AppTheme.Color.accent)

            HStack {
                Text(progress.coverageLabel)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(progress.completedTasksCount)/\(progress.totalTasksCount) done")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var createProjectSheet: some View {
        NavigationStack {
            Form {
                Section("Project Details") {
                    TextField("Title", text: $newProjectTitle)
                        .accessibilityLabel("Project title")
                    TextField("Description (optional)", text: $newProjectDescription)
                        .accessibilityLabel("Project description")
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showCreateProjectSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let title = newProjectTitle
                        let desc = newProjectDescription
                        showCreateProjectSheet = false
                        newProjectTitle = ""
                        newProjectDescription = ""
                        Task {
                            await viewModel?.createProject(title: title, description: desc)
                        }
                    }
                    .disabled(newProjectTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
