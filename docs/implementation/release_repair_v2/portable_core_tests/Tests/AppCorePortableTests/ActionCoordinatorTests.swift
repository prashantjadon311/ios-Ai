// Tests/AppCorePortableTests/ActionCoordinatorTests.swift
// Tests for ApplicationActionCoordinator enforcing Contract A & P02.

import Foundation
import XCTest
@testable import AppCorePortable

final class ActionCoordinatorTests: XCTestCase {

    actor MockTaskRepository: TaskRepositoryProtocol {
        var storedDefinitions: [TaskDefinition] = []
        var shouldFailUpsert: Bool = false

        func taskDefinitions(ownerID: UserID) async throws -> [TaskDefinition] {
            storedDefinitions.filter { $0.ownerID == ownerID && !$0.isArchived }
        }

        func upsertDefinition(_ definition: TaskDefinition, expectedRevision: Int) async throws {
            if shouldFailUpsert {
                throw AppError.storageRecoveryRequired(reason: "Injected disk write failure")
            }
            if let idx = storedDefinitions.firstIndex(where: { $0.id == definition.id }) {
                storedDefinitions[idx] = definition
            } else {
                storedDefinitions.append(definition)
            }
        }
    }

    private func makeSession(
        userID: UserID = UserID(),
        generation: UUID = UUID()
    ) -> SessionToken {
        SessionToken(
            userID: userID,
            generation: generation
        )
    }

    // MARK: - 1. Normal Reminder Execution

    func testExecuteReminder_persistsTaskAndSchedulesNotification() async throws {
        let repo = MockTaskRepository()
        let store = ToolReceiptStore()
        let notifBackend = SimulatedNotificationSchedulerBackend(authorized: true)
        let scheduler = LocalReminderScheduler(backend: notifBackend)
        let coordinator = ApplicationActionCoordinator(
            taskRepository: repo,
            receiptStore: store,
            reminderScheduler: scheduler
        )

        let session = makeSession()
        let fireDate = Date().addingTimeInterval(3600)
        let action = ValidatedAction(
            ownerID: session.userID,
            sessionGeneration: session.generation,
            source: .voice,
            payload: .reminder(
                title: "Call Doctor",
                fireDate: fireDate,
                timezoneIdentifier: "UTC",
                recurrence: nil
            )
        )

        let receipt = try await coordinator.execute(action, in: session)

        XCTAssertEqual(receipt.ownerID, session.userID)
        XCTAssertEqual(receipt.operationID, action.operationID)
        XCTAssertEqual(receipt.dbStatus, .stored)
        XCTAssertEqual(receipt.notificationStatus, .scheduled)
        XCTAssertTrue(receipt.wasApproved)

        // Verify repository has 1 task
        let tasks = try await repo.taskDefinitions(ownerID: session.userID)
        XCTAssertEqual(tasks.count, 1)
        XCTAssertEqual(tasks.first?.title, "Call Doctor")

        // Verify scheduler has 1 notification
        let pending = await notifBackend.pendingNotificationIdentifiers()
        XCTAssertEqual(pending.count, 1)
    }

    // MARK: - 2. Idempotency & Duplicate Execution

    func testDuplicateExecution_sameOperationID_returnsCachedReceiptWithoutDuplicateSideEffects() async throws {
        let repo = MockTaskRepository()
        let store = ToolReceiptStore()
        let notifBackend = SimulatedNotificationSchedulerBackend(authorized: true)
        let scheduler = LocalReminderScheduler(backend: notifBackend)
        let coordinator = ApplicationActionCoordinator(
            taskRepository: repo,
            receiptStore: store,
            reminderScheduler: scheduler
        )

        let session = makeSession()
        let opID = UUID()
        let action = ValidatedAction(
            ownerID: session.userID,
            sessionGeneration: session.generation,
            operationID: opID,
            source: .touch,
            payload: .reminder(
                title: "Buy Milk",
                fireDate: Date().addingTimeInterval(1800),
                timezoneIdentifier: "UTC",
                recurrence: nil
            )
        )

        // First execution
        let receipt1 = try await coordinator.execute(action, in: session)
        XCTAssertEqual(receipt1.dbStatus, .stored)

        // Second execution with identical opID
        let receipt2 = try await coordinator.execute(action, in: session)
        XCTAssertEqual(receipt2.operationID, opID)

        // Side-effect counts must be strictly 1, never 2
        let tasks = try await repo.taskDefinitions(ownerID: session.userID)
        XCTAssertEqual(tasks.count, 1)

        let pending = await notifBackend.pendingNotificationIdentifiers()
        XCTAssertEqual(pending.count, 1)
    }

