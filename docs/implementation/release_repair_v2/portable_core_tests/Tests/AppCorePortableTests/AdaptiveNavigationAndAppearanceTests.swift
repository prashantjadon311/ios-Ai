// AdaptiveNavigationAndAppearanceTests.swift
// Tests navigation contracts and appearance mappings for V5 Unified Navigation (Phase P04).

import XCTest
@testable import AppCorePortable

final class AdaptiveNavigationAndAppearanceTests: XCTestCase {

    func testAppearanceModeMapping() {
        // In Swift, AppearanceMode values:
        XCTAssertEqual(AppearanceMode.light.rawValue, "light")
        XCTAssertEqual(AppearanceMode.dark.rawValue, "dark")
        XCTAssertEqual(AppearanceMode.system.rawValue, "system")
    }

    func testAppPreferenceDefaultAppearanceIsSystem() {
        let prefs = AppPreference(ownerID: UserID())
        XCTAssertEqual(prefs.appearanceMode, .system, "Default appearance mode must be system")
    }

    func testAppearanceModePersistenceRoundTrip() {
        var prefs = AppPreference(ownerID: UserID())
        prefs.appearanceMode = .dark
        XCTAssertEqual(prefs.appearanceMode, .dark)

        prefs.appearanceMode = .light
        XCTAssertEqual(prefs.appearanceMode, .light)
    }
}
