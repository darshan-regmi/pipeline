//
//  InMemoryTokenStore.swift
//  pipeline
//

import Foundation

/// A non-persistent token store for SwiftUI previews, demo mode, and tests.
final class InMemoryTokenStore: TokenStoring {
    private(set) var token: String?

    init(token: String? = nil) {
        self.token = token
    }

    func load() throws -> String? {
        token
    }

    func save(_ token: String) throws {
        self.token = token
    }

    func delete() throws {
        token = nil
    }
}
