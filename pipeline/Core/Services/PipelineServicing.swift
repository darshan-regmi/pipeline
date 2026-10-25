//
//  PipelineServicing.swift
//  pipeline
//

import Foundation

/// Supplies repository and workflow-run data to the app.
///
/// The UI only depends on this protocol. A GitHub implementation can replace
/// the demo implementation without touching any screen.
protocol PipelineServicing {
    func fetchRepositories() async throws -> [PipelineRepository]
}
