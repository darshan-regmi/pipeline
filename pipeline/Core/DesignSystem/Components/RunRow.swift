//
//  RunRow.swift
//  pipeline
//

import SwiftUI

struct RunRow: View {
    let run: WorkflowRun

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
            StatusGlyph(state: run.state, size: 30)

            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(run.workflowName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: Theme.Spacing.xxs) {
                    Text(run.shortSHA)
                        .font(.caption.monospaced())
                    Text("•")
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                    Text(run.branch)
                        .lineLimit(1)
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Text(run.commitMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: Theme.Spacing.xs)

            VStack(alignment: .trailing, spacing: Theme.Spacing.xxs) {
                RelativeTimeText(date: run.updatedAt)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let duration = run.duration {
                    Text(duration.abbreviatedDuration)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.sm)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(String(localized: "Opens run details"))
    }

    private var accessibilityLabel: String {
        var parts = [
            run.workflowName,
            run.state.title,
            run.branch,
            run.shortSHA,
            run.commitMessage,
            "\(String(localized: "Updated")) \(run.updatedAt.relativeDescription)",
            "\(String(localized: "Triggered by")) \(run.actor)"
        ]

        if let duration = run.duration {
            parts.append("\(String(localized: "Duration")) \(duration.abbreviatedDuration)")
        }

        return parts.joined(separator: ", ")
    }
}
