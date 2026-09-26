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

    func taskDefinitions(ownerID: UserID) async throws -> [TaskDefinition] {
        let ownerUUID = ownerID.rawValue
        let stored = try await MainActor.run {
            let descriptor = FetchDescriptor<StoredTaskDefinition>(
                predicate: #Predicate { $0.ownerID == ownerUUID && !$0.isArchived },
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            return try context.fetch(descriptor)
        }
        let dec = JSONDecoder(); dec.dateDecodingStrategy = .iso8601
        let enc = JSONEncoder(); enc.dateEncodingStrategy = .iso8601
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
                revision: stored.revision,
                isArchived: stored.isArchived,
                notificationIdentifiers: notifIDs,
                createdAt: stored.createdAt,
                updatedAt: stored.updatedAt
            )
        }
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
                return taskRunFromStored(existing)
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
            return stored.map { taskRunFromStored($0) }
        }
    }
}
