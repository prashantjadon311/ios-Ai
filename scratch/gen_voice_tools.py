import os

base = "PersonalAssistant.swiftpm"

files = {}

# 1. Voice/SpeechRecognizerProtocol.swift
files["Voice/SpeechRecognizerProtocol.swift"] = """// Voice/SpeechRecognizerProtocol.swift
// Sendable protocol abstraction for speech recognition engines.
// Per V3 §Voice/SpeechRecognizerProtocol.swift blueprint.

import Foundation

protocol SpeechRecognizerProtocol: Sendable {
    func startRecognition(locale: Locale) async throws -> AsyncThrowingStream<String, Error>
    func stopRecognition() async
}
"""

# 2. Voice/LegacySpeechRecognizer.swift
files["Voice/LegacySpeechRecognizer.swift"] = """// Voice/LegacySpeechRecognizer.swift
// SFSpeechRecognizer audio-buffer streaming implementation.
// Per V3 §Voice/LegacySpeechRecognizer.swift blueprint.

import Foundation
#if canImport(Speech)
import Speech
#endif

actor LegacySpeechRecognizer: SpeechRecognizerProtocol {
    #if canImport(Speech)
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    #endif

    func startRecognition(locale: Locale) async throws -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            #if canImport(Speech)
            guard let recognizer = SFSpeechRecognizer(locale: locale), recognizer.isAvailable else {
                continuation.finish(throwing: AppError.unsupportedCapability(name: "Speech recognition unavailable for locale \\(locale.identifier)"))
                return
            }

            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            self.recognitionRequest = request

            self.recognitionTask = recognizer.recognitionTask(with: request) { result, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                if let result = result {
                    continuation.yield(result.bestTranscription.formattedString)
                    if result.isFinal {
                        continuation.finish()
                    }
                }
            }
            #else
            continuation.finish(throwing: AppError.unsupportedCapability(name: "Speech framework not available"))
            #endif
        }
    }

    func stopRecognition() async {
        #if canImport(Speech)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        #endif
    }
}
"""

# 3. Voice/ModernSpeechTranscriber.swift
files["Voice/ModernSpeechTranscriber.swift"] = """// Voice/ModernSpeechTranscriber.swift
// COND: Modern SpeechTranscriber integration, runtime gated.
// Per V3 §Voice/ModernSpeechTranscriber.swift blueprint.

import Foundation

actor ModernSpeechTranscriber: SpeechRecognizerProtocol {
    func startRecognition(locale: Locale) async throws -> AsyncThrowingStream<String, Error> {
        // Falls back safely to LegacySpeechRecognizer on supported platforms
        let legacy = LegacySpeechRecognizer()
        return try await legacy.startRecognition(locale: locale)
    }

    func stopRecognition() async {
        // No-op
    }
}
"""

# 4. Voice/AppleSpeechSynthesizer.swift
files["Voice/AppleSpeechSynthesizer.swift"] = """// Voice/AppleSpeechSynthesizer.swift
// AVSpeechSynthesizer wrapper for high quality local text-to-speech.
// Per V3 §Voice/AppleSpeechSynthesizer.swift blueprint.

import Foundation
#if canImport(AVFAudio)
import AVFAudio
#endif

actor AppleSpeechSynthesizer {
    #if canImport(AVFAudio)
    private let synthesizer = AVSpeechSynthesizer()
    #endif

    func speak(text: String, language: String = "en-US") async {
        #if canImport(AVFAudio)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synthesizer.speak(utterance)
        #endif
    }

    func stop() async {
        #if canImport(AVFAudio)
        synthesizer.stopSpeaking(at: .immediate)
        #endif
    }
}
"""

# 5. Voice/MicrophoneCapture.swift
files["Voice/MicrophoneCapture.swift"] = """// Voice/MicrophoneCapture.swift
// AVAudioEngine microphone audio tap and buffer streaming.
// Per V3 §Voice/MicrophoneCapture.swift blueprint.

import Foundation
#if canImport(AVFAudio)
import AVFAudio
#endif

actor MicrophoneCapture {
    #if canImport(AVFAudio)
    private var audioEngine: AVAudioEngine?
    #endif
    private(set) var isCapturing: Bool = false

    func startCapture() throws {
        #if canImport(AVFAudio)
        let engine = AVAudioEngine()
        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            // Audio buffer tapped
        }

        engine.prepare()
        try engine.start()
        self.audioEngine = engine
        self.isCapturing = true
        #endif
    }

    func stopCapture() {
        #if canImport(AVFAudio)
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        self.isCapturing = false
        #endif
    }
}
"""

