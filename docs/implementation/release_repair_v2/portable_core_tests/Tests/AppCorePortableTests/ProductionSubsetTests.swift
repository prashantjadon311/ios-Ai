import Foundation
import XCTest
@testable import AppCorePortable

final class ProductionSubsetTests: XCTestCase {
    func testSSEMultibyteFragmentation() throws {
        var decoder = SSEDecoder()
        let text = "data: {\"message\":\"नमस्ते 🌸\"}\r\n\r\n"
        var all: [SSEFrame] = []
        for byte in text.utf8 {
            all += try decoder.feed(Data([byte]))
        }
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.data, "{\"message\":\"नमस्ते 🌸\"}")
    }

    func testSSENoUnboundedUndelimitedFrame() throws {
        var decoder = SSEDecoder(maxFrameBytes: 4, maxTotalBytes: 1024)
        // NEGATIVE REGRESSION: original fifth-commit decoder checks
        // maxFrameBytes only AFTER a newline. It should reject this earlier.
        XCTAssertThrowsError(try decoder.feed(Data("data:abcdef".utf8)))
    }

    func testTaskStepDomainRoundTrip() throws {
        let step = TaskStepRecord(runID: TaskRunID(), description: "Run verified local action", status: .running)
        let data = try JSONEncoder().encode(step)
        let decoded = try JSONDecoder().decode(TaskStepRecord.self, from: data)
        XCTAssertEqual(decoded.id, step.id)
        XCTAssertEqual(decoded.status, .running)
    }

    func testWeeklyRecurrenceHonorsSelectedWeekday() throws {
        var cal = Calendar(identifier: .gregorian)
        let utc = TimeZone(secondsFromGMT: 0)!
        cal.timeZone = utc
        let starting = cal.date(from: DateComponents(year: 2026, month: 9, day: 22, hour: 9, minute: 0))! // Tue
        let recurrence = TaskRecurrence(frequency: .weekly, daysOfWeek: [2])  // Monday
        let result = TaskRecurrenceCalculator.nextDate(after: starting, recurrence: recurrence,
                                                        targetHour: 9, targetMinute: 0, calendar: cal, timeZone: utc)
        XCTAssertNotNil(result)
        if let result { XCTAssertEqual(cal.component(.weekday, from: result), 2) }
        // NEGATIVE REGRESSION: fifth-commit calculator ignores daysOfWeek.
    }
}
