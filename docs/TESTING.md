# Testing

## Current status

Pipeline has 20 unit tests and 1 UI test. All tests pass on the iPhone 18 Pro
simulator with Xcode 27.2.

| Suite | Framework | Tests | Focus |
| --- | --- | --- | --- |
| `AppStoreTests` | Swift Testing | 7 | Connection, demo mode, preferences, delete-all, summary |
| `RunStateTests` | Swift Testing | 7 | GitHub status/conclusion mapping and grouping helpers |
| `GitHubTokenValidatorTests` | Swift Testing | 6 | Token format validation and trimming |
| `pipelineUITests` | XCTest | 1 | Demo flow from launch to dashboard |

## Running tests

```bash
xcodebuild test \
  -project pipeline.xcodeproj \
  -scheme pipeline \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' \
  -derivedDataPath .derivedData \
  CODE_SIGNING_ALLOWED=NO
```

To run a single suite from Xcode, use the Test navigator or:

```bash
xcodebuild test \
  -project pipeline.xcodeproj \
  -scheme pipeline \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' \
  -only-testing:pipelineTests/AppStoreTests
```

To inspect results, open the generated `.xcresult` bundle in Xcode. The
`.derivedData` directory is ignored by git.

## Continuous integration

`.github/workflows/ci.yml` runs the same suite on every push to `main` and on
every pull request. The runner does three things the local command does not
need to:

1. Selects the newest Xcode installed on the image.
2. Discovers an available iPhone simulator by UDID, newest iOS runtime first,
   instead of hard-coding a device name that may not ship with the runner.
3. Uploads `TestResults/ci.xcresult` and the build log as a workflow artifact
   when the job fails.

The scheme is committed at
`pipeline.xcodeproj/xcshareddata/xcschemes/pipeline.xcscheme`. Without it a
fresh checkout has no scheme to build — user schemes live in `xcuserdata/`,
which is git-ignored.

### Current limitation: the runner cannot open this project

This project uses Xcode 27's folder-based format — a JSON `project.xcproj`
with no `project.pbxproj`. Xcode 26 and earlier expect the classic file and
fail with `missing its project.pbxproj file`.

GitHub's newest hosted image (`macos-26-arm64`) ships Xcode 26.6, and there is
no `macos-27` image yet. The workflow therefore detects the mismatch and skips
the test step with a `::notice` annotation instead of failing red every push.
It will start enforcing the suite automatically on the first image that ships
Xcode 27.

To make CI run today, either:

- **lower the project to a shipping toolchain** — target iOS 26 and keep the
  classic project format, which also makes the app installable on real devices
  and buildable by contributors; or
- **run on a self-hosted runner** with Xcode 27 installed.

## Unit tests

