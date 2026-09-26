// Features/Tasks/TaskDetailView.swift
// Displays task definition details and recurrence schedule.

import SwiftUI

struct TaskDetailView: View {
    let task: TaskDefinition

    var body: some View {
        Form {
            Section("Task") {
                Text(task.title)
                    .font(.headline)
                if !task.taskDescription.isEmpty {
                    Text(task.taskDescription)
                        .font(.body)
                }
                if let schedule = task.schedule {
                    LabeledContent("Scheduled For", value: DateFormattingHelpers.mediumDate(schedule.fireDate))
                }
            }
        }
        .navigationTitle("Task Details")
    }
}
