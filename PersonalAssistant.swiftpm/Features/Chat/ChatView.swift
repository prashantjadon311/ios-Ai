// Features/Chat/ChatView.swift
// Chat view — message list, composer, streaming indicator.

import SwiftUI

struct ChatView: View {
    let conversationID: ConversationID?
    let launchIntent: ChatLaunchIntent?

    @Environment(AppContainer.self) private var container
    @Environment(AppSession.self) private var session
    @Environment(AppRouter.self) private var router
    @State private var viewModel: ChatViewModel?
    @State private var scrollPosition: ScrollPosition = ScrollPosition(idType: MessageID.self)

    init(conversationID: ConversationID? = nil, launchIntent: ChatLaunchIntent? = nil) {
        self.conversationID = conversationID ?? launchIntent?.conversationID
        self.launchIntent = launchIntent
    }

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
            if let intent = router.pendingLaunchIntent, intent.conversationID == conversationID {
                router.pendingLaunchIntent = nil
                await vm.submitLaunchOnce(intent)
            } else if let intent = launchIntent {
                await vm.submitLaunchOnce(intent)
            }
        }
    }

    private var conversationTitle: String {
        viewModel?.conversation?.title ?? "Chat"
    }

    @ViewBuilder
    private func chatComposer(_ vm: ChatViewModel) -> some View {
        HStack(alignment: .bottom, spacing: AppTheme.Spacing.sm) {
            Button {
                toggleVoice(vm: vm)
            } label: {
                Image(systemName: container.voiceCoordinator.state == .capturing ? "mic.fill" : "mic")
                    .imageScale(.large)
                    .foregroundStyle(container.voiceCoordinator.state == .capturing ? .red : .secondary)
            }
            .frame(minWidth: AppTheme.minimumTapTarget, minHeight: AppTheme.minimumTapTarget)
            .accessibilityLabel(container.voiceCoordinator.state == .capturing ? "Stop listening" : "Start voice input")

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
                        .foregroundStyle(vm.composerText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : AppTheme.Color.accent)
                }
                .disabled(vm.composerText.trimmingCharacters(in: .whitespaces).isEmpty)
                .frame(minWidth: AppTheme.minimumTapTarget, minHeight: AppTheme.minimumTapTarget)
                .accessibilityLabel("Send message")
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Color.secondaryBackground)
        .onChange(of: container.voiceCoordinator.lastTranscript) { _, newTranscript in
            if let newTranscript, !newTranscript.isEmpty {
                vm.composerText = newTranscript
            }
        }
    }

    private func toggleVoice(vm: ChatViewModel) {
        if container.voiceCoordinator.state == .capturing {
            container.voiceCoordinator.stop()
        } else {
            let cid = vm.activeConversationID ?? ConversationID()
            Task {
                await container.voiceCoordinator.begin(conversationID: cid)
            }
        }
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
        case .attachment(_):
            Label("Attachment", systemImage: "paperclip")
                .font(.caption)
        case .toolResult(_, let summary):
            Label(summary, systemImage: "checkmark.seal")
                .font(.caption)
        }
    }
}
