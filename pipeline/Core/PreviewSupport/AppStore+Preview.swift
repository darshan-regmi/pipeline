//
//  AppStore+Preview.swift
//  pipeline
//

#if DEBUG
import Foundation

extension AppStore {
    /// A connected store with sample data for SwiftUI previews.
    static var preview: AppStore {
        makePreview(connected: true)
    }

    /// A disconnected store for the connect screen preview.
    static var previewDisconnected: AppStore {
        makePreview(connected: false)
    }

    private static func makePreview(connected: Bool) -> AppStore {
        let suiteName = "PipelinePreview-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let tokenStore = InMemoryTokenStore(
            token: connected ? "github_pat_preview_token_value" : nil
        )

        return AppStore(
            tokenStore: tokenStore,
            service: DemoPipelineService(delay: .zero),
            defaults: defaults,
            initialRepositories: connected ? SampleData.repositories : []
        )
    }
}
#endif
