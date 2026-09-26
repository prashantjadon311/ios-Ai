// Features/Approvals/ApprovalViewModel.swift
import Foundation
import Observation

@MainActor
@Observable
final class ApprovalViewModel {
    var pendingRequests: [ApprovalRequest] = []
    var errorMessage: String?
    private let coordinator: ApprovalCoordinator

    init(coordinator: ApprovalCoordinator = ApprovalCoordinator()) {
        self.coordinator = coordinator
    }

    func load() async {
        pendingRequests = await coordinator.allPending()
    }

    func approve(request: ApprovalRequest, currentSession: SessionToken) async {
        errorMessage = nil
        do {
            _ = try await coordinator.approve(
                requestID: request.id,
                expectedPayloadHash: request.payloadHash,
                currentSession: currentSession
            )
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reject(requestID: ApprovalID) async {
        errorMessage = nil
        await coordinator.reject(requestID: requestID)
        await load()
    }
}
