//
//  View+Destinations.swift
//  pipeline
//

import SwiftUI

/// Central navigation values. Passing identifiers instead of model copies
/// means a detail screen always reads the latest state from `AppStore`.
enum AppRoute: Hashable {
    case repository(id: String)
    case run(repositoryID: String, runID: Int)
    case about
}

extension View {
    /// Registers the app's shared destinations. Apply once per navigation
    /// stack, on the stack's root content.
    func appDestinations() -> some View {
        navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .repository(let id):
                RepositoryDetailView(repositoryID: id)
            case .run(let repositoryID, let runID):
                RunDetailView(repositoryID: repositoryID, runID: runID)
            case .about:
                AboutView()
            }
        }
    }
}
