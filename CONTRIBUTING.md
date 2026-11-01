# Contributing to Pipeline

Thanks for helping improve Pipeline. This document covers local setup, coding
conventions, and the pull request checklist.

## Before you start

Pipeline is currently a **UI prototype**. GitHub networking, caching, and the
widget are planned but not implemented. Check [docs/ROADMAP.md](docs/ROADMAP.md)
before starting a large change so the work lands in the right milestone.

- Small fixes and documentation improvements can go straight to a pull request.
- For new screens, services, or architectural changes, open an issue first.
- Never commit a real GitHub token, `.env` file, or captured user data.

## Local setup

1. Install Xcode 27.2 or newer.
2. Clone the repository and open `pipeline.xcodeproj`.
3. Select the `pipeline` scheme and an iPhone simulator.
4. Build and run, then choose **Explore with demo data**.

There are no package dependencies, code-generation steps, or local services to
start.

## Branch and commit conventions

- Branch from `main` using a short descriptive name, for example
  `feature/github-service` or `fix/tab-bar-clearance`.
- Write commit messages in the imperative mood and keep the subject under about
  72 characters.
- Scoped prefixes are encouraged but not enforced:
  - `feat(dashboard): add failure summary`
  - `fix(settings): keep last row above tab bar`
  - `docs(architecture): describe token storage`
  - `test(app-store): cover disconnect`
- Keep unrelated changes out of the same pull request.

## Coding conventions

### Architecture

- Views live in `Features/<FeatureName>/`.
- Domain types live in `Core/Models/`.
- Data access and app state live in `Core/Services/`.
- Reusable visual components live in `Core/DesignSystem/`.
- A view must not call `URLSession`, Keychain APIs, or `UserDefaults` directly.
  Route that work through a service or `AppStore`.

### SwiftUI and state

- Use `@Observable` and inject the store through the SwiftUI environment.
- The project enables `SWIFT_DEFAULT_ACTOR_ISOLATION=MainActor`; keep UI and
  store code main-actor isolated.
- Mark injected dependencies with `@ObservationIgnored` when they should not
  trigger view updates.
- Use optional dependency injection in initializers to avoid default-argument
  actor-isolation warnings.
- Keep computed state (for example `watchedRepositories`) in the store rather
  than duplicating it across views.

### Design system

- Use `Theme.Spacing` and `Theme.Radius` instead of magic numbers.
- Reuse components from `Core/DesignSystem/Components/` before creating new
  ones.
- Use semantic colors (`.primary`, `.secondary`, `Color.appBackground`,
  `Color.cardBackground`) so dark mode works automatically.
- Keep status presentation consistent by going through `RunState`.

### Accessibility

Accessibility is a requirement, not a follow-up task.

- Every status needs an icon, a written label, and a VoiceOver value. Never use
  color alone.
- Add an accessibility label when the visible text is not sufficient, and a hint
  when the result of an action is not obvious.
- Keep interactive controls at least 44 × 44 points.
- Use system text styles and avoid fixed heights so Dynamic Type can grow.
- Respect Reduce Motion for non-essential animation.
- Add stable accessibility identifiers for elements used by UI tests.

See [docs/ACCESSIBILITY.md](docs/ACCESSIBILITY.md) for the full checklist.

### Strings and localization

- Wrap user-facing strings in `String(localized:)` and add a `comment:` when the
  meaning depends on context.
- Do not concatenate localized sentences; use interpolation inside the
  localized string.
- Keep developer-facing comments in English.

### Tests

- Add unit tests for new state transitions, validation, and persistence rules.
- Add a UI test when a change affects a critical flow or navigation path.
- Unit tests use Swift Testing (`import Testing`) and UI tests use XCTest.
- Never use the network in tests. Inject a stub `PipelineServicing`
  implementation.
- Use an isolated `UserDefaults` suite and clean it up when the test finishes.

## Adding a screen

1. Create `pipeline/Features/<Name>/<Name>View.swift`.
2. Add a route to `AppRoute` in `Core/Extensions/View+Destinations.swift` if the
   screen is pushed from another screen.
3. Register the destination in `appDestinations()`.
4. Add a `#Preview` using `AppStore.preview` or `AppStore.previewDisconnected`.
5. Add accessibility labels, hints, and identifiers.
6. Add tests if the screen changes state or guards a flow.

## Adding a data source

1. Conform to `PipelineServicing` in `Core/Services/`.
2. Map API responses into `PipelineRepository` and `WorkflowRun`; do not expose
   transport types to views.
3. Inject the implementation in `AppStore.init` and keep the demo service as
   the default for previews and tests.
4. Add request and decoding tests using a stubbed URL protocol.

## Pull request checklist

- [ ] The app builds without warnings.
- [ ] Unit tests pass locally.
- [ ] The UI test passes locally.
- [ ] New behavior has tests.
- [ ] New strings are localized.
- [ ] VoiceOver labels and Dynamic Type were considered.
- [ ] Light and dark mode were checked.
- [ ] Documentation was updated when behavior or architecture changed.
- [ ] No secrets, credentials, or personal data are included.
- [ ] The pull request description explains the change and how to verify it.

## Reporting bugs

Include the Xcode version, simulator or device model, iOS version, steps to
reproduce, and whether the app was in demo mode. For security issues, follow
[SECURITY.md](SECURITY.md) instead of opening a public issue.
