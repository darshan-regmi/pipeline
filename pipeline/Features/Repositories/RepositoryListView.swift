//
//  RepositoryListView.swift
//  pipeline
//

import SwiftUI

struct RepositoryListView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var searchText = ""

    var body: some View {
        List {
            Section {
                ForEach(filteredRepositories) { repository in
                    repositoryRow(repository)
                }
            } header: {
                Text(String(localized: "Choose what to watch"))
            } footer: {
                Text(String(localized: "Pipeline shows the latest workflow run for each watched repository. Pin a repository from its detail screen to include it in the widget."))
            }
        }
        .contentMargins(.bottom, 96, for: .scrollContent)
        .navigationTitle(String(localized: "Repositories"))
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: String(localized: "Search repositories")
        )
        .overlay {
            if filteredRepositories.isEmpty && !searchText.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
        }
        .overlay {
            if store.isLoading && store.repositories.isEmpty {
                ProgressView(String(localized: "Loading repositories…"))
            }
        }
        .task {
            await store.loadInitialDataIfNeeded()
        }
        .appDestinations()
    }

    private func repositoryRow(_ repository: PipelineRepository) -> some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                        StatusGlyph(state: repository.latestRun?.state ?? .unknown, size: 30)
                        repositoryIdentity(repository)
                        Spacer(minLength: 0)
                    }

                    Toggle(String(localized: "Watch"), isOn: watchBinding(for: repository))
                        .accessibilityLabel(String(localized: "Watch \(repository.name)"))
                        .accessibilityHint(String(localized: "Adds \(repository.fullName) to the dashboard"))
                        .accessibilityIdentifier("repositories.toggle.\(repository.id)")
                }
            } else {
                HStack(spacing: Theme.Spacing.sm) {
                    StatusGlyph(state: repository.latestRun?.state ?? .unknown, size: 30)
                    repositoryIdentity(repository)

                    Spacer(minLength: Theme.Spacing.xs)

                    Toggle(
                        String(localized: "Watch \(repository.name)"),
                        isOn: watchBinding(for: repository)
                    )
                    .labelsHidden()
                    .accessibilityLabel(String(localized: "Watch \(repository.name)"))
                    .accessibilityHint(String(localized: "Adds \(repository.fullName) to the dashboard"))
                    .accessibilityIdentifier("repositories.toggle.\(repository.id)")
                }
            }
        }
        .padding(.vertical, Theme.Spacing.xxs)
    }

    private func repositoryIdentity(_ repository: PipelineRepository) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: Theme.Spacing.xxs) {
                Text(repository.name)
                    .font(.body.weight(.medium))

                if repository.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel(String(localized: "Pinned to widget"))
                }
            }

            Text(repository.fullName)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func watchBinding(for repository: PipelineRepository) -> Binding<Bool> {
        Binding(
            get: { store.repository(withID: repository.id)?.isWatched ?? false },
            set: { store.setWatched($0, repositoryID: repository.id) }
        )
    }

    private var filteredRepositories: [PipelineRepository] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return store.allRepositories
        }

        return store.allRepositories.filter { repository in
            repository.name.localizedCaseInsensitiveContains(query)
                || repository.fullName.localizedCaseInsensitiveContains(query)
                || repository.owner.localizedCaseInsensitiveContains(query)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        RepositoryListView()
    }
    .environment(AppStore.preview)
}
#endif
