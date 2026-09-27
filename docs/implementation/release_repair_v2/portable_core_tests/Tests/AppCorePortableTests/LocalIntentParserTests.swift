// Tests/AppCorePortableTests/LocalIntentParserTests.swift
// Deterministic offline intent parsing tests.
// Per V7 Phase P02/P03 and docs/04 Exact Engineering Contracts Section D.

import XCTest
@testable import AppCorePortable

final class LocalIntentParserTests: XCTestCase {

    private var calendar: Calendar!
    private var utcTimeZone: TimeZone!
    private var testClock: Date!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        utcTimeZone = TimeZone(identifier: "UTC")!
        calendar.timeZone = utcTimeZone

        // Fixed reference clock: 2026-09-28 10:00:00 UTC
        var components = DateComponents()
        components.year = 2026
        components.month = 9
        components.day = 28
        components.hour = 10
        components.minute = 0
        components.second = 0
        testClock = calendar.date(from: components)!
    }

    // MARK: - Deterministic English Phrases

    func testDeterministicPhrase_tomorrowAt6pm_parsedWithInjectedClock() {
        let text = "remind me tomorrow at 6 pm"
        let result = LocalIntentParser.parse(
            text: text,
            referenceDate: testClock,
            calendar: calendar,
            timeZone: utcTimeZone
        )

        // Tomorrow is 2026-09-29, 6 pm UTC is 18:00
        var expectedComponents = DateComponents()
        expectedComponents.year = 2026
        expectedComponents.month = 9
        expectedComponents.day = 29
        expectedComponents.hour = 18
        expectedComponents.minute = 0
        expectedComponents.second = 0
        let expectedDate = calendar.date(from: expectedComponents)!

        switch result {
        case .reminder(let title, let fireDate, let timeZone):
            XCTAssertEqual(title, "Reminder")
            XCTAssertEqual(fireDate, expectedDate)
            XCTAssertEqual(timeZone, utcTimeZone)
        default:
            XCTFail("Expected reminder parse result, got: \(result)")
        }
    }

    func testDeterministicPhrase_withSpecificTitle_extractsTitleAndDate() {
        let text = "remind me to buy groceries tomorrow at 6:30 pm"
        let result = LocalIntentParser.parse(
            text: text,
            referenceDate: testClock,
            calendar: calendar,
            timeZone: utcTimeZone
        )

        var expectedComponents = DateComponents()
        expectedComponents.year = 2026
        expectedComponents.month = 9
        expectedComponents.day = 29
        expectedComponents.hour = 18
        expectedComponents.minute = 30
        expectedComponents.second = 0
        let expectedDate = calendar.date(from: expectedComponents)!

        switch result {
        case .reminder(let title, let fireDate, _):
            XCTAssertEqual(title, "buy groceries")
            XCTAssertEqual(fireDate, expectedDate)
        default:
            XCTFail("Expected reminder with title 'buy groceries', got: \(result)")
        }
    }

    func testDeterministicPhrase_24hourFormat_tomorrow18() {
        let text = "remind me to submit report tomorrow at 18:00"
        let result = LocalIntentParser.parse(
            text: text,
            referenceDate: testClock,
            calendar: calendar,
            timeZone: utcTimeZone
        )

        switch result {
        case .reminder(let title, let fireDate, _):
            XCTAssertEqual(title, "submit report")
            let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            XCTAssertEqual(comps.year, 2026)
            XCTAssertEqual(comps.month, 9)
            XCTAssertEqual(comps.day, 29)
            XCTAssertEqual(comps.hour, 18)
            XCTAssertEqual(comps.minute, 0)
        default:
            XCTFail("Expected reminder parse, got: \(result)")
        }
    }

    // MARK: - Ambiguity and Clarification (Contract D & P02)

    func testAmbiguousRelativeDay_kal_returnsNeedsClarification() {
        let text = "mujhe kal 6 baje yaad dilana"
        let result = LocalIntentParser.parse(
            text: text,
            referenceDate: testClock,
            calendar: calendar,
            timeZone: utcTimeZone
        )

        switch result {
        case .needsClarification(let reason, _, _, _):
            XCTAssertEqual(reason, .ambiguousRelativeDate)
        default:
            XCTFail("Expected needsClarification for ambiguous relative day 'kal', got: \(result)")
        }
    }

    func testAmbiguousRelativeDay_parson_returnsNeedsClarification() {
        let text = "parson shaam 6 baje yaad dila dena"
        let result = LocalIntentParser.parse(
            text: text,
            referenceDate: testClock,
            calendar: calendar,
            timeZone: utcTimeZone
        )

        switch result {
        case .needsClarification(let reason, _, _, _):
            XCTAssertEqual(reason, .ambiguousRelativeDate)
        default:
            XCTFail("Expected needsClarification for ambiguous relative day 'parson', got: \(result)")
        }
    }

    func testUnspecifiedTime_tomorrowWithoutHour_returnsNeedsClarification() {
        let text = "remind me tomorrow"
        let result = LocalIntentParser.parse(
            text: text,
            referenceDate: testClock,
            calendar: calendar,
            timeZone: utcTimeZone
        )

        switch result {
        case .needsClarification(let reason, _, _, _):
            XCTAssertEqual(reason, .unspecifiedTime)
        default:
            XCTFail("Expected needsClarification for unspecified time, got: \(result)")
        }
    }

    func testUnspecifiedDay_timeOnly_returnsNeedsClarification() {
        let text = "remind me at 6 pm"
        let result = LocalIntentParser.parse(
            text: text,
            referenceDate: testClock,
            calendar: calendar,
            timeZone: utcTimeZone
        )

        switch result {
        case .needsClarification(let reason, _, _, _):
            XCTAssertEqual(reason, .ambiguousRelativeDate)
        default:
            XCTFail("Expected needsClarification for unspecified day, got: \(result)")
        }
    }

    // MARK: - Task Parsing

    func testTaskCreationPhrase_valid_extractsTitle() {
        let text = "create task finish slide deck"
        let result = LocalIntentParser.parse(
            text: text,
            referenceDate: testClock,
            calendar: calendar,
            timeZone: utcTimeZone
        )

        switch result {
        case .task(let title, let description, let schedule):
            XCTAssertEqual(title, "finish slide deck")
            XCTAssertEqual(description, "")
            XCTAssertNil(schedule)
        default:
            XCTFail("Expected task result, got: \(result)")
        }
    }

    // MARK: - Malformed and Non-matching Commands

    func testMalformedOrUnrecognized_returnsNotRecognized() {
        let text = "what is the weather in Delhi today?"
        let result = LocalIntentParser.parse(
            text: text,
            referenceDate: testClock,
            calendar: calendar,
            timeZone: utcTimeZone
        )

        XCTAssertEqual(result, .notRecognized)
    }

    func testEmptyString_returnsNotRecognized() {
        let result = LocalIntentParser.parse(
            text: "   ",
            referenceDate: testClock,
            calendar: calendar,
            timeZone: utcTimeZone
        )

        XCTAssertEqual(result, .notRecognized)
    }
}
