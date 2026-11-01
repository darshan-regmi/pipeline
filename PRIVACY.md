# Privacy Policy

**Effective date:** 1 November 2026

Pipeline is a CI/CD status app for GitHub Actions. This policy describes the
current prototype. It will be updated before any App Store release or before
networking is enabled.

## Summary

**Pipeline does not collect, sell, or share personal data.** The current build
stores a GitHub token and a few preferences on your device. It does not contact
a Pipeline server and does not include analytics or advertising SDKs.

## Data stored on your device

| Data | Where it is stored | Why |
| --- | --- | --- |
| GitHub personal access token | iOS Keychain | Authenticate with GitHub |
| Demo mode preference | `UserDefaults` | Remember that you chose sample data |
| Watched repository IDs | `UserDefaults` | Restore your dashboard selection |
| Pinned repository IDs | `UserDefaults` | Remember widget selections |
| Transient screen state | Memory only | Loading, errors, and navigation |

The token is stored with the Keychain accessibility class
`kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`. It is not written to
`UserDefaults`, logs, or analytics.

## Network activity

The current prototype makes **no network requests**. All repository and workflow
data is generated locally from sample data.

Tapping **Open on GitHub**, a repository link, or the token creation link opens
the system browser. GitHub then receives the request under
[GitHub's privacy statement](https://docs.github.com/en/site-policy/privacy-policies/github-privacy-statement).
Pipeline does not control that website.

A future version will call the GitHub REST API directly from your device using
your token. No Pipeline-operated server is planned. That change will be reflected
here before release.

## Analytics, tracking, and advertising

- No analytics or telemetry.
- No crash reporting service.
- No advertising.
- No cross-app or cross-site tracking.
- No third-party SDKs.
- No cookies or device identifiers collected by Pipeline.

For the current build, the App Store privacy label would be **Data Not
Collected**.

## Data sharing

Pipeline does not share data with third parties. Data leaves the device only
when you explicitly open a GitHub link in the browser.

## Data retention and deletion

- **Disconnect** in Settings removes the token from the Keychain and clears the
  in-memory session.
- **Delete all local data** removes the token and all Pipeline preferences from
  the device.
- Deleting the app removes its `UserDefaults`. iOS may retain Keychain items
  after uninstalling an app, so use **Delete all local data** first if you want
  the token erased.

## Children

Pipeline is a developer tool and is not directed to children under 13. The app
does not knowingly collect data from anyone.

## Your choices

- Use **Explore with demo data** to browse the app without providing a token.
- Use a fine-grained, read-only GitHub token limited to the repositories you
  need.
- Disconnect or delete all local data at any time.

## Changes to this policy

Material changes will be documented in [CHANGELOG.md](CHANGELOG.md) and reflected
in the effective date above. A released version will include the policy in the
app and in the App Store privacy details.

## Contact

For privacy questions, contact the project maintainer through the private
channel used to share this project. For security issues, follow
[SECURITY.md](SECURITY.md).
