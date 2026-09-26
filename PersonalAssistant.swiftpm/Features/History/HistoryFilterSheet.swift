// Features/History/HistoryFilterSheet.swift
import SwiftUI

struct HistoryFilterSheet: View {
    @Binding var selectedFilter: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Button("All") { selectedFilter = "all"; dismiss() }
                Button("Conversations") { selectedFilter = "conversations"; dismiss() }
                Button("Tasks") { selectedFilter = "tasks"; dismiss() }
            }
            .navigationTitle("Filter History")
        }
    }
}
