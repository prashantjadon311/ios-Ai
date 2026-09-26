// AI/Transport/ConnectivityMonitor.swift
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
