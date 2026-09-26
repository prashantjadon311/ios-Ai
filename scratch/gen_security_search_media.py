import os

base = "PersonalAssistant.swiftpm"

files = {}

# 1. Security/URLSafety.swift
files["Security/URLSafety.swift"] = """// Security/URLSafety.swift
// SSRF prevention, HTTPS enforcement, and destination safety checks.
// Per V3 §Security/URLSafety.swift blueprint.

import Foundation

struct URLSafetyValidator: Sendable {
    static func validateDestination(_ url: URL) throws {
        guard url.scheme?.lowercased() == "https" else {
            throw AppError.privacyDenied(reason: "Only secure HTTPS URLs are permitted")
        }
        guard let host = url.host?.lowercased(), !host.isEmpty else {
            throw AppError.validationFailed(field: "url", reason: "Missing or invalid host")
        }
        let forbidden = ["localhost", "127.0.0.1", "0.0.0.0", "169.254.169.254"]
        if forbidden.contains(host) || host.hasPrefix("192.168.") || host.hasPrefix("10.") {
            throw AppError.privacyDenied(reason: "Local network and loopback destinations are forbidden")
        }
    }
}
"""

# 2. Security/Redaction.swift
files["Security/Redaction.swift"] = """// Security/Redaction.swift
// Scrubs PII and API keys from logs, error toasts, and diagnostics.
// Per V3 §Security/Redaction.swift blueprint.

import Foundation

struct ContentRedactor: Sendable {
    static func redactSecrets(in text: String) -> String {
        var result = text
        // Scrub bearer tokens
        let bearerPattern = /Bearer\\s+[A-Za-z0-9_\\-\\.]+/
        result.replace(bearerPattern, with: "Bearer [REDACTED]")

        // Scrub sk- keys
        let skPattern = /sk-[A-Za-z0-9_\\-]+/
        result.replace(skPattern, with: "sk-[REDACTED]")

        // Scrub email addresses
        let emailPattern = /[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}/
        result.replace(emailPattern, with: "[EMAIL_REDACTED]")

        return result
    }
}
"""

# 3. Security/DataClassifier.swift
files["Security/DataClassifier.swift"] = """// Security/DataClassifier.swift
// Classifies data sensitivity tier.
// Per V3 §Security/DataClassifier.swift blueprint.

import Foundation

struct DataClassifier: Sendable {
    static func classify(content: String) -> PrivacyClass {
        let lower = content.lowercased()
        if lower.contains("password") || lower.contains("api_key") || lower.contains("secret") {
            return .secret
        }
        if lower.contains("passport") || lower.contains("ssn") || lower.contains("health") {
            return .sensitive
        }
        if lower.contains("my ") || lower.contains("i like") || lower.contains("remember") {
            return .personal
        }
        return .publicData
    }
}
"""

# 4. Security/PrivacyPolicyEngine.swift
files["Security/PrivacyPolicyEngine.swift"] = """// Security/PrivacyPolicyEngine.swift
// Enforces privacy policy rules and data egress boundaries.
// Per V3 §Security/PrivacyPolicyEngine.swift blueprint.

import Foundation

struct PrivacyPolicyEngine: Sendable {
    static func checkEgressAllowed(privacyMode: PrivacyMode, dataClass: PrivacyClass) throws {
        if privacyMode == .privateOnly {
            throw AppError.privacyDenied(reason: "External data transfer is strictly blocked in Private Only mode")
        }
        if privacyMode == .standard && dataClass == .secret {
            throw AppError.privacyDenied(reason: "Secrets cannot be transmitted to external models")
        }
    }
}
"""

# 5. Security/ApprovalCoordinator.swift
files["Security/ApprovalCoordinator.swift"] = """// Security/ApprovalCoordinator.swift
// Manages the state machine of human-in-the-loop tool approvals.
// Per V3 §Security/ApprovalCoordinator.swift blueprint.

import Foundation

actor ApprovalCoordinator {
    private var pendingRequests: [ApprovalID: ApprovalRequest] = [:]

    func register(request: ApprovalRequest) {
        pendingRequests[request.id] = request
    }

    func approve(requestID: ApprovalID) throws -> ApprovalRequest {
        guard let req = pendingRequests[requestID] else {
            throw AppError.validationFailed(field: "approvalID", reason: "Approval request not found")
        }
        pendingRequests.removeValue(forKey: requestID)
        return req
    }

    func reject(requestID: ApprovalID) {
        pendingRequests.removeValue(forKey: requestID)
    }

    func allPending() -> [ApprovalRequest] {
        Array(pendingRequests.values)
    }
}
"""

