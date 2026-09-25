// Features/Chat/ChatViewModel.swift
// Chat view model — manages one conversation, streaming turns, and message state.
// AI transport is wired in W05/W06; this gate provides UI state management.

import Foundation
import Observation

@MainActor
@Observable
final class ChatViewModel {
    private(set) var messages: [MessageRecord] = []
    private(set) var isStreaming: Bool = false
    private(set) var streamingText: String = ""
    private(set) var error: AppError?
    var composerText: String = ""
    var conversation: Conversation?

    private let conversationID: ConversationID?
    private let session: AppSession
    private let conversationRepository: ConversationRepository
    private let keychainVault: KeychainVault
    private let capabilityCenter: CapabilityCenter

    /// Active streaming task (cancellable).
    private var streamingTask: Task<Void, Never>?

    init(
        conversationID: ConversationID?,
        session: AppSession,
        conversationRepository: ConversationRepository,
        keychainVault: KeychainVault,
        capabilityCenter: CapabilityCenter
    ) {
        self.conversationID = conversationID
        self.session = session
        self.conversationRepository = conversationRepository
        self.keychainVault = keychainVault
        self.capabilityCenter = capabilityCenter
    }

    // MARK: - Load

    func load() async {
        guard let cid = conversationID,
              let owner = session.currentProfile else { return }
        do {
            messages = try await conversationRepository.pageMessages(
                owner: owner.id, conversationID: cid, cursor: 0
            )
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }
    }

    // MARK: - Send message

    func send() async {
        let text = composerText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, let owner = session.currentProfile else { return }
        composerText = ""
        error = nil

        // Ensure conversation exists
        let cid: ConversationID
        if let existing = conversationID {
            cid = existing
        } else {
            guard let assistant = session.activeAssistant else { return }
            do {
                let conv = try await conversationRepository.createConversation(
                    owner: owner.id, assistantID: assistant.id
                )
                conversation = conv
                cid = conv.id
            } catch {
                self.error = .unknown(underlying: error.localizedDescription)
                return
            }
        }

        // Persist user message before sending to provider (V3 §ConversationRepository)
        do {
            let session = try session.captureSession()
            let userMsg = try await conversationRepository.appendPendingUserMessage(
                owner: owner.id,
                conversationID: cid,
                parts: [.text(text)],
                session: session
            )
            messages.append(userMsg)
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
            return
        }

        // W05/W06: AI streaming will be wired here.
        // For now, show a placeholder assistant response for UI verification.
        isStreaming = true
        streamingText = ""
        do {
            let traceID = TraceID()
            // Placeholder: real streaming in W06
            try? await Task.sleep(for: .milliseconds(500))
            let placeholderText = "[AI response — configure a provider in Configuration to enable live chat]"
            let sessionToken = try session.captureSession()
            _ = try await conversationRepository.appendAssistantCheckpoint(
                traceID: traceID,
                conversationID: cid,
                ownerID: owner.id,
                deltaText: placeholderText,
                session: sessionToken
            )
            try await conversationRepository.finishAssistantMessage(
                traceID: traceID,
                ownerID: owner.id,
                status: .complete,
                session: sessionToken
            )
            messages = try await conversationRepository.pageMessages(
                owner: owner.id, conversationID: cid, cursor: 0
            )
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }
        isStreaming = false
        streamingText = ""
    }

    // MARK: - Cancel streaming

    func cancel() {
        streamingTask?.cancel()
        streamingTask = nil
        isStreaming = false
        streamingText = ""
    }
}
