// DesignSystem/ProfileNavigationDrawerView.swift
// Unified right-side navigation and profile drawer matching approved V5 specification.
// Triggered exclusively by the top-right profile avatar.
// Contains Profile, Home, Conversations, Tasks, Reminders, Memory, Assistants, Providers, Settings, Appearance.

import SwiftUI

// MARK: - Top Right Avatar Navigation Trigger Button

struct TopRightAvatarNavButton: View {
    @Environment(AppRouter.self) private var router
    @Environment(AppSession.self) private var session

    var body: some View {
        Button {
            router.toggleDrawer()
        } label: {
            HStack(spacing: 3) {
                if let assistant = session.activeAssistant {
                    Circle()
                        .fill(assistant.avatarRole.themeColor)
                        .frame(width: 30, height: 30)
                        .overlay {
                            Text(String(assistant.displayName.prefix(1)))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.white)
                        }
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(AppTheme.Color.accent)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(AppTheme.Color.textSecondary)
                    .rotationEffect(.degrees(router.isDrawerOpen ? 90 : 0))
            }
            .contentShape(Rectangle())
            .frame(minWidth: AppTheme.minimumTapTarget, minHeight: AppTheme.minimumTapTarget)
        }
        .accessibilityLabel(router.isDrawerOpen ? "Close profile and navigation" : "Open profile and navigation")
        .accessibilityHint("Toggles the main navigation and profile drawer")
    }
}

// MARK: - Unified Right-Side Profile & Navigation Drawer

struct ProfileNavigationDrawerView: View {
    @Environment(AppRouter.self) private var router
    @Environment(AppSession.self) private var session
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            let drawerWidth = min(320, geometry.size.width * 0.85)

