// Features/Chat/ChatView.swift
// Chat view — message list, composer, streaming indicator.

import SwiftUI

struct ChatView: View {
    let conversationID: ConversationID?

    @Environment(AppContainer.self) private var container
    @Environment(AppSession.self) private var session
    @Environment(AppRouter.self) private var router
    @State private var viewModel: ChatViewModel?
    @State private var scrollPosition: ScrollPosition = ScrollPosition(idType: MessageID.self)

    var body: some View {
        VStack(spacing: 0) {
            // Message list
            ScrollView {
                LazyVStack(spacing: AppTheme.Spacing.sm) {
                    if let vm = viewModel {
                        ForEach(vm.messages) { msg in
                            MessageBubble(message: msg)
                        }
                        if vm.isStreaming {
                            streamingIndicator(text: vm.streamingText)
                        }
                    }
                }
                .padding(AppTheme.Spacing.md)
            }

            Divider()

            // Composer
            if let vm = viewModel {
                chatComposer(vm)
            }
        }
        .navigationTitle(conversationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { router.dismissSheet() }
            }
        }
        .task {
            let vm = container.makeChatViewModel(
                conversationID: conversationID
            )
            viewModel = vm
            await vm.load()
        }
    }

    private var conversationTitle: String {
        viewModel?.conversation?.title ?? "Chat"
    }

    @ViewBuilder
    private func chatComposer(_ vm: ChatViewModel) -> some View {
        HStack(alignment: .bottom, spacing: AppTheme.Spacing.sm) {
            TextField("Message…", text: Binding(
                get: { vm.composerText },
                set: { vm.composerText = $0 }
            ), axis: .vertical)
            .textFieldStyle(.roundedBorder)
            .lineLimit(1...5)
            .submitLabel(.send)
            .accessibilityLabel("Message input")

            if vm.isStreaming {
                Button {
                    vm.cancel()
                } label: {
                    Image(systemName: "stop.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(.red)
                }
                .frame(minWidth: AppTheme.minimumTapTarget, minHeight: AppTheme.minimumTapTarget)
                .accessibilityLabel("Stop generating")
            } else {
                Button {
                    Task { await vm.send() }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(vm.composerText.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .accent)
                }
                .disabled(vm.composerText.trimmingCharacters(in: .whitespaces).isEmpty)
                .frame(minWidth: AppTheme.minimumTapTarget, minHeight: AppTheme.minimumTapTarget)
                .accessibilityLabel("Send message")
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Color.secondaryBackground)
    }

    @ViewBuilder
    private func streamingIndicator(text: String) -> some View {
        HStack(alignment: .bottom, spacing: AppTheme.Spacing.sm) {
            if text.isEmpty {
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(.secondary)
                            .frame(width: 6, height: 6)
                            .opacity(0.5)
                    }
                }
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Color.assistantBubble)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.bubble))
            } else {
                Text(text)
                    .padding(AppTheme.Spacing.md)
                    .background(AppTheme.Color.assistantBubble)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.bubble))
            }
            Spacer()
        }
        .accessibilityLabel("Assistant is thinking")
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: MessageRecord

    var body: some View {
        HStack {
            if message.role == .user { Spacer() }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                ForEach(Array(message.parts.enumerated()), id: \.offset) { _, part in
                    partView(part)
                }

                // Status indicator for non-complete messages
                if message.status == .interrupted || message.status == .failed {
                    Label(
                        message.status == .interrupted ? "Interrupted" : "Failed",
                        systemImage: message.status == .interrupted ? "exclamationmark.circle" : "xmark.circle"
                    )
                    .font(.caption2)
                    .foregroundStyle(.orange)
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(message.role == .user ? AppTheme.Color.userBubble : AppTheme.Color.assistantBubble)
            .foregroundStyle(message.role == .user ? Color.white : AppTheme.Color.primaryText)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.bubble))
            .frame(maxWidth: 280, alignment: message.role == .user ? .trailing : .leading)

            if message.role != .user { Spacer() }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func partView(_ part: ContentPart) -> some View {
        switch part {
        case .text(let t):
            Text(t)
                .font(.body)
                .textSelection(.enabled)
        case .attachment(let id):
            Label("Attachment", systemImage: "paperclip")
                .font(.caption)
        case .toolResult(_, let summary):
            Label(summary, systemImage: "checkmark.seal")
                .font(.caption)
        }
    }
}
