// Features/History/HistoryView.swift
// History screen — searchable list of conversations with delete/export.

import SwiftUI

struct HistoryView: View {
    @Environment(AppContainer.self) private var container
    @State private var viewModel: HistoryViewModel?
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    historyContent(vm)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("History")
            .searchable(text: $searchText, prompt: "Search conversations")
            .onChange(of: searchText) { _, new in viewModel?.onSearch(new) }
            .task {
                let vm = container.makeHistoryViewModel()
                viewModel = vm
                await vm.load()
            }
            .refreshable { await viewModel?.load() }
        }
    }

    @ViewBuilder
    private func historyContent(_ vm: HistoryViewModel) -> some View {
        if vm.isLoading {
            ProgressView("Loading history…")
        } else if vm.filteredConversations.isEmpty {
            ContentUnavailableView {
                Label(searchText.isEmpty ? "No History" : "No Results", systemImage: "clock")
            } description: {
                Text(searchText.isEmpty ? "Your conversations will appear here." : "Try a different search term.")
            }
        } else {
            List {
                ForEach(vm.filteredConversations) { conv in
                    Button {
                        vm.onOpenConversation(conv)
                    } label: {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text(conv.title)
                                .font(.subheadline.bold())
                                .foregroundStyle(.primary)
                            if let preview = conv.lastMessagePreview {
                                Text(preview)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            if let date = conv.lastMessageAt {
                                Text(date.formatted(.relative(presentation: .named)))
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .padding(.vertical, AppTheme.Spacing.xs)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Conversation: \(conv.title)")
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            Task { await vm.onDelete(conv) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}
