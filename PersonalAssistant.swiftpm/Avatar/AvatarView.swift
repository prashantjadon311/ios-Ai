// Avatar/AvatarView.swift
// SwiftUI rendering component honoring accessibility Reduce Motion.
// Per V3 §Avatar/AvatarView.swift blueprint.

import SwiftUI

struct AvatarView: View {
    let state: AvatarState
    let identity: AvatarIdentity
    var size: CGFloat = 80

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
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
                .scaleEffect(reduceMotion ? 1.0 : state.scaleFactor)
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: 0.6).repeatForever(autoreverses: true),
                    value: state
                )

            Image(systemName: AvatarAssetCatalog.systemImage(for: identity))
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.5, height: size * 0.5)
                .foregroundStyle(.white)
        }
        .accessibilityLabel(Text("\(identity.rawValue) Avatar: \(state.accessibilityDescription)"))
    }
}
