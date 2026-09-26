// Integrations/ShortcutsBridge.swift
// App Intents and Shortcuts integration bridge.
// Per V3 §Integrations/ShortcutsBridge.swift blueprint.

import Foundation

struct ShortcutsBridge: Sendable {
    static func isShortcutsAvailable() -> Bool {
        true
    }
}
