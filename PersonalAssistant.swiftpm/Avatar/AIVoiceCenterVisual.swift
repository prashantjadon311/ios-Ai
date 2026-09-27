// Avatar/AIVoiceCenterVisual.swift
// Central AI voice visual for V5 Dashboard:
// - Light mode: soft pearl orb with pastel spatial aura.
// - Dark mode: fine warm amber minimal waveform.
// - Event-driven animations only during active voice states (listening/speaking/thinking).
// - Completely static when Reduce Motion is enabled.

import SwiftUI

struct AIVoiceCenterVisual: View {
    let state: AvatarState
    var size: CGFloat = 110

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var wavePhase: CGFloat = 0

    var body: some View {
        ZStack {
            if colorScheme == .dark {
                darkAmberWaveformVisual
            } else {
                lightPearlOrbVisual
            }
        }
        .frame(width: size * 1.3, height: size * 1.3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("AI Assistant status: \(state.accessibilityDescription)")
        .onAppear {
            if !reduceMotion && isVoiceActive {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    wavePhase = 1.0
                }
            }
        }
        .onChange(of: state) { _, newState in
            if !reduceMotion && (newState == .listening || newState == .speaking || newState == .thinking) {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    wavePhase = 1.0
                }
            } else {
                wavePhase = 0
            }
        }
    }

    private var isVoiceActive: Bool {
        state == .listening || state == .speaking || state == .thinking
    }

    // MARK: - Light Mode: Pearl Soft Pastel Orb

    private var lightPearlOrbVisual: some View {
        ZStack {
            // Soft lavender/pearl aura glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppTheme.Color.accent.opacity(isVoiceActive ? 0.35 : 0.15),
                            AppTheme.Color.accent.opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: size * 0.2,
                        endRadius: size * 0.65
                    )
                )
                .scaleEffect(!reduceMotion && isVoiceActive ? 1.0 + (wavePhase * 0.1) : 1.0)

            // Inner pearl orb
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color(red: 0.95, green: 0.93, blue: 0.98),
                            Color(red: 0.88, green: 0.84, blue: 0.94)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                )

            // State icon or subtle pulse in center
            if isVoiceActive {
                Image(systemName: state == .speaking ? "waveform" : "mic.fill")
                    .font(.system(size: size * 0.28, weight: .medium))
                    .foregroundStyle(AppTheme.Color.accent)
            } else {
                Image(systemName: "sparkles")
                    .font(.system(size: size * 0.26, weight: .light))
                    .foregroundStyle(AppTheme.Color.accent.opacity(0.8))
            }
        }
    }

    // MARK: - Dark Mode: Fine Warm Amber Waveform

    private var darkAmberWaveformVisual: some View {
        ZStack {
            // Deep subtle aura
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppTheme.Color.amberWaveform.opacity(isVoiceActive ? 0.22 : 0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: size * 0.15,
                        endRadius: size * 0.65
                    )
                )
                .scaleEffect(!reduceMotion && isVoiceActive ? 1.0 + (wavePhase * 0.08) : 1.0)

            // Dark circular surface container
            Circle()
                .fill(AppTheme.Color.surface)
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(AppTheme.Color.border, lineWidth: 1)
                )

            // Fine amber waveform bars
            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { index in
                    waveformBar(index: index)
                }
            }
        }
    }

    @ViewBuilder
    private func waveformBar(index: Int) -> some View {
        let baseHeights: [CGFloat] = [0.25, 0.45, 0.75, 1.0, 0.75, 0.45, 0.25]
        let baseHeight = baseHeights[index] * (size * 0.42)
        let activeMultiplier: CGFloat = isVoiceActive ? (1.0 + (sin(CGFloat(index) * 0.9 + wavePhase * .pi) * 0.35)) : 0.6
        let finalHeight = reduceMotion ? baseHeight : max(size * 0.08, baseHeight * activeMultiplier)

        Capsule()
            .fill(
                LinearGradient(
                    colors: [
                        AppTheme.Color.amberWaveform,
                        AppTheme.Color.amberWaveform.opacity(0.7)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 3.5, height: finalHeight)
    }
}
