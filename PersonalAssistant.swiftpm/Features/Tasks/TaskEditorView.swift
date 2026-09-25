// Features/Tasks/TaskEditorView.swift
// Create/edit task definition with title, description, schedule, recurrence.

import SwiftUI

struct TaskEditorView: View {
    let taskID: TaskID?

    @Environment(AppContainer.self) private var container
    @Environment(AppSession.self) private var session
    @Environment(AppRouter.self) private var router

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var hasSchedule: Bool = false
    @State private var scheduleDate: Date = Date().addingTimeInterval(3600)
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
                }
            } header: {
                Text("Schedule")
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

        let definition = TaskDefinition(
            ownerID: owner.id,
            title: trimmedTitle,
            taskDescription: description,
            schedule: schedule
        )

        do {
            try await container.taskRepository.upsertDefinition(definition, expectedRevision: 0)
            router.dismissSheet()
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }
    }
}
