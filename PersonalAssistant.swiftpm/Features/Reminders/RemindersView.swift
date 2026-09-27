// Features/Reminders/RemindersView.swift
// Dedicated reminders view with category filtering, snooze, and completion toggles.
// Per V7 Phase P07 and V5 Unified Navigation Drawer.

import SwiftUI

struct RemindersView: View {
    @Environment(AppContainer.self) private var container
    @Environment(AppRouter.self) private var router

    @State private var viewModel: RemindersViewModel?
    @State private var showCreateSheet = false
    @State private var newTitle = ""
    @State private var newNotes = ""
    @State private var newDueDate = Date().addingTimeInterval(3600)
    @State private var newCategoryID: TaskCategoryID?

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    content(vm)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Reminders")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Button {
                            showCreateSheet = true
                        } label: {
                            Label("New Reminder", systemImage: "plus")
                        }
                        .accessibilityLabel("Create new reminder")

                        TopRightAvatarNavButton()
                    }
                }
            }
            .task {
                let vm = container.makeRemindersViewModel()
                viewModel = vm
                await vm.load()
            }
            .refreshable {
                await viewModel?.load()
            }
            .sheet(isPresented: $showCreateSheet) {
                createReminderSheet
            }
        }
    }

    @ViewBuilder
    private func content(_ vm: RemindersViewModel) -> some View {
        VStack(spacing: 0) {
            // Category filter chips
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
                    .padding(.vertical, 8)
                }
                Divider()
            }

            if vm.isLoading {
                Spacer()
                ProgressView("Loading reminders…")
                Spacer()
            } else if vm.reminders.isEmpty {
                Spacer()
                ContentUnavailableView {
                    Label("No Reminders", systemImage: "bell.slash")
                } description: {
                    Text("Stay on top of your schedule. Tap + to set a reminder.")
                } actions: {
                    Button("Add Reminder") { showCreateSheet = true }
                        .buttonStyle(.borderedProminent)
                }
                Spacer()
            } else {
                List {
                    // Overdue section
                    if !vm.overdueReminders.isEmpty {
                        Section("Overdue") {
                            ForEach(vm.overdueReminders) { rem in
                                reminderRow(rem, vm: vm, isOverdue: true)
                            }
                        }
                    }

                    // Due Today section
                    if !vm.dueTodayReminders.isEmpty {
                        Section("Due Today") {
                            ForEach(vm.dueTodayReminders) { rem in
                                reminderRow(rem, vm: vm, isOverdue: false)
                            }
                        }
                    }

                    // Upcoming section
                    if !vm.upcomingReminders.isEmpty {
                        Section("Upcoming") {
                            ForEach(vm.upcomingReminders) { rem in
                                reminderRow(rem, vm: vm, isOverdue: false)
                            }
                        }
                    }

                    // Completed section
                    if !vm.completedReminders.isEmpty {
                        Section("Completed (\(vm.completedReminders.count))") {
                            ForEach(vm.completedReminders) { rem in
                                reminderRow(rem, vm: vm, isOverdue: false)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }

    @ViewBuilder
    private func reminderRow(_ reminder: ReminderDefinition, vm: RemindersViewModel, isOverdue: Bool) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Button {
                Task { await vm.toggleCompleted(reminder) }
            } label: {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(reminder.isCompleted ? Color.green : (isOverdue ? Color.red : AppTheme.Color.accent))
            }
            .buttonStyle(.plain)
            .frame(minWidth: AppTheme.minimumTapTarget, minHeight: AppTheme.minimumTapTarget)
            .accessibilityLabel(reminder.isCompleted ? "Mark incomplete" : "Mark complete")

            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.title)
                    .font(.subheadline)
                    .strikethrough(reminder.isCompleted)
                    .foregroundStyle(reminder.isCompleted ? .secondary : AppTheme.Color.textPrimary)

                if let notes = reminder.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text(reminder.dueDate.formatted(.dateTime.month().day().hour().minute()))
                        .font(.caption2)

                    if let catID = reminder.categoryID, let cat = vm.categories.first(where: { $0.id == catID }) {
                        Text("•")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(cat.name)
                            .font(.caption2.bold())
                            .foregroundStyle(AppTheme.Color.accent)
                    }
                }
                .foregroundStyle(isOverdue && !reminder.isCompleted ? Color.red : .secondary)
            }

            Spacer()

            if isOverdue && !reminder.isCompleted {
                Button {
                    Task { await vm.snooze(reminder, minutes: 15) }
                } label: {
                    Text("+15m")
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Snooze reminder by 15 minutes")
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                Task { await vm.deleteReminder(reminder) }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private var createReminderSheet: some View {
        NavigationStack {
            Form {
                Section("Reminder") {
                    TextField("Title", text: $newTitle)
                        .accessibilityLabel("Reminder title")
                    TextField("Notes (optional)", text: $newNotes)
                        .accessibilityLabel("Reminder notes")
                    DatePicker("Date & Time", selection: $newDueDate)
                        .accessibilityLabel("Reminder due date and time")
                }

                if let vm = viewModel, !vm.categories.isEmpty {
                    Section("Category") {
                        Picker("Category", selection: $newCategoryID) {
                            Text("None").tag(nil as TaskCategoryID?)
                            ForEach(vm.categories) { cat in
                                Text(cat.name).tag(cat.id as TaskCategoryID?)
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showCreateSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let title = newTitle
                        let notes = newNotes.isEmpty ? nil : newNotes
                        let due = newDueDate
                        let cat = newCategoryID
                        showCreateSheet = false
                        newTitle = ""
                        newNotes = ""
                        Task {
                            await viewModel?.createReminder(title: title, notes: notes, dueDate: due, categoryID: cat)
                        }
                    }
                    .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
