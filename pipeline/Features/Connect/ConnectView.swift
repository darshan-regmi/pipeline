//
//  ConnectView.swift
//  pipeline
//

import SwiftUI

struct ConnectView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var token = ""
    @State private var isTokenVisible = false
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var showInstructions = false
    @FocusState private var isTokenFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                hero
                connectCard
                demoButton
                privacyNote
                instructionsCard
            }
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
            .padding(Theme.Spacing.lg)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .pipelineKeyboardBehavior()
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: errorMessage)
        .accessibilityIdentifier("connect.view")
    }

    private var hero: some View {
        VStack(spacing: Theme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.accent, Theme.accent.opacity(0.65)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)

                Image(systemName: "arrow.triangle.branch")
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)

            VStack(spacing: Theme.Spacing.xs) {
                Text("Pipeline")
                    .font(.largeTitle.weight(.bold))
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("connect.title")

                Text(String(localized: "Know if your builds are green before you open your laptop."))
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, Theme.Spacing.lg)
    }

    private var connectCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(String(localized: "Connect GitHub"))
                    .font(.title3.weight(.bold))

                Text(String(localized: "Paste a fine-grained personal access token with read-only access to Actions and metadata."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(String(localized: "Personal access token"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                HStack(spacing: Theme.Spacing.xs) {
                    tokenField

                    Button {
                        isTokenVisible.toggle()
                    } label: {
                        Image(systemName: isTokenVisible ? "eye.slash" : "eye")
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        isTokenVisible
                            ? String(localized: "Hide token")
                            : String(localized: "Show token")
                    )
                }
                .padding(.horizontal, Theme.Spacing.sm)
                .padding(.vertical, Theme.Spacing.xxs)
                .background(
                    Color.cardBackground,
                    in: RoundedRectangle(cornerRadius: Theme.Radius.control, style: .continuous)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.Radius.control, style: .continuous)
                        .strokeBorder(
                            isTokenFocused ? Theme.accent : Color.cardBorder,
                            lineWidth: isTokenFocused ? 2 : 1
                        )
                }
                .privacySensitive()
            }

            if let errorMessage {
                HStack(alignment: .top, spacing: Theme.Spacing.xs) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.red)
                        .accessibilityHidden(true)

                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.primary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(String(localized: "Error: \(errorMessage)"))
                .accessibilityIdentifier("connect.error")
            }

            Button(action: submit) {
                HStack(spacing: Theme.Spacing.xs) {
                    if isSubmitting {
                        ProgressView()
                            .controlSize(.small)
                    }

                    Text(String(localized: "Connect"))
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(trimmedToken.isEmpty || isSubmitting)
            .accessibilityHint(String(localized: "Saves the token securely and opens the dashboard"))
            .accessibilityIdentifier("connect.submitButton")
        }
        .card()
    }

    @ViewBuilder
    private var tokenField: some View {
        Group {
            if isTokenVisible {
                TextField(String(localized: "github_pat_…"), text: $token)
            } else {
                SecureField(String(localized: "github_pat_…"), text: $token)
            }
        }
        .textFieldStyle(.plain)
        .font(.body.monospaced())
        .focused($isTokenFocused)
        .submitLabel(.go)
        .onSubmit(submit)
        .accessibilityLabel(String(localized: "GitHub personal access token"))
        .accessibilityHint(String(localized: "Paste a fine-grained token with read-only Actions and Metadata permissions"))
        .accessibilityIdentifier("connect.tokenField")
    }

    private var privacyNote: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
            Image(systemName: "lock.shield.fill")
                .foregroundStyle(Theme.accent)
                .accessibilityHidden(true)

            Text(String(localized: "Your token is stored only in the iOS Keychain. Use a read-only token and disconnect at any time from Settings."))
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.xs)
        .accessibilityElement(children: .combine)
    }

    private var instructionsCard: some View {
        DisclosureGroup(isExpanded: $showInstructions) {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                instructionStep(
                    1,
                    String(localized: "Open GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens.")
                )
                instructionStep(
                    2,
                    String(localized: "Choose the repositories Pipeline should read.")
                )
                instructionStep(
                    3,
                    String(localized: "Set Actions and Metadata permissions to Read-only.")
                )
                instructionStep(
                    4,
                    String(localized: "Generate the token, then paste it above.")
                )

                Link(
                    String(localized: "Create a fine-grained token"),
                    destination: URL(string: "https://github.com/settings/personal-access-tokens/new")!
                )
                .font(.footnote.weight(.semibold))
                .padding(.top, Theme.Spacing.xxs)
            }
            .padding(.top, Theme.Spacing.sm)
        } label: {
            Label(
                String(localized: "How do I create a token?"),
                systemImage: "questionmark.circle"
            )
            .font(.subheadline.weight(.semibold))
        }
        .card()
    }

    private var demoButton: some View {
        Button {
            startDemo()
        } label: {
            Label(String(localized: "Explore with demo data"), systemImage: "sparkles")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .disabled(isSubmitting)
        .accessibilityHint(String(localized: "Opens the dashboard with sample repositories"))
        .accessibilityIdentifier("connect.demoButton")
    }

    private var trimmedToken: String {
        token.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func instructionStep(_ number: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: Theme.Spacing.xs) {
            Text("\(number)")
                .font(.caption2.weight(.bold))
                .foregroundStyle(Theme.accent)
                .frame(width: 22, height: 22)
                .background(Theme.accent.opacity(0.12), in: Circle())
                .accessibilityHidden(true)

            Text(text)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private func submit() {
        guard !isSubmitting, !trimmedToken.isEmpty else { return }

        isTokenFocused = false
        errorMessage = nil
        isSubmitting = true

        Task {
            defer { isSubmitting = false }

            do {
                try await store.connect(token: trimmedToken)
                token = ""
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func startDemo() {
        guard !isSubmitting else { return }

        isTokenFocused = false
        errorMessage = nil
        isSubmitting = true

        Task {
            await store.startDemo()
            isSubmitting = false
        }
    }
}

#if DEBUG
#Preview {
    ConnectView()
        .environment(AppStore.previewDisconnected)
}
#endif
