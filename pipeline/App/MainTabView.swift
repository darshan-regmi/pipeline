//
//  MainTabView.swift
//  pipeline
//

import SwiftUI

struct MainTabView: View {
    @State private var selection: AppTab = .dashboard

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "rectangle.grid.2x2")
            }
            .tag(AppTab.dashboard)

            NavigationStack {
                RepositoryListView()
            }
            .tabItem {
                Label("Repositories", systemImage: "folder")
            }
            .tag(AppTab.repositories)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(AppTab.settings)
        }
        .tint(Theme.accent)
    }
}

private enum AppTab: Hashable {
    case dashboard
    case repositories
    case settings
}
