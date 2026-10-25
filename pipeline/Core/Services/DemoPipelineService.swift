//
//  DemoPipelineService.swift
//  pipeline
//

import Foundation

/// Returns realistic sample data so the UI can be built and reviewed before
/// GitHub networking is connected.
struct DemoPipelineService: PipelineServicing {
    var delay: Duration = .milliseconds(450)

    func fetchRepositories() async throws -> [PipelineRepository] {
        try await Task.sleep(for: delay)
        return SampleData.repositories
    }
}
