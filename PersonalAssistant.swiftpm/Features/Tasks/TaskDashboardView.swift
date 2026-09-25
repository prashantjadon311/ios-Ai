// Features/Tasks/TaskDashboardView.swift
// Tasks screen — list of task definitions with create/edit/delete.

import SwiftUI

struct TaskDashboardView: View {
    @Environment(AppContainer.self) private var container
    @Environment(AppRouter.self) private var router
    @State private var viewModel: TaskDashboardViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    taskContent(vm)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel?.onCreate()
                    } label: {
                        Label("New Task", systemImage: "plus")
                    }
                    .accessibilityLabel("Create new task")
                }
            }
            .task {
                let vm = container.makeTasksViewModel()
                viewModel = vm
                await vm.load()
            }
            .refreshable { await viewModel?.load() }
        }
    }

    @ViewBuilder
    private func taskContent(_ vm: TaskDashboardViewModel) -> some View {
        if vm.isLoading {
            ProgressView("Loading tasks…")
        } else if vm.tasks.isEmpty {
            ContentUnavailableView {
                Label("No Tasks", systemImage: "checkmark.circle")
            } description: {
                Text("Tap + to create your first task.")
            } actions: {
                Button("Create Task") { vm.onCreate() }
                    .buttonStyle(.borderedProminent)
            }
        } else {
            List {
                ForEach(vm.tasks) { task in
                    taskRow(task, vm: vm)
                }
                .onDelete { indexSet in
                    for i in indexSet {
                        let task = vm.tasks[i]
                        Task { await vm.onDelete(task) }
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    @ViewBuilder
    private func taskRow(_ task: TaskDefinition, vm: TaskDashboardViewModel) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(task.title)
                    .font(.subheadline.bold())
                if !task.taskDescription.isEmpty {
                    Text(task.taskDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                if let schedule = task.schedule {
                    Label(schedule.fireDate.formatted(.dateTime.month().day().hour().minute()), systemImage: "clock")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
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
        .padding(.vertical, AppTheme.Spacing.xs)
        .accessibilityElement(children: .combine)
    }
}
