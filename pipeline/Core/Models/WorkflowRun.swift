//
//  WorkflowRun.swift
//  pipeline
//

import Foundation

/// One execution of a CI/CD workflow.
struct WorkflowRun: Identifiable, Hashable, Sendable {
    let id: Int
    let repositoryID: String
    let workflowName: String
    let branch: String
    let commitSHA: String
    let commitMessage: String
    let actor: String
    let event: String
    let status: RunStatus
    let conclusion: RunConclusion?
    let startedAt: Date
    let updatedAt: Date
    let htmlURL: URL

    var state: RunState {
        RunState(status: status, conclusion: conclusion)
    }

    var shortSHA: String {
        String(commitSHA.prefix(7))
    }

    var duration: TimeInterval? {
        guard status == .completed, updatedAt > startedAt else { return nil }
        return updatedAt.timeIntervalSince(startedAt)
    }
}
