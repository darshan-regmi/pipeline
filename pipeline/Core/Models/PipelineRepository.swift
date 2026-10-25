//
//  PipelineRepository.swift
//  pipeline
//

import Foundation

/// A repository that Pipeline can display.
struct PipelineRepository: Identifiable, Hashable, Sendable {
    let id: String
    let owner: String
    let name: String
    let provider: Provider
    let defaultBranch: String
    let isPrivate: Bool
    let htmlURL: URL
    let sortOrder: Int
    var isWatched: Bool
    var isPinned: Bool
    var runs: [WorkflowRun]

    var fullName: String {
        "\(owner)/\(name)"
    }

    var latestRun: WorkflowRun? {
        recentRuns.first
    }

    /// Runs sorted newest first. The API does not guarantee ordering, so the
    /// model normalizes it for every screen.
    var recentRuns: [WorkflowRun] {
        runs.sorted { $0.updatedAt > $1.updatedAt }
    }
}
