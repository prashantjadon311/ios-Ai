// Persistence/TaskRepository.swift
// Persists task definitions and runs with compare-and-set revision guards.
// Per V3 §Persistence/TaskRepository.swift blueprint.

import Foundation
import SwiftData

actor TaskRepository {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    @MainActor
    private var context: ModelContext { modelContainer.mainContext }

    // MARK: - Task definitions

    func taskDefinitions(ownerID: UserID, limit: Int? = nil) async throws -> [TaskDefinition] {
        let ownerUUID = ownerID.rawValue
        let stored = try await MainActor.run {
            var descriptor = FetchDescriptor<StoredTaskDefinition>(
                predicate: #Predicate { $0.ownerID == ownerUUID && !$0.isArchived },
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            if let limit {
                descriptor.fetchLimit = limit
            }
            return try context.fetch(descriptor)
        }
        let dec = JSONDecoder(); dec.dateDecodingStrategy = .iso8601
        return stored.compactMap { stored -> TaskDefinition? in
            let schedule = stored.scheduleData.flatMap { try? dec.decode(TaskSchedule.self, from: $0) }
            let recurrence = stored.recurrenceData.flatMap { try? dec.decode(TaskRecurrence.self, from: $0) }
            let notifIDs = (stored.notificationIdentifiersData.isEmpty ? nil :
                try? dec.decode([String].self, from: stored.notificationIdentifiersData)) ?? []
            return TaskDefinition(
                id: TaskID(rawValue: stored.id),
                ownerID: UserID(rawValue: stored.ownerID),
                title: stored.title,
                taskDescription: stored.taskDescription,
                schedule: schedule,
                recurrence: recurrence,
                projectID: stored.projectID.map { ProjectID(rawValue: $0) },
                categoryID: stored.categoryID.map { TaskCategoryID(rawValue: $0) },
                completionPercent: stored.completionPercent,
                timezoneIdentifier: stored.timezoneIdentifier ?? TimeZone.current.identifier,
                revision: stored.revision,
                isArchived: stored.isArchived,
                notificationIdentifiers: notifIDs,
                createdAt: stored.createdAt,
                updatedAt: stored.updatedAt
            )
        }
    }

    /// Convenience overload matching protocol requirement
    func taskDefinitions(ownerID: UserID) async throws -> [TaskDefinition] {
        try await taskDefinitions(ownerID: ownerID, limit: nil)
    }

    /// Upsert with compare-and-set revision (prevents concurrent overwrites).
    func upsertDefinition(_ definition: TaskDefinition, expectedRevision: Int) async throws {
        let enc = JSONEncoder(); enc.dateEncodingStrategy = .iso8601
        let id = definition.id.rawValue
        try await MainActor.run {
            let descriptor = FetchDescriptor<StoredTaskDefinition>(
                predicate: #Predicate { $0.id == id }
            )
            if let existing = try context.fetch(descriptor).first {
                guard existing.revision == expectedRevision else {
                    throw AppError.validationFailed(field: "revision", reason: "Task revision conflict")
                }
                existing.title = definition.title
                existing.taskDescription = definition.taskDescription
                existing.scheduleData = definition.schedule.flatMap { try? enc.encode($0) }
                existing.recurrenceData = definition.recurrence.flatMap { try? enc.encode($0) }
                existing.projectID = definition.projectID?.rawValue
                existing.categoryID = definition.categoryID?.rawValue
                existing.completionPercent = definition.completionPercent
                existing.timezoneIdentifier = definition.timezoneIdentifier
                existing.revision = definition.revision
                existing.isArchived = definition.isArchived
                existing.notificationIdentifiersData = (try? enc.encode(definition.notificationIdentifiers)) ?? Data()
                existing.updatedAt = definition.updatedAt
            } else {
                let stored = StoredTaskDefinition(
                    id: id,
                    ownerID: definition.ownerID.rawValue,
                    title: definition.title,
                    taskDescription: definition.taskDescription,
                    scheduleData: definition.schedule.flatMap { try? enc.encode($0) },
                    recurrenceData: definition.recurrence.flatMap { try? enc.encode($0) },
                    projectID: definition.projectID?.rawValue,
                    categoryID: definition.categoryID?.rawValue,
                    completionPercent: definition.completionPercent,
                    timezoneIdentifier: definition.timezoneIdentifier,
                    revision: definition.revision,
                    isArchived: definition.isArchived,
                    notificationIdentifiersData: (try? enc.encode(definition.notificationIdentifiers)) ?? Data(),
                    createdAt: definition.createdAt,
                    updatedAt: definition.updatedAt
                )
                context.insert(stored)
            }
            try context.save()
        }
    }

    /// Bounded query for tasks due today in the user's timezone.
    func dueTodayTasks(ownerID: UserID, referenceDate: Date = Date(), timeZone: TimeZone = TimeZone.current, limit: Int = 20) async throws -> [TaskDefinition] {
        let allTasks = try await taskDefinitions(ownerID: ownerID)
        let filtered = TaskDateFilter.filterDueToday(tasks: allTasks, in: timeZone, relativeTo: referenceDate)
        return Array(filtered.prefix(limit))
    }

    /// Bounded query for overdue tasks in the user's timezone.
    func overdueTasks(ownerID: UserID, referenceDate: Date = Date(), timeZone: TimeZone = TimeZone.current, limit: Int = 20) async throws -> [TaskDefinition] {
        let allTasks = try await taskDefinitions(ownerID: ownerID)
        let filtered = TaskDateFilter.filterOverdue(tasks: allTasks, in: timeZone, relativeTo: referenceDate)
        return Array(filtered.prefix(limit))
    }

    /// Updates manual completion percentage without modifying scheduler run execution (P07 invariant).
    func updateCompletionPercent(taskID: TaskID, percent: Int?, expectedRevision: Int) async throws {
        let uuid = taskID.rawValue
        try await MainActor.run {
            let descriptor = FetchDescriptor<StoredTaskDefinition>(
                predicate: #Predicate { $0.id == uuid }
            )
            guard let stored = try context.fetch(descriptor).first else {
                throw AppError.validationFailed(field: "taskID", reason: "Task not found")
            }
            guard stored.revision == expectedRevision else {
                throw AppError.validationFailed(field: "revision", reason: "Task revision conflict")
            }
            stored.completionPercent = percent.map { min(100, max(0, $0)) }
            stored.revision += 1
            stored.updatedAt = Date()
            try context.save()
        }
    }

    // MARK: - Task runs

    /// Reserve a unique occurrence key (exactly one run per key).
    func reserveOccurrenceKey(_ key: TaskOccurrenceKey, ownerID: UserID) async throws -> TaskRun {
        let enc = JSONEncoder(); enc.dateEncodingStrategy = .iso8601
        let keyData = (try? enc.encode(key)) ?? Data()
        return try await MainActor.run {
            // Check if already exists
            let descriptor = FetchDescriptor<StoredTaskRun>(
                predicate: #Predicate { $0.taskID == key.taskID.rawValue }
            )
            let existing = try context.fetch(descriptor).first { stored in
                guard let storedKey = try? JSONDecoder().decode(TaskOccurrenceKey.self, from: stored.occurrenceKeyData) else { return false }
                return storedKey == key
            }
            if let existing {
                // Return existing run
                return Self.taskRunFromStored(existing)
            }
            // Create new
            let run = TaskRun(
                ownerID: ownerID,
                taskID: key.taskID,
                definitionRevision: key.definitionRevision,
                occurrenceKey: key,
                scheduledAt: Date()
            )
            let stored = StoredTaskRun(
                id: run.id.rawValue,
                ownerID: ownerID.rawValue,
                taskID: key.taskID.rawValue,
                definitionRevision: key.definitionRevision,
                occurrenceKeyData: keyData,
                statusRaw: TaskRunStatus.queued.rawValue,
                stepsData: (try? enc.encode([TaskStepRecord]()) ) ?? Data(),
                scheduledAt: run.scheduledAt,
                startedAt: nil,
                completedAt: nil,
                errorMessage: nil,
                notificationID: nil,
                createdAt: run.createdAt,
                updatedAt: run.updatedAt
            )
            context.insert(stored)
            try context.save()
            return run
        }
    }

    @MainActor
    private static func taskRunFromStored(_ stored: StoredTaskRun) -> TaskRun {
        let dec = JSONDecoder(); dec.dateDecodingStrategy = .iso8601
        let key = (try? dec.decode(TaskOccurrenceKey.self, from: stored.occurrenceKeyData))
            ?? TaskOccurrenceKey(
                taskID: TaskID(rawValue: stored.taskID),
                definitionRevision: stored.definitionRevision,
                scheduledOccurrenceID: UUID()
            )
        let status = TaskRunStatus(rawValue: stored.statusRaw) ?? .interrupted
        let steps = (try? dec.decode([TaskStepRecord].self, from: stored.stepsData)) ?? []
        return TaskRun(
            id: TaskRunID(rawValue: stored.id),
            ownerID: UserID(rawValue: stored.ownerID),
            taskID: TaskID(rawValue: stored.taskID),
            definitionRevision: stored.definitionRevision,
            occurrenceKey: key,
            status: status,
            steps: steps,
            scheduledAt: stored.scheduledAt,
            notificationID: stored.notificationID,
            createdAt: stored.createdAt,
            updatedAt: stored.updatedAt
        )
    }

    // MARK: - Transition run status (pure state machine validation)

    func transitionRun(id: TaskRunID, from expected: TaskRunStatus, to next: TaskRunStatus) async throws {
        guard expected.canTransition(to: next) else {
            throw AppError.validationFailed(field: "status", reason: "Invalid task run transition \(expected) → \(next)")
        }
        let uuid = id.rawValue
        try await MainActor.run {
            let descriptor = FetchDescriptor<StoredTaskRun>(
                predicate: #Predicate { $0.id == uuid }
            )
            guard let stored = try context.fetch(descriptor).first else { return }
            guard stored.statusRaw == expected.rawValue else {
                throw AppError.validationFailed(field: "status", reason: "Current status mismatch")
            }
            stored.statusRaw = next.rawValue
            stored.updatedAt = Date()
            if next == .running { stored.startedAt = Date() }
            if next.isTerminal { stored.completedAt = Date() }
            try context.save()
        }
    }

    // MARK: - On-launch recovery (B06/A15)

    /// Marks any persisted 'running' tasks as 'interrupted' on fresh launch.
    func reconcileInterrupted(ownerID: UserID) async throws {
        let ownerUUID = ownerID.rawValue
        try await MainActor.run {
            let descriptor = FetchDescriptor<StoredTaskRun>(
                predicate: #Predicate {
                    $0.ownerID == ownerUUID &&
                    ($0.statusRaw == "running" || $0.statusRaw == "cancelRequested")
                }
            )
            let running = try context.fetch(descriptor)
            for run in running {
                run.statusRaw = TaskRunStatus.interrupted.rawValue
                run.updatedAt = Date()
            }
            if !running.isEmpty {
                try context.save()
            }
        }
    }

    // MARK: - Active runs for owner

    func activeRuns(ownerID: UserID) async throws -> [TaskRun] {
        let ownerUUID = ownerID.rawValue
        return try await MainActor.run {
            let descriptor = FetchDescriptor<StoredTaskRun>(
                predicate: #Predicate { $0.ownerID == ownerUUID },
                sortBy: [SortDescriptor(\.scheduledAt, order: .reverse)]
            )
            let stored = try context.fetch(descriptor)
            return stored.map { Self.taskRunFromStored($0) }
        }
    }
    // MARK: - Projects (V7 Phase P07)

    func projectDefinitions(ownerID: UserID) async throws -> [ProjectDefinition] {
        let ownerUUID = ownerID.rawValue
        let stored = try await MainActor.run {
            let descriptor = FetchDescriptor<StoredProjectDefinition>(
                predicate: #Predicate { $0.ownerID == ownerUUID && !$0.isArchived },
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            return try context.fetch(descriptor)
        }
        return stored.map { s in
            ProjectDefinition(
                id: ProjectID(rawValue: s.id),
                ownerID: UserID(rawValue: s.ownerID),
                title: s.title,
                projectDescription: s.projectDescription,
                categoryID: s.categoryID.map { TaskCategoryID(rawValue: $0) },
                colorHex: s.colorHex,
                isArchived: s.isArchived,
                revision: s.revision,
                createdAt: s.createdAt,
                updatedAt: s.updatedAt
            )
        }
    }

    func upsertProject(_ project: ProjectDefinition, expectedRevision: Int) async throws {
        let id = project.id.rawValue
        try await MainActor.run {
            let descriptor = FetchDescriptor<StoredProjectDefinition>(
                predicate: #Predicate { $0.id == id }
            )
            if let existing = try context.fetch(descriptor).first {
                guard existing.revision == expectedRevision else {
                    throw AppError.validationFailed(field: "revision", reason: "Project revision conflict")
                }
                existing.title = project.title
                existing.projectDescription = project.projectDescription
                existing.categoryID = project.categoryID?.rawValue
                existing.colorHex = project.colorHex
                existing.isArchived = project.isArchived
                existing.revision = project.revision
                existing.updatedAt = project.updatedAt
            } else {
                let stored = StoredProjectDefinition(
                    id: id,
                    ownerID: project.ownerID.rawValue,
                    title: project.title,
                    projectDescription: project.projectDescription,
                    categoryID: project.categoryID?.rawValue,
                    colorHex: project.colorHex,
                    isArchived: project.isArchived,
                    revision: project.revision,
                    createdAt: project.createdAt,
                    updatedAt: project.updatedAt
                )
                context.insert(stored)
            }
            try context.save()
        }
    }

    // MARK: - Categories (V7 Phase P07)

    func categories(ownerID: UserID) async throws -> [TaskCategory] {
        let ownerUUID = ownerID.rawValue
        let stored = try await MainActor.run {
            let descriptor = FetchDescriptor<StoredTaskCategory>(
                predicate: #Predicate { $0.ownerID == ownerUUID && !$0.isArchived },
                sortBy: [SortDescriptor(\.name, order: .forward)]
            )
            return try context.fetch(descriptor)
        }
        return stored.map { s in
            TaskCategory(
                id: TaskCategoryID(rawValue: s.id),
                ownerID: UserID(rawValue: s.ownerID),
                name: s.name,
                iconName: s.iconName,
                colorHex: s.colorHex,
                isArchived: s.isArchived,
                createdAt: s.createdAt,
                updatedAt: s.updatedAt
            )
        }
    }

    func upsertCategory(_ category: TaskCategory) async throws {
        let id = category.id.rawValue
        try await MainActor.run {
            let descriptor = FetchDescriptor<StoredTaskCategory>(
                predicate: #Predicate { $0.id == id }
            )
            if let existing = try context.fetch(descriptor).first {
                existing.name = category.name
                existing.iconName = category.iconName
                existing.colorHex = category.colorHex
                existing.isArchived = category.isArchived
                existing.updatedAt = category.updatedAt
            } else {
                let stored = StoredTaskCategory(
                    id: id,
                    ownerID: category.ownerID.rawValue,
                    name: category.name,
                    iconName: category.iconName,
                    colorHex: category.colorHex,
                    isArchived: category.isArchived,
                    createdAt: category.createdAt,
                    updatedAt: category.updatedAt
                )
                context.insert(stored)
            }
            try context.save()
        }
    }

    // MARK: - Reminders (V7 Phase P07)

    func reminders(ownerID: UserID, includeCompleted: Bool = false, limit: Int? = nil) async throws -> [ReminderDefinition] {
        let ownerUUID = ownerID.rawValue
        let stored = try await MainActor.run {
            var descriptor = FetchDescriptor<StoredReminderDefinition>(
                predicate: #Predicate {
                    $0.ownerID == ownerUUID &&
                    !$0.isArchived &&
                    (includeCompleted || !$0.isCompleted)
                },
                sortBy: [SortDescriptor(\.dueDate, order: .forward)]
            )
            if let limit {
                descriptor.fetchLimit = limit
            }
            return try context.fetch(descriptor)
        }
        let dec = JSONDecoder(); dec.dateDecodingStrategy = .iso8601
        return stored.map { s in
            let recurrence = s.recurrenceData.flatMap { try? dec.decode(TaskRecurrence.self, from: $0) }
            return ReminderDefinition(
                id: ReminderID(rawValue: s.id),
                ownerID: UserID(rawValue: s.ownerID),
                taskID: s.taskID.map { TaskID(rawValue: $0) },
                title: s.title,
                notes: s.notes,
                dueDate: s.dueDate,
                timezoneIdentifier: s.timezoneIdentifier,
                categoryID: s.categoryID.map { TaskCategoryID(rawValue: $0) },
                isCompleted: s.isCompleted,
                completedAt: s.completedAt,
                notificationIdentifier: s.notificationIdentifier,
                recurrence: recurrence,
                revision: s.revision,
                isArchived: s.isArchived,
                createdAt: s.createdAt,
                updatedAt: s.updatedAt
            )
        }
    }

    func dueTodayReminders(ownerID: UserID, referenceDate: Date = Date(), timeZone: TimeZone = TimeZone.current, limit: Int = 20) async throws -> [ReminderDefinition] {
        let allReminders = try await reminders(ownerID: ownerID, includeCompleted: false)
        let filtered = TaskDateFilter.filterRemindersDueToday(reminders: allReminders, in: timeZone, relativeTo: referenceDate)
        return Array(filtered.prefix(limit))
    }

    func upsertReminder(_ reminder: ReminderDefinition, expectedRevision: Int) async throws {
        let enc = JSONEncoder(); enc.dateEncodingStrategy = .iso8601
        let id = reminder.id.rawValue
        try await MainActor.run {
            let descriptor = FetchDescriptor<StoredReminderDefinition>(
                predicate: #Predicate { $0.id == id }
            )
            if let existing = try context.fetch(descriptor).first {
                guard existing.revision == expectedRevision else {
                    throw AppError.validationFailed(field: "revision", reason: "Reminder revision conflict")
                }
                existing.taskID = reminder.taskID?.rawValue
                existing.title = reminder.title
                existing.notes = reminder.notes
                existing.dueDate = reminder.dueDate
                existing.timezoneIdentifier = reminder.timezoneIdentifier
                existing.categoryID = reminder.categoryID?.rawValue
                existing.isCompleted = reminder.isCompleted
                existing.completedAt = reminder.completedAt
                existing.notificationIdentifier = reminder.notificationIdentifier
                existing.recurrenceData = reminder.recurrence.flatMap { try? enc.encode($0) }
                existing.revision = reminder.revision
                existing.isArchived = reminder.isArchived
                existing.updatedAt = reminder.updatedAt
            } else {
                let stored = StoredReminderDefinition(
                    id: id,
                    ownerID: reminder.ownerID.rawValue,
                    taskID: reminder.taskID?.rawValue,
                    title: reminder.title,
                    notes: reminder.notes,
                    dueDate: reminder.dueDate,
                    timezoneIdentifier: reminder.timezoneIdentifier,
                    categoryID: reminder.categoryID?.rawValue,
                    isCompleted: reminder.isCompleted,
                    completedAt: reminder.completedAt,
                    notificationIdentifier: reminder.notificationIdentifier,
                    recurrenceData: reminder.recurrence.flatMap { try? enc.encode($0) },
                    revision: reminder.revision,
                    isArchived: reminder.isArchived,
                    createdAt: reminder.createdAt,
                    updatedAt: reminder.updatedAt
                )
                context.insert(stored)
            }
            try context.save()
        }
    }

    func toggleReminderCompletion(id: ReminderID) async throws {
        let uuid = id.rawValue
        try await MainActor.run {
            let descriptor = FetchDescriptor<StoredReminderDefinition>(
                predicate: #Predicate { $0.id == uuid }
            )
            guard let existing = try context.fetch(descriptor).first else { return }
            existing.isCompleted.toggle()
            existing.completedAt = existing.isCompleted ? Date() : nil
            existing.revision += 1
            existing.updatedAt = Date()
            try context.save()
        }
    }
}

extension TaskRepository: TaskRepositoryProtocol {}
