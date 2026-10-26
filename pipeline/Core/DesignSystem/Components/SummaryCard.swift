//
//  SummaryCard.swift
//  pipeline
//

import SwiftUI

struct SummaryCard: View {
    let state: RunState
    let title: String
    let message: String
    let lastRefreshedAt: Date?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    StatusGlyph(state: state, size: 52)
                    summaryText
                }
            } else {
                HStack(spacing: Theme.Spacing.sm) {
                    StatusGlyph(state: state, size: 52)
                    summaryText
                }
            }

            Divider()

            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    updatedContent
                    Text(String(localized: "Pull to refresh"))
                        .foregroundStyle(.tertiary)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            } else {
                HStack(spacing: Theme.Spacing.xxs) {
                    updatedContent
                    Spacer(minLength: Theme.Spacing.xs)
                    Text(String(localized: "Pull to refresh"))
                        .foregroundStyle(.tertiary)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(Theme.Spacing.lg)
        .background(
            LinearGradient(
                colors: [state.tint.opacity(0.18), Color.cardBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: Theme.Radius.card + 4, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: Theme.Radius.card + 4, style: .continuous)
                .strokeBorder(Color.cardBorder, lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var updatedContent: some View {
        HStack(spacing: Theme.Spacing.xxs) {
            Image(systemName: "clock.arrow.circlepath")
                .accessibilityHidden(true)

            if let lastRefreshedAt {
                Text(String(localized: "Updated"))
                RelativeTimeText(date: lastRefreshedAt)
            } else {
                Text(String(localized: "Not refreshed yet"))
            }
        }
    }

    private var summaryText: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var accessibilityLabel: String {
        let updated = lastRefreshedAt?.relativeDescription
            ?? String(localized: "never")
        return "\(title). \(message) \(String(localized: "Updated")) \(updated)."
    }
}
