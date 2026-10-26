//
//  Theme.swift
//  pipeline
//

import SwiftUI

/// Shared layout and color tokens.
///
/// Screens should use these values instead of magic numbers so spacing and
/// shape language stay consistent as the app grows.
enum Theme {
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum Radius {
        static let control: CGFloat = 12
        static let card: CGFloat = 18
    }

    static let accent = Color.accentColor
}

extension RunState {
    var tint: Color {
        switch self {
        case .success: .green
        case .failure: .red
        case .running: .blue
        case .queued: .orange
        case .cancelled: .gray
        case .skipped: .gray
        case .neutral: .gray
        case .timedOut: .orange
        case .unknown: .secondary
        }
    }
}
