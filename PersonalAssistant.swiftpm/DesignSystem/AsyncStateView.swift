// DesignSystem/AsyncStateView.swift
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
