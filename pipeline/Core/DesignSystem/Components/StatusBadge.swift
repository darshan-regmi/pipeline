//
//  StatusBadge.swift
//  pipeline
//

import SwiftUI

/// A capsule that pairs the status color with an icon and a written label, so
/// status is never communicated by color alone.
struct StatusBadge: View {
    let state: RunState

    var body: some View {
        HStack(spacing: Theme.Spacing.xxs) {
            Image(systemName: state.symbolName)
                .font(.caption.weight(.bold))
                .foregroundStyle(state.tint)
                .accessibilityHidden(true)

            Text(state.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, Theme.Spacing.xs)
        .padding(.vertical, 5)
        .background(state.tint.opacity(0.14), in: Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "Status"))
        .accessibilityValue(state.title)
    }
}
