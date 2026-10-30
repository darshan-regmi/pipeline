//
//  RunDetailView.swift
//  pipeline
//

import SwiftUI

struct RunDetailView: View {
    let repositoryID: String
    let runID: Int

    @Environment(AppStore.self) private var store
    @Environment(\.openURL) private var openURL

    var body: some View {
        Group {
            if let repository, let run {
                content(repository: repository, run: run)
            } else {
                EmptyStateView(
                    systemImage: "questionmark.circle",
                    title: String(localized: "Run unavailable"),
                    message: String(localized: "Return to the repository and choose another run.")
                )
                .padding(Theme.Spacing.md)
            }
        }
        .background(Color.appBackground)
        .navigationTitle(String(localized: "Run details"))
        .pipelineNavigationBarInline()
        .toolbar {
            if let run {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        openURL(run.htmlURL)
                    } label: {
                        Image(systemName: "arrow.up.right.square")
                    }
                    .accessibilityLabel(String(localized: "Open run on GitHub"))
                }
            }
        }
    }

    private var repository: PipelineRepository? {
        store.repository(withID: repositoryID)
    }

    private var run: WorkflowRun? {
        store.run(repositoryID: repositoryID, runID: runID)
    }

    private func content(repository: PipelineRepository, run: WorkflowRun) -> some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                statusHero(repository: repository, run: run)
                openOnGitHubButton(run: run)
                detailsCard(run: run)
            }
            .padding(Theme.Spacing.md)
            .padding(.bottom, 96)
        }
        .refreshable {
            await store.refresh()
        }
    }

    private func statusHero(repository: PipelineRepository, run: WorkflowRun) -> some View {
        VStack(spacing: Theme.Spacing.sm) {
            StatusGlyph(state: run.state, size: 64)

            Text(run.state.title)
                .font(.title2.weight(.bold))
                .accessibilityAddTraits(.isHeader)

            Text(run.workflowName)
                .font(.headline)

            Text("\(repository.fullName) · \(run.branch)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.lg)
        .padding(.horizontal, Theme.Spacing.md)
        .background(
            LinearGradient(
                colors: [run.state.tint.opacity(0.2), Color.cardBackground],
                startPoint: .top,
                endPoint: .bottom
            ),
            in: RoundedRectangle(cornerRadius: Theme.Radius.card + 4, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: Theme.Radius.card + 4, style: .continuous)
                .strokeBorder(Color.cardBorder, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }

    private func detailsCard(run: WorkflowRun) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(String(localized: "Run details"))
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            detailRow(String(localized: "Repository"), value: repositoryID)
            Divider()
            detailRow(String(localized: "Workflow"), value: run.workflowName)
            Divider()
            detailRow(String(localized: "Branch"), value: run.branch)
            Divider()
            detailRow(
                String(localized: "Commit"),
                value: "\(run.shortSHA) · \(run.commitMessage)"
            )
            Divider()
            detailRow(String(localized: "Triggered by"), value: run.actor)
            Divider()
            detailRow(String(localized: "Event"), value: run.event.capitalized)
            Divider()
            detailRow(
                String(localized: "Started"),
                value: run.startedAt.formatted(date: .abbreviated, time: .shortened)
            )
            Divider()
            detailRow(
                String(localized: "Duration"),
                value: run.duration?.abbreviatedDuration ?? String(localized: "Not finished")
            )
        }
        .card()
    }

    private func detailRow(_ title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.md) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(minWidth: 96, alignment: .leading)

            Spacer(minLength: 0)

            Text(value)
                .font(.subheadline)
                .multilineTextAlignment(.trailing)
                .textSelection(.enabled)
        }
        .accessibilityElement(children: .combine)
    }

    private func openOnGitHubButton(run: WorkflowRun) -> some View {
        Button {
            openURL(run.htmlURL)
        } label: {
            Label(String(localized: "Open run on GitHub"), systemImage: "arrow.up.right.square")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .accessibilityHint(String(localized: "Opens this workflow run in your browser"))
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        RunDetailView(repositoryID: "darshanregmi/pipeline", runID: 2001)
            .appDestinations()
    }
    .environment(AppStore.preview)
}
#endif
