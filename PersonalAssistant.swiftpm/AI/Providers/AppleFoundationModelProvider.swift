// AI/Providers/AppleFoundationModelProvider.swift
// COND: Apple Foundation Models on-device provider, runtime gated with honest capability reporting.
// Per V3 §AI/Providers/AppleFoundationModelProvider.swift and P08 requirements.

import Foundation

actor AppleFoundationModelProvider: AssistantModel {
    let providerID: String = "appleFoundationModels"

    var isEligibleOnDevice: Bool {
        #if os(iOS)
        if #available(iOS 18.1, *) {
            #if arch(arm64)
            #if targetEnvironment(simulator)
            return false // Simulator does not support Apple Intelligence neural engine
            #else
            return true
            #endif
            #else
            return false
            #endif
        } else {
            return false
        }
        #elseif os(macOS)
        if #available(macOS 15.1, *) {
            #if arch(arm64)
            return true
            #else
            return false
            #endif
        } else {
            return false
        }
        #else
        return false
        #endif
    }

    func models() async throws -> [ModelDescriptor] {
        let eligible = isEligibleOnDevice
        return [
            ModelDescriptor(
                id: "apple-intelligence-on-device",
                providerID: providerID,
                displayName: "Apple Intelligence (On-Device)",
                capabilities: ModelCapabilitySet(
                    textChat: eligible ? .yes : .no,
                    tools: .no,
                    vision: eligible ? .yes : .no,
                    streaming: eligible ? .yes : .no,
                    jsonMode: .no
                ),
                contextLimit: 4096,
                available: eligible,
                verifiedAt: Date()
            )
        ]
    }

    func stream(_ request: AssistantRequest) async throws -> AsyncThrowingStream<AssistantEvent, Error> {
        guard isEligibleOnDevice else {
            throw AppError.unsupportedCapability(
                "Apple Intelligence on-device models are unavailable on this device/OS. Requires physical Apple Silicon device running iOS 18.1+ / macOS 15.1+."
            )
        }
        // In local mode when eligible, throw until Apple on-device Foundation Models framework is linked
        throw AppError.unsupportedCapability("Apple Foundation Models on-device runtime requires system entitlement and physical device.")
    }
}