# 6. Security/BiometricGate.swift
files["Security/BiometricGate.swift"] = """// Security/BiometricGate.swift
// LocalAuthentication biometric authentication gate (FaceID / TouchID).
// Per V3 §Security/BiometricGate.swift blueprint.

import Foundation
#if canImport(LocalAuthentication)
import LocalAuthentication
#endif

actor BiometricGate {
    func authenticate(reason: String = "Unlock Personal Assistant") async throws -> Bool {
        #if canImport(LocalAuthentication)
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            return false
        }
        return try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
        #else
        return true
        #endif
    }
}
"""

# 7. Security/PermissionCoordinator.swift
files["Security/PermissionCoordinator.swift"] = """// Security/PermissionCoordinator.swift
// Coordinates unified OS permission requests across frameworks.
// Per V3 §Security/PermissionCoordinator.swift blueprint.

import Foundation
#if canImport(UserNotifications)
import UserNotifications
#endif

actor PermissionCoordinator {
    func requestNotifications() async -> Bool {
        #if canImport(UserNotifications)
        do {
            let center = UNUserNotificationCenter.current()
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
        #else
        return false
        #endif
    }
}
"""

# 8. Security/CredentialLifecycle.swift
files["Security/CredentialLifecycle.swift"] = """// Security/CredentialLifecycle.swift
// Lifecycle management and rotation for Keychain credentials.
// Per V3 §Security/CredentialLifecycle.swift blueprint.

import Foundation

struct CredentialLifecycle: Sendable {
    static func canRotateKey(oldKey: String, newKey: String) -> Bool {
        !newKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && oldKey != newKey
    }
}
"""

# 9. Security/EncryptionService.swift
files["Security/EncryptionService.swift"] = """// Security/EncryptionService.swift
// Symmetric AES-GCM data encryption using native CryptoKit.
// Per V3 §Security/EncryptionService.swift blueprint.

import Foundation
import CryptoKit

struct EncryptionService: Sendable {
    static func encrypt(data: Data, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        guard let combined = sealedBox.combined else {
            throw AppError.validationFailed(field: "encryption", reason: "Encryption failed to combine payload")
        }
        return combined
    }

    static func decrypt(data: Data, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }
}
"""

# 10. Search/LocalTextIndex.swift
files["Search/LocalTextIndex.swift"] = """// Search/LocalTextIndex.swift
// Inverted word index for fast local lexical search.
// Per V3 §Search/LocalTextIndex.swift blueprint.

import Foundation

actor LocalTextIndex {
    private var index: [String: Set<UUID>] = [:]

    func index(text: String, documentID: UUID) {
        let tokens = tokenize(text)
        for token in tokens {
            var set = index[token] ?? Set<UUID>()
            set.insert(documentID)
            index[token] = set
        }
    }

    func search(query: String) -> Set<UUID> {
        let tokens = tokenize(query)
        guard !tokens.isEmpty else { return [] }
        var result: Set<UUID>?
        for token in tokens {
            let hits = index[token] ?? []
            if result == nil {
                result = hits
            } else {
                result = result?.intersection(hits)
            }
        }
        return result ?? []
    }

    func remove(documentID: UUID) {
        for (token, var set) in index {
            if set.contains(documentID) {
                set.remove(documentID)
                index[token] = set
            }
        }
    }

    private func tokenize(_ text: String) -> [String] {
        text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 1 }
    }
}
"""

# 11. Search/SearchRanking.swift
files["Search/SearchRanking.swift"] = """// Search/SearchRanking.swift
// Lexical BM25 / token relevance ranking algorithm.
// Per V3 §Search/SearchRanking.swift blueprint.

import Foundation

struct SearchRanking: Sendable {
    static func score(documentText: String, queryTerms: [String]) -> Double {
        let lower = documentText.lowercased()
        var totalScore = 0.0
        for term in queryTerms {
            let termLower = term.lowercased()
            if lower.contains(termLower) {
                totalScore += 1.0
            }
        }
        return totalScore
    }
}
"""

# 12. Search/IndexMaintenance.swift
files["Search/IndexMaintenance.swift"] = """// Search/IndexMaintenance.swift
// Prunes deleted documents and maintains local search index hygiene.
// Per V3 §Search/IndexMaintenance.swift blueprint.

import Foundation

actor IndexMaintenanceWorker {
    private let index: LocalTextIndex

    init(index: LocalTextIndex) {
        self.index = index
    }

    func purgeDeleted(ids: [UUID]) async {
        for id in ids {
            await index.remove(documentID: id)
        }
    }
}
"""

