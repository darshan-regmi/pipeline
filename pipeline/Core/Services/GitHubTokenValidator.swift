//
//  GitHubTokenValidator.swift
//  pipeline
//

import Foundation

enum GitHubTokenValidationError: LocalizedError, Equatable {
    case empty
    case invalidFormat

    var errorDescription: String? {
        switch self {
        case .empty:
            String(localized: "Enter a GitHub token to continue.")
        case .invalidFormat:
            String(localized: "That does not look like a GitHub token. Fine-grained tokens start with github_pat_.")
        }
    }
}

/// Performs local validation before a token is saved.
///
/// This is intentionally not a network check: the token format is the only
/// thing the app can verify without contacting GitHub. A real connection check
/// arrives with the GitHub service.
enum GitHubTokenValidator {
    private static let prefixes = [
        "ghp_",
        "github_pat_",
        "gho_",
        "ghu_",
        "ghs_",
        "ghr_"
    ]

    static func validate(_ token: String) throws {
        let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            throw GitHubTokenValidationError.empty
        }

        let hasValidPrefix = prefixes.contains { trimmed.hasPrefix($0) }
        let hasNoWhitespace = !trimmed.contains { $0.isWhitespace }

        guard hasValidPrefix, hasNoWhitespace, trimmed.count >= 20 else {
            throw GitHubTokenValidationError.invalidFormat
        }
    }
}
