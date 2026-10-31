//
//  PipelineApp.swift
//  pipeline
//

import SwiftUI

@main
struct PipelineApp: App {
    @State private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
        }
    }
}