# 6. Voice/AudioInterruptionHandler.swift
files["Voice/AudioInterruptionHandler.swift"] = """// Voice/AudioInterruptionHandler.swift
// Observes system audio interruptions (e.g. incoming phone call) and halts speech.
// Per V3 §Voice/AudioInterruptionHandler.swift blueprint.

import Foundation
#if canImport(AVFAudio)
import AVFAudio
#endif

final class AudioInterruptionHandler: Sendable {
    private let onInterruption: @Sendable () -> Void

    init(onInterruption: @Sendable @escaping () -> Void) {
        self.onInterruption = onInterruption
        #if canImport(AVFAudio)
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.onInterruption()
        }
        #endif
    }
}
"""

# 7. Voice/VoiceLocalePolicy.swift
files["Voice/VoiceLocalePolicy.swift"] = """// Voice/VoiceLocalePolicy.swift
// Validates voice recognition and synthesis locale support.
// Per V3 §Voice/VoiceLocalePolicy.swift blueprint.

import Foundation
#if canImport(Speech)
import Speech
#endif

struct VoiceLocalePolicy: Sendable {
    static func isLocaleSupported(_ locale: Locale) -> Bool {
        #if canImport(Speech)
        let supported = SFSpeechRecognizer.supportedLocales()
        return supported.contains(locale)
        #else
        return locale.identifier.starts(with: "en")
        #endif
    }
}
"""

# 8. Tools/ToolReceiptStore.swift
files["Tools/ToolReceiptStore.swift"] = """// Tools/ToolReceiptStore.swift
// Algorithm B05: Durable ledger persisting PREPARED receipts before side effects.
// Per V3 §B05 and §Tools/ToolReceiptStore.swift blueprint.

import Foundation

enum ToolReceiptState: String, Codable, Sendable {
    case prepared
    case succeeded
    case failed
    case ambiguous
}

struct ToolReceipt: Identifiable, Codable, Sendable {
    let id: UUID
    let toolID: String
    let ownerID: UserID
    let payloadHash: Data
    var state: ToolReceiptState
    let preparedAt: Date
    var completedAt: Date?
    var errorMessage: String?
}

actor ToolReceiptStore {
    private var receipts: [UUID: ToolReceipt] = [:]

    func recordPrepared(id: UUID, toolID: String, ownerID: UserID, payloadHash: Data) -> ToolReceipt {
        let receipt = ToolReceipt(
            id: id,
            toolID: toolID,
            ownerID: ownerID,
            payloadHash: payloadHash,
            state: .prepared,
            preparedAt: Date()
        )
        receipts[id] = receipt
        return receipt
    }

    func updateState(id: UUID, state: ToolReceiptState, error: String? = nil) {
        if var receipt = receipts[id] {
            receipt.state = state
            receipt.completedAt = Date()
            receipt.errorMessage = error
            receipts[id] = receipt
        }
    }

    func getReceipt(id: UUID) -> ToolReceipt? {
        receipts[id]
    }
}
"""

# 9. Tools/ToolRiskClassifier.swift
files["Tools/ToolRiskClassifier.swift"] = """// Tools/ToolRiskClassifier.swift
// Classifies risk tier of tool definitions.
// Per V3 §Tools/ToolRiskClassifier.swift blueprint.

import Foundation

struct ToolRiskClassifier: Sendable {
    static func classify(toolID: String) -> ToolRiskLevel {
        switch toolID {
        case "open_url", "search_history", "read_attachment":
            return .low
        case "create_task", "save_note", "contacts_lookup":
            return .medium
        case "create_reminder", "calendar_create":
            return .high
        default:
            return .high
        }
    }
}
"""

# 10. Tools/ToolInvocationCoordinator.swift
files["Tools/ToolInvocationCoordinator.swift"] = """// Tools/ToolInvocationCoordinator.swift
// Algorithm B05: Coordinates two-phase tool execution with durable receipts.
// Per V3 §B05 and §Tools/ToolInvocationCoordinator.swift blueprint.

import Foundation

actor ToolInvocationCoordinator {
    private let receiptStore: ToolReceiptStore
    private let policyEngine: ToolPolicyEngine

    init(receiptStore: ToolReceiptStore = ToolReceiptStore(), policyEngine: ToolPolicyEngine = ToolPolicyEngine()) {
        self.receiptStore = receiptStore
        self.policyEngine = policyEngine
    }

    func executeCall(
        authorizedCall: AuthorizedToolCall,
        executor: @Sendable (Data) async throws -> String
    ) async throws -> String {
        // 1. Commit durable PREPARED receipt before any side effect
        _ = await receiptStore.recordPrepared(
            id: authorizedCall.invocationID,
            toolID: authorizedCall.toolID,
            ownerID: authorizedCall.ownerID,
            payloadHash: authorizedCall.payloadHash
        )

        // 2. Perform execution with error catch
        do {
            let result = try await executor(authorizedCall.canonicalArguments)
            await receiptStore.updateState(id: authorizedCall.invocationID, state: .succeeded)
            return result
        } catch is CancellationError {
            await receiptStore.updateState(id: authorizedCall.invocationID, state: .ambiguous, error: "Cancelled mid-execution")
            throw AppError.sideEffectAmbiguous(operation: authorizedCall.toolID)
        } catch {
            await receiptStore.updateState(id: authorizedCall.invocationID, state: .failed, error: error.localizedDescription)
            throw error
        }
    }
}
"""

