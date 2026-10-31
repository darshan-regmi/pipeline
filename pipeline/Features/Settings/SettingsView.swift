//
//  SettingsView.swift
//  pipeline
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppStore.self) private var store

    @State private var showDisconnectConfirmation = false
    @State private var showDeleteAllConfirmation = false

    var body: some View {
        List {
            Section {
                LabeledContent(String(localized: "Status")) {
                    Text(connectionStatus)
                }

                if let token = store.token {
                    HStack {
                        Text(String(localized: "Token"))
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text(maskedToken(token))
                            .font(.body.monospaced())
                            .accessibilityLabel(
                                String(localized: "Saved token ending in \(String(token.suffix(4)))")
                            )
                    }
                }

                Button(String(localized: "Disconnect"), role: .destructive) {
                    showDisconnectConfirmation = true
                }
                .accessibilityIdentifier("settings.disconnectButton")
            } header: {
                Text(String(localized: "Connection"))
            } footer: {
                Text(String(localized: "Disconnecting removes the token from the Keychain. Repository preferences stay on this device."))
            }

            Section {
                Label(
                    String(localized: "Pull down on the dashboard or open the app to check for new runs."),
                    systemImage: "arrow.clockwise"
                )
                .font(.subheadline)

                Label(
                    String(localized: "Widget refreshes are scheduled by iOS and may be delayed."),
                    systemImage: "square.grid.2x2"
                )
                .font(.subheadline)
            } header: {
                Text(String(localized: "Refresh"))
            }

            Section {
                Button(String(localized: "Delete all local data"), role: .destructive) {
                    showDeleteAllConfirmation = true
                }
                .accessibilityIdentifier("settings.deleteAllButton")
            } header: {
                Text(String(localized: "Data"))
            } footer: {
                Text(String(localized: "Removes the saved token, watched repositories, and pins from this device. This cannot be undone."))
            }

            Section {
                NavigationLink(value: AppRoute.about) {
                    Label(String(localized: "About Pipeline"), systemImage: "info.circle")
                }

                LabeledContent(String(localized: "Version")) {
                    Text(appVersion)
                }
            } header: {
                Text(String(localized: "About"))
            }
        }
        .contentMargins(.bottom, 96, for: .scrollContent)
        .navigationTitle(String(localized: "Settings"))
        .appDestinations()
        .confirmationDialog(
            String(localized: "Disconnect GitHub?"),
            isPresented: $showDisconnectConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "Disconnect"), role: .destructive) {
                store.disconnect()
            }
        } message: {
            Text(String(localized: "Your saved token will be removed from the Keychain."))
        }
        .confirmationDialog(
            String(localized: "Delete all local data?"),
            isPresented: $showDeleteAllConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "Delete Everything"), role: .destructive) {
                store.deleteAllData()
            }
        } message: {
            Text(String(localized: "This removes your token, preferences, and cached status from this device. It cannot be undone."))
        }
    }

    private var connectionStatus: String {
        if store.isDemoMode {
            String(localized: "Demo mode")
        } else if store.token != nil {
            String(localized: "GitHub token saved")
        } else {
            String(localized: "Not connected")
        }
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }

    private func maskedToken(_ token: String) -> String {
        "•••• \(token.suffix(4))"
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        SettingsView()
            .appDestinations()
    }
    .environment(AppStore.preview)
}
#endif
