//
//  RepositoryCard.swift
//  pipeline
//

import SwiftUI

struct RepositoryCard: View {
    let repository: PipelineRepository

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                providerIcon

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: Theme.Spacing.xxs) {
                        Text(repository.name)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        if repository.isPinned {
                            Image(systemName: "pin.fill")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .accessibilityHidden(true)
                        }
                    }

                    Text(repository.fullName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: Theme.Spacing.xs)

                StatusGlyph(state: repository.latestRun?.state ?? .unknown, size: 32)
            }

            if let run = repository.latestRun {
                HStack(spacing: Theme.Spacing.xxs) {
                    Text(run.workflowName)
                        .lineLimit(1)

                    Text("•")
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)

                    Label(run.branch, systemImage: "arrow.triangle.branch")
                        .lineLimit(1)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                HStack(spacing: Theme.Spacing.xs) {
                    StatusBadge(state: run.state)

                    Spacer(minLength: Theme.Spacing.xs)

                    HStack(spacing: Theme.Spacing.xxs) {
                        Text(String(localized: "Updated"))
                        RelativeTimeText(date: run.updatedAt)
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
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(String(localized: "Opens repository details"))
    }

    private var providerIcon: some View {
        Image(systemName: repository.provider.symbolName)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(Theme.accent)
            .frame(width: 34, height: 34)
            .background(Theme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .accessibilityHidden(true)
    }

    private var accessibilityLabel: String {
        var parts = [
            repository.name,
            repository.fullName,
            repository.provider.displayName
        ]

        if repository.isPinned {
            parts.append(String(localized: "Pinned to widget"))
        }

        if let run = repository.latestRun {
            parts.append(run.workflowName)
            parts.append(run.branch)
            parts.append(run.state.title)
            parts.append("\(String(localized: "Updated")) \(run.updatedAt.relativeDescription)")
        } else {
            parts.append(String(localized: "No runs yet"))
        }

        return parts.joined(separator: ", ")
    }
}
