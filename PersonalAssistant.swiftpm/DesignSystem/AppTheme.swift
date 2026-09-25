// DesignSystem/AppTheme.swift
// Shared semantic colors, spacing, radii and typography.
// Supports dark/light mode, high contrast, Dynamic Type.

import SwiftUI

enum AppTheme {

    // MARK: - Colors

    enum Color {
        /// Primary brand accent
        static var accent: SwiftUI.Color { .brown }
        static var background: SwiftUI.Color { SwiftUI.Color(uiColor: .systemBackground) }
        static var secondaryBackground: SwiftUI.Color { SwiftUI.Color(uiColor: .secondarySystemBackground) }
        static var tertiaryBackground: SwiftUI.Color { SwiftUI.Color(uiColor: .tertiarySystemBackground) }
        static var primaryText: SwiftUI.Color { SwiftUI.Color(uiColor: .label) }
        static var secondaryText: SwiftUI.Color { SwiftUI.Color(uiColor: .secondaryLabel) }
        static var separator: SwiftUI.Color { SwiftUI.Color(uiColor: .separator) }
        static var destructive: SwiftUI.Color { .red }
        static var success: SwiftUI.Color { .green }
        static var warning: SwiftUI.Color { .orange }

        // Assistant-specific
        static var mayaAccent: SwiftUI.Color { SwiftUI.Color(hue: 0.55, saturation: 0.7, brightness: 0.85) }
        static var saarAccent: SwiftUI.Color { SwiftUI.Color(hue: 0.08, saturation: 0.7, brightness: 0.85) }

        // Message bubbles
        static var userBubble: SwiftUI.Color { .accentColor }
        static var assistantBubble: SwiftUI.Color { SwiftUI.Color(uiColor: .secondarySystemBackground) }
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Radii

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let bubble: CGFloat = 18
        static let full: CGFloat = 999
    }

    // MARK: - Minimum tap target

    static let minimumTapTarget: CGFloat = 44
}

// MARK: - Avatar color helper

extension AvatarRole {
    var themeColor: SwiftUI.Color {
        switch self {
        case .maya: return AppTheme.Color.mayaAccent
        case .saar: return AppTheme.Color.saarAccent
        }
    }
}
