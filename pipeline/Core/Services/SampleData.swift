//
//  SampleData.swift
//  pipeline
//

import Foundation

/// Deterministic, realistic data for the UI prototype.
///
/// Timestamps are generated relative to the moment the data is loaded so the
/// dashboard always looks current. Replace this file with real API responses
/// once the GitHub service lands.
enum SampleData {
    static var repositories: [PipelineRepository] {
        let now = Date()

        func timestamp(minutesAgo: Int) -> Date {
            now.addingTimeInterval(-Double(minutesAgo) * 60)
        }

        func run(
            id: Int,
            repositoryID: String,
            workflow: String,
            branch: String,
            status: RunStatus,
            conclusion: RunConclusion?,
            minutesAgo: Int,
            duration: TimeInterval,
            actor: String = "darshanregmi",
            event: String = "push",
            sha: String,
            message: String
        ) -> WorkflowRun {
            let updatedAt = timestamp(minutesAgo: minutesAgo)
            return WorkflowRun(
                id: id,
                repositoryID: repositoryID,
                workflowName: workflow,
                branch: branch,
                commitSHA: sha,
                commitMessage: message,
                actor: actor,
                event: event,
                status: status,
                conclusion: conclusion,
                startedAt: updatedAt.addingTimeInterval(-duration),
                updatedAt: updatedAt,
                htmlURL: URL(string: "https://github.com/\(repositoryID)/actions/runs/\(id)")!
            )
        }

        let brainBaseID = "darshanregmi/brain-base"
        let pipelineID = "darshanregmi/pipeline"
        let portfolioID = "darshanregmi/portfolio"
        let workerID = "darshanregmi/cloudflare-worker"
        let habitID = "darshanregmi/habit-streak"
        let notesID = "darshanregmi/notes-api"

        let brainBase = PipelineRepository(
            id: brainBaseID,
            owner: "darshanregmi",
            name: "brain-base",
            provider: .github,
            defaultBranch: "main",
            isPrivate: true,
            htmlURL: URL(string: "https://github.com/\(brainBaseID)")!,
            sortOrder: 0,
            isWatched: true,
            isPinned: true,
            runs: [
                run(
                    id: 1001,
                    repositoryID: brainBaseID,
                    workflow: "Deploy to Production",
                    branch: "main",
                    status: .completed,
                    conclusion: .success,
                    minutesAgo: 4,
                    duration: 222,
                    sha: "9f3c1ab",
                    message: "Polish dashboard empty states"
                ),
                run(
                    id: 1002,
                    repositoryID: brainBaseID,
                    workflow: "CI",
                    branch: "main",
                    status: .completed,
                    conclusion: .success,
                    minutesAgo: 42,
                    duration: 138,
                    sha: "9f3c1ab",
                    message: "Polish dashboard empty states"
                ),
                run(
                    id: 1003,
                    repositoryID: brainBaseID,
                    workflow: "Deploy to Production",
                    branch: "main",
                    status: .completed,
                    conclusion: .failure,
                    minutesAgo: 1_460,
                    duration: 112,
                    sha: "2b8e0d4",
                    message: "Try edge runtime for API routes"
                ),
                run(
                    id: 1004,
                    repositoryID: brainBaseID,
                    workflow: "CI",
                    branch: "main",
                    status: .completed,
                    conclusion: .success,
                    minutesAgo: 1_475,
                    duration: 164,
                    sha: "2b8e0d4",
                    message: "Try edge runtime for API routes"
                )
            ]
        )

        let pipeline = PipelineRepository(
            id: pipelineID,
            owner: "darshanregmi",
            name: "pipeline",
            provider: .github,
            defaultBranch: "main",
            isPrivate: false,
            htmlURL: URL(string: "https://github.com/\(pipelineID)")!,
            sortOrder: 1,
            isWatched: true,
            isPinned: true,
            runs: [
                run(
                    id: 2001,
                    repositoryID: pipelineID,
                    workflow: "Build & Test",
                    branch: "main",
                    status: .completed,
                    conclusion: .failure,
                    minutesAgo: 11,
                    duration: 96,
                    sha: "c41d7e2",
                    message: "Add run status mapping"
                ),
                run(
                    id: 2002,
                    repositoryID: pipelineID,
                    workflow: "Build & Test",
                    branch: "main",
                    status: .completed,
                    conclusion: .success,
                    minutesAgo: 128,
                    duration: 102,
                    sha: "7a2f9c0",
                    message: "Build accessible status badges"
                ),
                run(
                    id: 2003,
                    repositoryID: pipelineID,
                    workflow: "Build & Test",
                    branch: "main",
                    status: .completed,
                    conclusion: .success,
                    minutesAgo: 1_590,
                    duration: 99,
                    sha: "1e6b8a3",
                    message: "Create repository picker"
                )
            ]
        )

        let portfolio = PipelineRepository(
            id: portfolioID,
            owner: "darshanregmi",
            name: "portfolio",
            provider: .github,
            defaultBranch: "main",
            isPrivate: false,
            htmlURL: URL(string: "https://github.com/\(portfolioID)")!,
            sortOrder: 2,
            isWatched: true,
            isPinned: false,
            runs: [
                run(
                    id: 3001,
                    repositoryID: portfolioID,
                    workflow: "Deploy Preview",
                    branch: "preview/dark-mode",
                    status: .inProgress,
                    conclusion: nil,
                    minutesAgo: 2,
                    duration: 120,
                    event: "pull_request",
                    sha: "5d9c2f1",
                    message: "Add dark mode tokens"
                ),
                run(
                    id: 3002,
                    repositoryID: portfolioID,
                    workflow: "Deploy Preview",
                    branch: "preview/dark-mode",
                    status: .completed,
                    conclusion: .success,
                    minutesAgo: 185,
                    duration: 148,
                    event: "pull_request",
                    sha: "a03f7b8",
                    message: "Tune project card spacing"
                ),
                run(
                    id: 3003,
                    repositoryID: portfolioID,
                    workflow: "Lighthouse",
                    branch: "main",
                    status: .completed,
                    conclusion: .success,
                    minutesAgo: 1_520,
                    duration: 204,
                    event: "schedule",
                    sha: "f8b1d60",
                    message: "Update project metadata"
                )
            ]
        )

        let worker = PipelineRepository(
            id: workerID,
            owner: "darshanregmi",
            name: "cloudflare-worker",
            provider: .github,
            defaultBranch: "main",
            isPrivate: true,
            htmlURL: URL(string: "https://github.com/\(workerID)")!,
            sortOrder: 3,
            isWatched: true,
            isPinned: false,
            runs: [
                run(
                    id: 4001,
                    repositoryID: workerID,
                    workflow: "Deploy Worker",
                    branch: "main",
                    status: .queued,
                    conclusion: nil,
                    minutesAgo: 1,
                    duration: 0,
                    sha: "e7a4b21",
                    message: "Handle webhook retries"
                ),
                run(
                    id: 4002,
                    repositoryID: workerID,
                    workflow: "Deploy Worker",
                    branch: "main",
                    status: .completed,
                    conclusion: .success,
                    minutesAgo: 312,
                    duration: 54,
                    sha: "b62d9e5",
                    message: "Add request logging"
                )
            ]
        )

        let habitStreak = PipelineRepository(
            id: habitID,
            owner: "darshanregmi",
            name: "habit-streak",
            provider: .github,
            defaultBranch: "main",
            isPrivate: false,
            htmlURL: URL(string: "https://github.com/\(habitID)")!,
            sortOrder: 4,
            isWatched: false,
            isPinned: false,
            runs: [
                run(
                    id: 5001,
                    repositoryID: habitID,
                    workflow: "iOS Tests",
                    branch: "main",
                    status: .completed,
                    conclusion: .success,
                    minutesAgo: 18,
                    duration: 287,
                    sha: "4c1e8f7",
                    message: "Fix streak calculation edge case"
                ),
                run(
                    id: 5002,
                    repositoryID: habitID,
                    workflow: "iOS Tests",
                    branch: "main",
                    status: .completed,
                    conclusion: .success,
                    minutesAgo: 2_890,
                    duration: 291,
                    sha: "0a9d5b2",
                    message: "Add widget snapshot tests"
                )
            ]
        )

        let notesAPI = PipelineRepository(
            id: notesID,
            owner: "darshanregmi",
            name: "notes-api",
            provider: .github,
            defaultBranch: "main",
            isPrivate: true,
            htmlURL: URL(string: "https://github.com/\(notesID)")!,
            sortOrder: 5,
            isWatched: false,
            isPinned: false,
            runs: [
                run(
                    id: 6001,
                    repositoryID: notesID,
                    workflow: "Test",
                    branch: "main",
                    status: .completed,
                    conclusion: .cancelled,
                    minutesAgo: 8_640,
                    duration: 38,
                    sha: "d3f0c14",
                    message: "Upgrade database driver"
                ),
                run(
                    id: 6002,
                    repositoryID: notesID,
                    workflow: "Test",
                    branch: "main",
                    status: .completed,
                    conclusion: .success,
                    minutesAgo: 10_080,
                    duration: 76,
                    sha: "d3f0c14",
                    message: "Upgrade database driver"
                )
            ]
        )

        return [
            brainBase,
            pipeline,
            portfolio,
            worker,
            habitStreak,
            notesAPI
        ]
    }
}
