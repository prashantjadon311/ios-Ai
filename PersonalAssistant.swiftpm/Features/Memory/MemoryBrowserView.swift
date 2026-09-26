// Features/Memory/MemoryBrowserView.swift
import SwiftUI

struct MemoryBrowserView: View {
    @Environment(AppContainer.self) private var container
    @Environment(AppSession.self) private var session
    @State private var memories: [MemoryItem] = []

    var body: some View {
        List {
            ForEach(memories, id: \.id) { memory in
                Text(memory.content)
            }
        }
        .navigationTitle("Memories")
        .task {
            guard let owner = session.currentProfile else { return }
            memories = (try? await container.memoryRepository.activeMemories(ownerID: owner.id)) ?? []
        }
    }
}
