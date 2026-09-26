// Domain/Errors.swift
// Typed error taxonomy for all layers.
// Domain cannot import SwiftUI, networking, SwiftData, UIKit.

import Foundation

// MARK: - Central typed error enum (frozen in V3 contracts §Error and result policy)

enum AppError: Error, Sendable, Equatable {
    // Session / auth
    case notAuthenticated
    case sessionChanged(expectedGeneration: UUID, currentGeneration: UUID)
    case permissionDenied(resource: String)
    case ownerMismatch(requested: UserID, current: UserID)

    // Provider / AI
    case unsupportedCapability(String)
    case noEligibleModel(reason: String)
    case rateLimited(retryAfter: Date?)
    case providerAuthInvalid(providerID: String)
    case providerTransient(providerID: String, statusCode: Int?)
    case budgetExceeded(estimatedCost: Decimal?, limit: Decimal)
    case contextTooLarge(estimatedTokens: Int, limit: Int)

    // Privacy / security
    case privacyDenied(route: String, requiredClass: PrivacyClass)

    // Tool / approval
    case validationFailed(field: String, reason: String)
    case approvalExpired(invocationID: UUID)
    case approvalPayloadMismatch(invocationID: UUID)
    case sideEffectAmbiguous(operationKey: String)
    case toolNotFound(toolID: String)
    case toolVersionMismatch(toolID: String, expected: Int, got: Int)
    case toolExecutionFailed(toolID: String, message: String)

    // Storage
    case storageRecoveryRequired(reason: String)
    case migrationFailed(reason: String)

    // Voice
    case voicePermissionDenied
    case voiceLocaleUnsupported(locale: String)
    case voiceSessionStale(sessionID: UUID)

    // Attachment / media
    case attachmentTooLarge(bytes: Int, limit: Int)
    case attachmentTypeDenied(detectedMIME: String)
    case attachmentReadFailed(reason: String)

    // Keychain
    case keychainLocked
    case keychainItemNotFound(key: String)
    case keychainWriteFailed(status: Int32)

    // Search
    case searchIndexUnavailable
    case spotlightNotSupported

    // General
    case interrupted(reason: String)
    case unknown(underlying: String)
}

// MARK: - PrivacyClass (canonical, used by errors and routing)

/// Sensitivity of data and the maximum permitted disclosure route.
/// Higher value = more sensitive. Route must accept the class before data flows.
enum PrivacyClass: Int, Codable, Sendable, Comparable, CaseIterable {
    case publicData = 0
    case personal   = 1
    case sensitive  = 2
    case secret     = 3

    static func < (lhs: PrivacyClass, rhs: PrivacyClass) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Provider failure (surface in AssistantEvent.failed)

struct ProviderFailure: Codable, Sendable, Error {
    let providerID: String
    let statusCode: Int?
    let errorCode: String?
    let message: String
    let isRetryable: Bool
    let retryAfter: Date?

    init(
        providerID: String,
        statusCode: Int? = nil,
        errorCode: String? = nil,
        message: String,
        isRetryable: Bool = false,
        retryAfter: Date? = nil
    ) {
        self.providerID = providerID
        self.statusCode = statusCode
        self.errorCode = errorCode
        self.message = message
        self.isRetryable = isRetryable
        self.retryAfter = retryAfter
    }
}

// MARK: - Typed result alias

typealias AppResult<T: Sendable> = Result<T, AppError>
