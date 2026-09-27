import Foundation
import XCTest
@testable import AppCorePortable

final class SessionGuardTests: XCTestCase {

    final class ExecutionTracker: @unchecked Sendable {
        private var _count = 0
        private let lock = NSLock()

        var count: Int {
            lock.lock()
            defer { lock.unlock() }
            return _count
        }

        func record() {
            lock.lock()
            _count += 1
            lock.unlock()
        }
    }

    private func makeApprovalRequest(
        id: ApprovalID = ApprovalID(),
        invocationID: UUID = UUID(),
        ownerID: UserID = UserID(),
        toolID: String = "calendar_create",
        payloadHash: Data = Data(repeating: 7, count: 32),
        sessionGeneration: UUID = UUID(),
        expiresIn: TimeInterval = 300
    ) -> ApprovalRequest {
        ApprovalRequest(
            id: id,
            invocationID: invocationID,
            toolID: toolID,
            schemaVersion: 1,
            ownerID: ownerID,
            traceID: TraceID(),
            payloadHash: payloadHash,
            riskLevel: .medium,
            humanReadableSummary: "Create calendar event",
            recipient: "local",
            dataClasses: [.personal],
            canonicalArguments: Data("{\"title\":\"Dinner\"}".utf8),
            sessionGeneration: sessionGeneration,
            expiresAt: Date().addingTimeInterval(expiresIn)
        )
    }

    // MARK: - SessionGuard Direct Tests

    func testSessionGuard_matchingSession_succeeds() {
        let owner = UserID()
        let gen = UUID()
        let tokenA = SessionToken(userID: owner, generation: gen)
        let tokenB = SessionToken(userID: owner, generation: gen)

        XCTAssertNoThrow(try SessionGuard.require(token: tokenA, against: tokenB))
    }

    func testSessionGuard_staleGeneration_throwsSessionChanged() {
        let owner = UserID()
        let gen1 = UUID()
        let gen2 = UUID()
        let provided = SessionToken(userID: owner, generation: gen1)
        let current = SessionToken(userID: owner, generation: gen2)

        XCTAssertThrowsError(try SessionGuard.require(token: provided, against: current)) { error in
            guard let appError = error as? AppError,
                  case .sessionChanged(let expected, let cur) = appError else {
                XCTFail("Expected AppError.sessionChanged, got \(error)")
                return
            }
            XCTAssertEqual(expected, gen1)
            XCTAssertEqual(cur, gen2)
        }
    }

    func testSessionGuard_ownerMismatch_throwsOwnerMismatch() {
        let ownerA = UserID()
        let ownerB = UserID()
        let gen = UUID()
        let provided = SessionToken(userID: ownerA, generation: gen)
        let current = SessionToken(userID: ownerB, generation: gen)

        XCTAssertThrowsError(try SessionGuard.require(token: provided, against: current)) { error in
            guard let appError = error as? AppError,
                  case .ownerMismatch(let req, let cur) = appError else {
                XCTFail("Expected AppError.ownerMismatch, got \(error)")
                return
            }
            XCTAssertEqual(req, ownerA)
            XCTAssertEqual(cur, ownerB)
        }
    }

    func testSessionGuard_requireOwner_matching_succeeds() {
        let owner = UserID()
        XCTAssertNoThrow(try SessionGuard.requireOwner(userID: owner, against: owner))
    }

    func testSessionGuard_requireOwner_mismatch_throwsOwnerMismatch() {
        let ownerA = UserID()
        let ownerB = UserID()

        XCTAssertThrowsError(try SessionGuard.requireOwner(userID: ownerA, against: ownerB)) { error in
            guard let appError = error as? AppError,
                  case .ownerMismatch(let req, let cur) = appError else {
                XCTFail("Expected AppError.ownerMismatch, got \(error)")
                return
            }
            XCTAssertEqual(req, ownerA)
            XCTAssertEqual(cur, ownerB)
        }
    }

    // MARK: - ApprovalCoordinator Owner & Session Guarding

    func testApprovalCoordinator_approve_matchingSession_succeeds() async throws {
        let coordinator = ApprovalCoordinator()
        let owner = UserID()
        let gen = UUID()
        let session = SessionToken(userID: owner, generation: gen)
        let payloadHash = Data(repeating: 7, count: 32)

        let req = makeApprovalRequest(
            ownerID: owner,
            payloadHash: payloadHash,
            sessionGeneration: gen
        )

        await coordinator.register(request: req)
        let authorized = try await coordinator.approve(
            requestID: req.id,
            expectedPayloadHash: payloadHash,
            currentSession: session
        )

        XCTAssertEqual(authorized.approvalID, req.id)
        XCTAssertEqual(authorized.ownerID, owner)
        XCTAssertEqual(authorized.sessionGeneration, gen)
    }

    func testApprovalCoordinator_approve_ownerMismatch_throwsOwnerMismatch() async throws {
        let coordinator = ApprovalCoordinator()
        let ownerA = UserID()
        let ownerB = UserID()
        let gen = UUID()
        let sessionB = SessionToken(userID: ownerB, generation: gen)
        let payloadHash = Data(repeating: 7, count: 32)

        let req = makeApprovalRequest(
            ownerID: ownerA,
            payloadHash: payloadHash,
            sessionGeneration: gen
        )

        await coordinator.register(request: req)

        do {
            _ = try await coordinator.approve(
                requestID: req.id,
                expectedPayloadHash: payloadHash,
                currentSession: sessionB
            )
            XCTFail("Expected ownerMismatch error")
        } catch let appError as AppError {
            guard case .ownerMismatch(let reqOwner, let curOwner) = appError else {
                XCTFail("Expected AppError.ownerMismatch, got \(appError)")
                return
            }
            XCTAssertEqual(reqOwner, ownerA)
            XCTAssertEqual(curOwner, ownerB)
        }
    }

