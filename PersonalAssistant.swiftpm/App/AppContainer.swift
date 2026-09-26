// App/AppContainer.swift
// Dependency composition root — constructs exactly one instance of each service.
// Per V3 §App/AppContainer.swift blueprint.
// Views receive protocols/view models, not raw URLSession or ModelContainer.

import Foundation
import SwiftData

@MainActor
final class AppContainer {

    // MARK: - Core services (constructed once)

    let modelContainer: ModelContainer
    let keychainVault: KeychainVault
    let conversationRepository: ConversationRepository
    let configurationRepository: ConfigurationRepository
    let memoryRepository: MemoryRepository
    let taskRepository: TaskRepository
    let auditRepository: AuditRepository
    let session: AppSession
    let router: AppRouter
    let capabilityCenter: CapabilityCenter

    // MARK: - Init

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer

        // One instance per service
        self.keychainVault = KeychainVault()
        self.conversationRepository = ConversationRepository(modelContainer: modelContainer)
        self.configurationRepository = ConfigurationRepository(modelContainer: modelContainer)
        self.memoryRepository = MemoryRepository(modelContainer: modelContainer)
        self.taskRepository = TaskRepository(modelContainer: modelContainer)
        self.auditRepository = AuditRepository(modelContainer: modelContainer)

        self.session = AppSession(
            conversationRepository: conversationRepository,
            configurationRepository: configurationRepository,
            keychainVault: keychainVault
        )
        self.router = AppRouter()
        self.capabilityCenter = CapabilityCenter()
    }

    // MARK: - View model factories

    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(
            session: session,
            router: router,
            conversationRepository: conversationRepository,
            taskRepository: taskRepository
        )
    }

    func makeChatViewModel(conversationID: ConversationID) -> ChatViewModel {
        ChatViewModel(
            conversationID: conversationID,
            session: session,
            conversationRepository: conversationRepository,
            keychainVault: keychainVault,
            capabilityCenter: capabilityCenter
        )
    }

    func makeTasksViewModel() -> TaskDashboardViewModel {
        TaskDashboardViewModel(
            session: session,
            taskRepository: taskRepository,
            router: router
        )
    }

    func makeHistoryViewModel() -> HistoryViewModel {
        HistoryViewModel(
            session: session,
            conversationRepository: conversationRepository,
            router: router
        )
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            session: session,
            configurationRepository: configurationRepository,
            keychainVault: keychainVault,
            capabilityCenter: capabilityCenter
        )
    }

    // MARK: - Preview container (DEBUG only)

    #if DEBUG
    static func makePreviewContainer() -> AppContainer {
        let container = StoreBootstrap.makePreviewContainer()
        return AppContainer(modelContainer: container)
    }
    #endif
}
