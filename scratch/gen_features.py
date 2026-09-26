import os

base = "PersonalAssistant.swiftpm"

files = {}

# Approvals
files["Features/Approvals/ApprovalViewModel.swift"] = """// Features/Approvals/ApprovalViewModel.swift
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
"""

files["Features/Approvals/ApprovalDetailView.swift"] = """// Features/Approvals/ApprovalDetailView.swift
import SwiftUI

struct ApprovalDetailView: View {
    let request: ApprovalRequest
    let onApprove: () -> Void
    let onReject: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "exclamationmark.shield")
                .font(.system(size: 64))
                .foregroundStyle(Color.orange)

            Text("Approval Required")
                .font(.title2.bold())

            Text(request.summary)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()

            HStack(spacing: AppTheme.Spacing.md) {
                Button("Reject", role: .destructive, action: onReject)
                    .buttonStyle(.bordered)
                    .frame(minHeight: 44)

                Button("Approve", action: onApprove)
                    .buttonStyle(.borderedProminent)
                    .frame(minHeight: 44)
            }
        }
        .padding()
    }
}
"""

# Assistant
files["Features/Assistant/AssistantNameEditor.swift"] = """// Features/Assistant/AssistantNameEditor.swift
import SwiftUI

struct AssistantNameEditor: View {
    @Binding var name: String
    @Environment(\\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField("Assistant Name", text: $name)
            }
            .navigationTitle("Edit Name")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { dismiss() }
                }
            }
        }
    }
}
"""

files["Features/Assistant/AssistantProfileView.swift"] = """// Features/Assistant/AssistantProfileView.swift
import SwiftUI

struct AssistantProfileView: View {
    @Environment(AppSession.self) private var session
    @State private var showingNameEditor = false

    var body: some View {
        List {
            Section("Active Assistant") {
                if let assistant = session.activeAssistant {
                    HStack {
                        AvatarView(state: .idle, identity: assistant.avatarType == .saar ? .saar : .maya, size: 50)
                        VStack(alignment: .leading) {
                            Text(assistant.name)
                                .font(.headline)
                            Text(assistant.voiceIdentifier)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("All Profiles") {
                ForEach(session.assistantProfiles, id: \\.id) { profile in
                    HStack {
                        Text(profile.name)
                        Spacer()
                        if profile.id == session.activeAssistant?.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Task { try? await session.setActiveAssistant(profile) }
                    }
                }
            }
        }
        .navigationTitle("Assistant Profiles")
    }
}
"""

# Chat
files["Features/Chat/StreamingStatusView.swift"] = """// Features/Chat/StreamingStatusView.swift
import SwiftUI

struct StreamingStatusView: View {
    let isStreaming: Bool

    var body: some View {
        if isStreaming {
            HStack(spacing: 6) {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Streaming response…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
        }
    }
}
"""

files["Features/Chat/ToolActionCard.swift"] = """// Features/Chat/ToolActionCard.swift
import SwiftUI

struct ToolActionCard: View {
    let toolName: String
    let statusText: String

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "wrench.and.screwdriver")
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading) {
                Text(toolName)
                    .font(.caption.bold())
                Text(statusText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
    }
}
"""

files["Features/Chat/ConversationListView.swift"] = """// Features/Chat/ConversationListView.swift
import SwiftUI

struct ConversationListView: View {
    let conversations: [Conversation]
    let onSelect: (ConversationID) -> Void

    var body: some View {
        List(conversations) { conv in
            Button {
                onSelect(conv.id)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(conv.title)
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                    Text(conv.updatedAt, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
"""

# Configuration
files["Features/Configuration/AIConfigurationView.swift"] = """// Features/Configuration/AIConfigurationView.swift
import SwiftUI

struct AIConfigurationView: View {
    @State private var maxTokens = 2048
    @State private var temperature = 0.7

    var body: some View {
        Form {
            Section("Generation Settings") {
                Stepper("Response Limit: \\(maxTokens) tokens", value: $maxTokens, in: 256...8192, step: 256)
                VStack(alignment: .leading) {
                    Text("Temperature: \\(String(format: \\"%.1f\\", temperature))")
                    Slider(value: $temperature, in: 0.0...1.0, step: 0.1)
                }
            }
        }
        .navigationTitle("AI Configuration")
    }
}
"""

