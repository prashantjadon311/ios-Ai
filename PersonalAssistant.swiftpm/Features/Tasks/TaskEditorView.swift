// Features/Tasks/TaskEditorView.swift
// Create/edit task definition with title, description, schedule, recurrence, project, and category.
// Per V7 Phase P07 and V7 §§6, 3.4.

import SwiftUI

struct TaskEditorView: View {
    let taskID: TaskID?

    @Environment(AppContainer.self) private var container
    @Environment(AppSession.self) private var session
    @Environment(AppRouter.self) private var router

    @State private var existingTask: TaskDefinition?
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var hasSchedule: Bool = false
    @State private var scheduleDate: Date = Date().addingTimeInterval(3600)
    @State private var hasRecurrence: Bool = false
    @State private var recurrenceFrequency: RecurrenceFrequency = .daily
    @State private var recurrenceInterval: Int = 1

    @State private var projects: [ProjectDefinition] = []
    @State private var categories: [TaskCategory] = []
    @State private var selectedProjectID: ProjectID?
    @State private var selectedCategoryID: TaskCategoryID?
    @State private var hasCompletionPercent: Bool = false
    @State private var completionPercent: Int = 0

    @State private var isSaving = false
    @State private var error: AppError?

    var body: some View {
        Form {
            Section("Task") {
                TextField("Title", text: $title)
                    .accessibilityLabel("Task title")
                TextField("Description (optional)", text: $description, axis: .vertical)
                    .lineLimit(3...6)
                    .accessibilityLabel("Task description")
            }

            Section("Project & Category") {
                if !projects.isEmpty {
                    Picker("Project", selection: $selectedProjectID) {
                        Text("None").tag(nil as ProjectID?)
                        ForEach(projects) { p in
                            Text(p.title).tag(p.id as ProjectID?)
                        }
                    }
                }

                if !categories.isEmpty {
                    Picker("Category", selection: $selectedCategoryID) {
                        Text("None").tag(nil as TaskCategoryID?)
                        ForEach(categories) { c in
                            Text(c.name).tag(c.id as TaskCategoryID?)
                        }
                    }
                }

                Toggle("Track Completion Progress", isOn: $hasCompletionPercent)
                if hasCompletionPercent {
                    Stepper("Progress: \(completionPercent)%", value: $completionPercent, in: 0...100, step: 10)
                }
            }

            Section {
                Toggle("Schedule this task", isOn: $hasSchedule)
                    .accessibilityLabel("Enable schedule")
                if hasSchedule {
                    DatePicker("Date & Time", selection: $scheduleDate)
                        .datePickerStyle(.compact)
                        .accessibilityLabel("Task date and time")

                    Toggle("Repeat", isOn: $hasRecurrence)
                        .accessibilityLabel("Enable recurrence")

                    if hasRecurrence {
                        Picker("Frequency", selection: $recurrenceFrequency) {
                            Text("Daily").tag(RecurrenceFrequency.daily)
                            Text("Weekly").tag(RecurrenceFrequency.weekly)
                            Text("Monthly").tag(RecurrenceFrequency.monthly)
                            Text("Yearly").tag(RecurrenceFrequency.yearly)
                        }
                        Stepper("Every \(recurrenceInterval) \(frequencyUnit)", value: $recurrenceInterval, in: 1...99)
                    }
                }
            } header: {
                Text("Schedule & Recurrence")
            }

            if let error {
                Section {
                    Text(error.localizedDescription)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(taskID == nil ? "New Task" : "Edit Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { router.dismissSheet() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await save() }
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
            }
        }
        .task {
            await loadTask()
        }
    }

    private var frequencyUnit: String {
        switch recurrenceFrequency {
        case .daily: return recurrenceInterval == 1 ? "day" : "days"
        case .weekly: return recurrenceInterval == 1 ? "week" : "weeks"
        case .monthly: return recurrenceInterval == 1 ? "month" : "months"
        case .yearly: return recurrenceInterval == 1 ? "year" : "years"
        }
    }

    private func loadTask() async {
        guard let owner = session.currentProfile else { return }
        do {
            async let projsTask = container.taskRepository.projectDefinitions(ownerID: owner.id)
            async let catsTask = container.taskRepository.categories(ownerID: owner.id)
            async let tasksTask = container.taskRepository.taskDefinitions(ownerID: owner.id)

            let (p, c, tasks) = try await (projsTask, catsTask, tasksTask)
            projects = p
            categories = c

            if let tid = taskID, let task = tasks.first(where: { $0.id == tid }) {
                existingTask = task
                title = task.title
                description = task.taskDescription
                selectedProjectID = task.projectID
                selectedCategoryID = task.categoryID
                if let cp = task.completionPercent {
                    hasCompletionPercent = true
                    completionPercent = cp
                }
                if let schedule = task.schedule {
                    hasSchedule = true
                    scheduleDate = schedule.fireDate
                }
                if let recurrence = task.recurrence {
                    hasRecurrence = true
                    recurrenceFrequency = recurrence.frequency
                    recurrenceInterval = recurrence.interval
                }
            }
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }
    }

    private func save() async {
        guard let owner = session.currentProfile else { return }
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }
        isSaving = true
        error = nil
        defer { isSaving = false }

        let schedule = hasSchedule ? TaskSchedule(
            fireDate: scheduleDate,
            timezoneIdentifier: TimeZone.current.identifier
        ) : nil

        let recurrence = (hasSchedule && hasRecurrence) ? TaskRecurrence(
            frequency: recurrenceFrequency,
            interval: recurrenceInterval
        ) : nil

        let tid = existingTask?.id ?? TaskID()
        let expectedRev = existingTask?.revision ?? 0

        var definition = existingTask ?? TaskDefinition(
            id: tid,
            ownerID: owner.id,
            title: trimmedTitle,
            taskDescription: description,
            schedule: schedule,
            recurrence: recurrence,
            projectID: selectedProjectID,
            categoryID: selectedCategoryID,
            completionPercent: hasCompletionPercent ? completionPercent : nil
        )
        definition.title = trimmedTitle
        definition.taskDescription = description
        definition.schedule = schedule
        definition.recurrence = recurrence
        definition.projectID = selectedProjectID
        definition.categoryID = selectedCategoryID
        definition.completionPercent = hasCompletionPercent ? completionPercent : nil
        definition.revision = expectedRev + 1
        definition.updatedAt = Date()

        do {
            try await container.taskRepository.upsertDefinition(definition, expectedRevision: expectedRev)
            let reminderScheduler = LocalReminderScheduler()
            if let sched = schedule {
                do {
                    try await reminderScheduler.scheduleReminder(
                        taskID: tid,
                        title: trimmedTitle,
                        fireDate: sched.fireDate
                    )
                } catch {
                    // Task saved, but notifications might not be permitted (T016)
                }
            } else {
                await reminderScheduler.cancelReminder(taskID: tid)
            }
            router.dismissSheet()
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }
    }
}