            ZStack(alignment: .trailing) {
                // Dimmed backdrop scrim
                if router.isDrawerOpen {
                    AppTheme.Color.canvas
                        .opacity(0.65)
                        .ignoresSafeArea()
                        .onTapGesture {
                            closeDrawer()
                        }
                        .transition(.opacity)
                }

                // Drawer surface
                if router.isDrawerOpen {
                    VStack(spacing: 0) {
                        // Header with profile card and close button
                        drawerHeader

                        Divider()
                            .overlay(AppTheme.Color.border)

                        // Navigation list
                        ScrollView {
                            VStack(spacing: AppTheme.Spacing.xs) {
                                ForEach(navItems, id: \.destination) { item in
                                    navRow(for: item)
                                }
                            }
                            .padding(.vertical, AppTheme.Spacing.sm)
                            .padding(.horizontal, AppTheme.Spacing.sm)
                        }

                        Divider()
                            .overlay(AppTheme.Color.border)

                        // Footer with Appearance mode toggle
                        drawerFooter
                    }
                    .frame(width: drawerWidth)
                    .frame(maxHeight: .infinity)
                    .background(AppTheme.Color.nav)
                    .overlay(
                        Rectangle()
                            .frame(width: 1)
                            .foregroundStyle(AppTheme.Color.border),
                        alignment: .leading
                    )
                    .offset(x: max(0, dragOffset))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if value.translation.width > 0 {
                                    dragOffset = value.translation.width
                                }
                            }
                            .onEnded { value in
                                if value.translation.width > 80 || value.predictedEndTranslation.width > 120 {
                                    closeDrawer()
                                } else {
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        dragOffset = 0
                                    }
                                }
                            }
                    )
                    .transition(reduceMotion ? .opacity : .move(edge: .trailing))
                }
            }
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: router.isDrawerOpen)
        }
    }

    // MARK: - Drawer Header

    private var drawerHeader: some View {
        HStack(alignment: .center, spacing: AppTheme.Spacing.md) {
            // Profile icon
            if let assistant = session.activeAssistant {
                Circle()
                    .fill(assistant.avatarRole.themeColor)
                    .frame(width: 44, height: 44)
                    .overlay {
                        Text(String(assistant.displayName.prefix(1)))
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                    }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(AppTheme.Color.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(session.currentProfile?.displayName ?? "Guest User")
                    .font(.headline)
                    .foregroundStyle(AppTheme.Color.textPrimary)
                    .lineLimit(1)

                if let assistant = session.activeAssistant {
                    Text("Assistant: \(assistant.displayName)")
                        .font(.caption)
                        .foregroundStyle(AppTheme.Color.textSecondary)
                }
            }

            Spacer()

            // Close button
            Button {
                closeDrawer()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(AppTheme.Color.textMuted)
                    .frame(minWidth: AppTheme.minimumTapTarget, minHeight: AppTheme.minimumTapTarget)
            }
            .accessibilityLabel("Close menu")
            .keyboardShortcut(.escape, modifiers: [])
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.md)
    }

    // MARK: - Navigation Items

    private struct NavItem {
        let destination: AppDestination
        let icon: String
        let title: String
    }

    private var navItems: [NavItem] {
        [
            NavItem(destination: .dashboard, icon: "sparkles", title: "Home"),
            NavItem(destination: .history, icon: "bubble.left.and.bubble.right", title: "Conversations"),
            NavItem(destination: .tasks, icon: "checklist", title: "Tasks & Projects"),
            NavItem(destination: .reminders, icon: "bell", title: "Reminders"),
            NavItem(destination: .memory, icon: "brain", title: "Memory"),
            NavItem(destination: .assistants, icon: "person.2", title: "Assistants"),
            NavItem(destination: .configuration, icon: "cpu", title: "AI Providers"),
            NavItem(destination: .settings, icon: "gearshape", title: "Settings"),
        ]
    }

    @ViewBuilder
    private func navRow(for item: NavItem) -> some View {
        let isSelected = router.selectedDestination == item.destination

        Button {
            router.navigate(to: item.destination)
        } label: {
            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: item.icon)
                    .font(.system(size: 17))
                    .foregroundStyle(isSelected ? AppTheme.Color.accent : AppTheme.Color.textSecondary)
                    .frame(width: 24)

                Text(item.title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? AppTheme.Color.accent : AppTheme.Color.textPrimary)

                Spacer()
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, 10)
            .frame(minHeight: AppTheme.minimumTapTarget)
            .background(
                isSelected ? AppTheme.Color.accent.opacity(0.12) : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.title)
    }

    // MARK: - Drawer Footer: Appearance Controls

    private var drawerFooter: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Appearance")
                .font(.caption.bold())
                .foregroundStyle(AppTheme.Color.textSecondary)
                .padding(.horizontal, AppTheme.Spacing.sm)

            HStack(spacing: AppTheme.Spacing.xs) {
                appearanceButton(title: "Light", mode: .light, icon: "sun.max.fill")
                appearanceButton(title: "Dark", mode: .dark, icon: "moon.fill")
                appearanceButton(title: "System", mode: .system, icon: "circle.lefthalf.filled")
            }
        }
        .padding(AppTheme.Spacing.md)
    }

    private func appearanceButton(title: String, mode: AppearanceMode, icon: String) -> some View {
        let currentMode = session.preferences?.appearanceMode ?? .system
        let isSelected = currentMode == mode

        return Button {
            Task {
                try? await session.updateAppearanceMode(mode)
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption.bold())
            }
            .frame(maxWidth: .infinity, minHeight: 34)
            .foregroundStyle(isSelected ? AppTheme.Color.textPrimary : AppTheme.Color.textSecondary)
            .background(
                isSelected ? AppTheme.Color.surface : Color.clear
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                    .stroke(isSelected ? AppTheme.Color.accent : AppTheme.Color.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Switch to \(title) mode")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }

    private func closeDrawer() {
        withAnimation(.easeOut(duration: 0.2)) {
            dragOffset = 0
            router.closeDrawer()
        }
    }
}
