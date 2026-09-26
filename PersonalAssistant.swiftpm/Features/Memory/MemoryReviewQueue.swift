// Features/Memory/MemoryReviewQueue.swift
import SwiftUI

struct MemoryReviewQueue: View {
    let proposals: [MemoryItem]
    let onVerify: (MemoryItemID) -> Void

    var body: some View {
        List(proposals, id: \.id) { proposal in
            HStack {
                Text(proposal.content)
                Spacer()
                Button("Verify") {
                    onVerify(proposal.id)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle("Review Memories")
    }
}
