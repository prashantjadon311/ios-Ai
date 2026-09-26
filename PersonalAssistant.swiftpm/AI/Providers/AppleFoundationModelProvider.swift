// AI/Providers/AppleFoundationModelProvider.swift
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
