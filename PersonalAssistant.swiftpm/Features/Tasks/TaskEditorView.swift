// Features/Tasks/TaskEditorView.swift
// Create/edit task definition with title, description, schedule, recurrence.

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

            Section {
                Toggle("Schedule this task", isOn: $hasSchedule)
                    .accessibilityLabel("Enable schedule")
                if hasSchedule {
                    DatePicker("Date & Time", selection: $scheduleDate, style: .compact)
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
        guard let tid = taskID, let owner = session.currentProfile else { return }
        do {
            let tasks = try await container.taskRepository.taskDefinitions(ownerID: owner.id)
            if let task = tasks.first(where: { $0.id == tid }) {
                existingTask = task
                title = task.title
                description = task.taskDescription
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
            recurrence: recurrence
        )
        definition.title = trimmedTitle
        definition.taskDescription = description
        definition.schedule = schedule
        definition.recurrence = recurrence
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
