//
//  AppStoreTests.swift
//  pipelineTests
//

import Foundation
import Testing
@testable import pipeline

@MainActor
struct AppStoreTests {
    @Test func connectSavesTokenAndLoadsRepositories() async throws {
        let testDefaults = TestDefaults()
        defer { testDefaults.cleanUp() }

        let tokenStore = InMemoryTokenStore()
        let token = "github_pat_" + String(repeating: "a", count: 30)
        let store = makeStore(tokenStore: tokenStore, defaults: testDefaults.defaults)

        try await store.connect(token: token)

        #expect(store.isConnected)
        #expect(store.token == token)
        #expect(tokenStore.token == token)
        #expect(store.repositories.count == SampleData.repositories.count)
        #expect(store.lastRefreshedAt != nil)
    }

    @Test func connectRejectsInvalidTokenWithoutSavingIt() async {
        let testDefaults = TestDefaults()
        defer { testDefaults.cleanUp() }

        let tokenStore = InMemoryTokenStore()
        let store = makeStore(tokenStore: tokenStore, defaults: testDefaults.defaults)

        do {
            try await store.connect(token: "not-a-github-token")
            Issue.record("Expected token validation to throw.")
        } catch {
            let validationError = error as? GitHubTokenValidationError
            #expect(validationError == .invalidFormat)
        }

        #expect(tokenStore.token == nil)
        #expect(!store.isConnected)
    }

    @Test func demoModeIsRememberedAcrossStores() async {
        let testDefaults = TestDefaults()
        defer { testDefaults.cleanUp() }

        let firstStore = makeStore(defaults: testDefaults.defaults)
        await firstStore.startDemo()

        #expect(firstStore.isConnected)
        #expect(firstStore.isDemoMode)
        #expect(firstStore.repositories.count == SampleData.repositories.count)

        let secondStore = makeStore(defaults: testDefaults.defaults)
        #expect(secondStore.isConnected)
        #expect(secondStore.isDemoMode)
    }

    @Test func watchAndPinPreferencesPersist() {
        let testDefaults = TestDefaults()
        defer { testDefaults.cleanUp() }

        let repositoryID = "darshanregmi/pipeline"
        let firstStore = makeStore(
            defaults: testDefaults.defaults,
            initialRepositories: SampleData.repositories
        )

        firstStore.setWatched(false, repositoryID: repositoryID)
        firstStore.setPinned(false, repositoryID: repositoryID)

        #expect(firstStore.repository(withID: repositoryID)?.isWatched == false)
        #expect(firstStore.repository(withID: repositoryID)?.isPinned == false)

        let secondStore = makeStore(
            defaults: testDefaults.defaults,
            initialRepositories: SampleData.repositories
        )

        #expect(secondStore.repository(withID: repositoryID)?.isWatched == false)
        #expect(secondStore.repository(withID: repositoryID)?.isPinned == false)
    }

    @Test func pinningRequiresWatching() {
        let testDefaults = TestDefaults()
        defer { testDefaults.cleanUp() }

        let repositoryID = "darshanregmi/habit-streak"
        let store = makeStore(
            defaults: testDefaults.defaults,
            initialRepositories: SampleData.repositories
        )

        store.setPinned(true, repositoryID: repositoryID)

        #expect(store.repository(withID: repositoryID)?.isPinned == false)
    }

    @Test func deleteAllDataClearsTokenAndPreferences() async throws {
        let testDefaults = TestDefaults()
        defer { testDefaults.cleanUp() }

        let tokenStore = InMemoryTokenStore()
        let store = makeStore(tokenStore: tokenStore, defaults: testDefaults.defaults)

        try await store.connect(token: "github_pat_" + String(repeating: "a", count: 30))
        store.setWatched(false, repositoryID: "darshanregmi/pipeline")
        store.deleteAllData()

        #expect(tokenStore.token == nil)
        #expect(store.token == nil)
        #expect(!store.isConnected)
        #expect(store.repositories.isEmpty)
        #expect(testDefaults.defaults.object(forKey: "preferences.demoMode") == nil)
        #expect(testDefaults.defaults.object(forKey: "preferences.watchedRepositories") == nil)
        #expect(testDefaults.defaults.object(forKey: "preferences.pinnedRepositories") == nil)
    }

    @Test func sampleDataProducesFailureSummary() {
        let testDefaults = TestDefaults()
        defer { testDefaults.cleanUp() }

        let store = makeStore(
            defaults: testDefaults.defaults,
            initialRepositories: SampleData.repositories
        )

        #expect(store.watchedRepositories.count == 4)
        #expect(store.overallState == .failure)
        #expect(store.failingCount == 1)
        #expect(store.activeCount == 2)
        #expect(store.healthyCount == 1)
    }

    private func makeStore(
        tokenStore: InMemoryTokenStore = InMemoryTokenStore(),
        defaults: UserDefaults,
        initialRepositories: [PipelineRepository] = []
    ) -> AppStore {
        AppStore(
            tokenStore: tokenStore,
            service: StubPipelineService(repositories: SampleData.repositories),
            defaults: defaults,
            initialRepositories: initialRepositories
        )
    }
}

private struct StubPipelineService: PipelineServicing {
    let repositories: [PipelineRepository]

    func fetchRepositories() async throws -> [PipelineRepository] {
        repositories
    }
}

private struct TestDefaults {
    let suiteName: String
    let defaults: UserDefaults

    init() {
        suiteName = "PipelineTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
    }

    func cleanUp() {
        defaults.removePersistentDomain(forName: suiteName)
    }
}
