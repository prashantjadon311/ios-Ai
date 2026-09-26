// App/AppContainer.swift
// Dependency composition root — constructs exactly one instance of each service.
// Per V3 §App/AppContainer.swift blueprint.
// Views receive protocols/view models, not raw URLSession or ModelContainer.

import Foundation
import SwiftData
import Observation

@MainActor
@Observable
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

    // AI & Transport
    let httpClient: HTTPClient
    let modelRouter: ModelRouter
    let assistantOrchestrator: AssistantOrchestrator

    // Tools & Security
    let toolReceiptStore: ToolReceiptStore
    let toolPolicyEngine: ToolPolicyEngine
    let toolInvocationCoordinator: ToolInvocationCoordinator
    let approvalCoordinator: ApprovalCoordinator

    // Voice & Command Bus
    let commandBus: ApplicationCommandBus
    let voiceCoordinator: VoiceCoordinator

    // MARK: - Init

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer

        let vault = KeychainVault()
        self.keychainVault = vault
        let convRepo = ConversationRepository(modelContainer: modelContainer)
        self.conversationRepository = convRepo
        let configRepo = ConfigurationRepository(modelContainer: modelContainer)
        self.configurationRepository = configRepo
        let memRepo = MemoryRepository(modelContainer: modelContainer)
        self.memoryRepository = memRepo
        let taskRepo = TaskRepository(modelContainer: modelContainer)
        self.taskRepository = taskRepo
        let auditRepo = AuditRepository(modelContainer: modelContainer)
        self.auditRepository = auditRepo

        self.session = AppSession(
            conversationRepository: convRepo,
            configurationRepository: configRepo,
            keychainVault: vault
        )
        self.router = AppRouter()
        self.capabilityCenter = CapabilityCenter()

        let http = HTTPClient()
        self.httpClient = http

        var initialProviders: [any AssistantModel] = []
        if let groqURL = URL(string: "https://api.groq.com/openai/v1") {
            let groqProvider = OpenAICompatibleProvider(
                providerID: "groq",
                baseURL: groqURL,
                keychainVault: vault,
                httpClient: http
            )
            initialProviders.append(groqProvider)
        }
        if let openRouterURL = URL(string: "https://openrouter.ai/api/v1") {
            let openRouterProvider = OpenAICompatibleProvider(
                providerID: "openRouter",
                baseURL: openRouterURL,
                keychainVault: vault,
                httpClient: http
            )
            initialProviders.append(openRouterProvider)
        }

        let router = ModelRouter(keychainVault: vault, initialProviders: initialProviders)
        self.modelRouter = router

        self.assistantOrchestrator = AssistantOrchestrator(
            conversationRepository: convRepo,
            configurationRepository: configRepo,
            memoryRepository: memRepo,
            auditRepository: auditRepo,
            modelRouter: router
        )

        let receiptStore = ToolReceiptStore(modelContainer: modelContainer)
        self.toolReceiptStore = receiptStore
        let policyEngine = ToolPolicyEngine()
        self.toolPolicyEngine = policyEngine
        self.toolInvocationCoordinator = ToolInvocationCoordinator(
            receiptStore: receiptStore,
            policyEngine: policyEngine
        )
        self.approvalCoordinator = ApprovalCoordinator()

        let bus = ApplicationCommandBus(session: self.session, router: self.router)
        self.commandBus = bus
        self.voiceCoordinator = VoiceCoordinator(capabilityCenter: self.capabilityCenter, commandBus: bus)

        // Reconcile any orphaned PREPARED tool operations from previous run
        Task {
            await receiptStore.reconcileStartup()
        }
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

    func makeChatViewModel(conversationID: ConversationID? = nil) -> ChatViewModel {
        ChatViewModel(
            conversationID: conversationID,
            session: session,
            conversationRepository: conversationRepository,
            keychainVault: keychainVault,
            capabilityCenter: capabilityCenter,
            orchestrator: assistantOrchestrator,
            configurationRepository: configurationRepository
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

    func makeApprovalViewModel() -> ApprovalViewModel {
        ApprovalViewModel(coordinator: approvalCoordinator)
    }

    // MARK: - Preview container (DEBUG only)

    #if DEBUG
    static func makePreviewContainer() -> AppContainer {
        let container = StoreBootstrap.makePreviewContainer()
        return AppContainer(modelContainer: container)
    }
    #endif
}
