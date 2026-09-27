// Tasks/ApplicationActionCoordinator.swift
// Unified coordinator for touch, text, voice, and shortcut action execution.
// Per V7 Phase P02/P03 and docs/04 Exact Engineering Contracts Section A.

import Foundation

actor ApplicationActionCoordinator {

    private let taskRepository: any TaskRepositoryProtocol
    private let receiptStore: ToolReceiptStore
    private let reminderScheduler: LocalReminderScheduler
    private let clock: @Sendable () -> Date

    init(
        taskRepository: any TaskRepositoryProtocol,
        receiptStore: ToolReceiptStore,
        reminderScheduler: LocalReminderScheduler,
        clock: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.taskRepository = taskRepository
        self.receiptStore = receiptStore
        self.reminderScheduler = reminderScheduler
        self.clock = clock
    }

    /// Executes a validated action within an active authenticated session.
    /// Strictly enforces session generation, owner binding, durable PREPARED receipts,
    /// atomic idempotency, and explicit notification statuses.
    func execute(_ action: ValidatedAction, in session: SessionToken) async throws -> ActionReceipt {
        // 1. Owner and session validation (Contract A)
        guard session.userID == action.ownerID else {
            throw AppError.ownerMismatch(requested: action.ownerID, current: session.userID)
        }
        guard session.generation == action.sessionGeneration else {
            throw AppError.sessionChanged(
                expectedGeneration: action.sessionGeneration,
                currentGeneration: session.generation
            )
        }

        // 2. Owner-bound idempotency key
        let opKey = "\(action.ownerID.rawValue.uuidString):\(action.source.rawValue):\(action.operationID.uuidString)"

        // 3. Check for previous execution
        if let existing = await receiptStore.receiptForOperationKey(opKey) {
            switch existing.status {
            case .succeeded:
                return ActionReceipt(
                    id: existing.id,
                    ownerID: existing.ownerID,
                    operationID: action.operationID,
                    targetEntityID: existing.invocationID.uuidString,
                    dbStatus: .stored,
                    notificationStatus: .scheduled,
                    wasApproved: true,
                    redactedSummary: existing.redactedResult ?? "Action already executed",
                    timestamp: existing.createdAt
                )
            case .prepared, .ambiguous:
                throw AppError.sideEffectAmbiguous(operationKey: opKey)
            case .failed:
                throw AppError.toolExecutionFailed(
                    toolID: action.source.rawValue,
                    message: "Prior action execution failed"
                )
            }
        }

        // 4. Commit durable PREPARED receipt before any side effect
        _ = try await receiptStore.recordPrepared(
            id: action.operationID,
            invocationID: action.operationID,
            toolID: action.source.rawValue,
            ownerID: action.ownerID,
            traceID: TraceID(rawValue: action.operationID),
            operationKey: opKey
        )

        // 5. Re-verify session generation after async await boundary
        guard session.userID == action.ownerID else {
            throw AppError.ownerMismatch(requested: action.ownerID, current: session.userID)
        }
        guard session.generation == action.sessionGeneration else {
            throw AppError.sessionChanged(
                expectedGeneration: action.sessionGeneration,
                currentGeneration: session.generation
            )
        }

        // 6. Perform the side effect based on payload
        let now = clock()
        switch action.payload {
        case .reminder(let title, let fireDate, let timezoneIdentifier, let recurrence):
            let taskID = TaskID()
            let notifID = "task_\(taskID.rawValue.uuidString)"
            let definition = TaskDefinition(
                id: taskID,
                ownerID: action.ownerID,
                title: title,
                taskDescription: "Reminder scheduled for \(fireDate)",
                schedule: TaskSchedule(fireDate: fireDate, timezoneIdentifier: timezoneIdentifier),
                recurrence: recurrence,
                revision: 1,
                isArchived: false,
                notificationIdentifiers: [notifID],
                createdAt: now,
                updatedAt: now
            )

            // Step A: Persist to repository first
            do {
                try await taskRepository.upsertDefinition(definition, expectedRevision: 1)
            } catch {
                try? await receiptStore.updateStatus(id: action.operationID, status: .failed, result: error.localizedDescription)
                throw error
            }

            // Step B: Schedule notification via OS scheduler
            var notifStatus: NotificationScheduleStatus = .none
            do {
                try await reminderScheduler.scheduleReminder(
                    taskID: taskID,
                    occurrenceID: nil,
                    title: title,
                    fireDate: fireDate
                )
                notifStatus = .scheduled
            } catch AppError.permissionDenied {
                // Denied UserNotifications: persists reminder but reports alertNotScheduled (Contract P02)
                notifStatus = .alertNotScheduled
            } catch {
                notifStatus = .failed
            }

            let summary = notifStatus == .alertNotScheduled
                ? "Reminder stored (alert not scheduled: notifications disabled): \(title)"
                : "Reminder scheduled: \(title)"

            // Step C: Reconcile and commit final receipt status
            do {
                try await receiptStore.updateStatus(id: action.operationID, status: .succeeded, result: summary)
            } catch {
                try? await receiptStore.updateStatus(
                    id: action.operationID,
                    status: .ambiguous,
                    result: "Task persisted but receipt finalization failed: \(error.localizedDescription)"
                )
                throw AppError.sideEffectAmbiguous(operationKey: opKey)
            }

            return ActionReceipt(
                id: UUID(),
                ownerID: action.ownerID,
                operationID: action.operationID,
                targetEntityID: taskID.rawValue.uuidString,
                dbStatus: .stored,
                notificationStatus: notifStatus,
                wasApproved: true,
                redactedSummary: summary,
                timestamp: now
            )

        case .task(let title, let description, let schedule, let recurrence):
            let taskID = TaskID()
            let definition = TaskDefinition(
                id: taskID,
                ownerID: action.ownerID,
                title: title,
                taskDescription: description,
                schedule: schedule,
                recurrence: recurrence,
                revision: 1,
                isArchived: false,
                notificationIdentifiers: [],
                createdAt: now,
                updatedAt: now
            )

            do {
                try await taskRepository.upsertDefinition(definition, expectedRevision: 1)
            } catch {
                try? await receiptStore.updateStatus(id: action.operationID, status: .failed, result: error.localizedDescription)
                throw error
            }

            let summary = "Task created: \(title)"
            do {
                try await receiptStore.updateStatus(id: action.operationID, status: .succeeded, result: summary)
            } catch {
                try? await receiptStore.updateStatus(
                    id: action.operationID,
                    status: .ambiguous,
                    result: "Task persisted but receipt finalization failed: \(error.localizedDescription)"
                )
                throw AppError.sideEffectAmbiguous(operationKey: opKey)
            }

            return ActionReceipt(
                id: UUID(),
                ownerID: action.ownerID,
                operationID: action.operationID,
                targetEntityID: taskID.rawValue.uuidString,
                dbStatus: .stored,
                notificationStatus: .none,
                wasApproved: true,
                redactedSummary: summary,
                timestamp: now
            )

        case .conversation(let conversationID, let message):
            let summary = "Conversation action: \(message.prefix(40))"
            do {
                try await receiptStore.updateStatus(id: action.operationID, status: .succeeded, result: summary)
            } catch {
                try? await receiptStore.updateStatus(id: action.operationID, status: .ambiguous, result: error.localizedDescription)
                throw AppError.sideEffectAmbiguous(operationKey: opKey)
            }

            return ActionReceipt(
                id: UUID(),
                ownerID: action.ownerID,
                operationID: action.operationID,
                targetEntityID: conversationID.rawValue.uuidString,
                dbStatus: .stored,
                notificationStatus: .none,
                wasApproved: true,
                redactedSummary: summary,
                timestamp: now
            )
        }
    }
}
