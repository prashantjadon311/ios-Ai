// Avatar/AvatarView.swift
// Display male/female image/animation and accessible alternative.
// Per V3 §Avatar/AvatarView.swift blueprint and W04 gate requirements.

import SwiftUI

struct AvatarView: View {
    let role: AvatarRole
    let state: AvatarActivityState
    var size: CGFloat = 80

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            // Animated aura glow
            if !reduceMotion && state.isProcessing {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: AvatarAssetCatalog.glowColors(for: role).map { $0.opacity(0.4) } + [SwiftUI.Color.clear],
                            center: .center,
                            startRadius: size * 0.3,
                            endRadius: size * 0.7
                        )
                    )
                    .frame(width: size * 1.4, height: size * 1.4)
            }

            // Main avatar body
            Circle()
                .fill(role.themeColor)
                .frame(width: size, height: size)
                .overlay {
                    // Try bundled image asset, fallback to monogram and SF symbol
                    if let image = UIImage(named: AvatarAssetCatalog.assetName(for: role)) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                    } else {
                        VStack(spacing: 2) {
                            Text(role == .maya ? "M" : "S")
                                .font(.system(size: size * 0.4, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    stateBadge
                }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(role.rawValue.capitalized) avatar, \(state.accessibilityLabel)")
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
        case .working:
            Circle()
                .fill(.purple)
                .frame(width: size * 0.28, height: size * 0.28)
                .overlay {
                    Image(systemName: "gear")
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
