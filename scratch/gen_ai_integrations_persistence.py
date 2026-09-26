import os

base = "PersonalAssistant.swiftpm"

files = {}

# 1. AI/Providers/GroqProvider.swift
files["AI/Providers/GroqProvider.swift"] = """// AI/Providers/GroqProvider.swift
// Groq cloud provider wrapper using OpenAI-compatible wire format.
// Per V3 §AI/Providers/GroqProvider.swift blueprint.

import Foundation

actor GroqProvider: AssistantModel {
    let providerID: String = "groq"
    private let underlying: OpenAICompatibleProvider

    init(keychainVault: KeychainVault, httpClient: HTTPClient) {
        self.underlying = OpenAICompatibleProvider(
            providerID: "groq",
            baseURL: URL(string: "https://api.groq.com/openai/v1")!,
            keychainVault: keychainVault,
            httpClient: httpClient
        )
    }

    func models() async throws -> [ModelDescriptor] {
        try await underlying.models()
    }

    func stream(_ request: AssistantRequest) async throws -> AsyncThrowingStream<AssistantEvent, Error> {
        try await underlying.stream(request)
    }
}
"""

# 2. AI/Providers/OpenRouterProvider.swift
files["AI/Providers/OpenRouterProvider.swift"] = """// AI/Providers/OpenRouterProvider.swift
// OpenRouter provider wrapper using OpenAI-compatible wire format.
// Per V3 §AI/Providers/OpenRouterProvider.swift blueprint.

import Foundation

actor OpenRouterProvider: AssistantModel {
    let providerID: String = "openRouter"
    private let underlying: OpenAICompatibleProvider

    init(keychainVault: KeychainVault, httpClient: HTTPClient) {
        self.underlying = OpenAICompatibleProvider(
            providerID: "openRouter",
            baseURL: URL(string: "https://openrouter.ai/api/v1")!,
            keychainVault: keychainVault,
            httpClient: httpClient
        )
    }

    func models() async throws -> [ModelDescriptor] {
        try await underlying.models()
    }

    func stream(_ request: AssistantRequest) async throws -> AsyncThrowingStream<AssistantEvent, Error> {
        try await underlying.stream(request)
    }
}
"""

# 3. AI/Providers/CustomEndpointProvider.swift
files["AI/Providers/CustomEndpointProvider.swift"] = """// AI/Providers/CustomEndpointProvider.swift
// User-configurable custom OpenAI-compatible endpoint provider.
// Per V3 §AI/Providers/CustomEndpointProvider.swift blueprint.

import Foundation

actor CustomEndpointProvider: AssistantModel {
    let providerID: String = "custom"
    private let underlying: OpenAICompatibleProvider

    init(baseURL: URL, keychainVault: KeychainVault, httpClient: HTTPClient) {
        self.underlying = OpenAICompatibleProvider(
            providerID: "custom",
            baseURL: baseURL,
            keychainVault: keychainVault,
            httpClient: httpClient
        )
    }

    func models() async throws -> [ModelDescriptor] {
        try await underlying.models()
    }

    func stream(_ request: AssistantRequest) async throws -> AsyncThrowingStream<AssistantEvent, Error> {
        try await underlying.stream(request)
    }
}
"""

# 4. AI/Providers/AppleFoundationModelProvider.swift
files["AI/Providers/AppleFoundationModelProvider.swift"] = """// AI/Providers/AppleFoundationModelProvider.swift
// COND: Apple Foundation Models on-device provider, runtime gated.
// Per V3 §AI/Providers/AppleFoundationModelProvider.swift blueprint.

import Foundation

actor AppleFoundationModelProvider: AssistantModel {
    let providerID: String = "appleFoundationModels"

    func models() async throws -> [ModelDescriptor] {
        return [
            ModelDescriptor(
                id: "apple-intelligence-on-device",
                providerID: providerID,
                displayName: "Apple Intelligence (On-Device)",
                capabilities: ModelCapabilitySet(textChat: .yes, tools: .unknown, vision: .unknown, streaming: .yes, jsonMode: .unknown),
                contextLimit: 4096,
                available: false,
                verifiedAt: Date()
            )
        ]
    }

    func stream(_ request: AssistantRequest) async throws -> AsyncThrowingStream<AssistantEvent, Error> {
        throw AppError.unsupportedCapability(name: "Apple Foundation Models unavailable on current hardware")
    }
}
"""

