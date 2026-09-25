// Domain/TaskDefinition.swift
// TaskDefinition (revisioned, user-editable) and schedule types.
// TaskRun (immutable occurrence identity, guarded status transitions).
// TaskStep (per-step execution record).

import Foundation

// MARK: - TaskDefinition

/// V3 §Stable business entities — TaskDefinition.
/// Mutable only through revisioned compare-and-set edits.
struct TaskDefinition: Identifiable, Codable, Sendable, Hashable {
    let id: TaskID
    let ownerID: UserID
    var title: String
    var taskDescription: String
    var schedule: TaskSchedule?
    var recurrence: TaskRecurrence?
    /// Monotonically increasing — each edit increments revision.
    var revision: Int
    var isArchived: Bool
    var notificationIdentifiers: [String]
    let createdAt: Date
    var updatedAt: Date

    init(
        id: TaskID = TaskID(),
        ownerID: UserID,
        title: String,
        taskDescription: String = "",
        schedule: TaskSchedule? = nil,
        recurrence: TaskRecurrence? = nil,
        revision: Int = 1,
        isArchived: Bool = false,
        notificationIdentifiers: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.ownerID = ownerID
        self.title = title
        self.taskDescription = taskDescription
        self.schedule = schedule
        self.recurrence = recurrence
        self.revision = revision
        self.isArchived = isArchived
        self.notificationIdentifiers = notificationIdentifiers
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Task schedule

struct TaskSchedule: Codable, Sendable, Hashable {
    /// Wall-clock fire time (stored in user's specified timezone).
    var fireDate: Date
    /// IANA timezone identifier (e.g. "Asia/Kolkata"). Preserved until changed by user.
    var timezoneIdentifier: String

    init(fireDate: Date, timezoneIdentifier: String = TimeZone.current.identifier) {
        self.fireDate = fireDate
        self.timezoneIdentifier = timezoneIdentifier
    }

    var timezone: TimeZone? { TimeZone(identifier: timezoneIdentifier) }
}

// MARK: - Task recurrence

struct TaskRecurrence: Codable, Sendable, Hashable {
    var frequency: RecurrenceFrequency
    var interval: Int  // e.g. every 2 weeks = frequency .weekly, interval 2
    var endCondition: RecurrenceEndCondition
    var daysOfWeek: Set<Int>?  // 1=Sun..7=Sat for .weekly
    var dayOfMonth: Int?       // 1-31 for .monthly

    init(
        frequency: RecurrenceFrequency,
        interval: Int = 1,
        endCondition: RecurrenceEndCondition = .never,
        daysOfWeek: Set<Int>? = nil,
        dayOfMonth: Int? = nil
    ) {
        self.frequency = frequency
        self.interval = max(1, interval)
        self.endCondition = endCondition
        self.daysOfWeek = daysOfWeek
        self.dayOfMonth = dayOfMonth
    }
}

enum RecurrenceFrequency: String, Codable, Sendable, Hashable, CaseIterable {
    case daily
    case weekly
    case monthly
    case yearly
}

enum RecurrenceEndCondition: Codable, Sendable, Hashable {
    case never
    case afterCount(Int)
    case until(Date)
}

// MARK: - TaskRun

/// V3 §Task state machine — TaskRun.
/// Immutable occurrence identity; status transitions are strictly guarded.
struct TaskRun: Identifiable, Codable, Sendable, Hashable {
    let id: TaskRunID
    let ownerID: UserID
    let taskID: TaskID
    let definitionRevision: Int
    let occurrenceKey: TaskOccurrenceKey
    var status: TaskRunStatus
    var steps: [TaskStepRecord]
    let scheduledAt: Date
    var startedAt: Date?
    var completedAt: Date?
    var errorMessage: String?
    /// Local notification request identifier for this occurrence.
    var notificationID: String?
    let createdAt: Date
    var updatedAt: Date

    init(
        id: TaskRunID = TaskRunID(),
        ownerID: UserID,
        taskID: TaskID,
        definitionRevision: Int,
        occurrenceKey: TaskOccurrenceKey,
        status: TaskRunStatus = .queued,
        steps: [TaskStepRecord] = [],
        scheduledAt: Date,
        notificationID: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.ownerID = ownerID
        self.taskID = taskID
        self.definitionRevision = definitionRevision
        self.occurrenceKey = occurrenceKey
        self.status = status
        self.steps = steps
        self.scheduledAt = scheduledAt
        self.notificationID = notificationID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - TaskRunStatus state machine

/// Per V3 §Task state machine.
enum TaskRunStatus: String, Codable, Sendable, Hashable, CaseIterable {
    case queued
    case running
    case waitingApproval
    case waitingNetwork
    case completed
    case failed
    case cancelled
    case cancelRequested
    case interrupted
    case needsReview   // unresolved external side effect after interruption
    case ambiguous     // timeout after dispatch, cannot confirm remote outcome

    /// Valid forward transitions (pure, no side effects).
    func canTransition(to next: TaskRunStatus) -> Bool {
        switch (self, next) {
        case (.queued, .running),
             (.queued, .cancelled):
            return true
        case (.running, .waitingApproval),
             (.running, .waitingNetwork),
             (.running, .completed),
             (.running, .failed),
             (.running, .cancelRequested),
             (.running, .interrupted):
            return true
        case (.waitingApproval, .queued),
             (.waitingApproval, .cancelled),
             (.waitingApproval, .failed):
            return true
        case (.waitingNetwork, .queued),
             (.waitingNetwork, .cancelled):
            return true
        case (.cancelRequested, .cancelled),
             (.cancelRequested, .completed),
             (.cancelRequested, .failed),
             (.cancelRequested, .ambiguous):
            return true
        case (.interrupted, .queued):
            return true  // only if no unresolved external side effect
        case (.interrupted, .needsReview):
            return true  // if there are unresolved external side effects
        default:
            return false
        }
    }

    /// Terminal states — no further transitions allowed.
    var isTerminal: Bool {
        switch self {
        case .completed, .failed, .cancelled, .ambiguous: return true
        default: return false
        }
    }
}

// MARK: - TaskStepRecord

struct TaskStepRecord: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    let runID: TaskRunID
    var description: String
    var status: StepStatus
    var toolReceiptID: UUID?
    let startedAt: Date
    var completedAt: Date?
    var errorMessage: String?

    init(
        id: UUID = UUID(),
        runID: TaskRunID,
        description: String,
        status: StepStatus = .running,
        toolReceiptID: UUID? = nil,
        startedAt: Date = Date()
    ) {
        self.id = id
        self.runID = runID
        self.description = description
        self.status = status
        self.toolReceiptID = toolReceiptID
        self.startedAt = startedAt
    }
}

enum StepStatus: String, Codable, Sendable, Hashable, CaseIterable {
    case running
    case completed
    case failed
    case skipped
    case ambiguous
}
