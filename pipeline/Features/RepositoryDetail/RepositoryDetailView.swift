//
//  RepositoryDetailView.swift
//  pipeline
//

import SwiftUI

struct RepositoryDetailView: View {
    let repositoryID: String

    @Environment(AppStore.self) private var store

    var body: some View {
        Group {
            if let repository {
                content(for: repository)
            } else {
                EmptyStateView(
                    systemImage: "questionmark.folder",
                    title: String(localized: "Repository unavailable"),
                    message: String(localized: "Refresh the dashboard and try again.")
                )
                .padding(Theme.Spacing.md)
            }
        }
        .background(Color.appBackground)
        .navigationTitle(repository?.name ?? String(localized: "Repository"))
        .pipelineNavigationBarInline()
        .toolbar {
            if let repository {
                ToolbarItem(placement: .primaryAction) {
                    repositoryMenu(for: repository)
                }
            }
        }
    }

    private var repository: PipelineRepository? {
        store.repository(withID: repositoryID)
    }

    private func content(for repository: PipelineRepository) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                header(for: repository)
                runsSection(for: repository)
            }
            .padding(Theme.Spacing.md)
            .padding(.bottom, 96)
        }
        .refreshable {
            await store.refresh()
        }
    }

    private func header(for repository: PipelineRepository) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                StatusGlyph(state: repository.latestRun?.state ?? .unknown, size: 52)

                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(repository.name)
                        .font(.title3.weight(.bold))

                    Text(repository.fullName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: Theme.Spacing.sm) {
                        Label(repository.provider.displayName, systemImage: repository.provider.symbolName)

                        Label(repository.defaultBranch, systemImage: "arrow.triangle.branch")

                        Label(
                            repository.isPrivate
                                ? String(localized: "Private")
                                : String(localized: "Public"),
                            systemImage: repository.isPrivate ? "lock.fill" : "globe"
                        )
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }

            if repository.isPinned {
                Label(String(localized: "Pinned to widget"), systemImage: "pin.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, Theme.Spacing.xs)
                    .padding(.vertical, 5)
                    .background(.quaternary, in: Capsule())
            }

            Divider()

            if let run = repository.latestRun {
                HStack {
                    StatusBadge(state: run.state)

                    Spacer()

                    HStack(spacing: Theme.Spacing.xxs) {
                        Text(String(localized: "Updated"))
                        RelativeTimeText(date: run.updatedAt)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(run.commitMessage)
                        .font(.subheadline)

                    HStack(spacing: Theme.Spacing.xs) {
                        Text(run.shortSHA)
                            .font(.caption.monospaced())
                        Text("•")
                            .accessibilityHidden(true)
                        Text(run.branch)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            } else {
                Text(String(localized: "No runs yet"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .card()
    }

    private func runsSection(for repository: PipelineRepository) -> some View {
        let runs = Array(repository.recentRuns.prefix(20))

        return VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(String(localized: "Recent runs"))
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            if runs.isEmpty {
                EmptyStateView(
                    systemImage: "clock.badge.questionmark",
                    title: String(localized: "No runs yet"),
                    message: String(localized: "Push a commit to trigger this repository's first workflow run.")
                )
            } else {
                VStack(spacing: 0) {
                    ForEach(runs) { run in
                        NavigationLink(
                            value: AppRoute.run(
                                repositoryID: repository.id,
                                runID: run.id
                            )
                        ) {
                            RunRow(run: run)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("repository.run.\(run.id)")

                        if run.id != runs.last?.id {
                            Divider()
                                .padding(.leading, 46)
                        }
                    }
                }
                .card(padding: 0)
            }
        }
    }

    private func repositoryMenu(for repository: PipelineRepository) -> some View {
        Menu {
            Button {
                store.setWatched(!repository.isWatched, repositoryID: repository.id)
            } label: {
                Label(
                    repository.isWatched
                        ? String(localized: "Stop watching")
                        : String(localized: "Watch repository"),
                    systemImage: repository.isWatched ? "eye.slash" : "eye"
                )
            }

            Button {
                store.setPinned(!repository.isPinned, repositoryID: repository.id)
            } label: {
                Label(
                    repository.isPinned
                        ? String(localized: "Unpin from widget")
                        : String(localized: "Pin to widget"),
                    systemImage: repository.isPinned ? "pin.slash" : "pin"
                )
            }
            .disabled(!repository.isWatched)

            Divider()

            Link(destination: repository.htmlURL) {
                Label(String(localized: "Open on GitHub"), systemImage: "arrow.up.right.square")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
        .accessibilityLabel(String(localized: "Repository actions"))
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        RepositoryDetailView(repositoryID: "darshanregmi/pipeline")
            .appDestinations()
    }
    .environment(AppStore.preview)
}
#endif