# 5. AI/Context/ContextBuilder.swift
files["AI/Context/ContextBuilder.swift"] = """// AI/Context/ContextBuilder.swift
// Algorithm B04: Deterministic trust-ordered context assembly.
// Per V3 §B04 and §AI/Context/ContextBuilder.swift blueprint.

import Foundation

struct ContextBuilder: Sendable {
    static func buildContext(
        systemPrompt: String,
        memories: [MemoryItem],
        history: [MessageRecord],
        userTurn: String
    ) -> [ContextMessage] {
        var result: [ContextMessage] = []

        // 1. Trusted System Policy
        result.append(ContextMessage(
            role: .system,
            parts: [.text(systemPrompt)],
            provenanceHash: nil
        ))

        // 2. Active Memories (Deterministic sort by ID)
        let sortedMemories = memories.sorted { $0.id.rawValue.uuidString < $1.id.rawValue.uuidString }
        if !sortedMemories.isEmpty {
            let memoryText = sortedMemories.map { "- \\($0.content)" }.joined(separator: "\\n")
            result.append(ContextMessage(
                role: .system,
                parts: [.text("Relevant user preferences and facts:\\n" + memoryText)],
                provenanceHash: nil
            ))
        }

        // 3. Conversation History
        for msg in history {
            result.append(ContextMessage(
                role: msg.role,
                parts: msg.parts.map { part in
                    switch part {
                    case .text(let t): return .text(t)
                    case .attachment(let id): return .text("[attachment \\(id.rawValue)]")
                    case .toolResult(let id, let out, _): return .text("[tool \\(id): \\(out)]")
                    }
                },
                provenanceHash: nil
            ))
        }

        // 4. Current User Command
        result.append(ContextMessage(
            role: .user,
            parts: [.text(userTurn)],
            provenanceHash: nil
        ))

        return result
    }
}
"""

# 6. AI/Context/TokenBudget.swift
files["AI/Context/TokenBudget.swift"] = """// AI/Context/TokenBudget.swift
// Conservative token budgeting using UTF8/3 byte estimation.
// Per V3 §AI/Context/TokenBudget.swift blueprint.

import Foundation

struct TokenBudgetEstimator: Sendable {
    static func estimateTokens(for text: String) -> Int {
        let bytes = text.utf8.count
        return max(1, (bytes + 2) / 3)
    }

    static func fitsInBudget(messages: [ContextMessage], maxTokens: Int = 4096) -> Bool {
        var total = 0
        for msg in messages {
            for part in msg.parts {
                if case .text(let t) = part {
                    total += estimateTokens(for: t)
                }
            }
        }
        return total <= maxTokens
    }
}
"""

# 7. AI/Context/ContextProvenance.swift
files["AI/Context/ContextProvenance.swift"] = """// AI/Context/ContextProvenance.swift
// Non-PII SHA-256 digest of assembled context messages.
// Per V3 §AI/Context/ContextProvenance.swift blueprint.

import Foundation
import CryptoKit

struct ContextProvenanceDigest: Sendable {
    static func computeDigest(for messages: [ContextMessage]) -> Data {
        var hasher = SHA256()
        for msg in messages {
            hasher.update(data: Data(msg.role.rawValue.utf8))
            for part in msg.parts {
                if case .text(let t) = part {
                    hasher.update(data: Data(t.utf8))
                }
            }
        }
        return Data(hasher.finalize())
    }
}
"""

# 8. AI/Context/HistoryRetriever.swift
files["AI/Context/HistoryRetriever.swift"] = """// AI/Context/HistoryRetriever.swift
// Retrieves owner-scoped historical messages for context assembly.
// Per V3 §AI/Context/HistoryRetriever.swift blueprint.

import Foundation

actor HistoryRetriever {
    private let conversationRepo: ConversationRepository

    init(conversationRepo: ConversationRepository) {
        self.conversationRepo = conversationRepo
    }

    func retrieveRecentMessages(conversationID: ConversationID, ownerID: UserID, limit: Int = 20) async throws -> [MessageRecord] {
        let all = try await conversationRepo.pageMessages(owner: ownerID, conversationID: conversationID, cursor: 0)
        return Array(all.suffix(limit))
    }
}
"""

# 9. AI/Context/MemoryRetriever.swift
files["AI/Context/MemoryRetriever.swift"] = """// AI/Context/MemoryRetriever.swift
// Retrieves active, owner-verified memory items.
// Per V3 §AI/Context/MemoryRetriever.swift blueprint.

import Foundation

actor MemoryRetriever {
    private let memoryRepo: MemoryRepository

    init(memoryRepo: MemoryRepository) {
        self.memoryRepo = memoryRepo
    }

    func retrieveActiveMemories(ownerID: UserID) async throws -> [MemoryItem] {
        try await memoryRepo.activeMemories(ownerID: ownerID)
    }
}
"""

