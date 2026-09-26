// Avatar/AvatarStateController.swift
// Observable state controller managing avatar animation transitions.
// Per V3 §Avatar/AvatarStateController.swift blueprint.

import SwiftUI
import Observation

@MainActor
@Observable
final class AvatarStateController {
    var state: AvatarState = .idle
    var identity: AvatarIdentity = .maya

    private var resetTask: Task<Void, Never>?

    func transition(to newState: AvatarState, autoResetAfter: TimeInterval? = nil) {
        resetTask?.cancel()
        state = newState

        if let duration = autoResetAfter {
            resetTask = Task {
                try? await Task.sleep(for: .seconds(duration))
                guard !Task.isCancelled else { return }
                self.state = .idle
            }
        }
    }

    func setIdentity(_ newIdentity: AvatarIdentity) {
        identity = newIdentity
    }
}
