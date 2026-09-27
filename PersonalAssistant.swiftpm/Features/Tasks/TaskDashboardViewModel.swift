// Features/Tasks/TaskDashboardViewModel.swift
// Tasks and projects view model with real progress calculation, category filtering, and owner isolation.
// Per V7 Phase P07 and V7 §§6, 3.4.

import Foundation
import Observation

@MainActor
@Observable
final class TaskDashboardViewModel {
    enum DashboardTab: String, CaseIterable, Identifiable {
        case tasks = "Tasks"
        case projects = "Projects"
        var id: String { rawValue }
    }

    var selectedTab: DashboardTab = .tasks
    var selectedCategoryID: TaskCategoryID?
    var selectedProjectID: ProjectID?

    private(set) var tasks: [TaskDefinition] = []
    private(set) var projects: [ProjectDefinition] = []
    private(set) var categories: [TaskCategory] = []
    private(set) var isLoading = false
    private(set) var error: AppError?

    private let session: AppSession
    private let taskRepository: TaskRepository
    private let router: AppRouter

    init(session: AppSession, taskRepository: TaskRepository, router: AppRouter) {
        self.session = session
        self.taskRepository = taskRepository
        self.router = router
    }

    var filteredTasks: [TaskDefinition] {
        tasks.filter { task in
            if let catID = selectedCategoryID, task.categoryID != catID {
                return false
            }
            if let projID = selectedProjectID, task.projectID != projID {
                return false
            }
            return true
        }
    }

    func progress(for project: ProjectDefinition) -> ProjectProgressSummary {
        ProjectProgressCalculator.calculateProjectProgress(projectID: project.id, tasks: tasks)
    }

    func load() async {
        guard let owner = session.currentProfile else { return }
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            async let fetchedTasks = taskRepository.taskDefinitions(ownerID: owner.id)
            async let fetchedProjects = taskRepository.projectDefinitions(ownerID: owner.id)
            async let fetchedCategories = taskRepository.categories(ownerID: owner.id)

            let (t, p, c) = try await (fetchedTasks, fetchedProjects, fetchedCategories)
            tasks = t
            projects = p
            categories = c
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }
    }

    func onCreate() { router.openTaskEditor(taskID: nil) }

    func onEdit(_ task: TaskDefinition) { router.openTaskEditor(taskID: task.id) }

    func updateCompletion(_ task: TaskDefinition, percent: Int?) async {
        do {
            try await taskRepository.updateCompletionPercent(
                taskID: task.id,
                percent: percent,
                expectedRevision: task.revision
            )
            await load()
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }
    }

    func onDelete(_ task: TaskDefinition) async {
        var updated = task
        updated.isArchived = true
        updated.revision += 1
        updated.updatedAt = Date()
        do {
            try await taskRepository.upsertDefinition(updated, expectedRevision: task.revision)
            let reminderScheduler = LocalReminderScheduler()
            await reminderScheduler.cancelReminder(taskID: task.id)
            await load()
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }
    }

    func createProject(title: String, description: String = "", colorHex: String? = nil) async {
        guard let owner = session.currentProfile else { return }
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let project = ProjectDefinition(
            ownerID: owner.id,
            title: trimmed,
            projectDescription: description,
            colorHex: colorHex
        )

        do {
            try await taskRepository.upsertProject(project, expectedRevision: 0)
            await load()
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }
    }

    func deleteProject(_ project: ProjectDefinition) async {
        var updated = project
        updated.isArchived = true
        updated.revision += 1
        updated.updatedAt = Date()
        do {
            try await taskRepository.upsertProject(updated, expectedRevision: project.revision)
            await load()
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }
    }
}
