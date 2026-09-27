// Tasks/TaskProgress.swift
// Deterministic progress estimation based on completed task steps and project task aggregation.
// Per V3 §Tasks/TaskProgress.swift blueprint and V7 Phase P07.

import Foundation

struct TaskProgressEstimator: Sendable {
    static func calculateProgress(
        steps: [TaskStepRecord]
    ) -> Double {
        guard !steps.isEmpty else { return 0.0 }

        let completed = steps.filter {
            $0.status == .completed
        }.count

        return Double(completed) /
               Double(steps.count)
    }
}

// MARK: - Project Progress Summary & Aggregator (V7 Phase P07)

struct ProjectProgressSummary: Sendable, Equatable {
    let projectID: ProjectID
    let totalTasksCount: Int
    let trackedTasksCount: Int
    let untrackedTasksCount: Int
    let averageCompletionPercent: Double?
    let completedTasksCount: Int
    let coverageFraction: Double
    let coverageLabel: String
}

struct ProjectProgressCalculator: Sendable {
    /// Computes project progress from contained tasks with explicit unknown coverage labeling.
    /// In accordance with P07:
    /// - Known-progress mean or weighted calculation
    /// - Unknown coverage count and percentage clearly reported
    /// - 100% manual completion does NOT alter scheduler run execution
    static func calculateProjectProgress(
        projectID: ProjectID,
        tasks: [TaskDefinition]
    ) -> ProjectProgressSummary {
        let projectTasks = tasks.filter { $0.projectID == projectID && !$0.isArchived }
        let total = projectTasks.count
        guard total > 0 else {
            return ProjectProgressSummary(
                projectID: projectID,
                totalTasksCount: 0,
                trackedTasksCount: 0,
                untrackedTasksCount: 0,
                averageCompletionPercent: nil,
                completedTasksCount: 0,
                coverageFraction: 0.0,
                coverageLabel: "No tasks"
            )
        }

        let tracked = projectTasks.filter { $0.completionPercent != nil }
        let trackedCount = tracked.count
        let untrackedCount = total - trackedCount
        let completedCount = projectTasks.filter { ($0.completionPercent ?? 0) >= 100 }.count

        let avgPercent: Double?
        if trackedCount > 0 {
            let sum = tracked.reduce(0) { $0 + ($1.completionPercent ?? 0) }
            avgPercent = Double(sum) / Double(trackedCount)
        } else {
            avgPercent = nil
        }

        let coverageFraction = Double(trackedCount) / Double(total)
        let coveragePct = Int(round(coverageFraction * 100.0))
        let coverageLabel = "\(trackedCount) of \(total) tasks tracked (\(coveragePct)% coverage)"

        return ProjectProgressSummary(
            projectID: projectID,
            totalTasksCount: total,
            trackedTasksCount: trackedCount,
            untrackedTasksCount: untrackedCount,
            averageCompletionPercent: avgPercent,
            completedTasksCount: completedCount,
            coverageFraction: coverageFraction,
            coverageLabel: coverageLabel
        )
    }
}
