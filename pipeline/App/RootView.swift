//
//  RootView.swift
//  pipeline
//

import SwiftUI

struct RootView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if store.isConnected {
                MainTabView()
            } else {
                ConnectView()
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: store.isConnected)
        .task {
            await store.loadInitialDataIfNeeded()
        }
    }
}