Unit tests use [Swift Testing](https://developer.apple.com/xcode/swift-testing/):

```swift
import Testing
@testable import pipeline

@MainActor
struct ExampleTests {
    @Test func stateIsMappedCorrectly() {
        #expect(RunState(status: .completed, conclusion: .success) == .success)
    }
}
```

Guidelines:

- Mark suites `@MainActor` when they touch `AppStore`.
- Inject `InMemoryTokenStore`, a stub `PipelineServicing`, and an isolated
  `UserDefaults` suite.
- Use a unique suite name per test and remove the persistent domain in a
  `defer`.
- Never call the real network or the real Keychain in a unit test.
- Test behavior, not private implementation details.
- Keep sample data deterministic; `SampleData` computes timestamps relative to
  the current time, so assert on counts and states rather than exact dates.

### AppStore coverage

`AppStoreTests` verifies:

- A valid token is saved and repositories load.
- An invalid token is rejected and not saved.
- Demo mode survives a new store instance.
- Watch and pin preferences persist.
- Pinning requires watching.
- Delete-all clears the token and all preference keys.
- Sample data produces the expected failure summary.

Not yet covered:

- Refresh failure retaining previous data.
- Concurrent refresh guards.
- Disconnect leaving watch preferences intact.
- Keychain errors.
- Token validation with a network response (not implemented).

### RunState coverage

`RunStateTests` verifies the full mapping:

- Completed success, failure, action required, and startup failure.
- Cancelled and timed out.
- In-progress, queued, waiting, requested, and pending.
- Completed without a conclusion and stale runs.
- `isFailure`, `isActive`, and `isHealthy` groupings.

### Token validator coverage

`GitHubTokenValidatorTests` verifies:

- Fine-grained and classic token prefixes are accepted.
- Surrounding whitespace is trimmed.
- Empty and whitespace-only input is rejected.
- Unknown prefixes are rejected.
- Short tokens are rejected.
- Internal whitespace is rejected.

This is format validation only. It does not prove a token is valid.

## UI tests

UI tests use XCTest and accessibility identifiers.

The current test handles the fact that the simulator can retain app data between
runs:

1. Launch the app.
2. If the dashboard is already showing, open Settings and use **Delete all local
   data** to return to a clean state.
3. Tap **Explore with demo data**.
4. Assert the failure summary appears.
5. Assert all three tabs exist.

Guidelines:

- Prefer accessibility identifiers (`dashboard.repository.<id>`,
  `settings.deleteAllButton`) over visible text.
- Clear state through the real UI, not a launch argument, so the test exercises
  the same path a user would.
- Use `waitForExistence` with a timeout instead of fixed sleeps.
- Keep UI tests focused on navigation and critical flows, not visual details.
- Do not depend on animation timing.

## Manual QA checklist

Run this before merging a change that affects layout or state.

### Screens

- [ ] Connect: empty state, invalid token error, show/hide, demo mode.
- [ ] Dashboard: healthy, failure, running, queued, empty watch list, loading,
      refresh error.
- [ ] Repositories: search, no results, watch on/off, pinned indicator.
- [ ] Repository detail: latest run, no runs, missing repository.
- [ ] Run detail: success, failure, running, missing run, GitHub link.
- [ ] Settings: disconnect confirmation, delete-all confirmation, About.
- [ ] About: version and privacy copy.

### Appearance

- [ ] Light mode.
- [ ] Dark mode.
- [ ] Largest Dynamic Type size (an initial pass was done on iPhone 18 Pro;
      repeat on all screens before release).
- [ ] Increase Contrast.
- [ ] Reduce Motion.
- [ ] Landscape orientation.

### Accessibility

- [ ] VoiceOver reads status for the summary, repository cards, and run rows.
- [ ] Every button has a label.
- [ ] Rows are single VoiceOver stops.
- [ ] Focus order matches the visual order.
- [ ] Connect errors are discoverable.
- [ ] No status relies on color alone.

See [ACCESSIBILITY.md](ACCESSIBILITY.md) for the full checklist.

### Data and privacy

- [ ] Disconnect removes the token.
- [ ] Delete all local data removes the token and preferences.
- [ ] No token appears in logs or screenshots.
- [ ] Demo mode works with no token stored.

## Adding tests

### New store behavior

1. Add a test to `AppStoreTests`.
2. Create an isolated `TestDefaults`.
3. Inject an `InMemoryTokenStore` and a stub service.
4. Assert both in-memory state and persisted state.
5. Clean up the defaults domain.

### New status mapping

1. Add a case to `RunStateTests`.
2. Assert the mapping and any grouping helper.
3. Add the state to the design-system status table.

### New network code

1. Use a custom `URLProtocol` stub; never hit GitHub.
2. Test success, non-2xx responses, malformed JSON, and timeouts.
3. Assert that the token appears only in the expected authorization header and
   never in error descriptions.
4. Add a test for pagination and rate-limit responses.

### New UI flow

1. Add a stable accessibility identifier to each element the test needs.
2. Write the test in `pipelineUITests`.
3. Handle a dirty simulator state by clearing through Settings.
4. Keep assertions on existence and navigation, not pixel values.

## Continuous integration

A minimal CI job can run:

```bash
xcodebuild test \
  -project pipeline.xcodeproj \
  -scheme pipeline \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' \
  -derivedDataPath .derivedData \
  -resultBundlePath TestResults/Pipeline.xcresult \
  CODE_SIGNING_ALLOWED=NO
```

Upload `TestResults/Pipeline.xcresult` as an artifact. No CI configuration is
checked in yet.

## Known gaps

- No snapshot or visual regression tests.
- No coverage target or coverage reporting.
- Only one UI flow is automated.
- Error, loading, and empty states are not automated.
- Accessibility is checked manually, not in CI.
- Network behavior will need URL protocol stubs when the GitHub service lands.
- Performance and launch-time tests are not defined.
