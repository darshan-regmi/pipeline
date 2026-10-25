//
//  AppStore.swift
//  pipeline
//

import Foundation
import Observation

/// The single source of truth for connection state, repositories, and
/// preferences.
///
/// Keeping this state in one observable object avoids passing bindings through
/// every screen and makes the demo-to-live-data swap a one-line dependency
/// change.
@MainActor
@Observable
final class AppStore {
    @ObservationIgnored private let tokenStore: any TokenStoring
    @ObservationIgnored private let service: any PipelineServicing
    @ObservationIgnored private let defaults: UserDefaults

    private(set) var token: String?
    private(set) var isDemoMode: Bool
    private(set) var repositories: [PipelineRepository]
    private(set) var isLoading = false
    private(set) var isRefreshing = false
    private(set) var lastRefreshedAt: Date?
    var errorMessage: String?

    init(
        tokenStore: (any TokenStoring)? = nil,
        service: (any PipelineServicing)? = nil,
        defaults: UserDefaults = .standard,
        initialRepositories: [PipelineRepository] = []
    ) {
        let tokenStore = tokenStore ?? KeychainTokenStore()
        let service = service ?? DemoPipelineService()

        self.tokenStore = tokenStore
        self.service = service
        self.defaults = defaults
        self.token = try? tokenStore.load()
        self.isDemoMode = defaults.bool(forKey: PreferenceKey.demoMode)
        self.repositories = initialRepositories

        if !initialRepositories.isEmpty {
            applyPreferences()
            self.lastRefreshedAt = .now
        }
    }

    var isConnected: Bool {
        token != nil || isDemoMode
    }

    var watchedRepositories: [PipelineRepository] {
        repositories
            .filter { $0.isWatched }
            .sorted(by: repositorySort)
    }

    var allRepositories: [PipelineRepository] {
        repositories.sorted(by: repositorySort)
    }

    var pinnedRepositories: [PipelineRepository] {
        watchedRepositories.filter { $0.isPinned }
    }

    var overallState: RunState {
        let states = watchedRepositories.compactMap { $0.latestRun?.state }

        guard !states.isEmpty else { return .unknown }
        if states.contains(where: { $0.isFailure }) { return .failure }
        if states.contains(where: { $0 == .running }) { return .running }
        if states.contains(where: { $0 == .queued }) { return .queued }
        if states.contains(where: { $0 == .unknown }) { return .unknown }
        return .success
    }

    var healthyCount: Int {
        watchedRepositories.filter { $0.latestRun?.state.isHealthy == true }.count
    }

    var failingCount: Int {
        watchedRepositories.filter { $0.latestRun?.state.isFailure == true }.count
    }

    var activeCount: Int {
        watchedRepositories.filter { $0.latestRun?.state.isActive == true }.count
    }

    func loadInitialDataIfNeeded() async {
        guard isConnected, repositories.isEmpty, !isLoading else { return }
        await reload(showSpinner: true)
    }

    func connect(token rawToken: String) async throws {
        let trimmed = rawToken.trimmingCharacters(in: .whitespacesAndNewlines)
        try GitHubTokenValidator.validate(trimmed)
        try tokenStore.save(trimmed)

        token = trimmed
        isDemoMode = false
        defaults.set(false, forKey: PreferenceKey.demoMode)

        await reload(showSpinner: true)
    }

    func startDemo() async {
        isDemoMode = true
        defaults.set(true, forKey: PreferenceKey.demoMode)
        await reload(showSpinner: true)
    }

    func refresh() async {
        guard isConnected, !isLoading, !isRefreshing else { return }
        await reload(showSpinner: false)
    }

    func disconnect() {
        do {
            try tokenStore.delete()
        } catch {
            errorMessage = error.localizedDescription
        }

        token = nil
        isDemoMode = false
        defaults.set(false, forKey: PreferenceKey.demoMode)
        repositories = []
        lastRefreshedAt = nil
    }

    func deleteAllData() {
        try? tokenStore.delete()
        PreferenceKey.all.forEach { defaults.removeObject(forKey: $0) }

        token = nil
        isDemoMode = false
        repositories = []
        lastRefreshedAt = nil
        errorMessage = nil
    }

    func setWatched(_ isWatched: Bool, repositoryID: String) {
        guard let index = repositories.firstIndex(where: { $0.id == repositoryID }) else { return }

        repositories[index].isWatched = isWatched
        if !isWatched {
            repositories[index].isPinned = false
        }
        persistPreferences()
    }

    func setPinned(_ isPinned: Bool, repositoryID: String) {
        guard let index = repositories.firstIndex(where: { $0.id == repositoryID }),
              repositories[index].isWatched else {
            return
        }

        repositories[index].isPinned = isPinned
        persistPreferences()
    }

    func repository(withID id: String) -> PipelineRepository? {
        repositories.first { $0.id == id }
    }

    func run(repositoryID: String, runID: Int) -> WorkflowRun? {
        repository(withID: repositoryID)?.runs.first { $0.id == runID }
    }

    private func reload(showSpinner: Bool) async {
        if showSpinner {
            isLoading = true
        } else {
            isRefreshing = true
        }

        defer {
            isLoading = false
            isRefreshing = false
        }

        do {
            var fetched = try await service.fetchRepositories()
            applyPreferences(to: &fetched)
            repositories = fetched
            lastRefreshedAt = .now
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func applyPreferences() {
        applyPreferences(to: &repositories)
    }

    private func applyPreferences(to repositories: inout [PipelineRepository]) {
        let watchedIDs = defaults.stringArray(forKey: PreferenceKey.watchedRepositories)
        let pinnedIDs = defaults.stringArray(forKey: PreferenceKey.pinnedRepositories)

        for index in repositories.indices {
            if let watchedIDs {
                repositories[index].isWatched = watchedIDs.contains(repositories[index].id)
            }
            if let pinnedIDs {
                repositories[index].isPinned = pinnedIDs.contains(repositories[index].id)
            }
        }
    }

    private func persistPreferences() {
        defaults.set(
            repositories.filter { $0.isWatched }.map(\.id),
            forKey: PreferenceKey.watchedRepositories
        )
        defaults.set(
            repositories.filter { $0.isPinned }.map(\.id),
            forKey: PreferenceKey.pinnedRepositories
        )
    }

    private func repositorySort(_ lhs: PipelineRepository, _ rhs: PipelineRepository) -> Bool {
        if lhs.isPinned != rhs.isPinned {
            return lhs.isPinned && !rhs.isPinned
        }
        if lhs.sortOrder != rhs.sortOrder {
            return lhs.sortOrder < rhs.sortOrder
        }
        return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
    }
}

private enum PreferenceKey {
    static let demoMode = "preferences.demoMode"
    static let watchedRepositories = "preferences.watchedRepositories"
    static let pinnedRepositories = "preferences.pinnedRepositories"

    static let all = [
        demoMode,
        watchedRepositories,
        pinnedRepositories
    ]
}
