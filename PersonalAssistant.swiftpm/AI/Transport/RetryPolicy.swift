// AI/Transport/RetryPolicy.swift
// Exponential backoff with jitter and circuit-breaker for HTTP calls.
// Per V3 §AI/Transport/RetryPolicy.swift blueprint, T007, T008, T009.

import Foundation

// MARK: - Retry classification

enum RetryClassification: Sendable, Equatable {
    case notRetryable(reason: String)
    case rateLimited(retryAfter: Date)
    case retryable(delay: TimeInterval)
}

// MARK: - Retry policy

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

    func classify(statusCode: Int, retryAfterSeconds: TimeInterval? = nil) -> RetryClassification {
        switch statusCode {
        case 401, 403:
            return .notRetryable(reason: "Authentication failed. Reconfiguration required.")
        case 429:
            let cooldown = retryAfterSeconds ?? 30.0
            return .rateLimited(retryAfter: Date().addingTimeInterval(cooldown))
        case 500...599:
            return .retryable(delay: initialDelay)
        default:
            return .notRetryable(reason: "HTTP error \(statusCode)")
        }
    }
}

// MARK: - Circuit breaker state machine (T009)

actor CircuitBreaker {
    enum State: Sendable, Equatable {
        case closed
        case open(until: Date)
        case halfOpen
    }

    private(set) var state: State = .closed
    private(set) var consecutiveFailures: Int = 0
    let failureThreshold: Int
    let cooldownDuration: TimeInterval

    init(failureThreshold: Int = 3, cooldownDuration: TimeInterval = 60.0) {
        self.failureThreshold = failureThreshold
        self.cooldownDuration = cooldownDuration
    }

    func canAttempt() -> Bool {
        switch state {
        case .closed:
            return true
        case .open(let until):
            if Date() >= until {
                state = .halfOpen
                return true
            }
            return false
        case .halfOpen:
            return true
        }
    }

    func recordSuccess() {
        consecutiveFailures = 0
        state = .closed
    }

    func recordFailure(statusCode: Int? = nil) {
        consecutiveFailures += 1
        if consecutiveFailures >= failureThreshold {
            state = .open(until: Date().addingTimeInterval(cooldownDuration))
        }
    }

    func tripOpen(until: Date) {
        state = .open(until: until)
    }

    func reset() {
        consecutiveFailures = 0
        state = .closed
    }
}
