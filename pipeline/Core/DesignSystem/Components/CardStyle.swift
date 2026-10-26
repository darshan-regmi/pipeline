//
//  CardStyle.swift
//  pipeline
//

import SwiftUI

private struct CardStyle: ViewModifier {
    let padding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                Color.cardBackground,
                in: RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                    .strokeBorder(Color.cardBorder, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.035), radius: 10, x: 0, y: 4)
    }
}

extension View {
    /// Wraps content in the app's standard card surface.
    func card(padding: CGFloat = Theme.Spacing.md) -> some View {
        modifier(CardStyle(padding: padding))
    }
}
