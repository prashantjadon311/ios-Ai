// Features/History/ActionTimelineView.swift
import SwiftUI

struct ActionTimelineView: View {
    let events: [AuditEvent]

    var body: some View {
        List(events, id: \.id) { event in
            VStack(alignment: .leading, spacing: 4) {
                Text(event.action)
                    .font(.headline)
                Text(event.timestamp, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Action Timeline")
    }
}
