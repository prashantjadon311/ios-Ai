// Features/Tasks/TaskDashboardViewModel.swift

import Foundation
import Observation

@MainActor
@Observable
final class TaskDashboardViewModel {
    private(set) var tasks: [TaskDefinition] = []
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

    func load() async {
        guard let owner = session.currentProfile else { return }
        isLoading = true; error = nil
        defer { isLoading = false }
        do {
            tasks = try await taskRepository.taskDefinitions(ownerID: owner.id)
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }
    }

    func onCreate() { router.openTaskEditor(taskID: nil) }

    func onEdit(_ task: TaskDefinition) { router.openTaskEditor(taskID: task.id) }

    func onDelete(_ task: TaskDefinition) async {
        guard let owner = session.currentProfile else { return }
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
}
