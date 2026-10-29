//
//  DashboardView.swift
//  pipeline
//

import SwiftUI

struct DashboardView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                if let errorMessage = store.errorMessage {
                    ErrorBanner(message: errorMessage) {
                        store.errorMessage = nil
                    }
                }

                SummaryCard(
                    state: store.overallState,
                    title: summaryTitle,
                    message: summaryMessage,
                    lastRefreshedAt: store.lastRefreshedAt
                )
                .accessibilityIdentifier("dashboard.summary")

                watchedSection
            }
            .padding(Theme.Spacing.md)
            .padding(.bottom, 96)
        }
        .background(Color.appBackground)
        .navigationTitle(String(localized: "Pipeline"))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task { await store.refresh() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(store.isRefreshing)
                .accessibilityLabel(String(localized: "Refresh pipeline status"))
                .accessibilityHint(String(localized: "Checks for the latest workflow runs"))
            }
        }
        .refreshable {
            await store.refresh()
        }
        .overlay {
            if store.isLoading && store.repositories.isEmpty {
                ProgressView(String(localized: "Loading your pipeline…"))
                    .padding(Theme.Spacing.lg)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Theme.Radius.control))
            }
        }
        .task {
            await store.loadInitialDataIfNeeded()
        }
        .appDestinations()
    }

    @ViewBuilder
    private var watchedSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack(alignment: .firstTextBaseline) {
                Text(String(localized: "Watched repositories"))
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)

                Spacer()

                Text("\(store.watchedRepositories.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel(
                        String(localized: "\(store.watchedRepositories.count) watched repositories")
                    )
            }

            if store.watchedRepositories.isEmpty {
                EmptyStateView(
                    systemImage: "folder.badge.plus",
                    title: String(localized: "No repositories watched"),
                    message: String(localized: "Open the Repositories tab and choose the projects you want to keep an eye on.")
                )
                .accessibilityIdentifier("dashboard.emptyState")
            } else {
                ForEach(store.watchedRepositories) { repository in
                    NavigationLink(value: AppRoute.repository(id: repository.id)) {
                        RepositoryCard(repository: repository)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("dashboard.repository.\(repository.id)")
                }
            }
        }
    }

    private var summaryTitle: String {
        switch store.overallState {
        case .failure, .timedOut:
            String(localized: "Builds need attention")
        case .running:
            String(localized: "Builds are running")
        case .queued:
            String(localized: "Builds are queued")
        case .success:
            String(localized: "All systems operational")
        default:
            String(localized: "Waiting for a run")
        }
    }

    private var summaryMessage: String {
        let watchedCount = store.watchedRepositories.count

        switch store.overallState {
        case .failure, .timedOut:
            return String(localized: "\(store.failingCount) of \(watchedCount) watched repositories failing.")
        case .running, .queued:
            return String(localized: "\(store.activeCount) of \(watchedCount) watched repositories are in progress.")
        case .success:
            if watchedCount == 1 {
                return String(localized: "Your watched repository is healthy.")
            }
            return String(localized: "All \(watchedCount) watched repositories are healthy.")
        default:
            return String(localized: "Open the Repositories tab to choose what to watch.")
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        DashboardView()
    }
    .environment(AppStore.preview)
}
#endif