files["Features/Configuration/ModelPickerView.swift"] = """// Features/Configuration/ModelPickerView.swift
import SwiftUI

struct ModelPickerView: View {
    @State private var selectedModel: String = "llama-3.3-70b-versatile"
    let availableModels = [
        "llama-3.3-70b-versatile",
        "llama-3.1-8b-instant",
        "meta-llama/llama-3.3-70b-instruct"
    ]

    var body: some View {
        List {
            ForEach(availableModels, id: \\.self) { model in
                HStack {
                    Text(model)
                    Spacer()
                    if selectedModel == model {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedModel = model
                }
            }
        }
        .navigationTitle("Select Model")
    }
}
"""

files["Features/Configuration/PrivacyRoutingView.swift"] = """// Features/Configuration/PrivacyRoutingView.swift
import SwiftUI

struct PrivacyRoutingView: View {
    @State private var privacyMode: PrivacyMode = .standard

    var body: some View {
        Form {
            Section("Privacy Boundary") {
                Picker("Egress Mode", selection: $privacyMode) {
                    Text("Standard (BYOK Cloud)").tag(PrivacyMode.standard)
                    Text("Private Only (Local Only)").tag(PrivacyMode.privateOnly)
                }
                .pickerStyle(.inline)
            }
        }
        .navigationTitle("Privacy Routing")
    }
}
"""

files["Features/Configuration/ProviderListView.swift"] = """// Features/Configuration/ProviderListView.swift
import SwiftUI

struct ProviderListView: View {
    var body: some View {
        List {
            NavigationLink("Groq") {
                ProviderDetailView(providerName: "Groq", providerID: "groq")
            }
            NavigationLink("OpenRouter") {
                ProviderDetailView(providerName: "OpenRouter", providerID: "openRouter")
            }
            NavigationLink("Custom Endpoint") {
                ProviderDetailView(providerName: "Custom", providerID: "custom")
            }
        }
        .navigationTitle("Providers")
    }
}
"""

files["Features/Configuration/ProviderDetailView.swift"] = """// Features/Configuration/ProviderDetailView.swift
import SwiftUI

struct ProviderDetailView: View {
    let providerName: String
    let providerID: String

    @Environment(AppContainer.self) private var container
    @Environment(AppSession.self) private var session
    @State private var apiKey: String = ""
    @State private var statusMessage: String?

    var body: some View {
        Form {
            Section("API Credentials") {
                SecureField("API Key", text: $apiKey)
                Button("Save to Keychain") {
                    guard let owner = session.currentProfile else { return }
                    Task {
                        try? await container.keychainVault.setSecret(
                            ownerID: owner.id,
                            providerID: providerID,
                            value: apiKey
                        )
                        statusMessage = "Key saved securely."
                    }
                }
                .buttonStyle(.borderedProminent)
            }

            if let msg = statusMessage {
                Section {
                    Text(msg)
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
        }
        .navigationTitle(providerName)
    }
}
"""

files["Features/Configuration/VoiceConfigurationView.swift"] = """// Features/Configuration/VoiceConfigurationView.swift
import SwiftUI

struct VoiceConfigurationView: View {
    @State private var selectedVoice = "Default Apple Speech"

    var body: some View {
        Form {
            Section("Speech Output") {
                Picker("Voice", selection: $selectedVoice) {
                    Text("Default Apple Speech").tag("Default Apple Speech")
                    Text("Enhanced Samantha").tag("Enhanced Samantha")
                    Text("Rishi (Indian English)").tag("Rishi (Indian English)")
                }
            }
        }
        .navigationTitle("Voice Settings")
    }
}
"""

