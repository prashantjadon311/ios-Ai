// Features/Onboarding/OnboardingView.swift
// First-run onboarding — privacy intro, provider setup prompts, permissions.

import SwiftUI

struct OnboardingView: View {
    @Environment(AppSession.self) private var session
    @Environment(AppRouter.self) private var router
    @State private var page: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                welcomePage.tag(0)
                providerPage.tag(1)
                permissionsPage.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .animation(.easeInOut, value: page)

            if page < 2 {
                Button("Continue") { page += 1 }
                    .buttonStyle(.borderedProminent)
                    .padding(AppTheme.Spacing.lg)
                    .accessibilityLabel("Continue to next step")
            } else {
                Button("Get Started") {
                    Task {
                        // Mark onboarding complete
                        await session.completeOnboarding()
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(AppTheme.Spacing.lg)
                .accessibilityLabel("Complete setup")
            }
        }
        .interactiveDismissDisabled()
    }

    private var welcomePage: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 80))
                .foregroundStyle(.accent)
            Text("Personal Assistant")
                .font(.largeTitle.bold())
            Text("Your private, local-first AI companion.\n\nAll data stays on your device. You control when and if anything is shared.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(AppTheme.Spacing.xl)
    }

    private var providerPage: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "key.fill")
                .font(.system(size: 80))
                .foregroundStyle(.accent)
            Text("Bring Your Own Key")
                .font(.largeTitle.bold())
            Text("To enable AI chat, add your own API key in Configuration.\n\nGroq and OpenRouter offer free tiers. No key is required for local features.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(AppTheme.Spacing.xl)
    }

    private var permissionsPage: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "shield.fill")
                .font(.system(size: 80))
                .foregroundStyle(.accent)
            Text("Permissions")
                .font(.largeTitle.bold())
            Text("The app will request permission for microphone and notifications when you first use those features.\n\nYou can manage all permissions in Settings.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(AppTheme.Spacing.xl)
    }
}

// MARK: - AppSession onboarding extension

extension AppSession {
    func completeOnboarding() async {
        requiresOnboarding = false
    }
}
