import Foundation
import XCTest
@testable import AppCorePortable

final class ToolReceiptTests: XCTestCase {

    final class ExecutionTracker: @unchecked Sendable {
        private var _count = 0
        private let lock = NSLock()

        var count: Int {
            lock.lock()
            defer { lock.unlock() }
            return _count
        }

        var executed: Bool {
            count > 0
        }

        func record() {
            lock.lock()
            _count += 1
            lock.unlock()
        }
    }

    private func makeAuthorizedCall(
        invocationID: UUID = UUID(),
        ownerID: UserID = UserID(),
        toolID: String = "calendar_create",
        sessionGeneration: UUID = UUID(),
        expiresIn: TimeInterval = 120
    ) -> AuthorizedToolCall {
        AuthorizedToolCall(
            approvalID: ApprovalID(),
            invocationID: invocationID,
            toolID: toolID,
            schemaVersion: 1,
            ownerID: ownerID,
            traceID: TraceID(),
            canonicalArguments: Data("{\"title\":\"Meeting\"}".utf8),
            payloadHash: Data(repeating: 1, count: 32),
            authorizedAt: Date(),
            expiresAt: Date().addingTimeInterval(expiresIn),
            sessionGeneration: sessionGeneration
        )
    }

    // MARK: - (a) Failure to persist PREPARED -> zero side effects
    func testRecordPreparedFailure_causesZeroSideEffects() async {
        let store = ToolReceiptStore()
        await store.setRecordPreparedHook { _, _ in
            throw AppError.storageRecoveryRequired(reason: "Injected disk failure on PREPARED reservation")
        }

        let coordinator = ToolInvocationCoordinator(receiptStore: store)
        let call = makeAuthorizedCall()
        let tracker = ExecutionTracker()

        do {
            _ = try await coordinator.executeCall(authorizedCall: call) { _ in
                tracker.record()
                return "Created"
            }
            XCTFail("executeCall must fail when recordPrepared throws")
        } catch let appErr as AppError {
            if case .storageRecoveryRequired(let reason) = appErr {
                XCTAssertTrue(reason.contains("Injected disk failure"))
            } else {
                XCTFail("Expected storageRecoveryRequired error, got: \(appErr)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }

        XCTAssertFalse(tracker.executed, "Side effect must NEVER execute when PREPARED receipt persistence fails")
    }

    // MARK: - (b) External action succeeded but success persistence failed -> AMBIGUOUS, never false success
    func testSuccessfulSideEffectWithFailedSuccessReceipt_markedAmbiguousAndThrowsSideEffectAmbiguous() async {
        let store = ToolReceiptStore()
        await store.setUpdateStatusHook { _, status in
            if status == .succeeded {
                throw AppError.storageRecoveryRequired(reason: "Injected disk failure on SUCCEEDED receipt update")
            }
        }

        let coordinator = ToolInvocationCoordinator(receiptStore: store)
        let call = makeAuthorizedCall()
        let tracker = ExecutionTracker()

        do {
            _ = try await coordinator.executeCall(authorizedCall: call) { _ in
                tracker.record()
                return "Calendar event created on remote server"
            }
            XCTFail("executeCall must NEVER report success when success receipt persistence fails")
        } catch let appErr as AppError {
            guard case .sideEffectAmbiguous = appErr else {
                XCTFail("Expected sideEffectAmbiguous error, got: \(appErr)")
                return
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }

        XCTAssertTrue(tracker.executed, "External action was executed")
        let receipt = await store.getReceipt(id: call.invocationID)
        XCTAssertEqual(receipt?.status, .ambiguous, "Receipt must be transitioned to .ambiguous")
        XCTAssertTrue(receipt?.redactedResult?.contains("persistence failed") ?? false)
    }

    // MARK: - (c) Repeated request -> owner-bound idempotency and one effect
    func testDuplicateRequest_returnsCachedSuccessWithoutReExecutingSideEffect() async throws {
        let store = ToolReceiptStore()
        let coordinator = ToolInvocationCoordinator(receiptStore: store)
        let call = makeAuthorizedCall()
        let tracker = ExecutionTracker()

        let result1 = try await coordinator.executeCall(authorizedCall: call) { _ in
            tracker.record()
            return "Event-1234"
        }
        XCTAssertEqual(result1, "Event-1234")
        XCTAssertEqual(tracker.count, 1)

        // Second call with same authorized call
        let result2 = try await coordinator.executeCall(authorizedCall: call) { _ in
            tracker.record()
            return "Event-5678"
        }
        XCTAssertEqual(result2, "Event-1234", "Must return first execution's result")
        XCTAssertEqual(tracker.count, 1, "Side effect must NOT execute a second time")
    }

    // MARK: - (d) Startup reconciliation preserves committed ledger and marks prepared as ambiguous
    func testStartupReconciliation_orphanedPreparedReceiptsReconciledToAmbiguous() async throws {
        let store = ToolReceiptStore()
        let ownerID = UserID()
        let traceID = TraceID()

        // 1. Prepared receipt (orphaned before finish)
        let preparedID = UUID()
        _ = try await store.recordPrepared(
            id: preparedID,
            invocationID: preparedID,
            toolID: "calendar_create",
            ownerID: ownerID,
            traceID: traceID,
            operationKey: "op-prepared"
        )

        // 2. Succeeded receipt (already completed)
        let succeededID = UUID()
        _ = try await store.recordPrepared(
            id: succeededID,
            invocationID: succeededID,
            toolID: "create_reminder",
            ownerID: ownerID,
            traceID: traceID,
            operationKey: "op-succeeded"
        )
        try await store.updateStatus(id: succeededID, status: .succeeded, result: "Reminder-1")

        // 3. Failed receipt
        let failedID = UUID()
        _ = try await store.recordPrepared(
            id: failedID,
            invocationID: failedID,
            toolID: "open_url",
            ownerID: ownerID,
            traceID: traceID,
            operationKey: "op-failed"
        )
        try await store.updateStatus(id: failedID, status: .failed, result: "Network down")

        // Run crash reconciliation
        let reconciledCount = await store.reconcileStartup()
        XCTAssertEqual(reconciledCount, 1, "Exactly one orphaned PREPARED receipt should be reconciled")

        let preparedReceipt = await store.getReceipt(id: preparedID)
        XCTAssertEqual(preparedReceipt?.status, .ambiguous, "Orphaned receipt must be reconciled to .ambiguous")
        XCTAssertEqual(preparedReceipt?.redactedResult, "Execution interrupted by process termination")

        let succeededReceipt = await store.getReceipt(id: succeededID)
        XCTAssertEqual(succeededReceipt?.status, .succeeded, "Committed succeeded receipt must remain intact")
        XCTAssertEqual(succeededReceipt?.redactedResult, "Reminder-1")

        let failedReceipt = await store.getReceipt(id: failedID)
        XCTAssertEqual(failedReceipt?.status, .failed, "Committed failed receipt must remain intact")
        XCTAssertEqual(failedReceipt?.redactedResult, "Network down")
    }

    // MARK: - Cancellation mid-execution -> marks ambiguous and throws
    func testCancellationMidExecution_markedAmbiguousAndThrowsSideEffectAmbiguous() async {
        let store = ToolReceiptStore()
        let coordinator = ToolInvocationCoordinator(receiptStore: store)
        let call = makeAuthorizedCall()

        do {
            _ = try await coordinator.executeCall(authorizedCall: call) { _ in
                throw CancellationError()
            }
            XCTFail("executeCall must throw on cancellation")
        } catch let appErr as AppError {
            guard case .sideEffectAmbiguous = appErr else {
                XCTFail("Expected sideEffectAmbiguous error on cancellation, got: \(appErr)")
                return
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }

        let receipt = await store.getReceipt(id: call.invocationID)
        XCTAssertEqual(receipt?.status, .ambiguous, "Receipt must be marked ambiguous on cancellation")
    }

    // MARK: - Expired approval -> throws without side effect
    func testExpiredApproval_throwsApprovalExpiredWithoutSideEffect() async {
        let store = ToolReceiptStore()
        let coordinator = ToolInvocationCoordinator(receiptStore: store)
        let expiredCall = makeAuthorizedCall(expiresIn: -10)
        let tracker = ExecutionTracker()

        do {
            _ = try await coordinator.executeCall(authorizedCall: expiredCall) { _ in
                tracker.record()
                return "Done"
            }
            XCTFail("executeCall must throw on expired approval")
        } catch let appErr as AppError {
            guard case .approvalExpired = appErr else {
                XCTFail("Expected approvalExpired error, got: \(appErr)")
                return
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }

        XCTAssertFalse(tracker.executed, "Side effect must not execute on expired approval")
    }

    // MARK: - Session generation mismatch -> throws sessionChanged without side effect
    func testSessionMismatch_throwsSessionChangedWithoutSideEffect() async {
        let store = ToolReceiptStore()
        let coordinator = ToolInvocationCoordinator(receiptStore: store)
        let ownerID = UserID()
        let call = makeAuthorizedCall(ownerID: ownerID, sessionGeneration: UUID())
        let activeSession = SessionToken(userID: ownerID, generation: UUID()) // different generation
        let tracker = ExecutionTracker()

        do {
            _ = try await coordinator.executeCall(authorizedCall: call, currentSession: activeSession) { _ in
                tracker.record()
                return "Done"
            }
            XCTFail("executeCall must throw on session mismatch")
        } catch let appErr as AppError {
            guard case .sessionChanged = appErr else {
                XCTFail("Expected sessionChanged error, got: \(appErr)")
                return
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }

        XCTAssertFalse(tracker.executed, "Side effect must not execute on session generation mismatch")
    }
}
