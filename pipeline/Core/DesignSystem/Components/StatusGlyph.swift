//
//  StatusGlyph.swift
//  pipeline
//

import SwiftUI

/// A colored status icon. The accompanying text is always present elsewhere;
/// this view is decorative for VoiceOver.
struct StatusGlyph: View {
    let state: RunState
    var size: CGFloat = 36

    var body: some View {
        Image(systemName: state.symbolName)
            .font(.system(size: size * 0.4, weight: .bold))
            .foregroundStyle(state.tint)
            .frame(width: size, height: size)
            .background(state.tint.opacity(0.13), in: Circle())
            .accessibilityHidden(true)
    }
}