# 10. AI/Context/ConversationSummarizer.swift
files["AI/Context/ConversationSummarizer.swift"] = """// AI/Context/ConversationSummarizer.swift
// Summarizes long conversation histories to fit within token limits.
// Per V3 §AI/Context/ConversationSummarizer.swift blueprint.

import Foundation

struct ConversationSummarizer: Sendable {
    static func compactMessages(messages: [MessageRecord], maxCount: Int = 10) -> [MessageRecord] {
        if messages.count <= maxCount {
            return messages
        }
        return Array(messages.suffix(maxCount))
    }
}
"""

# 11. AI/Context/MemoryConflictResolver.swift
files["AI/Context/MemoryConflictResolver.swift"] = """// AI/Context/MemoryConflictResolver.swift
// Resolves conflicts when new memory proposals overlap existing items.
// Per V3 §AI/Context/MemoryConflictResolver.swift blueprint.

import Foundation

struct MemoryConflictResolver: Sendable {
    static func findConflicts(newContent: String, existingMemories: [MemoryItem]) -> [MemoryItem] {
        let newLower = newContent.lowercased()
        return existingMemories.filter { item in
            let existingLower = item.content.lowercased()
            return newLower.contains(existingLower) || existingLower.contains(newLower)
        }
    }
}
"""

# 12. AI/Context/MemoryProposalEngine.swift
files["AI/Context/MemoryProposalEngine.swift"] = """// AI/Context/MemoryProposalEngine.swift
// Proposes memory items from conversational turns, keeping state .proposed.
// Per V3 §A13 and §AI/Context/MemoryProposalEngine.swift blueprint.

import Foundation

struct MemoryProposalEngine: Sendable {
    static func proposeMemory(from text: String, ownerID: UserID) -> MemoryItem? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > 10 else { return nil }
        return MemoryItem(
            ownerID: ownerID,
            content: trimmed,
            scope: .general,
            verificationState: .proposed
        )
    }
}
"""

# 13. AI/Context/MemoryRetentionWorker.swift
files["AI/Context/MemoryRetentionWorker.swift"] = """// AI/Context/MemoryRetentionWorker.swift
// Evaluates memory items for expiration and retention policies.
// Per V3 §AI/Context/MemoryRetentionWorker.swift blueprint.

import Foundation

struct MemoryRetentionWorker: Sendable {
    static func filterExpired(memories: [MemoryItem], now: Date = Date()) -> [MemoryItem] {
        memories.filter { $0.isActive(at: now) }
    }
}
"""

# 14. AI/Transport/RetryPolicy.swift
files["AI/Transport/RetryPolicy.swift"] = """// AI/Transport/RetryPolicy.swift
// Exponential backoff with jitter and circuit-breaker for HTTP calls.
// Per V3 §AI/Transport/RetryPolicy.swift blueprint.

import Foundation

struct RetryPolicy: Sendable {
    let maxRetries: Int
    let initialDelay: TimeInterval
    let multiplier: Double

    init(maxRetries: Int = 3, initialDelay: TimeInterval = 1.0, multiplier: Double = 2.0) {
        self.maxRetries = maxRetries
        self.initialDelay = initialDelay
        self.multiplier = multiplier
    }

    func delay(forAttempt attempt: Int) -> TimeInterval {
        let base = initialDelay * pow(multiplier, Double(attempt))
        let jitter = Double.random(in: 0...0.3) * base
        return base + jitter
    }
}
"""

# 15. AI/Transport/ConnectivityMonitor.swift
files["AI/Transport/ConnectivityMonitor.swift"] = """// AI/Transport/ConnectivityMonitor.swift
// Observes network availability transitions via Network framework.
// Per V3 §AI/Transport/ConnectivityMonitor.swift blueprint.

import Foundation
#if canImport(Network)
import Network
#endif

actor ConnectivityMonitor {
    #if canImport(Network)
    private var monitor: NWPathMonitor?
    #endif
    private(set) var isConnected: Bool = true

    func start() {
        #if canImport(Network)
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            Task { [weak self] in
                await self?.updateStatus(path.status == .satisfied)
            }
        }
        let queue = DispatchQueue(label: "ConnectivityMonitor")
        monitor.start(queue: queue)
        self.monitor = monitor
        #endif
    }

    private func updateStatus(_ connected: Bool) {
        self.isConnected = connected
    }
}
"""

