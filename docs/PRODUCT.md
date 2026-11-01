# Product Overview

## The problem

CI/CD status is buried. To answer "did my build pass?" a developer usually
opens a laptop, signs in to GitHub, navigates to a repository, opens the Actions
tab, and finds the relevant run. That is too much friction for a question that
is asked many times a day.

Pipeline puts the answer on the iPhone home screen and one tap away in the app:
**the latest workflow result for the repositories you care about.**

## Target audience

- **Solo developers and small teams** who ship from GitHub Actions and want a
  fast personal status check.
- **Developers on the move** who want to know about a failure before opening a
  laptop.
- **Maintainers** who watch a handful of critical repositories rather than every
  project in an organization.

Pipeline is not a replacement for the GitHub app or a full Actions console. It
is a focused status layer.

## Value proposition

> Know if your builds are green before you open your laptop.

Pipeline is:

- **Glanceable** — one summary answers the health of every watched repository.
- **Focused** — only the repositories and workflows you choose.
- **Private** — the token stays in the iOS Keychain; no Pipeline account.
- **Accessible** — status is readable by everyone, including VoiceOver users and
  people who cannot distinguish red from green.

## Product principles

1. **Status first.** The answer to "are my builds green?" is visible without
   scrolling or tapping.
2. **Calm by default.** The app is quiet when everything is healthy. Failures
   earn attention; routine successes do not create noise.
3. **Never color alone.** Every status has an icon, a written label, and a
   VoiceOver value.
4. **Local and private.** No Pipeline account, no server, no analytics.
5. **Small surface area.** A short list of well-made screens beats a partial
   GitHub client.
6. **Fast to scan, safe to act.** Destructive actions are confirmed, and
   external links are explicit.

## Jobs to be done

- _When I push a commit,_ I want to know whether the build passed without
  opening GitHub on my laptop.
- _When a build fails,_ I want to see which repository and workflow failed and
  jump to the run.
- _When I only care about a few projects,_ I want to hide the rest.
- _When I check my home screen,_ I want the pinned repositories to show their
  latest status.
- _When I stop using the app,_ I want to remove my token and local data
  completely.

## Scope of the first release

### In scope

- Connect with a GitHub fine-grained personal access token.
- Dashboard with overall health and watched repository cards.
- Repository picker with search and watch toggles.
- Repository detail with recent runs.
- Run detail with metadata and a GitHub link.
- Settings with disconnect and delete-all.
- Widget with pinned repositories (planned milestone).
- VoiceOver, Dynamic Type, Reduce Motion, and non-color status.

### Out of scope

- Editing workflows, re-running jobs, or cancelling runs.
- A full log viewer.
- GitHub Issues, pull requests, or code browsing.
- Organization-wide administration.
- Multiple CI providers in the first release.
- Accounts, sync, or a Pipeline backend.
- Android or web clients.

## Screen inventory

| Screen | Purpose | Entry point |
| --- | --- | --- |
| Connect | Explain the app, accept a token, offer demo mode | First launch or after delete-all |
| Dashboard | Overall health and watched repositories | Dashboard tab |
| Repositories | Search and choose watched repositories | Repositories tab |
| Repository detail | Latest run and recent history | Tap a repository card |
| Run detail | Full metadata and GitHub link | Tap a run |
| Settings | Connection, data controls, refresh info | Settings tab |
| About | Prototype status and privacy summary | Settings → About |

## Key flows

### First run

1. User opens Pipeline.
2. The connect screen explains the value and the token requirements.
3. User creates a fine-grained, read-only token in GitHub.
4. User pastes it, optionally reveals it, and taps **Connect**.
5. The token is validated locally and saved to the Keychain.
6. The dashboard loads with the user's repositories.

A user can skip the token and choose **Explore with demo data** at any time.

### Daily check

1. Open the app or the widget.
2. Read the summary: all green, running, queued, or needs attention.
3. Scan watched repository cards.
4. Tap a failing repository to see recent runs.
5. Tap a run to inspect metadata or open it on GitHub.

### Leaving

1. Open Settings.
2. Tap **Disconnect** to remove the token, or **Delete all local data** to remove
   the token and preferences.
3. Confirm the destructive action.

## Success metrics

These are targets for the first release, not current measurements.

- **Time to answer:** a returning user can determine overall build health in
  under 5 seconds.
- **Setup completion:** a developer can connect a token in under 2 minutes.
- **Widget usefulness:** pinned repositories show a status no older than the
  system refresh budget allows.
- **Accessibility:** every status is understandable with VoiceOver and without
  color; no critical flow depends on a gesture or color.
- **Reliability:** a failed refresh never removes the last known good data.
- **Privacy:** no token leaves the device except in requests to GitHub.

## Open questions

- Should the dashboard group repositories by owner or by status?
- How much run history should be kept locally for offline viewing?
- Should failures notify by default, or should notifications be opt-in?
- Should the widget show one pinned repository or a compact list?
- Is a classic token worth supporting alongside fine-grained tokens?
- Should there be an iPad-specific layout or a Mac companion app?
- Which additional CI providers are worth supporting after GitHub?

## Naming

The product is **Pipeline**. The Xcode project, scheme, and bundle identifier
remain lowercase (`pipeline`, `com.shipyard.pipeline`) for continuity with the
template.
