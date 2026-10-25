//
//  Provider.swift
//  pipeline
//

import Foundation

/// A source of CI/CD workflow data.
///
/// Version 1 supports GitHub only. The enum keeps provider-specific UI and
/// service code from spreading string literals throughout the app.
enum Provider: String, Codable, CaseIterable, Identifiable, Sendable {
    case github

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .github: "GitHub"
        }
    }

    var symbolName: String {
        switch self {
        case .github: "chevron.left.forwardslash.chevron.right"
        }
    }
}
