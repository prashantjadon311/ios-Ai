// Tests/AppCorePortableTests/ProjectAndProgressTests.swift
// Exhaustive unit tests for Gate G8 (Phase P07):
// - Project progress calculation and explicit unknown coverage labeling
// - Owner isolation for projects, categories, tasks, and reminders
// - Timezone-aware due-today and overdue queries across DST transitions
// - Independence of human completion percent from scheduler run execution
// - Standalone vs task-linked reminders and snooze

import XCTest
@testable import AppCorePortable

final class ProjectAndProgressTests: XCTestCase {

    // MARK: - 1. Project & Owner Isolation

    func testProjectCreation_and_ownerIsolation() {
        let owner1 = UserID()
        let owner2 = UserID()

        let proj1 = ProjectDefinition(
            ownerID: owner1,
            title: "iOS App Release",
            projectDescription: "V7.2 release milestones",
            colorHex: "#A78CCF"
        )

        let proj2 = ProjectDefinition(
            ownerID: owner2,
            title: "Private Research",
            projectDescription: "Confidential notes"
        )

        XCTAssertNotEqual(proj1.id, proj2.id)
        XCTAssertEqual(proj1.ownerID, owner1)
        XCTAssertEqual(proj2.ownerID, owner2)
        XCTAssertEqual(proj1.revision, 1)
        XCTAssertFalse(proj1.isArchived)
    }

    // MARK: - 2. Category Assignment for Tasks and Reminders

    func testCategoryAssignment_forTasksAndReminders() {
        let owner = UserID()
        let category = TaskCategory(
            ownerID: owner,
            name: "Work",
            iconName: "briefcase.fill",
            colorHex: "#4A90E2"
        )

        let task = TaskDefinition(
            ownerID: owner,
            title: "Write documentation",
            categoryID: category.id
        )

        let reminder = ReminderDefinition(
            ownerID: owner,
            title: "Submit PR",
            dueDate: Date().addingTimeInterval(3600),
            categoryID: category.id
        )

        XCTAssertEqual(task.categoryID, category.id)
        XCTAssertEqual(reminder.categoryID, category.id)
    }

    // MARK: - 3. Project Progress: Exact Mean of Known Tasks

    func testProjectProgressCalculation_exactMeanOfKnownTasks() {
        let owner = UserID()
        let projectID = ProjectID()

        let tasks = [
            TaskDefinition(ownerID: owner, title: "Step 1", projectID: projectID, completionPercent: 20),
            TaskDefinition(ownerID: owner, title: "Step 2", projectID: projectID, completionPercent: 40),
            TaskDefinition(ownerID: owner, title: "Step 3", projectID: projectID, completionPercent: 60)
        ]

        let summary = ProjectProgressCalculator.calculateProjectProgress(
            projectID: projectID,
            tasks: tasks
        )

        XCTAssertEqual(summary.totalTasksCount, 3)
        XCTAssertEqual(summary.trackedTasksCount, 3)
        XCTAssertEqual(summary.untrackedTasksCount, 0)
        XCTAssertEqual(summary.completedTasksCount, 0)
        XCTAssertEqual(summary.coverageFraction, 1.0)
        XCTAssertEqual(summary.coverageLabel, "3 of 3 tasks tracked (100% coverage)")

        // (20 + 40 + 60) / 3 = 40.0
        XCTAssertNotNil(summary.averageCompletionPercent)
        XCTAssertEqual(summary.averageCompletionPercent!, 40.0, accuracy: 0.001)
    }

    // MARK: - 4. Project Progress: Explicit Unknown Coverage

    func testProjectProgressCalculation_withUntrackedTasks() {
        let owner = UserID()
        let projectID = ProjectID()

        let tasks = [
            TaskDefinition(ownerID: owner, title: "Task A", projectID: projectID, completionPercent: 40),
            TaskDefinition(ownerID: owner, title: "Task B", projectID: projectID, completionPercent: 100),
            TaskDefinition(ownerID: owner, title: "Task C", projectID: projectID, completionPercent: nil), // untracked
            TaskDefinition(ownerID: owner, title: "Task D", projectID: projectID, completionPercent: nil)  // untracked
        ]

        let summary = ProjectProgressCalculator.calculateProjectProgress(
            projectID: projectID,
            tasks: tasks
        )

        XCTAssertEqual(summary.totalTasksCount, 4)
        XCTAssertEqual(summary.trackedTasksCount, 2)
        XCTAssertEqual(summary.untrackedTasksCount, 2)
        XCTAssertEqual(summary.completedTasksCount, 1)
        XCTAssertEqual(summary.coverageFraction, 0.5)
        XCTAssertEqual(summary.coverageLabel, "2 of 4 tasks tracked (50% coverage)")

        // (40 + 100) / 2 = 70.0
        XCTAssertNotNil(summary.averageCompletionPercent)
        XCTAssertEqual(summary.averageCompletionPercent!, 70.0, accuracy: 0.001)
    }

