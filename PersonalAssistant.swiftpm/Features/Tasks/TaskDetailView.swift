// Features/Tasks/TaskDetailView.swift
import SwiftUI

struct TaskDetailView: View {
    let task: TaskDefinition

    var body: some View {
        Form {
            Section("Task") {
                Text(task.title)
                    .font(.headline)
                if let schedule = task.scheduleTime {
                    LabeledContent("Scheduled For", value: DateFormattingHelpers.mediumDate(schedule))
                }
            }
        }
        .navigationTitle("Task Details")
    }
}
