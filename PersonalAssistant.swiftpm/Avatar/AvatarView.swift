// Avatar/AvatarView.swift
// Display male/female image/animation and accessible alternative.
// Per V3 §Avatar/AvatarView.swift blueprint and W04 gate requirements.

import SwiftUI

struct AvatarView: View {
    let state: AvatarState
    let identity: AvatarIdentity
    var size: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(state: AvatarState = .idle, identity: AvatarIdentity, size: CGFloat = 80) {
        self.state = state
        self.identity = identity
        self.size = size
    }

    init(role: AvatarRole, state: AvatarState = .idle, size: CGFloat = 80) {
        self.state = state
        self.identity = role.identity
        self.size = size
    }

    var body: some View {
        ZStack {
            // Animated aura glow
            if !reduceMotion && isProcessing {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: AvatarAssetCatalog.glowColors(for: identity).map { $0.opacity(0.4) } + [SwiftUI.Color.clear],
                            center: .center,
                            startRadius: size * 0.3,
                            endRadius: size * 0.7
                        )
                    )
                    .frame(width: size * 1.4, height: size * 1.4)
            }

            // Main avatar body
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            AvatarAssetCatalog.primaryColor(for: identity),
                            AvatarAssetCatalog.secondaryColor(for: identity)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .overlay {
                    // Bundled character image asset
                    Image(identity.rawValue)
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                }
                .scaleEffect(reduceMotion ? 1.0 : state.scaleFactor)
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: 0.6).repeatForever(autoreverses: true),
                    value: state
                )
                .overlay(alignment: .bottomTrailing) {
                    stateBadge
                }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(identity.rawValue) avatar, \(state.accessibilityDescription)")
    }

    private var isProcessing: Bool {
        state == .listening || state == .thinking || state == .speaking
    }

    // MARK: - State badge

    @ViewBuilder
    private var stateBadge: some View {
        switch state {
        case .idle:
            EmptyView()
        case .listening:
            Circle()
                .fill(.green)
                .frame(width: size * 0.28, height: size * 0.28)
                .overlay {
                    Image(systemName: "mic.fill")
                        .font(.system(size: size * 0.14))
                        .foregroundStyle(.white)
                }
        case .thinking:
            Circle()
                .fill(.orange)
                .frame(width: size * 0.28, height: size * 0.28)
                .overlay {
                    Image(systemName: "ellipsis")
                        .font(.system(size: size * 0.14))
                        .foregroundStyle(.white)
                }
        case .speaking:
            Circle()
                .fill(.blue)
                .frame(width: size * 0.28, height: size * 0.28)
                .overlay {
                    Image(systemName: "waveform")
                        .font(.system(size: size * 0.14))
                        .foregroundStyle(.white)
                }
        case .error:
            Circle()
                .fill(.red)
                .frame(width: size * 0.28, height: size * 0.28)
                .overlay {
                    Image(systemName: "exclamationmark")
                        .font(.system(size: size * 0.14, weight: .bold))
                        .foregroundStyle(.white)
                }
        }
    }
}
