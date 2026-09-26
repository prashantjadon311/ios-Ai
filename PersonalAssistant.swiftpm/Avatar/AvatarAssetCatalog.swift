// Avatar/AvatarAssetCatalog.swift
// Resolve installed built-in and user-selected avatar assets.
// Per V3 §Avatar/AvatarAssetCatalog.swift and §B04/W04.

import Foundation
import SwiftUI

/// Resolves avatar images, colors, and fallback representations.
/// Does not couple avatar gender with voice gender.
enum AvatarAssetCatalog {

    /// Returns asset name or system icon fallback for the given avatar role.
    static func assetName(for role: AvatarRole) -> String {
        switch role {
        case .maya: return "Maya"
        case .saar: return "Saar"
        }
    }

    /// System image fallback if bundled image asset is absent.
    static func systemFallbackIcon(for role: AvatarRole) -> String {
        switch role {
        case .maya: return "person.crop.circle.fill"
        case .saar: return "person.crop.circle.fill"
        }
    }

    /// Accent gradient colors for avatar aura during animations.
    static func glowColors(for role: AvatarRole) -> [SwiftUI.Color] {
        switch role {
        case .maya:
            return [
                SwiftUI.Color(hue: 0.55, saturation: 0.8, brightness: 0.9),
                SwiftUI.Color(hue: 0.65, saturation: 0.6, brightness: 0.8)
            ]
        case .saar:
            return [
                SwiftUI.Color(hue: 0.08, saturation: 0.8, brightness: 0.9),
                SwiftUI.Color(hue: 0.15, saturation: 0.7, brightness: 0.85)
            ]
        }
    }
}
