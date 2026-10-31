//
//  AboutView.swift
//  pipeline
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                VStack(spacing: Theme.Spacing.sm) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Theme.accent, Theme.accent.opacity(0.65)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 84, height: 84)

                        Image(systemName: "arrow.triangle.branch")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .accessibilityHidden(true)

                    Text("Pipeline")
                        .font(.title2.weight(.bold))
                        .accessibilityAddTraits(.isHeader)

                    Text(String(localized: "CI/CD status at a glance."))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, Theme.Spacing.lg)

                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text(String(localized: "About this build"))
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)

                    Text(String(localized: "This is the UI prototype for Pipeline. It uses realistic sample workflow data while the GitHub API, local cache, and widget are built in later milestones."))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .card()

                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Label(String(localized: "Privacy"), systemImage: "lock.shield")
                        .font(.headline)

                    Text(String(localized: "Your GitHub token is stored in the iOS Keychain. Repository preferences stay on this device. This prototype does not send your token to a server or collect analytics."))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .card()

                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    LabeledContent(String(localized: "Version")) {
                        Text(appVersion)
                    }

                    LabeledContent(String(localized: "Made with")) {
                        Text(String(localized: "SwiftUI"))
                    }
                }
                .font(.subheadline)
                .card()

                Text(String(localized: "Built for developers who want to know if their builds are green before opening a laptop."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.lg)
            }
            .padding(Theme.Spacing.md)
            .padding(.bottom, Theme.Spacing.lg)
        }
        .background(Color.appBackground)
        .navigationTitle(String(localized: "About"))
        .pipelineNavigationBarInline()
        .accessibilityIdentifier("about.view")
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        AboutView()
    }
}
#endif