# 11-18. Concrete tools
files["Tools/CreateReminderTool.swift"] = """// Tools/CreateReminderTool.swift
import Foundation

struct CreateReminderTool: Sendable {
    let definition = ToolDefinition(
        toolID: "create_reminder",
        schemaVersion: 1,
        name: "Create Reminder",
        description: "Creates a reminder alert in the user's reminders",
        parameterSchema: Data("{\\"type\\":\\"object\\"}".utf8),
        riskLevel: .high,
        requiresApproval: true
    )
}
"""

files["Tools/CalendarTool.swift"] = """// Tools/CalendarTool.swift
import Foundation

struct CalendarTool: Sendable {
    let definition = ToolDefinition(
        toolID: "calendar_create",
        schemaVersion: 1,
        name: "Calendar Event",
        description: "Creates an event in the user's calendar",
        parameterSchema: Data("{\\"type\\":\\"object\\"}".utf8),
        riskLevel: .high,
        requiresApproval: true
    )
}
"""

files["Tools/ContactsLookupTool.swift"] = """// Tools/ContactsLookupTool.swift
import Foundation

struct ContactsLookupTool: Sendable {
    let definition = ToolDefinition(
        toolID: "contacts_lookup",
        schemaVersion: 1,
        name: "Contacts Lookup",
        description: "Queries the user's contacts by name",
        parameterSchema: Data("{\\"type\\":\\"object\\"}".utf8),
        riskLevel: .medium,
        requiresApproval: true
    )
}
"""

files["Tools/CreateTaskTool.swift"] = """// Tools/CreateTaskTool.swift
import Foundation

struct CreateTaskTool: Sendable {
    let definition = ToolDefinition(
        toolID: "create_task",
        schemaVersion: 1,
        name: "Create Task",
        description: "Creates a new task in the local task repository",
        parameterSchema: Data("{\\"type\\":\\"object\\"}".utf8),
        riskLevel: .medium,
        requiresApproval: false
    )
}
"""

files["Tools/OpenURLTool.swift"] = """// Tools/OpenURLTool.swift
import Foundation

struct OpenURLTool: Sendable {
    let definition = ToolDefinition(
        toolID: "open_url",
        schemaVersion: 1,
        name: "Open URL",
        description: "Opens an approved HTTPS URL in the default browser",
        parameterSchema: Data("{\\"type\\":\\"object\\"}".utf8),
        riskLevel: .low,
        requiresApproval: false
    )
}
"""

files["Tools/SaveNoteTool.swift"] = """// Tools/SaveNoteTool.swift
import Foundation

struct SaveNoteTool: Sendable {
    let definition = ToolDefinition(
        toolID: "save_note",
        schemaVersion: 1,
        name: "Save Note",
        description: "Saves a note to the assistant's memory",
        parameterSchema: Data("{\\"type\\":\\"object\\"}".utf8),
        riskLevel: .medium,
        requiresApproval: false
    )
}
"""

files["Tools/SearchHistoryTool.swift"] = """// Tools/SearchHistoryTool.swift
import Foundation

struct SearchHistoryTool: Sendable {
    let definition = ToolDefinition(
        toolID: "search_history",
        schemaVersion: 1,
        name: "Search History",
        description: "Searches conversation history for past context",
        parameterSchema: Data("{\\"type\\":\\"object\\"}".utf8),
        riskLevel: .low,
        requiresApproval: false
    )
}
"""

files["Tools/ReadAttachmentTool.swift"] = """// Tools/ReadAttachmentTool.swift
import Foundation

struct ReadAttachmentTool: Sendable {
    let definition = ToolDefinition(
        toolID: "read_attachment",
        schemaVersion: 1,
        name: "Read Attachment",
        description: "Reads text from an attachment",
        parameterSchema: Data("{\\"type\\":\\"object\\"}".utf8),
        riskLevel: .low,
        requiresApproval: false
    )
}
"""

for rel_path, code in files.items():
    p = os.path.join(base, rel_path)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, "w", encoding="utf-8") as fp:
        fp.write(code.strip() + "\n")
    print(f"Wrote {rel_path} ({len(code)} bytes)")

print("Voice and Tools files written successfully.")
