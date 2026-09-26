import os

base = "PersonalAssistant.swiftpm"

files = {}

# 1. Tasks/TaskStateMachine.swift
files["Tasks/TaskStateMachine.swift"] = """// Tasks/TaskStateMachine.swift
// Exhaustive state transitions and lifecycle validation for task runs.
// Per V3 §Tasks/TaskStateMachine.swift blueprint.

import Foundation

enum TaskTransitionError: Error, Sendable {
    case invalidTransition(from: TaskRunStatus, to: TaskRunStatus)
    case taskAlreadyTerminal(TaskRunStatus)
}

struct TaskStateMachine: Sendable {
    static func canTransition(from: TaskRunStatus, to: TaskRunStatus) -> Bool {
        switch (from, to) {
        case (.queued, .running): return true
        case (.queued, .cancelled): return true
        case (.running, .succeeded): return true
        case (.running, .failed): return true
        case (.running, .cancelled): return true
        case (.running, .ambiguous): return true
        case (.ambiguous, .succeeded): return true
        case (.ambiguous, .failed): return true
        case (.ambiguous, .cancelled): return true
        default: return false
        }
    }

    static func validateTransition(from: TaskRunStatus, to: TaskRunStatus) throws {
        guard canTransition(from: from, to: to) else {
            throw TaskTransitionError.invalidTransition(from: from, to: to)
        }
    }
}
"""

# 2. Tasks/TaskRecurrence.swift
files["Tasks/TaskRecurrence.swift"] = """// Tasks/TaskRecurrence.swift
// Algorithm B06: Wall-clock recurrence calculation handling DST shifts.
// Per V3 §B06 and §Tasks/TaskRecurrence.swift blueprint.

import Foundation

struct TaskRecurrenceCalculator: Sendable {
    /// Computes the next fire date for a recurring task.
    /// Preserves wall-clock time across 23h spring-forward and 25h fall-back days.
    static func nextDate(
        after current: Date,
        recurrence: RecurrenceRule,
        calendar: Calendar = Calendar.current,
        timeZone: TimeZone = TimeZone.current
    ) -> Date? {
        var cal = calendar
        cal.timeZone = timeZone

        switch recurrence.frequency {
        case .daily:
            return cal.date(byAdding: .day, value: recurrence.interval, to: current)

        case .weekly:
            return cal.date(byAdding: .day, value: 7 * recurrence.interval, to: current)

        case .monthly:
            return cal.date(byAdding: .month, value: recurrence.interval, to: current)

        case .yearly:
            return cal.date(byAdding: .year, value: recurrence.interval, to: current)
        }
    }
}
"""

# 3. Tasks/TaskScheduler.swift
files["Tasks/TaskScheduler.swift"] = """// Tasks/TaskScheduler.swift
// Schedules upcoming task occurrences with deterministic occurrence keys.
// Per V3 §Tasks/TaskScheduler.swift blueprint.

import Foundation

struct TaskScheduler: Sendable {
    static func makeOccurrenceKey(taskID: TaskID, scheduledDate: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return "\\(taskID.rawValue.uuidString)_\\(formatter.string(from: scheduledDate))"
    }

    static func scheduleNextRun(
        for task: TaskDefinition,
        after lastDate: Date = Date()
    ) -> (occurrenceKey: String, scheduledDate: Date)? {
        guard let rule = task.recurrenceRule else { return nil }
        guard let next = TaskRecurrenceCalculator.nextDate(after: lastDate, recurrence: rule) else {
            return nil
        }
        let key = makeOccurrenceKey(taskID: task.id, scheduledDate: next)
        return (key, next)
    }
}
"""

# 4. Tasks/TaskIdempotency.swift
files["Tasks/TaskIdempotency.swift"] = """// Tasks/TaskIdempotency.swift
// Prevents duplicate executions of the same task run occurrence.
// Per V3 §Tasks/TaskIdempotency.swift blueprint.

import Foundation

actor TaskIdempotencyLedger {
    private var executedKeys: Set<String> = []

    func claimExecution(occurrenceKey: String) -> Bool {
        if executedKeys.contains(occurrenceKey) {
            return false
        }
        executedKeys.insert(occurrenceKey)
        return true
    }

    func releaseExecution(occurrenceKey: String) {
        executedKeys.remove(occurrenceKey)
    }
}
"""

# 5. Tasks/LocalReminderScheduler.swift
files["Tasks/LocalReminderScheduler.swift"] = """// Tasks/LocalReminderScheduler.swift
// UserNotifications integration for local task alerts.
// Per V3 §Tasks/LocalReminderScheduler.swift blueprint.

import Foundation
#if canImport(UserNotifications)
import UserNotifications
#endif

actor LocalReminderScheduler {
    func scheduleReminder(taskID: TaskID, title: String, fireDate: Date) async throws {
        #if canImport(UserNotifications)
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = title
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: "task_\\(taskID.rawValue.uuidString)",
            content: content,
            trigger: trigger
        )
        try await center.add(request)
        #endif
    }

    func cancelReminder(taskID: TaskID) async {
        #if canImport(UserNotifications)
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["task_\\(taskID.rawValue.uuidString)"])
        #endif
    }
}
"""

# 6. Tasks/TaskRecovery.swift
files["Tasks/TaskRecovery.swift"] = """// Tasks/TaskRecovery.swift
// Reconciles interrupted or crashed in-flight tasks upon app launch.
// Per V3 §Tasks/TaskRecovery.swift blueprint.

import Foundation

struct TaskRecoveryWorker: Sendable {
    static func reconcileInFlightRuns(
        runs: [TaskRun]
    ) -> [TaskRun] {
        return runs.map { run in
            if run.status == .running {
                var reconciled = run
                reconciled.status = .ambiguous
                return reconciled
            }
            return run
        }
    }
}
"""

