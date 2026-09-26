// Features/Approvals/ApprovalViewModel.swift
import Foundation
import Observation

@MainActor
@Observable
final class ApprovalViewModel {
    var pendingRequests: [ApprovalRequest] = []
    private let coordinator: ApprovalCoordinator

    init(coordinator: ApprovalCoordinator = ApprovalCoordinator()) {
        self.coordinator = coordinator
    }

    func load() async {
        pendingRequests = await coordinator.allPending()
    }

    func approve(requestID: ApprovalID) async {
        _ = try? await coordinator.approve(requestID: requestID)
        await load()
    }

    func reject(requestID: ApprovalID) async {
        await coordinator.reject(requestID: requestID)
        await load()
    }
}