files["Features/Configuration/ToolPermissionsView.swift"] = """// Features/Configuration/ToolPermissionsView.swift
import SwiftUI

struct ToolPermissionsView: View {
    @State private var enableCalendar = true
    @State private var enableReminders = true
    @State private var enableOpenURL = true

    var body: some View {
        Form {
            Section("Permitted Actions") {
                Toggle("Calendar Access", isOn: $enableCalendar)
                Toggle("Reminders Access", isOn: $enableReminders)
                Toggle("Open URLs in Browser", isOn: $enableOpenURL)
            }
        }
        .navigationTitle("Tool Permissions")
    }
}
"""

# Dashboard
files["Features/Dashboard/AttentionSummary.swift"] = """// Features/Dashboard/AttentionSummary.swift
import SwiftUI

struct AttentionSummary: View {
    let pendingCount: Int

    var body: some View {
        if pendingCount > 0 {
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(Color.orange)
                Text("\\(pendingCount) item(s) need your review")
                    .font(.subheadline.bold())
                Spacer()
            }
            .padding()
            .background(Color.orange.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
        }
    }
}
"""

files["Features/Dashboard/TodayTaskCard.swift"] = """// Features/Dashboard/TodayTaskCard.swift
import SwiftUI

struct TodayTaskCard: View {
    let task: TaskDefinition

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "checklist")
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.headline)
                if let schedule = task.scheduleTime {
                    Text(DateFormattingHelpers.shortTime(schedule))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
    }
}
"""

files["Features/Dashboard/AssistantHeader.swift"] = """// Features/Dashboard/AssistantHeader.swift
import SwiftUI

struct AssistantHeader: View {
    let name: String
    let identity: AvatarIdentity

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            AvatarView(state: .idle, identity: identity, size: 60)
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(name)
                    .font(.title2.bold())
            }
            Spacer()
        }
    }
}
"""

files["Features/Dashboard/QuickActionGrid.swift"] = """// Features/Dashboard/QuickActionGrid.swift
import SwiftUI

struct QuickActionGrid: View {
    let onNewChat: () -> Void
    let onVoice: () -> Void
    let onNewTask: () -> Void

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            actionCard(title: "Chat", systemImage: "bubble.left.and.bubble.right", action: onNewChat)
            actionCard(title: "Voice", systemImage: "mic", action: onVoice)
            actionCard(title: "New Task", systemImage: "plus.circle", action: onNewTask)
        }
    }

    private func actionCard(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: systemImage)
                    .font(.title2)
                Text(title)
                    .font(.caption.bold())
            }
            .frame(maxWidth: .infinity, minHeight: 70)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
        }
        .buttonStyle(.plain)
    }
}
"""

# History
files["Features/History/ActionTimelineView.swift"] = """// Features/History/ActionTimelineView.swift
import SwiftUI

struct ActionTimelineView: View {
    let events: [AuditEvent]

    var body: some View {
        List(events, id: \\.id) { event in
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
"""

files["Features/History/HistoryFilterSheet.swift"] = """// Features/History/HistoryFilterSheet.swift
import SwiftUI

struct HistoryFilterSheet: View {
    @Binding var selectedFilter: String
    @Environment(\\.dismiss) private var dismiss

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
"""

files["Features/History/HistoryResultRow.swift"] = """// Features/History/HistoryResultRow.swift
import SwiftUI

struct HistoryResultRow: View {
    let title: String
    let subtitle: String
    let date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(date, style: .relative)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}
"""

# Memory
files["Features/Memory/MemoryBrowserView.swift"] = """// Features/Memory/MemoryBrowserView.swift
import SwiftUI

struct MemoryBrowserView: View {
    @Environment(AppContainer.self) private var container
    @Environment(AppSession.self) private var session
    @State private var memories: [MemoryItem] = []

    var body: some View {
        List {
            ForEach(memories, id: \\.id) { memory in
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
"""

