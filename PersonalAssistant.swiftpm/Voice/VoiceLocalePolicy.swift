// Voice/VoiceLocalePolicy.swift
// Validates voice recognition and synthesis locale support.
// Per V3 §Voice/VoiceLocalePolicy.swift blueprint, T023.

import Foundation
#if canImport(Speech)
import Speech
#endif

struct VoiceLocalePolicy: Sendable {
    static let supportedCanonicalLocales = ["en-US", "en-GB", "en-IN", "hi-IN"]

    static func isLocaleSupported(_ locale: Locale) -> Bool {
        #if canImport(Speech)
        let supported = SFSpeechRecognizer.supportedLocales()
        return supported.contains(locale) || supported.contains(Locale(identifier: locale.identifier))
        #else
        return supportedCanonicalLocales.contains(locale.identifier) || locale.identifier.starts(with: "en")
        #endif
    }

    static func checkLocaleAvailability(identifier: String) -> (isSupported: Bool, message: String?) {
        let loc = Locale(identifier: identifier)
        if isLocaleSupported(loc) {
            return (true, nil)
        } else {
            return (false, "Voice recognition is not available for '\(identifier)' on this device. Please select English or use text input.")
        }
    }
}