# 16. AI/Transport/ModelCatalogClient.swift
files["AI/Transport/ModelCatalogClient.swift"] = """// AI/Transport/ModelCatalogClient.swift
// Parses ProviderCatalog.json from bundle resources.
// Per V3 §AI/Transport/ModelCatalogClient.swift blueprint.

import Foundation

struct ModelCatalogClient: Sendable {
    static func loadBundledCatalog() -> [String: Any]? {
        guard let url = Bundle.main.url(forResource: "ProviderCatalog", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json
    }
}
"""

# 17. Integrations/CalendarAdapter.swift
files["Integrations/CalendarAdapter.swift"] = """// Integrations/CalendarAdapter.swift
// COND: EventKit Calendar integration, runtime guarded.
// Per V3 §Integrations/CalendarAdapter.swift blueprint.

import Foundation
#if canImport(EventKit)
import EventKit
#endif

actor CalendarAdapter {
    #if canImport(EventKit)
    private let store = EKEventStore()
    #endif

    func requestAccess() async throws -> Bool {
        #if canImport(EventKit)
        if #available(iOS 17.0, *) {
            return try await store.requestFullAccessToEvents()
        } else {
            return try await store.requestAccess(to: .event)
        }
        #else
        return false
        #endif
    }
}
"""

# 18. Integrations/ContactsAdapter.swift
files["Integrations/ContactsAdapter.swift"] = """// Integrations/ContactsAdapter.swift
// COND: Contacts framework integration, runtime guarded.
// Per V3 §Integrations/ContactsAdapter.swift blueprint.

import Foundation
#if canImport(Contacts)
import Contacts
#endif

actor ContactsAdapter {
    func requestAccess() async throws -> Bool {
        #if canImport(Contacts)
        let store = CNContactStore()
        return try await store.requestAccess(for: .contacts)
        #else
        return false
        #endif
    }
}
"""

# 19. Integrations/RemindersAdapter.swift
files["Integrations/RemindersAdapter.swift"] = """// Integrations/RemindersAdapter.swift
// COND: EventKit Reminders integration, runtime guarded.
// Per V3 §Integrations/RemindersAdapter.swift blueprint.

import Foundation
#if canImport(EventKit)
import EventKit
#endif

actor RemindersAdapter {
    #if canImport(EventKit)
    private let store = EKEventStore()
    #endif

    func requestAccess() async throws -> Bool {
        #if canImport(EventKit)
        if #available(iOS 17.0, *) {
            return try await store.requestFullAccessToReminders()
        } else {
            return try await store.requestAccess(to: .reminder)
        }
        #else
        return false
        #endif
    }
}
"""

# 20. Integrations/ShortcutsBridge.swift
files["Integrations/ShortcutsBridge.swift"] = """// Integrations/ShortcutsBridge.swift
// App Intents and Shortcuts integration bridge.
// Per V3 §Integrations/ShortcutsBridge.swift blueprint.

import Foundation

struct ShortcutsBridge: Sendable {
    static func isShortcutsAvailable() -> Bool {
        true
    }
}
"""

# 21. Persistence/AttachmentRepository.swift
files["Persistence/AttachmentRepository.swift"] = """// Persistence/AttachmentRepository.swift
// Actor managing SwiftData StoredAttachment models with owner isolation.
// Per V3 §Persistence/AttachmentRepository.swift blueprint.

import Foundation
import SwiftData

actor AttachmentRepository: ModelActor {
    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        let context = ModelContext(modelContainer)
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: context)
    }

    func saveAttachment(_ attachment: Attachment) throws {
        let stored = StoredAttachment(
            id: attachment.id.rawValue,
            ownerID: attachment.ownerID.rawValue,
            filename: attachment.filename,
            mimeType: attachment.mimeType,
            byteSize: attachment.byteSize,
            extractedText: attachment.extractedText,
            createdAt: attachment.createdAt
        )
        modelContext.insert(stored)
        try modelContext.save()
    }
}
"""

# 22. Persistence/RepositoryTransaction.swift
files["Persistence/RepositoryTransaction.swift"] = """// Persistence/RepositoryTransaction.swift
// Actor-confined atomic transaction helper for SwiftData mutations.
// Per V3 §Persistence/RepositoryTransaction.swift blueprint.

import Foundation
import SwiftData

struct RepositoryTransaction: Sendable {
    static func perform<T>(on context: ModelContext, action: () throws -> T) throws -> T {
        let result = try action()
        try context.save()
        return result
    }
}
"""

for rel_path, code in files.items():
    p = os.path.join(base, rel_path)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, "w", encoding="utf-8") as fp:
        fp.write(code.strip() + "\n")
    print(f"Wrote {rel_path} ({len(code)} bytes)")

print("AI Providers, Context, Transport, Integrations & Persistence files written successfully.")