    // MARK: - 3. Session Generation Mismatch (Contract A)

    func testSessionGenerationMismatch_rejectsBeforeAnySideEffect() async throws {
        let repo = MockTaskRepository()
        let store = ToolReceiptStore()
        let notifBackend = SimulatedNotificationSchedulerBackend(authorized: true)
        let scheduler = LocalReminderScheduler(backend: notifBackend)
        let coordinator = ApplicationActionCoordinator(
            taskRepository: repo,
            receiptStore: store,
            reminderScheduler: scheduler
        )

        let session = makeSession()
        let staleGeneration = UUID() // Different generation!
        let action = ValidatedAction(
            ownerID: session.userID,
            sessionGeneration: staleGeneration,
            source: .text,
            payload: .task(title: "Secret Task", description: "", schedule: nil, recurrence: nil)
        )

        do {
            _ = try await coordinator.execute(action, in: session)
            XCTFail("Must throw sessionChanged error")
        } catch let appErr as AppError {
            if case .sessionChanged(let expected, let current) = appErr {
                XCTAssertEqual(expected, staleGeneration)
                XCTAssertEqual(current, session.generation)
            } else {
                XCTFail("Expected sessionChanged, got: \(appErr)")
            }
        }

        // Verify ZERO side effects
        let tasks = try await repo.taskDefinitions(ownerID: session.userID)
        XCTAssertEqual(tasks.count, 0)
    }

    // MARK: - 4. Owner Mismatch (Contract A)

    func testOwnerMismatch_rejectsBeforeAnySideEffect() async throws {
        let repo = MockTaskRepository()
        let store = ToolReceiptStore()
        let notifBackend = SimulatedNotificationSchedulerBackend(authorized: true)
        let scheduler = LocalReminderScheduler(backend: notifBackend)
        let coordinator = ApplicationActionCoordinator(
            taskRepository: repo,
            receiptStore: store,
            reminderScheduler: scheduler
        )

        let session = makeSession()
        let wrongOwner = UserID()
        let action = ValidatedAction(
            ownerID: wrongOwner,
            sessionGeneration: session.generation,
            source: .text,
            payload: .task(title: "Other User Task", description: "", schedule: nil, recurrence: nil)
        )

        do {
            _ = try await coordinator.execute(action, in: session)
            XCTFail("Must throw ownerMismatch error")
        } catch let appErr as AppError {
            if case .ownerMismatch(let requested, let current) = appErr {
                XCTAssertEqual(requested, wrongOwner)
                XCTAssertEqual(current, session.userID)
            } else {
                XCTFail("Expected ownerMismatch, got: \(appErr)")
            }
        }

        let tasks = try await repo.taskDefinitions(ownerID: session.userID)
        XCTAssertEqual(tasks.count, 0)
    }

    // MARK: - 5. Notification Denied -> alertNotScheduled (Contract P02)

