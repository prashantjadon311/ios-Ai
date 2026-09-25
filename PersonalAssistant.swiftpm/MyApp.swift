// App/PersonalAssistantApp.swift
// @main entry point — single SwiftUI app, creates ModelContainer and AppContainer.
// Per V3 §App/PersonalAssistantApp.swift — never fires network from initializer.

import SwiftUI
import SwiftData

@main
struct PersonalAssistantApp: App {

    @State private var appContainer: AppContainer?
    @State private var storeRecoveryInfo: (reason: String, url: URL?)?

    var body: some Scene {
        WindowGroup {
            Group {
                if let info = storeRecoveryInfo {
                    StoreRecoveryView(reason: info.reason, storeURL: info.url)
                } else if let container = appContainer {
                    RootNavigationView()
                        .environment(container.session)
                        .environment(container.router)
                        .environment(container.capabilityCenter)
                        .environment(container)
                        .task {
                            await container.session.bootstrapLocalProfile()
                            await container.capabilityCenter.refresh(.sceneActive)
                        }
                } else {
                    ProgressView("Loading…")
                }
            }
            .onAppear {
                setupContainer()
            }
        }
    }

    // MARK: - Container initialization

    private func setupContainer() {
        guard appContainer == nil, storeRecoveryInfo == nil else { return }
        let result = StoreBootstrap.makeContainer()
        switch result {
        case .success(let container):
            let ac = AppContainer(modelContainer: container)
            appContainer = ac
        case .recoveryRequired(let reason, let url):
            storeRecoveryInfo = (reason, url)
        }
    }
}

// MARK: - Store recovery view

/// Shown when the database cannot be opened. Preserves original store.
struct StoreRecoveryView: View {
    let reason: String
    let storeURL: URL?

    var body: some View {
        ContentUnavailableView {
            Label("Data Recovery Needed", systemImage: "exclamationmark.triangle.fill")
        } description: {
            Text(reason)
            if let url = storeURL {
                Text("Store location: \(url.path)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } actions: {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
