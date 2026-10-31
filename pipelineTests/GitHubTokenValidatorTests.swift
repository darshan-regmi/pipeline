//
//  GitHubTokenValidatorTests.swift
//  pipelineTests
//

import Testing
@testable import pipeline

@MainActor
struct GitHubTokenValidatorTests {
    @Test func acceptsFineGrainedAndClassicTokens() throws {
        try GitHubTokenValidator.validate("github_pat_" + String(repeating: "a", count: 30))
        try GitHubTokenValidator.validate("ghp_" + String(repeating: "b", count: 36))
    }

    @Test func trimsSurroundingWhitespace() throws {
        try GitHubTokenValidator.validate("  github_pat_\(String(repeating: "c", count: 30))  ")
    }

    @Test func rejectsEmptyInput() {
        #expect(throws: GitHubTokenValidationError.empty) {
            try GitHubTokenValidator.validate("")
        }
        #expect(throws: GitHubTokenValidationError.empty) {
            try GitHubTokenValidator.validate("   \n")
        }
    }

    @Test func rejectsUnknownPrefixes() {
        #expect(throws: GitHubTokenValidationError.invalidFormat) {
            try GitHubTokenValidator.validate("sk_live_" + String(repeating: "d", count: 30))
        }
    }

    @Test func rejectsShortTokens() {
        #expect(throws: GitHubTokenValidationError.invalidFormat) {
            try GitHubTokenValidator.validate("ghp_short")
        }
    }

    @Test func rejectsTokensWithWhitespace() {
        #expect(throws: GitHubTokenValidationError.invalidFormat) {
            try GitHubTokenValidator.validate("github_pat_\(String(repeating: "e", count: 15)) \(String(repeating: "f", count: 15))")
        }
    }
}
