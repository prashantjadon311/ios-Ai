// Security/BiometricGate.swift
// LocalAuthentication biometric authentication gate (FaceID / TouchID).
// Per V3 §Security/BiometricGate.swift blueprint.
// Fails closed on unsupported platforms and authentication failures.

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
        // Fail closed per P0-20
        return false
        #endif
    }
}
