// Features/Reminders/RemindersViewModel.swift
// Dedicated reminders management view model with categories, snooze, and completion.
// Per V7 Phase P07 and V7 §§6, 3.4.

import Foundation
import Observation

@MainActor
@Observable
final class RemindersViewModel {
    private(set) var reminders: [ReminderDefinition] = []
    private(set) var categories: [TaskCategory] = []
    var selectedCategoryID: TaskCategoryID? = nil
    var showCompleted: Bool = false
    private(set) var isLoading = false
    private(set) var error: AppError?

    private let session: AppSession
    private let taskRepository: TaskRepository
    private let reminderScheduler: LocalReminderScheduler

    init(
        session: AppSession,
        taskRepository: TaskRepository,
        reminderScheduler: LocalReminderScheduler
    ) {
        self.session = session
        self.taskRepository = taskRepository
        self.reminderScheduler = reminderScheduler
    }

    var filteredReminders: [ReminderDefinition] {
        reminders.filter { reminder in
            if let catID = selectedCategoryID {
                return reminder.categoryID == catID
            }
            return true
        }
    }

    var dueTodayReminders: [ReminderDefinition] {
        TaskDateFilter.filterRemindersDueToday(reminders: filteredReminders, in: TimeZone.current)
    }

    var overdueReminders: [ReminderDefinition] {
        TaskDateFilter.filterRemindersOverdue(reminders: filteredReminders, in: TimeZone.current)
    }

    var upcomingReminders: [ReminderDefinition] {
        filteredReminders.filter { reminder in
            !reminder.isCompleted &&
            !TaskDateFilter.isDueToday(date: reminder.dueDate, in: TimeZone.current) &&
            !TaskDateFilter.isOverdue(date: reminder.dueDate, in: TimeZone.current)
        }
    }

    var completedReminders: [ReminderDefinition] {
        filteredReminders.filter { $0.isCompleted }
    }

    func load() async {
        guard let owner = session.currentProfile else { return }
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            async let rems = taskRepository.reminders(ownerID: owner.id, includeCompleted: true, limit: 100)
            async let cats = taskRepository.categories(ownerID: owner.id)
            let (fetchedRems, fetchedCats) = try await (rems, cats)
            reminders = fetchedRems
            categories = fetchedCats
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }
    }

    func toggleCompleted(_ reminder: ReminderDefinition) async {
        do {
            try await taskRepository.toggleReminderCompletion(id: reminder.id)
            if !reminder.isCompleted {
                // Was not completed, now completed: cancel notification alert
                await reminderScheduler.cancelStandaloneReminder(reminderID: reminder.id)
            }
            await load()
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }
    }

    func snooze(_ reminder: ReminderDefinition, minutes: Int = 15) async {
        guard let owner = session.currentProfile else { return }
        let newDate = Date().addingTimeInterval(Double(minutes * 60))
        var updated = reminder
        updated.dueDate = newDate
        updated.revision += 1
        updated.updatedAt = Date()
        do {
            try await taskRepository.upsertReminder(updated, expectedRevision: reminder.revision)
            _ = try? await reminderScheduler.snoozeReminder(reminderID: reminder.id, title: reminder.title, minutes: minutes)
            await load()
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }
    }

    func createReminder(
        title: String,
        notes: String? = nil,
        dueDate: Date,
        categoryID: TaskCategoryID? = nil,
        taskID: TaskID? = nil
    ) async {
        guard let owner = session.currentProfile else { return }
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let remID = ReminderID()
        let notifID = "reminder_\(remID.rawValue.uuidString)"
        let reminder = ReminderDefinition(
            id: remID,
            ownerID: owner.id,
            taskID: taskID,
            title: trimmed,
            notes: notes,
            dueDate: dueDate,
            timezoneIdentifier: TimeZone.current.identifier,
            categoryID: categoryID,
            isCompleted: false,
            notificationIdentifier: notifID,
            revision: 1
        )

        do {
            try await taskRepository.upsertReminder(reminder, expectedRevision: 0)
            try? await reminderScheduler.scheduleStandaloneReminder(reminderID: remID, title: trimmed, fireDate: dueDate)
            await load()
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }
    }

    func deleteReminder(_ reminder: ReminderDefinition) async {
        var updated = reminder
        updated.isArchived = true
        updated.revision += 1
        updated.updatedAt = Date()
        do {
            try await taskRepository.upsertReminder(updated, expectedRevision: reminder.revision)
            await reminderScheduler.cancelStandaloneReminder(reminderID: reminder.id)
            await load()
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }
    }
}
