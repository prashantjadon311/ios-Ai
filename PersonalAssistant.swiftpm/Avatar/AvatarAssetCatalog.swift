// Avatar/AvatarAssetCatalog.swift
// Color palettes and asset lookups for Maya and Saar identities.
// Per V3 §Avatar/AvatarAssetCatalog.swift blueprint.

import SwiftUI

enum AvatarIdentity: String, Sendable, CaseIterable {
    case maya = "Maya"
    case saar = "Saar"
}

struct AvatarAssetCatalog {
    static func primaryColor(for identity: AvatarIdentity) -> Color {
        switch identity {
        case .maya:
            return Color.purple
        case .saar:
            return Color.teal
        }
    }

    static func secondaryColor(for identity: AvatarIdentity) -> Color {
        switch identity {
        case .maya:
            return Color.pink.opacity(0.8)
        case .saar:
            return Color.cyan.opacity(0.8)
        }
    }

    static func systemImage(for identity: AvatarIdentity) -> String {
        switch identity {
        case .maya:
            return "person.crop.circle.fill"
        case .saar:
            return "brain.head.profile"
        }
    }
}