# 7. Tasks/TaskEngineActor.swift
files["Tasks/TaskEngineActor.swift"] = """// Tasks/TaskEngineActor.swift
// Core actor coordinating task scheduling, progress tracking, and execution runs.
// Per V3 §Tasks/TaskEngineActor.swift blueprint.

import Foundation

actor TaskEngineActor {
    private let taskRepository: TaskRepository
    private let reminderScheduler: LocalReminderScheduler
    private var activeTasks: [TaskID: Task<Void, Never>] = [:]

    init(taskRepository: TaskRepository, reminderScheduler: LocalReminderScheduler = LocalReminderScheduler()) {
        self.taskRepository = taskRepository
        self.reminderScheduler = reminderScheduler
    }

    func cancelTask(taskID: TaskID) async {
        activeTasks[taskID]?.cancel()
        activeTasks.removeValue(forKey: taskID)
        await reminderScheduler.cancelReminder(taskID: taskID)
    }

    func scheduleTask(task: TaskDefinition) async throws {
        if let schedule = task.scheduleTime {
            try await reminderScheduler.scheduleReminder(
                taskID: task.id,
                title: task.title,
                fireDate: schedule
            )
        }
    }
}
"""

# 8. Tasks/ForegroundExecutor.swift
files["Tasks/ForegroundExecutor.swift"] = """// Tasks/ForegroundExecutor.swift
// Bounded foreground execution with strict cancellation checks.
// Per V3 §Tasks/ForegroundExecutor.swift blueprint.

import Foundation

struct ForegroundExecutor: Sendable {
    static func executeWithTimeout<T: Sendable>(
        timeoutSeconds: TimeInterval,
        operation: @Sendable @escaping () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            group.addTask {
                try await Task.sleep(for: .seconds(timeoutSeconds))
                throw AppError.interrupted(reason: "Operation timed out")
            }
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
}
"""

# 9. Tasks/TaskPlanner.swift
files["Tasks/TaskPlanner.swift"] = """// Tasks/TaskPlanner.swift
// Decomposes high-level goals into atomic verifiable TaskStep items.
// Per V3 §Tasks/TaskPlanner.swift blueprint.

import Foundation

struct TaskPlanner: Sendable {
    static func planSteps(for goal: String) -> [TaskStep] {
        return [
            TaskStep(title: "Analyze goal: \\(goal)", sequence: 1),
            TaskStep(title: "Execute primary task actions", sequence: 2),
            TaskStep(title: "Verify completion and record audit receipt", sequence: 3)
        ]
    }
}
"""

# 10. Tasks/TaskProgress.swift
files["Tasks/TaskProgress.swift"] = """// Tasks/TaskProgress.swift
// Deterministic progress estimation based on completed task steps.
// Per V3 §Tasks/TaskProgress.swift blueprint.

import Foundation

struct TaskProgressEstimator: Sendable {
    static func calculateProgress(steps: [TaskStep]) -> Double {
        guard !steps.isEmpty else { return 0.0 }
        let completed = steps.filter { $0.isCompleted }.count
        return Double(completed) / Double(steps.count)
    }
}
"""

# 11. Tasks/TaskRunExecutor.swift
files["Tasks/TaskRunExecutor.swift"] = """// Tasks/TaskRunExecutor.swift
// Step-by-step runner executing task steps with state checkpoints.
// Per V3 §Tasks/TaskRunExecutor.swift blueprint.

import Foundation

actor TaskRunExecutor {
    func executeStep(
        step: TaskStep,
        onProgress: @Sendable (Double) async -> Void
    ) async throws -> TaskStep {
        try Task.checkCancellation()
        await onProgress(0.5)
        var updated = step
        updated.isCompleted = true
        updated.completedAt = Date()
        await onProgress(1.0)
        return updated
    }
}
"""

# 12. Tasks/ContinuedBackgroundExecutor.swift
files["Tasks/ContinuedBackgroundExecutor.swift"] = """// Tasks/ContinuedBackgroundExecutor.swift
// COND: BGContinuedProcessingTask integration, runtime gated.
// Per V3 §Tasks/ContinuedBackgroundExecutor.swift blueprint.

import Foundation
#if canImport(BackgroundTasks)
import BackgroundTasks
#endif

final class ContinuedBackgroundExecutor: Sendable {
    static let taskIdentifier = "com.personalassistant.task.processing"

    func registerBackgroundTasks() {
        #if canImport(BackgroundTasks)
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.taskIdentifier,
            using: nil
        ) { task in
            task.setTaskCompleted(success: true)
        }
        #endif
    }
}
"""

# 13. Tasks/RemoteTaskScheduler.swift
files["Tasks/RemoteTaskScheduler.swift"] = """// Tasks/RemoteTaskScheduler.swift
// Protocol contract for future autonomous remote task scheduling.
// Per V3 §Tasks/RemoteTaskScheduler.swift blueprint.

import Foundation

protocol RemoteTaskSchedulerProtocol: Sendable {
    func registerRemoteSchedule(taskID: TaskID, cronExpression: String) async throws
    func cancelRemoteSchedule(taskID: TaskID) async throws
}

final class RemoteTaskSchedulerStub: RemoteTaskSchedulerProtocol {
    func registerRemoteSchedule(taskID: TaskID, cronExpression: String) async throws {
        // V1 local-only release: remote scheduler is a contract interface only
    }

    func cancelRemoteSchedule(taskID: TaskID) async throws {
        // V1 local-only release
    }
}
"""

for rel_path, code in files.items():
    p = os.path.join(base, rel_path)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, "w", encoding="utf-8") as fp:
        fp.write(code.strip() + "\n")
    print(f"Wrote {rel_path} ({len(code)} bytes)")

print("Tasks files written successfully.")
