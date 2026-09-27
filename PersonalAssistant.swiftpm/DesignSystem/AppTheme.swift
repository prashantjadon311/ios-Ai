// DesignSystem/AppTheme.swift
// Shared semantic colors, spacing, radii and typography matching approved V5 tokens.
// Supports dark/light mode, high contrast, Dynamic Type, Reduce Motion.

import SwiftUI
#if canImport(UIKit)
import UIKit

extension UIColor {
    convenience init(light: UIColor, dark: UIColor) {
        self.init { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? dark : light
        }
    }

    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
#endif

enum AppTheme {

    // MARK: - Colors (Approved V5 Semantic Tokens)

    enum Color {
        #if canImport(UIKit)
        /// Primary brand accent (lilac restrained)
        static var accent: SwiftUI.Color {
            SwiftUI.Color(uiColor: UIColor(
                light: UIColor(hex: "#A78CCF"),
                dark: UIColor(hex: "#D2B8E9")
            ))
        }

        /// Canvas background
        static var canvas: SwiftUI.Color {
            SwiftUI.Color(uiColor: UIColor(
                light: UIColor(hex: "#FCFBFE"),
                dark: UIColor(hex: "#141319")
            ))
        }

        /// Nav / Drawer background
        static var nav: SwiftUI.Color {
            SwiftUI.Color(uiColor: UIColor(
                light: UIColor(hex: "#F8F6FB"),
                dark: UIColor(hex: "#1A1920")
            ))
        }

        /// Surface / Card background
        static var surface: SwiftUI.Color {
            SwiftUI.Color(uiColor: UIColor(
                light: UIColor(hex: "#FFFFFF"),
                dark: UIColor(hex: "#211F28")
            ))
        }

        /// Border / Separator
        static var border: SwiftUI.Color {
            SwiftUI.Color(uiColor: UIColor(
                light: UIColor(hex: "#EAE6EE"),
                dark: UIColor(hex: "#302D39")
            ))
        }

        /// Primary text
        static var textPrimary: SwiftUI.Color {
            SwiftUI.Color(uiColor: UIColor(
                light: UIColor(hex: "#26242D"),
                dark: UIColor(hex: "#F8F5F8")
            ))
        }

        /// Secondary text
        static var textSecondary: SwiftUI.Color {
            SwiftUI.Color(uiColor: UIColor(
                light: UIColor(hex: "#4E4B58"),
                dark: UIColor(hex: "#D5CDD9")
            ))
        }

        /// Muted text
        static var textMuted: SwiftUI.Color {
            SwiftUI.Color(uiColor: UIColor(
                light: UIColor(hex: "#9B95A3"),
                dark: UIColor(hex: "#9A929F")
            ))
        }

        /// Warm amber voice waveform (dark mode voice center)
        static var amberWaveform: SwiftUI.Color {
            SwiftUI.Color(uiColor: UIColor(hex: "#F5A623"))
        }

        /// Soft pearl aura (light mode voice center)
        static var pearlAura: SwiftUI.Color {
            SwiftUI.Color(uiColor: UIColor(hex: "#E5DDF5"))
        }
        #else
        static var accent: SwiftUI.Color { .purple }
        static var canvas: SwiftUI.Color { .black }
        static var nav: SwiftUI.Color { .gray }
        static var surface: SwiftUI.Color { .gray }
        static var border: SwiftUI.Color { .gray }
        static var textPrimary: SwiftUI.Color { .white }
        static var textSecondary: SwiftUI.Color { .gray }
        static var textMuted: SwiftUI.Color { .gray }
        static var amberWaveform: SwiftUI.Color { .orange }
        static var pearlAura: SwiftUI.Color { .purple }
        #endif

        // Compatibility aliases for existing components
        static var background: SwiftUI.Color { canvas }
        static var secondaryBackground: SwiftUI.Color { surface }
        static var tertiaryBackground: SwiftUI.Color { nav }
        static var primaryText: SwiftUI.Color { textPrimary }
        static var secondaryText: SwiftUI.Color { textSecondary }
        static var separator: SwiftUI.Color { border }
        static var destructive: SwiftUI.Color { .red }
        static var success: SwiftUI.Color { .green }
        static var warning: SwiftUI.Color { .orange }

        // Assistant-specific
        static var mayaAccent: SwiftUI.Color { SwiftUI.Color(hue: 0.55, saturation: 0.7, brightness: 0.85) }
        static var saarAccent: SwiftUI.Color { SwiftUI.Color(hue: 0.08, saturation: 0.7, brightness: 0.85) }

        // Message bubbles
        static var userBubble: SwiftUI.Color { accent }
        static var assistantBubble: SwiftUI.Color { surface }
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