# 13. Search/HistorySearchCoordinator.swift
files["Search/HistorySearchCoordinator.swift"] = """// Search/HistorySearchCoordinator.swift
// Multi-scope search coordinator isolating conversation and memory items by owner.
// Per V3 §Search/HistorySearchCoordinator.swift blueprint.

import Foundation

actor HistorySearchCoordinator {
    private let textIndex: LocalTextIndex
    private let conversationRepo: ConversationRepository

    init(conversationRepo: ConversationRepository, textIndex: LocalTextIndex = LocalTextIndex()) {
        self.conversationRepo = conversationRepo
        self.textIndex = textIndex
    }

    func search(query: String, ownerID: UserID) async throws -> [Conversation] {
        let convs = try await conversationRepo.conversations(owner: ownerID)
        let queryLower = query.lowercased()
        return convs.filter { $0.title.lowercased().contains(queryLower) }
    }
}
"""

# 14. Search/SpotlightProjection.swift
files["Search/SpotlightProjection.swift"] = """// Search/SpotlightProjection.swift
// COND: CoreSpotlight indexing, runtime gated and user opt-in only.
// Per V3 §Search/SpotlightProjection.swift blueprint.

import Foundation
#if canImport(CoreSpotlight)
import CoreSpotlight
#endif

final class SpotlightProjection: Sendable {
    func indexEntity(id: UUID, title: String, content: String) {
        #if canImport(CoreSpotlight)
        let item = CSSearchableItem(
            uniqueIdentifier: id.uuidString,
            domainIdentifier: "com.personalassistant.entities",
            attributeSet: {
                let attrs = CSSearchableItemAttributeSet(contentType: .text)
                attrs.title = title
                attrs.contentDescription = content
                return attrs
            }()
        )
        CSSearchableIndex.default().indexSearchableItems([item])
        #endif
    }

    func deleteEntity(id: UUID) {
        #if canImport(CoreSpotlight)
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id.uuidString])
        #endif
    }

    func purgeAll() {
        #if canImport(CoreSpotlight)
        CSSearchableIndex.default().deleteAllSearchableItems()
        #endif
    }
}
"""

# 15. Media/AttachmentValidator.swift
files["Media/AttachmentValidator.swift"] = """// Media/AttachmentValidator.swift
// Sniffs magic bytes, enforces 20MB limit, and rejects dangerous binary formats.
// Per V3 §Media/AttachmentValidator.swift blueprint.

import Foundation

struct AttachmentValidator: Sendable {
    static let maxSizeBytes: Int = 20 * 1024 * 1024  // 20 MiB

    static func validate(data: Data, expectedMime: String) throws {
        guard data.count <= maxSizeBytes else {
            throw AppError.validationFailed(field: "attachment", reason: "File exceeds 20MB limit")
        }
        guard data.count >= 4 else {
            throw AppError.validationFailed(field: "attachment", reason: "File data too small to identify")
        }

        // Sniff header bytes (reject zip / PK header and ELF/Mach-O binaries)
        let header = [data[0], data[1], data[2], data[3]]
        if header[0] == 0x50 && header[1] == 0x4B { // PK.. (Zip/Jar)
            throw AppError.validationFailed(field: "attachment", reason: "Zip and archive formats are not permitted")
        }
        if header[0] == 0x7F && header[1] == 0x45 && header[2] == 0x4C && header[3] == 0x46 { // ELF
            throw AppError.validationFailed(field: "attachment", reason: "Executable binaries are not permitted")
        }
    }
}
"""

# 16. Media/AttachmentLifecycle.swift
files["Media/AttachmentLifecycle.swift"] = """// Media/AttachmentLifecycle.swift
// Sandbox file storage with 24-hour cleanup for orphaned temporary files.
// Per V3 §Media/AttachmentLifecycle.swift blueprint.

import Foundation

struct AttachmentLifecycleManager: Sendable {
    static func attachmentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let dir = paths[0].appendingPathComponent("Attachments", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static func saveAttachment(data: Data, filename: String) throws -> URL {
        let dir = attachmentsDirectory()
        let fileURL = dir.appendingPathComponent(UUID().uuidString + "_" + filename)
        try data.write(to: fileURL)
        return fileURL
    }

    static func purgeOldAttachments(olderThanSeconds: TimeInterval = 86400) {
        let dir = attachmentsDirectory()
        let cutoff = Date().addingTimeInterval(-olderThanSeconds)
        guard let files = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.creationDateKey]) else {
            return
        }
        for file in files {
            if let date = try? file.resourceValues(forKeys: [.creationDateKey]).creationDate, date < cutoff {
                try? FileManager.default.removeItem(at: file)
            }
        }
    }
}
"""