files["Features/Memory/MemoryEditorView.swift"] = """// Features/Memory/MemoryEditorView.swift
import SwiftUI

struct MemoryEditorView: View {
    @State var content: String = ""
    let onSave: (String) -> Void
    @Environment(\\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextEditor(text: $content)
                    .frame(minHeight: 150)
            }
            .navigationTitle("Edit Memory")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(content)
                        dismiss()
                    }
                }
            }
        }
    }
}
"""

files["Features/Memory/MemoryReviewQueue.swift"] = """// Features/Memory/MemoryReviewQueue.swift
import SwiftUI

struct MemoryReviewQueue: View {
    let proposals: [MemoryItem]
    let onVerify: (MemoryItemID) -> Void

    var body: some View {
        List(proposals, id: \\.id) { proposal in
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
"""

files["Features/Memory/MemorySourceView.swift"] = """// Features/Memory/MemorySourceView.swift
import SwiftUI

struct MemorySourceView: View {
    let sourceText: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Memory Source")
                .font(.headline)
            Text(sourceText)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
"""

# Onboarding
files["Features/Onboarding/LocalProfileSetup.swift"] = """// Features/Onboarding/LocalProfileSetup.swift
import SwiftUI

struct LocalProfileSetup: View {
    @Binding var displayName: String

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Text("What should we call you?")
                .font(.headline)
            TextField("Your Name", text: $displayName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
        }
    }
}
"""

files["Features/Onboarding/PermissionEducationView.swift"] = """// Features/Onboarding/PermissionEducationView.swift
import SwiftUI

struct PermissionEducationView: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
                .foregroundStyle(Color.accentColor)
            Text("Your Data Stays on Device")
                .font(.title3.bold())
            Text("Personal Assistant stores conversations, tasks, and memories locally.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
"""

files["Features/Onboarding/ProviderSetupView.swift"] = """// Features/Onboarding/ProviderSetupView.swift
import SwiftUI

struct ProviderSetupView: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Text("Bring Your Own Key")
                .font(.title2.bold())
            Text("Add an API key in Configuration to enable AI chat.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
"""

# Tasks
files["Features/Tasks/SchedulePicker.swift"] = """// Features/Tasks/SchedulePicker.swift
import SwiftUI

struct SchedulePicker: View {
    @Binding var selectedDate: Date

    var body: some View {
        DatePicker("Schedule", selection: $selectedDate, in: Date()...)
    }
}
"""

files["Features/Tasks/TaskApprovalStrip.swift"] = """// Features/Tasks/TaskApprovalStrip.swift
import SwiftUI

struct TaskApprovalStrip: View {
    let taskTitle: String
    let onApprove: () -> Void

    var body: some View {
        HStack {
            Text("Approval needed: \\(taskTitle)")
                .font(.caption)
            Spacer()
            Button("Review", action: onApprove)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        }
        .padding(8)
        .background(Color.orange.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
    }
}
"""

files["Features/Tasks/TaskDetailView.swift"] = """// Features/Tasks/TaskDetailView.swift
import SwiftUI

struct TaskDetailView: View {
    let task: TaskDefinition

    var body: some View {
        Form {
            Section("Task") {
                Text(task.title)
                    .font(.headline)
                if let schedule = task.scheduleTime {
                    LabeledContent("Scheduled For", value: DateFormattingHelpers.mediumDate(schedule))
                }
            }
        }
        .navigationTitle("Task Details")
    }
}
"""

files["Features/Tasks/TaskRunCard.swift"] = """// Features/Tasks/TaskRunCard.swift
import SwiftUI

struct TaskRunCard: View {
    let run: TaskRun

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Run: \\(run.status.rawValue)")
                    .font(.headline)
                Text(run.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
    }
}
"""

for rel_path, code in files.items():
    p = os.path.join(base, rel_path)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, "w", encoding="utf-8") as fp:
        fp.write(code.strip() + "\n")
    print(f"Wrote {rel_path} ({len(code)} bytes)")

print("Features subviews written successfully.")
