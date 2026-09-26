import os

base = "PersonalAssistant.swiftpm"

files = {}

# 1. Avatar/AvatarState.swift
files["Avatar/AvatarState.swift"] = """// Avatar/AvatarState.swift
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
"""

# 2. Avatar/AvatarAssetCatalog.swift
files["Avatar/AvatarAssetCatalog.swift"] = """// Avatar/AvatarAssetCatalog.swift
// Color palettes and asset lookups for Maya and Saar identities.
// Per V3 §Avatar/AvatarAssetCatalog.swift blueprint.

import SwiftUI

enum AvatarIdentity: String, Sendable, CaseIterable {
    case maya = "Maya"
    case saar = "Saar"
}

struct AvatarAssetCatalog {
    static func primaryColor(for identity: AvatarIdentity) -> Color {
        switch identity {
        case .maya:
            return Color.purple
        case .saar:
            return Color.teal
        }
    }

    static func secondaryColor(for identity: AvatarIdentity) -> Color {
        switch identity {
        case .maya:
            return Color.pink.opacity(0.8)
        case .saar:
            return Color.cyan.opacity(0.8)
        }
    }

    static func systemImage(for identity: AvatarIdentity) -> String {
        switch identity {
        case .maya:
            return "person.crop.circle.fill"
        case .saar:
            return "brain.head.profile"
        }
    }
}
"""

# 3. Avatar/AvatarStateController.swift
files["Avatar/AvatarStateController.swift"] = """// Avatar/AvatarStateController.swift
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
"""

# 4. Avatar/AvatarView.swift
files["Avatar/AvatarView.swift"] = """// Avatar/AvatarView.swift
// SwiftUI rendering component honoring accessibility Reduce Motion.
// Per V3 §Avatar/AvatarView.swift blueprint.

import SwiftUI

struct AvatarView: View {
    let state: AvatarState
    let identity: AvatarIdentity
    var size: CGFloat = 80

    @Environment(\\.accessibilityReduceMotion) private var reduceMotion

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
        .accessibilityLabel(Text("\\(identity.rawValue) Avatar: \\(state.accessibilityDescription)"))
    }
}
"""

# 5. Avatar/AvatarPickerView.swift
files["Avatar/AvatarPickerView.swift"] = """// Avatar/AvatarPickerView.swift
// Identity switcher sheet for Maya and Saar.
// Per V3 §Avatar/AvatarPickerView.swift blueprint.

import SwiftUI

struct AvatarPickerView: View {
    @Binding var selectedIdentity: AvatarIdentity
    @Environment(\\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(AvatarIdentity.allCases, id: \\.self) { identity in
                    Button {
                        selectedIdentity = identity
                        dismiss()
                    } label: {
                        HStack(spacing: AppTheme.Spacing.md) {
                            AvatarView(state: .idle, identity: identity, size: 50)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(identity.rawValue)
                                    .font(.headline)
                                    .foregroundStyle(Color.primary)
                                Text(identity == .maya ? "Creative and intuitive assistant" : "Analytical and structured assistant")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.secondary)
                            }

                            Spacer()

                            if selectedIdentity == identity {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accentColor)
                                    .font(.headline)
                            }
                        }
                        .padding(.vertical, AppTheme.Spacing.xs)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Choose Identity")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
"""

# 6. DesignSystem/AccessibleButton.swift
files["DesignSystem/AccessibleButton.swift"] = """// DesignSystem/AccessibleButton.swift
// Button with guaranteed 44pt minimum touch target and accessible states.
// Per V3 §DesignSystem/AccessibleButton.swift blueprint.

import SwiftUI

struct AccessibleButton: View {
    let title: String
    var systemImage: String? = nil
    var role: ButtonRole? = nil
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(role: role) {
            guard !isLoading && !isDisabled else { return }
            action()
        } label: {
            HStack(spacing: AppTheme.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else if let icon = systemImage {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.medium)
            }
            .frame(minWidth: 44, minHeight: 44)
            .padding(.horizontal, AppTheme.Spacing.md)
            .contentShape(Rectangle())
        }
        .disabled(isDisabled || isLoading)
        .accessibilityLabel(Text(title))
    }
}
"""

# 7. DesignSystem/AssistantStatusChip.swift
files["DesignSystem/AssistantStatusChip.swift"] = """// DesignSystem/AssistantStatusChip.swift
// Compact status pill displaying current assistant identity and model.
// Per V3 §DesignSystem/AssistantStatusChip.swift blueprint.

import SwiftUI

struct AssistantStatusChip: View {
    let assistantName: String
    let modelName: String?
    var isStreaming: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isStreaming ? Color.green : Color.secondary)
                .frame(width: 8, height: 8)

            Text(assistantName)
                .font(.caption.weight(.semibold))

            if let model = modelName {
                Text("•")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(model)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color(.secondarySystemBackground))
        .clipShape(Capsule())
    }
}
"""

