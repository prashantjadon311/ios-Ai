// Integrations/URLLauncher.swift
// Dispatch allowlisted URLs to system app handlers per V3 §A17.

import Foundation
import UIKit

@MainActor
final class URLLauncher {

    /// Opens an external URL if verified safe.
    static func openURL(_ url: URL) async -> Bool {
        guard URLSafetyValidator.isSafe(url: url) else { return false }
        return await UIApplication.shared.open(url)
    }
}