    func testNotificationDenied_persistsReminderWithAlertNotScheduled() async throws {
        let repo = MockTaskRepository()
        let store = ToolReceiptStore()
        // Notifications are NOT authorized by user
        let notifBackend = SimulatedNotificationSchedulerBackend(authorized: false)
        let scheduler = LocalReminderScheduler(backend: notifBackend)
        let coordinator = ApplicationActionCoordinator(
            taskRepository: repo,
            receiptStore: store,
            reminderScheduler: scheduler
        )

        let session = makeSession()
        let action = ValidatedAction(
            ownerID: session.userID,
            sessionGeneration: session.generation,
            source: .voice,
            payload: .reminder(
                title: "Offline Reminder",
                fireDate: Date().addingTimeInterval(3600),
                timezoneIdentifier: "UTC",
                recurrence: nil
            )
        )

        // Must succeed with task stored, but notification clearly marked alertNotScheduled!
        let receipt = try await coordinator.execute(action, in: session)

        XCTAssertEqual(receipt.dbStatus, .stored)
        XCTAssertEqual(receipt.notificationStatus, .alertNotScheduled)
        XCTAssertTrue(receipt.redactedSummary.contains("alert not scheduled"))

        // Task IS in the repository!
        let tasks = try await repo.taskDefinitions(ownerID: session.userID)
        XCTAssertEqual(tasks.count, 1)
        XCTAssertEqual(tasks.first?.title, "Offline Reminder")

        // Zero notifications scheduled
        let pending = await notifBackend.pendingNotificationIdentifiers()
        XCTAssertEqual(pending.count, 0)
    }

    // MARK: - 6. Repository Failure -> No Notification, Receipt Failed

    func testRepositoryFailure_marksReceiptFailedAndSchedulesZeroNotifications() async throws {
        let repo = MockTaskRepository()
        await repo.setShouldFailUpsert(true)

        let store = ToolReceiptStore()
        let notifBackend = SimulatedNotificationSchedulerBackend(authorized: true)
        let scheduler = LocalReminderScheduler(backend: notifBackend)
        let coordinator = ApplicationActionCoordinator(
            taskRepository: repo,
            receiptStore: store,
            reminderScheduler: scheduler
        )

        let session = makeSession()
        let action = ValidatedAction(
            ownerID: session.userID,
            sessionGeneration: session.generation,
            source: .shortcut,
            payload: .reminder(
                title: "Failed Write",
                fireDate: Date().addingTimeInterval(3600),
                timezoneIdentifier: "UTC",
                recurrence: nil
            )
        )

        do {
            _ = try await coordinator.execute(action, in: session)
            XCTFail("Must fail when repository fails")
        } catch {
            // Expected
        }

        // Notification must not be scheduled
        let pending = await notifBackend.pendingNotificationIdentifiers()
        XCTAssertEqual(pending.count, 0)
    }

    // MARK: - 7. Ambiguous Outcome (Receipt status update fails after commit)

    func testReceiptFinalizationFails_throwsSideEffectAmbiguous() async throws {
        let repo = MockTaskRepository()
        let store = ToolReceiptStore()
        // Inject updateStatus failure on succeeded
        await store.setUpdateStatusHook { _, status in
            if status == .succeeded {
                throw AppError.storageRecoveryRequired(reason: "Disk write failure on receipt commit")
            }
        }

        let notifBackend = SimulatedNotificationSchedulerBackend(authorized: true)
        let scheduler = LocalReminderScheduler(backend: notifBackend)
        let coordinator = ApplicationActionCoordinator(
            taskRepository: repo,
            receiptStore: store,
            reminderScheduler: scheduler
        )

        let session = makeSession()
        let action = ValidatedAction(
            ownerID: session.userID,
            sessionGeneration: session.generation,
            source: .shortcut,
            payload: .reminder(
                title: "Ambiguous Outcome Task",
                fireDate: Date().addingTimeInterval(3600),
                timezoneIdentifier: "UTC",
                recurrence: nil
            )
        )

        do {
            _ = try await coordinator.execute(action, in: session)
            XCTFail("Must throw sideEffectAmbiguous when receipt write fails after side effect")
        } catch let appErr as AppError {
            if case .sideEffectAmbiguous = appErr {
                // Expected!
            } else {
                XCTFail("Expected sideEffectAmbiguous, got: \(appErr)")
            }
        }
    }
}

private extension ActionCoordinatorTests.MockTaskRepository {
    func setShouldFailUpsert(_ value: Bool) {
        shouldFailUpsert = value
    }
}