# 8. DesignSystem/AsyncStateView.swift
files["DesignSystem/AsyncStateView.swift"] = """// DesignSystem/AsyncStateView.swift
// State view for loading, empty, and failure presentations.
// Per V3 §DesignSystem/AsyncStateView.swift blueprint.

import SwiftUI

enum ViewLoadState<T> {
    case loading
    case empty(title: String, message: String, systemImage: String)
    case failure(AppError, retryAction: (() -> Void)?)
    case ready(T)
}

struct AsyncStateView<T, Content: View>: View {
    let state: ViewLoadState<T>
    @ViewBuilder let content: (T) -> Content

    var body: some View {
        switch state {
        case .loading:
            ProgressView("Loading…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .empty(let title, let message, let systemImage):
            ContentUnavailableView(title, systemImage: systemImage, description: Text(message))

        case .failure(let error, let retryAction):
            VStack(spacing: AppTheme.Spacing.md) {
                ContentUnavailableView(
                    "Something Went Wrong",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error.localizedDescription)
                )
                if let retry = retryAction {
                    Button("Try Again", action: retry)
                        .buttonStyle(.borderedProminent)
                        .frame(minHeight: 44)
                }
            }
            .padding()

        case .ready(let data):
            content(data)
        }
    }
}
"""

# 9. DesignSystem/ConfirmationSheet.swift
files["DesignSystem/ConfirmationSheet.swift"] = """// DesignSystem/ConfirmationSheet.swift
// Reusable confirmation sheet for destructive actions.
// Per V3 §DesignSystem/ConfirmationSheet.swift blueprint.

import SwiftUI

struct ConfirmationSheet: View {
    let title: String
    let message: String
    let confirmTitle: String
    var isDestructive: Bool = true
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: isDestructive ? "exclamationmark.triangle.fill" : "questionmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(isDestructive ? Color.red : Color.accentColor)

            Text(title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: AppTheme.Spacing.sm) {
                Button(role: isDestructive ? .destructive : nil) {
                    onConfirm()
                } label: {
                    Text(confirmTitle)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                .buttonStyle(.borderedProminent)

                Button("Cancel") {
                    onCancel()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
        }
        .padding(AppTheme.Spacing.xl)
    }
}
"""

# 10. DesignSystem/DateAndRelativeTime.swift
files["DesignSystem/DateAndRelativeTime.swift"] = """// DesignSystem/DateAndRelativeTime.swift
// Localized date, time, and relative timestamp display helpers.
// Per V3 §DesignSystem/DateAndRelativeTime.swift blueprint.

import SwiftUI

struct RelativeTimeText: View {
    let date: Date

    var body: some View {
        Text(date, style: .relative)
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}

enum DateFormattingHelpers {
    static func mediumDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .shortened)
    }

    static func shortTime(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }

    static func relativeOrDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today at " + shortTime(date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday at " + shortTime(date)
        } else {
            return mediumDate(date)
        }
    }
}
"""

# 11. DesignSystem/MarkdownMessageView.swift
files["DesignSystem/MarkdownMessageView.swift"] = """// DesignSystem/MarkdownMessageView.swift
// Formatted markdown message bubble rendering.
// Per V3 §DesignSystem/MarkdownMessageView.swift blueprint.

import SwiftUI

struct MarkdownMessageView: View {
    let content: String
    var isUser: Bool = false

    var body: some View {
        Text(LocalizedStringKey(content))
            .font(.body)
            .foregroundStyle(isUser ? Color.white : Color.primary)
            .textSelection(.enabled)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(
                isUser ? Color.accentColor : Color(.secondarySystemBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            .frame(maxWidth: 600, alignment: isUser ? .trailing : .leading)
    }
}
"""

# 12. DesignSystem/ToastAndBanner.swift
files["DesignSystem/ToastAndBanner.swift"] = """// DesignSystem/ToastAndBanner.swift
// Non-intrusive floating toasts and status banners.
// Per V3 §DesignSystem/ToastAndBanner.swift blueprint.

import SwiftUI

struct ToastBanner: View {
    let message: String
    var systemImage: String? = "info.circle"
    var isError: Bool = false

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            if let icon = systemImage {
                Image(systemName: icon)
                    .foregroundStyle(isError ? Color.red : Color.accentColor)
            }
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.primary)
            Spacer()
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
        .shadow(radius: 4)
        .padding(.horizontal, AppTheme.Spacing.md)
    }
}
"""

for rel_path, code in files.items():
    p = os.path.join(base, rel_path)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, "w", encoding="utf-8") as fp:
        fp.write(code.strip() + "\n")
    print(f"Wrote {rel_path} ({len(code)} bytes)")

print("Avatar & DesignSystem files written successfully.")
