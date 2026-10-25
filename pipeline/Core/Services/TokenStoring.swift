//
//  TokenStoring.swift
//  pipeline
//

import Foundation

/// Secure storage for the GitHub token.
///
/// The token deliberately lives outside the app database so it is never
/// included in a backup, widget snapshot, or debug export.
protocol TokenStoring {
    func load() throws -> String?
    func save(_ token: String) throws
    func delete() throws
}