    func testApprovalCoordinator_approve_generationMismatch_throwsSessionChanged() async throws {
        let coordinator = ApprovalCoordinator()
        let owner = UserID()
        let genOld = UUID()
        let genNew = UUID()
        let sessionNew = SessionToken(userID: owner, generation: genNew)
        let payloadHash = Data(repeating: 7, count: 32)

        let req = makeApprovalRequest(
            ownerID: owner,
            payloadHash: payloadHash,
            sessionGeneration: genOld
        )

        await coordinator.register(request: req)

        do {
            _ = try await coordinator.approve(
                requestID: req.id,
                expectedPayloadHash: payloadHash,
                currentSession: sessionNew
            )
            XCTFail("Expected sessionChanged error")
        } catch let appError as AppError {
            guard case .sessionChanged(let expGen, let curGen) = appError else {
                XCTFail("Expected AppError.sessionChanged, got \(appError)")
                return
            }
            XCTAssertEqual(expGen, genOld)
            XCTAssertEqual(curGen, genNew)
        }
    }

    func testApprovalCoordinator_approve_payloadMismatch_throwsPayloadMismatch() async throws {
        let coordinator = ApprovalCoordinator()
        let owner = UserID()
        let gen = UUID()
        let session = SessionToken(userID: owner, generation: gen)
        let payloadHashOriginal = Data(repeating: 1, count: 32)
        let payloadHashTampered = Data(repeating: 2, count: 32)

        let req = makeApprovalRequest(
            ownerID: owner,
            payloadHash: payloadHashOriginal,
            sessionGeneration: gen
        )

        await coordinator.register(request: req)

        do {
            _ = try await coordinator.approve(
                requestID: req.id,
                expectedPayloadHash: payloadHashTampered,
                currentSession: session
            )
            XCTFail("Expected approvalPayloadMismatch error")
        } catch let appError as AppError {
            guard case .approvalPayloadMismatch = appError else {
                XCTFail("Expected AppError.approvalPayloadMismatch, got \(appError)")
                return
            }
        }
    }

    // MARK: - ToolInvocationCoordinator Owner & Session Guarding

    func testToolInvocationCoordinator_sessionGenerationMismatch_rejectsBeforeExecution() async {
        let store = ToolReceiptStore()
        let coordinator = ToolInvocationCoordinator(receiptStore: store)
        let tracker = ExecutionTracker()

        let owner = UserID()
        let genOld = UUID()
        let genNew = UUID()

        let call = AuthorizedToolCall(
            approvalID: ApprovalID(),
            invocationID: UUID(),
            toolID: "mail_send",
            schemaVersion: 1,
            ownerID: owner,
            traceID: TraceID(),
            canonicalArguments: Data("{}".utf8),
            payloadHash: Data(repeating: 5, count: 32),
            authorizedAt: Date(),
            expiresAt: Date().addingTimeInterval(120),
            sessionGeneration: genOld
        )

        let currentSession = SessionToken(userID: owner, generation: genNew)

        do {
            _ = try await coordinator.executeCall(authorizedCall: call, currentSession: currentSession) { _ in
                tracker.record()
                return "ok"
            }
            XCTFail("Expected sessionChanged error")
        } catch let appError as AppError {
            guard case .sessionChanged(let expGen, let curGen) = appError else {
                XCTFail("Expected AppError.sessionChanged, got \(appError)")
                return
            }
            XCTAssertEqual(expGen, genOld)
            XCTAssertEqual(curGen, genNew)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertEqual(tracker.count, 0, "Side effect must NEVER execute when session generation mismatches")
    }

    func testToolInvocationCoordinator_ownerMismatch_rejectsBeforeExecution() async {
        let store = ToolReceiptStore()
        let coordinator = ToolInvocationCoordinator(receiptStore: store)
        let tracker = ExecutionTracker()

        let ownerA = UserID()
        let ownerB = UserID()
        let gen = UUID()

        let call = AuthorizedToolCall(
            approvalID: ApprovalID(),
            invocationID: UUID(),
            toolID: "mail_send",
            schemaVersion: 1,
            ownerID: ownerA,
            traceID: TraceID(),
            canonicalArguments: Data("{}".utf8),
            payloadHash: Data(repeating: 5, count: 32),
            authorizedAt: Date(),
            expiresAt: Date().addingTimeInterval(120),
            sessionGeneration: gen
        )

        let currentSession = SessionToken(userID: ownerB, generation: gen)

        do {
            _ = try await coordinator.executeCall(authorizedCall: call, currentSession: currentSession) { _ in
                tracker.record()
                return "ok"
            }
            XCTFail("Expected ownerMismatch error")
        } catch let appError as AppError {
            guard case .ownerMismatch(let reqOwner, let curOwner) = appError else {
                XCTFail("Expected AppError.ownerMismatch, got \(appError)")
                return
            }
            XCTAssertEqual(reqOwner, ownerA)
            XCTAssertEqual(curOwner, ownerB)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertEqual(tracker.count, 0, "Side effect must NEVER execute when owner mismatches")
    }
}
