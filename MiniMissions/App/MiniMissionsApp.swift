// MiniMissionsApp.swift
// App entry point. Sets up ModelContainer, seeds data, injects AppEnvironment.
// See ADR-004 for testability design, ADR-005 for topic categories schema.

import SwiftUI
import SwiftData

@main
struct MiniMissionsApp: App {
    @Environment(\.scenePhase) private var scenePhase
    private let environment: AppEnvironment
    private let modelContainer: ModelContainer

    init() {
        let env = AppEnvironment.fromLaunchArguments(ProcessInfo.processInfo.arguments)
        environment = env

        let schema = Schema([Child.self, Task.self, TaskCompletion.self, Topic.self, TaskTemplate.self, TaskAssignment.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: env.useInMemoryStore
        )
        let container = try! ModelContainer(for: schema, configurations: [config])
        SeedDataService.seedIfNeeded(context: container.mainContext)
        if env.clearKeychain {
            try? KeychainStore.shared.deletePINHash()
        }
        if let hash = env.presetPINHash {
            try? KeychainStore.shared.savePINHash(hash)
        }
        if env.resetDateYesterday {
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: Date()))!
            UserDefaults.standard.set(yesterday, forKey: "lastDailyResetDate")
        }
        modelContainer = container
    }

    var body: some Scene {
        WindowGroup {
            ContentRootView()
                .environment(\.appEnvironment, environment)
        }
        .modelContainer(modelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                performDailyResetIfNeeded()
            }
        }
    }

    private func performDailyResetIfNeeded() {
        let key = "lastDailyResetDate"
        let today = Calendar.current.startOfDay(for: Date())
        let last = UserDefaults.standard.object(forKey: key) as? Date ?? .distantPast
        guard last < today else { return }
        try? ResetService.resetAll(context: modelContainer.mainContext)
        UserDefaults.standard.set(today, forKey: key)
    }
}
