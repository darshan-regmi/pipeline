# Roadmap

Pipeline is built in small milestones. Each milestone should leave the app in a
usable, tested state. Dates are targets, not commitments.

## Vision

Know if your builds are green before you open your laptop. Pipeline is a calm,
private, accessible status layer for the CI/CD systems developers already use,
starting with GitHub Actions.

## Milestones

| Milestone | Focus | Status |
| --- | --- | --- |
| 0.1 — UI prototype | Complete interface on sample data | Done (1 Nov 2026) |
| 0.2 — GitHub connection | Real authentication, repositories, and runs | Next |
| 0.3 — Local cache | Offline reads, last-known-good data, background refresh | Planned |
| 0.4 — Widget | Pinned repository status on the home screen | Planned |
| 0.5 — Notifications | Failure and recovery alerts | Planned |
| 1.0 — Release | Accessibility audit, localization, TestFlight, App Store | Planned |
| Later | Additional providers and platforms | Exploring |

## 0.1 — UI prototype (done)

**Goal:** validate the information architecture, visual language, and
accessibility patterns before investing in networking.

Delivered:

- Connect screen with token entry, local validation, Keychain storage, and demo
  mode.
- Dashboard with overall health, watched repositories, loading and error states,
  and pull-to-refresh.
- Repository picker with search and watch toggles.
- Repository detail with recent runs and watch, pin, and GitHub actions.
- Run detail with metadata and GitHub link.
- Settings with disconnect, delete-all, refresh information, and About.
- Design system, previews, 20 unit tests, and 1 UI test.

## 0.2 — GitHub connection (next)

**Goal:** replace sample data with real GitHub Actions data using a
fine-grained, read-only token.

Scope:

- `GitHubPipelineService` conforming to `PipelineServicing`.
- Authenticate with `GET /user` and surface a clear error for invalid or expired
  tokens.
- Fetch repositories with `GET /user/repos` and respect pagination.
- Fetch workflow runs with
  `GET /repos/{owner}/{repo}/actions/runs`.
- Map GitHub status and conclusion values into `RunState`.
- Handle rate limits, offline errors, and permission failures.
- Add network token validation to the connect flow.
- Add request/decoding tests with a stubbed `URLProtocol`.
- Never log the token or include it in error messages.

Acceptance criteria:

- A valid token shows the user's real repositories and latest runs.
- An invalid token shows an actionable error and is not saved.
- A repository with no runs shows an empty state, not an error.
- A failed refresh keeps the last successful data and shows an error banner.
- No request is made to a non-GitHub host with the token attached.

## 0.3 — Local cache

**Goal:** make the app fast and useful when offline or rate-limited.

Scope:

- Persist the latest repositories, runs, and fetch timestamp.
- Use SwiftData or a lightweight file cache; choose based on query needs.
- Show last-known-good data immediately on launch.
- Distinguish "fresh", "stale", and "never loaded" states.
- Add background refresh where iOS permits it.
- Prune old runs with a documented retention policy.
- Keep the cache scoped to the current account and clear it on disconnect.

Acceptance criteria:

- Cold launch with no network still shows the last successful snapshot.
- The UI clearly indicates when data is stale.
- Delete all local data removes the cache.
- Switching accounts cannot show the previous account's repositories.

## 0.4 — Widget

**Goal:** answer the status question from the home screen.

Scope:

- WidgetKit extension with small and medium families.
- App Group shared container for the snapshot.
- Show pinned repositories, or the overall health summary when none are pinned.
- Deep-link taps into the relevant repository or run.
- Respect the system timeline budget and avoid unbounded refreshes.
- Support light, dark, and tinted widget appearances.

Acceptance criteria:

- The widget shows the same status as the app for pinned repositories.
- Tapping a widget item opens the correct screen.
- No token is stored in the App Group container.
- The widget remains legible with large text and without color.

## 0.5 — Notifications

**Goal:** alert users to failures and recoveries without creating noise.

Scope:

- Opt-in notifications for failures and recoveries.
- Per-repository or global preferences.
- Quiet hours.
- Deep links into the failed run.
- Clear permission priming; never ask on first launch.

Acceptance criteria:

- Notifications are opt-in and easy to disable.
- A failure notification identifies the repository, workflow, and branch.
- Duplicate alerts are suppressed.
- No notification includes the token or private data in a lock-screen preview
  beyond what the user has allowed.

## 1.0 — Release

**Goal:** ship a polished, accessible, private app.

Scope:

- App icon and launch screen artwork.
- Full accessibility audit: VoiceOver, Dynamic Type, Increase Contrast, Reduce
  Motion, Voice Control, and color filters.
- Localization infrastructure and at least one non-English locale.
- Empty, loading, error, and offline states reviewed on every screen.
- Privacy manifest and App Store privacy details.
- TestFlight beta and crash-free session target.
- App Store metadata, screenshots, and support URL.
- Security review of token handling and redirect behavior.

Release blockers:

- No open critical accessibility issues.
- No token leakage in logs, analytics, or error messages.
- Delete all local data verified to remove every stored artifact.
- No placeholder assets.

## Later

Candidates, not commitments:

- GitLab CI, Bitrise, CircleCI, and Buildkite providers.
- iPad-specific layout and Mac companion app.
- Organization and team dashboards.
- Run log summaries with failure excerpts.
- Re-run failed jobs from the app.
- Home Screen and Lock Screen widget families.
- Shortcuts and App Intents.
- TestFlight/App Store release notifications.

## Non-goals

- A full GitHub client (issues, pull requests, code browsing).
- Editing workflow YAML from the phone.
- Hosting a Pipeline backend or user accounts.
- Selling or sharing data.
- Supporting every CI provider in version 1.

## How this roadmap changes

Update this file in the same pull request that changes scope or completes a
milestone. Keep completed items in the milestone and record notable changes in
[CHANGELOG.md](../CHANGELOG.md).
