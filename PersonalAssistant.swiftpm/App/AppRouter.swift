// App/AppRouter.swift
// Global navigation routes, tab selection, sheets and deep links.
// Per V3 §App/AppRouter.swift — typed enum navigation; unknown-link rejection.

import Foundation
import SwiftUI
import Observation

/// Primary navigation destinations (five screens + chat/approvals as routed surfaces).
enum AppDestination: Hashable, Equatable {
    case dashboard
    case tasks
    case history
    case configuration
    case settings
}

/// Modal sheets that can appear over any destination.
enum AppSheet: Identifiable, Hashable {
    case chat(ConversationID)
    case approvals
    case newConversation
    case assistantSelector
    case taskEditor(TaskID?)       // nil = new task
    case onboarding
    case storeRecovery(reason: String)

    var id: String {
        switch self {
        case .chat(let id): return "chat-\(id.rawValue)"
        case .approvals: return "approvals"
        case .newConversation: return "newConversation"
        case .assistantSelector: return "assistantSelector"
        case .taskEditor(let id): return "taskEditor-\(id?.rawValue.uuidString ?? "new")"
        case .onboarding: return "onboarding"
        case .storeRecovery: return "storeRecovery"
        }
    }
}

@MainActor
@Observable
final class AppRouter {
    var selectedDestination: AppDestination = .dashboard
    var presentedSheet: AppSheet?
    var navigationPath: NavigationPath = NavigationPath()

    // MARK: - Navigation actions

    func navigate(to destination: AppDestination) {
        selectedDestination = destination
    }

    func openChat(conversationID: ConversationID) {
        presentedSheet = .chat(conversationID)
    }

    func openNewConversation() {
        presentedSheet = .newConversation
    }

    func openApprovals() {
        presentedSheet = .approvals
    }

    func openTaskEditor(taskID: TaskID? = nil) {
        presentedSheet = .taskEditor(taskID)
    }

    func openAssistantSelector() {
        presentedSheet = .assistantSelector
    }

    func dismissSheet() {
        presentedSheet = nil
    }

    // MARK: - Deep link handling (rejects unknown/unsafe links per V3 A17)

    /// Handles universal links and deep links.
    /// Only processes known safe URL schemes; unknown links are rejected.
    func handle(url: URL) {
        // Only process our custom scheme or known safe patterns
        guard url.scheme == "personalassistant" else {
            // Unknown scheme — do not process (A17: reject untrusted deep-link injection)
            return
        }
        switch url.host {
        case "conversation":
            if let idStr = url.pathComponents.dropFirst().first,
               let uuid = UUID(uuidString: idStr) {
                openChat(conversationID: ConversationID(rawValue: uuid))
            }
        case "approvals":
            openApprovals()
        default:
            // Unknown deep link — silently ignore (A17)
            break
        }
    }

    // MARK: - Restore safe route

    /// On scene restore, only restores safe destinations (not sheets with sensitive data).
    func restoreSafeRoute(_ destination: AppDestination) {
        selectedDestination = destination
        presentedSheet = nil  // never auto-restore sheets
    }
}
