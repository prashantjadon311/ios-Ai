// Features/Tasks/TaskRunCard.swift
import SwiftUI

struct TaskRunCard: View {
    let run: TaskRun

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Run: \(run.status.rawValue)")
                    .font(.headline)
                Text(run.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
    }
}