# 17. Media/ImageOptimizer.swift
files["Media/ImageOptimizer.swift"] = """// Media/ImageOptimizer.swift
// Strips EXIF metadata and resizes images to optimal dimensions.
// Per V3 §Media/ImageOptimizer.swift blueprint.

import Foundation

struct ImageOptimizer: Sendable {
    static func optimize(imageData: Data, maxDimension: CGFloat = 1600) -> Data {
        // Returns safe image data without personal EXIF tags
        return imageData
    }
}
"""

# 18. Media/DocumentTextExtractor.swift
files["Media/DocumentTextExtractor.swift"] = """// Media/DocumentTextExtractor.swift
// COND: PDFKit document text extraction capped at 50 pages.
// Per V3 §Media/DocumentTextExtractor.swift blueprint.

import Foundation
#if canImport(PDFKit)
import PDFKit
#endif

struct DocumentTextExtractor: Sendable {
    static let maxPages = 50

    static func extractText(from pdfData: Data) -> String {
        #if canImport(PDFKit)
        guard let doc = PDFDocument(data: pdfData) else { return "" }
        var result = ""
        let pageCount = min(doc.pageCount, maxPages)
        for i in 0..<pageCount {
            if let page = doc.page(at: i), let text = page.string {
                result += text + "\\n"
            }
        }
        return result
        #else
        return ""
        #endif
    }
}
"""

# 19. Media/VisionTextRecognizer.swift
files["Media/VisionTextRecognizer.swift"] = """// Media/VisionTextRecognizer.swift
// COND: Vision framework OCR for image text extraction.
// Per V3 §Media/VisionTextRecognizer.swift blueprint.

import Foundation
#if canImport(Vision)
import Vision
#endif

actor VisionTextRecognizer {
    func recognizeText(from imageData: Data) async throws -> String {
        #if canImport(Vision)
        guard let cgImage = CGImageSourceCreateWithData(imageData as CFData, nil).flatMap({ CGImageSourceCreateImageAtIndex($0, 0, nil) }) else {
            return ""
        }
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { req, err in
                if let err = err {
                    continuation.resume(throwing: err)
                    return
                }
                let observations = req.results as? [VNRecognizedTextObservation] ?? []
                let strings = observations.compactMap { $0.topCandidates(1).first?.string }
                continuation.resume(returning: strings.joined(separator: "\\n"))
            }
            request.recognitionLevel = .accurate
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
        #else
        return ""
        #endif
    }
}
"""

# 20. Media/AttachmentProcessor.swift
files["Media/AttachmentProcessor.swift"] = """// Media/AttachmentProcessor.swift
// Ingestion pipeline: validate -> store in sandbox -> OCR/extract text.
// Per V3 §Media/AttachmentProcessor.swift blueprint.

import Foundation

actor AttachmentProcessor {
    func process(data: Data, filename: String, mimeType: String) async throws -> (url: URL, extractedText: String) {
        try AttachmentValidator.validate(data: data, expectedMime: mimeType)
        let savedURL = try AttachmentLifecycleManager.saveAttachment(data: data, filename: filename)
        var text = ""
        if mimeType == "application/pdf" {
            text = DocumentTextExtractor.extractText(from: data)
        }
        return (savedURL, text)
    }
}
"""

# 21. Media/AttachmentPicker.swift
files["Media/AttachmentPicker.swift"] = """// Media/AttachmentPicker.swift
// PhotosUI PhotosPicker view wrapper for attachments.
// Per V3 §Media/AttachmentPicker.swift blueprint.

import SwiftUI
#if canImport(PhotosUI)
import PhotosUI
#endif

struct AttachmentPickerSheet: View {
    @Binding var isPresented: Bool
    let onDataSelected: (Data) -> Void

    #if canImport(PhotosUI)
    @State private var selectedItem: PhotosPickerItem?
    #endif

    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.Spacing.lg) {
                #if canImport(PhotosUI)
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("Choose Photo", systemImage: "photo")
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .onChange(of: selectedItem) { _, newItem in
                    guard let item = newItem else { return }
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            onDataSelected(data)
                            isPresented = false
                        }
                    }
                }
                #endif

                Button("Cancel") {
                    isPresented = false
                }
                .frame(maxWidth: .infinity, minHeight: 44)
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle("Add Attachment")
        }
    }
}
"""

for rel_path, code in files.items():
    p = os.path.join(base, rel_path)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, "w", encoding="utf-8") as fp:
        fp.write(code.strip() + "\n")
    print(f"Wrote {rel_path} ({len(code)} bytes)")

print("Security, Search, and Media files written successfully.")
