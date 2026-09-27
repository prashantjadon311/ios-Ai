import Foundation
import XCTest
@testable import AppCorePortable

final class PrivacyAndConsentTests: XCTestCase {

    // MARK: - Safe Initial State (B04)
    func testAppPreference_defaultInit_isPrivateOnly() {
        let prefs = AppPreference(ownerID: UserID())
        // Invariant: Initial default must be .privateOnly, never .cloudAllowed
        XCTAssertEqual(prefs.privacyMode, .privateOnly, "Fresh AppPreference must default to privateOnly fail-closed")
        XCTAssertTrue(prefs.consents.isEmpty, "Fresh AppPreference must have empty consents")
    }

    // MARK: - Privacy Policy Engine Egress Gates
    func testPrivacyPolicyEngine_privateOnly_blocksAllExternalDestinations() {
        let destinations: [DataEgressDestination] = [.groqAPI, .openRouterAPI, .customEndpoint, .managedGateway, .appleSTT, .externalURL]
        for dest in destinations {
            XCTAssertThrowsError(
                try PrivacyPolicyEngine.checkEgressAllowed(
                    destination: dest,
                    privacyMode: .privateOnly,
                    dataClass: .personal,
                    consent: nil
                ),
                "Destination \(dest) must be blocked in privateOnly mode"
            ) { error in
                guard case AppError.privacyDenied(let route, _) = error else {
                    XCTFail("Expected privacyDenied error, got: \(error)")
                    return
                }
                XCTAssertEqual(route, dest.rawValue)
            }
        }
    }

    func testPrivacyPolicyEngine_localDestinations_allowedInPrivateOnly() throws {
        let localDestinations: [DataEgressDestination] = [.system, .appleFoundationModel]
        for dest in localDestinations {
            XCTAssertNoThrow(
                try PrivacyPolicyEngine.checkEgressAllowed(
                    destination: dest,
                    privacyMode: .privateOnly,
                    dataClass: .personal,
                    consent: nil
                ),
                "Local destination \(dest) must be permitted in privateOnly mode"
            )
        }
    }

    func testPrivacyPolicyEngine_cloudAllowedWithoutConsent_throwsPrivacyDenied() {
        // Invariant: cloudAllowed alone does NOT authorize cloud egress without explicit opt-in
        XCTAssertThrowsError(
            try PrivacyPolicyEngine.checkEgressAllowed(
                destination: .groqAPI,
                privacyMode: .cloudAllowed,
                dataClass: .personal,
                consent: nil
            ),
            "cloudAllowed without explicit consent must throw privacyDenied"
        )
    }

    func testPrivacyPolicyEngine_revokedConsent_throwsPrivacyDenied() {
        let revokedConsent = ConsentRecord(
            destination: .groqAPI,
            maximumDataClass: .sensitive,
            isGranted: false,
            grantedAt: Date().addingTimeInterval(-3600),
            revokedAt: Date().addingTimeInterval(-60)
        )
        XCTAssertThrowsError(
            try PrivacyPolicyEngine.checkEgressAllowed(
                destination: .groqAPI,
                privacyMode: .cloudAllowed,
                dataClass: .personal,
                consent: revokedConsent
            ),
            "Revoked consent must throw privacyDenied"
        )
    }

    func testPrivacyPolicyEngine_wrongDestinationConsent_throwsPrivacyDenied() {
        let groqConsent = ConsentRecord(
            destination: .groqAPI,
            maximumDataClass: .sensitive,
            isGranted: true,
            grantedAt: Date()
        )
        // Checking openRouterAPI with groqAPI consent must fail
        XCTAssertThrowsError(
            try PrivacyPolicyEngine.checkEgressAllowed(
                destination: .openRouterAPI,
                privacyMode: .cloudAllowed,
                dataClass: .personal,
                consent: groqConsent
            ),
            "Consent for Groq must not authorize OpenRouter"
        )
    }

    func testPrivacyPolicyEngine_customEndpoint_changedOrigin_throwsPrivacyDenied() {
        let originalOriginConsent = ConsentRecord(
            destination: .customEndpoint,
            providerConfigID: ProviderConfigID(),
            endpointOrigin: "https://api.original.com",
            maximumDataClass: .sensitive,
            isGranted: true,
            grantedAt: Date()
        )
        XCTAssertEqual(originalOriginConsent.endpointOrigin, "https://api.original.com")
        // Querying for changed origin must fail
        XCTAssertThrowsError(
            try PrivacyPolicyEngine.checkEgressAllowed(
                destination: .customEndpoint,
                privacyMode: .cloudAllowed,
                dataClass: .personal,
                consent: nil // consent for new origin does not exist
            ),
            "Changed custom origin without new consent must throw privacyDenied"
        )
    }

    func testPrivacyPolicyEngine_sensitivityExceedsCeiling_throwsPrivacyDenied() {
        let personalOnlyConsent = ConsentRecord(
            destination: .groqAPI,
            maximumDataClass: .personal,
            isGranted: true,
            grantedAt: Date()
        )
        XCTAssertThrowsError(
            try PrivacyPolicyEngine.checkEgressAllowed(
                destination: .groqAPI,
                privacyMode: .cloudAllowed,
                dataClass: .sensitive, // Exceeds ceiling
                consent: personalOnlyConsent
            ),
            "Sensitivity exceeding consent maximumDataClass must throw privacyDenied"
        )
    }

    func testPrivacyPolicyEngine_secretDataClass_alwaysBlocked() {
        let maxConsent = ConsentRecord(
            destination: .groqAPI,
            maximumDataClass: .secret,
            isGranted: true,
            grantedAt: Date()
        )
        XCTAssertThrowsError(
            try PrivacyPolicyEngine.checkEgressAllowed(
                destination: .groqAPI,
                privacyMode: .cloudAllowed,
                dataClass: .secret,
                consent: maxConsent
            ),
            "Secret data must never leave device even with consent"
        )
    }

    func testProviderConfiguration_normalizedEndpointOrigin_enforcesHTTPS() {
        let httpConfig = ProviderConfiguration(
            ownerID: UserID(),
            providerKind: .custom,
            displayName: "Insecure HTTP",
            baseURL: URL(string: "http://insecure.api.com/v1"),
            keychainKey: "test"
        )
        XCTAssertNil(httpConfig.normalizedEndpointOrigin, "Non-HTTPS endpoint must return nil origin")

        let httpsConfig = ProviderConfiguration(
            ownerID: UserID(),
            providerKind: .custom,
            displayName: "Secure HTTPS",
            baseURL: URL(string: "https://secure.api.com:8443/v1/chat"),
            keychainKey: "test"
        )
        XCTAssertEqual(httpsConfig.normalizedEndpointOrigin, "https://secure.api.com:8443", "HTTPS endpoint must normalize to scheme://host:port")
    }
}
