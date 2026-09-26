// Avatar/AvatarState.swift
// Avatar expression states and animation metadata.
// Per V3 §Avatar/AvatarState.swift blueprint.

import Foundation
import SwiftUI

/// States representing the assistant avatar's real-time expression.
enum AvatarState: String, Sendable, CaseIterable {
    case idle
    case listening
    case thinking
    case speaking
    case error

    var accessibilityDescription: String {
        switch self {
        case .idle: return "Assistant is idle"
        case .listening: return "Assistant is listening to your voice"
        case .thinking: return "Assistant is thinking"
        case .speaking: return "Assistant is speaking"
        case .error: return "Assistant encountered an issue"
        }
    }

    var scaleFactor: CGFloat {
        switch self {
        case .idle: return 1.0
        case .listening: return 1.05
        case .thinking: return 0.98
        case .speaking: return 1.08
        case .error: return 0.95
        }
    }
}