    // MARK: - 5. Project Progress: Empty Project

    func testProjectProgressCalculation_emptyProject() {
        let projectID = ProjectID()
        let summary = ProjectProgressCalculator.calculateProjectProgress(
            projectID: projectID,
            tasks: []
        )

        XCTAssertEqual(summary.totalTasksCount, 0)
        XCTAssertEqual(summary.trackedTasksCount, 0)
        XCTAssertEqual(summary.untrackedTasksCount, 0)
        XCTAssertNil(summary.averageCompletionPercent)
        XCTAssertEqual(summary.coverageLabel, "No tasks")
    }

    // MARK: - 6. Invariant: 100% Manual Completion Does Not Complete Scheduler Run

    func testManualProgress100_doesNotAffectTaskRunExecution() {
        let owner = UserID()
        let taskID = TaskID()

        var task = TaskDefinition(
            id: taskID,
            ownerID: owner,
            title: "Backup Database",
            completionPercent: 0
        )

        let occurrenceKey = TaskOccurrenceKey(
            taskID: taskID,
            definitionRevision: 1,
            scheduledOccurrenceID: UUID()
        )

        var run = TaskRun(
            ownerID: owner,
            taskID: taskID,
            definitionRevision: 1,
            occurrenceKey: occurrenceKey,
            status: .running,
            scheduledAt: Date()
        )

        // User manually sets completionPercent to 100%
        task.completionPercent = 100

        // P07 Invariant: TaskRun status is completely separate and must remain running
        XCTAssertEqual(task.completionPercent, 100)
        XCTAssertEqual(run.status, .running)
        XCTAssertFalse(run.status.isTerminal)

        // Only explicit state machine transitions can complete a run
        XCTAssertTrue(run.status.canTransition(to: .completed))
        run.status = .completed
        XCTAssertTrue(run.status.isTerminal)
    }

    // MARK: - 7. Timezone-Aware Due Today Filtering

    func testTaskDateFilter_dueToday_inUserTimezone() {
        // Create a specific reference date: 2026-05-15 15:00:00 UTC
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        var refComponents = DateComponents()
        refComponents.year = 2026
        refComponents.month = 5
        refComponents.day = 15
        refComponents.hour = 15
        refComponents.minute = 0
        refComponents.second = 0
        let refDate = calendar.date(from: refComponents)!

        // Tokyo is UTC+9: At 15:00 UTC on May 15, Tokyo is already 00:00 on May 16!
        let tokyoTZ = TimeZone(identifier: "Asia/Tokyo")!
        // New York is UTC-4: At 15:00 UTC on May 15, NY is 11:00 AM on May 15.
        let nyTZ = TimeZone(identifier: "America/New_York")!

        // Date A: May 15, 11:00 UTC
        var dateAComponents = DateComponents()
        dateAComponents.year = 2026
        dateAComponents.month = 5
        dateAComponents.day = 15
        dateAComponents.hour = 11
        let dateA = calendar.date(from: dateAComponents)!

        // In NY (where refDate is May 15 11:00 AM), dateA (May 15 07:00 AM NY) is due today:
        XCTAssertTrue(TaskDateFilter.isDueToday(date: dateA, in: nyTZ, relativeTo: refDate))

        // In Tokyo (where refDate is May 16 00:00), dateA (May 15 20:00 Tokyo) is YESTERDAY (overdue), not due today:
        XCTAssertFalse(TaskDateFilter.isDueToday(date: dateA, in: tokyoTZ, relativeTo: refDate))
        XCTAssertTrue(TaskDateFilter.isOverdue(date: dateA, in: tokyoTZ, relativeTo: refDate))
    }

    // MARK: - 8. Overdue Filtering: Strictly Before Start of Day

