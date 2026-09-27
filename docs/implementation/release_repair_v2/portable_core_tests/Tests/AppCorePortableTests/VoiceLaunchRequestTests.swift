// Tests/AppCorePortableTests/VoiceLaunchRequestTests.swift
// Tests for VoiceLaunchRequest and ShortcutsBridge lifecycle (Contract D & P03).

import Foundation
import XCTest
@testable import AppCorePortable

final class VoiceLaunchRequestTests: XCTestCase {

    // MARK: - 1. 15-second TTL Expiration

    func testVoiceLaunchRequest_under15s_isNotExpired() {
        let baseDate = Date()
        let request = VoiceLaunchRequest(
            avatarRole: .maya,
            nonce: UUID(),
            createdAt: baseDate,
            source: .shortcut
        )

        // 14 seconds later: still valid
        let checkDate = baseDate.addingTimeInterval(14.0)
        XCTAssertFalse(request.isExpired(currentTime: checkDate))
    }

    func testVoiceLaunchRequest_over15s_isExpired() {
        let baseDate = Date()
        let request = VoiceLaunchRequest(
            avatarRole: .saar,
            nonce: UUID(),
            createdAt: baseDate,
            source: .shortcut
        )

        // 16 seconds later: expired
        let checkDate = baseDate.addingTimeInterval(16.0)
        XCTAssertTrue(request.isExpired(currentTime: checkDate))
    }

    // MARK: - 2. Rapid Tap Coalescing (ShortcutsBridge)

    @MainActor
    func testShortcutsBridge_rapidTapCoalescing() {
        let bridge = ShortcutsBridge()
        let t0 = Date()

        // First tap
        bridge.handleLaunch(role: .maya, currentTime: t0)
        let firstNonce = bridge.pendingLaunchRequest?.nonce
        XCTAssertNotNil(firstNonce)

        // Second tap 0.3s later: should coalesce (ignored)
        let t1 = t0.addingTimeInterval(0.3)
        bridge.handleLaunch(role: .maya, currentTime: t1)
        XCTAssertEqual(bridge.pendingLaunchRequest?.nonce, firstNonce, "Rapid tap within 1.0s must be coalesced")

        // Third tap 1.5s later: creates new request
        let t2 = t0.addingTimeInterval(1.5)
        bridge.handleLaunch(role: .maya, currentTime: t2)
        XCTAssertNotEqual(bridge.pendingLaunchRequest?.nonce, firstNonce, "Tap after 1.0s must register new request")
    }

    // MARK: - 3. Account Switch and Stale Request Dropping (Contract D)

    @MainActor
    func testShortcutsBridge_consumePendingRequest_wrongOwner_dropsRequest() {
        let bridge = ShortcutsBridge()
        let t0 = Date()
        bridge.handleLaunch(role: .maya, currentTime: t0)
        XCTAssertNotNil(bridge.pendingLaunchRequest)

        let ownerA = UserID()
        let ownerB = UserID() // Different account signed in!

        // Attempting to consume with mismatched owner
        let consumed = bridge.consumePendingLaunchRequest(
            currentOwner: ownerB,
            expectedOwner: ownerA,
            currentTime: t0.addingTimeInterval(2.0)
        )

        XCTAssertNil(consumed, "Queued launch request must NOT be consumed by a different account")
        XCTAssertNil(bridge.pendingLaunchRequest, "Mismatched owner must clear pending launch request")
    }

    @MainActor
    func testShortcutsBridge_consumePendingRequest_matchingOwner_consumesSuccessfully() {
        let bridge = ShortcutsBridge()
        let t0 = Date()
        bridge.handleLaunch(role: .saar, currentTime: t0)

        let owner = UserID()
        let consumed = bridge.consumePendingLaunchRequest(
            currentOwner: owner,
            expectedOwner: owner,
            currentTime: t0.addingTimeInterval(2.0)
        )

        XCTAssertNotNil(consumed)
        XCTAssertEqual(consumed?.avatarRole, .saar)
        XCTAssertNil(bridge.pendingLaunchRequest, "Consuming must clear pending request")
    }

    @MainActor
    func testShortcutsBridge_consumePendingRequest_expired_returnsNil() {
        let bridge = ShortcutsBridge()
        let t0 = Date()
        bridge.handleLaunch(role: .maya, currentTime: t0)

        let owner = UserID()
        // 20s later: expired
        let consumed = bridge.consumePendingLaunchRequest(
            currentOwner: owner,
            expectedOwner: owner,
            currentTime: t0.addingTimeInterval(20.0)
        )

        XCTAssertNil(consumed, "Expired launch request must return nil")
    }
}