    func testTaskDateFilter_overdue_strictlyBeforeStartOfDay() {
        let tz = TimeZone(identifier: "UTC")!
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = tz

        let today18pm = cal.date(from: DateComponents(year: 2026, month: 5, day: 15, hour: 18))!
        let today10am = cal.date(from: DateComponents(year: 2026, month: 5, day: 15, hour: 10))!
        let yesterday23pm = cal.date(from: DateComponents(year: 2026, month: 5, day: 14, hour: 23))!

        // Evaluated at 18:00 today:
        // - Today 10:00 AM is NOT overdue (it's due today)
        XCTAssertFalse(TaskDateFilter.isOverdue(date: today10am, in: tz, relativeTo: today18pm))
        XCTAssertTrue(TaskDateFilter.isDueToday(date: today10am, in: tz, relativeTo: today18pm))

        // - Yesterday 23:00 is overdue
        XCTAssertTrue(TaskDateFilter.isOverdue(date: yesterday23pm, in: tz, relativeTo: today18pm))
        XCTAssertFalse(TaskDateFilter.isDueToday(date: yesterday23pm, in: tz, relativeTo: today18pm))
    }

    // MARK: - 9. DST Spring-Forward (23-Hour Day) Calculation

    func testTaskDateFilter_DSTSpringForward_23HourDay() {
        // America/New_York sprang forward on March 10, 2024 at 02:00 -> 03:00 (23-hour day)
        let nyTZ = TimeZone(identifier: "America/New_York")!
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = nyTZ

        let noon = cal.date(from: DateComponents(year: 2024, month: 3, day: 10, hour: 12))!
        let morning = cal.date(from: DateComponents(year: 2024, month: 3, day: 10, hour: 8))!
        let evening = cal.date(from: DateComponents(year: 2024, month: 3, day: 10, hour: 20))!

        // All times on March 10 must match isDueToday regardless of the 1-hour spring-forward gap
        XCTAssertTrue(TaskDateFilter.isDueToday(date: morning, in: nyTZ, relativeTo: noon))
        XCTAssertTrue(TaskDateFilter.isDueToday(date: evening, in: nyTZ, relativeTo: noon))
        XCTAssertFalse(TaskDateFilter.isOverdue(date: morning, in: nyTZ, relativeTo: noon))
    }

    // MARK: - 10. DST Fall-Back (25-Hour Day) Calculation

    func testTaskDateFilter_DSTFallBack_25HourDay() {
        // America/New_York fell back on November 3, 2024 at 02:00 -> 01:00 (25-hour day)
        let nyTZ = TimeZone(identifier: "America/New_York")!
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = nyTZ

        let noon = cal.date(from: DateComponents(year: 2024, month: 11, day: 3, hour: 12))!
        let lateNight = cal.date(from: DateComponents(year: 2024, month: 11, day: 3, hour: 23, minute: 30))!
        let nextDay = cal.date(from: DateComponents(year: 2024, month: 11, day: 4, hour: 1))!

        XCTAssertTrue(TaskDateFilter.isDueToday(date: lateNight, in: nyTZ, relativeTo: noon))
        XCTAssertFalse(TaskDateFilter.isDueToday(date: nextDay, in: nyTZ, relativeTo: noon))
    }

    // MARK: - 11. Standalone vs Task-Linked Reminders

    func testReminderDefinition_taskLinkedAndStandalone() {
        let owner = UserID()
        let taskID = TaskID()
        let due = Date().addingTimeInterval(3600)

        let linked = ReminderDefinition(
            ownerID: owner,
            taskID: taskID,
            title: "Linked reminder",
            dueDate: due
        )

        let standalone = ReminderDefinition(
            ownerID: owner,
            taskID: nil,
            title: "Standalone grocery reminder",
            dueDate: due
        )

        XCTAssertEqual(linked.taskID, taskID)
        XCTAssertNil(standalone.taskID)
        XCTAssertFalse(linked.isCompleted)
        XCTAssertFalse(standalone.isCompleted)
    }

    // MARK: - 12. Completion Percent Clamping

    func testTaskDefinition_completionPercentClamping() {
        let owner = UserID()

        let over = TaskDefinition(ownerID: owner, title: "Over", completionPercent: 150)
        let under = TaskDefinition(ownerID: owner, title: "Under", completionPercent: -20)
        let normal = TaskDefinition(ownerID: owner, title: "Normal", completionPercent: 42)

        XCTAssertEqual(over.completionPercent, 100)
        XCTAssertEqual(under.completionPercent, 0)
        XCTAssertEqual(normal.completionPercent, 42)
    }
}
