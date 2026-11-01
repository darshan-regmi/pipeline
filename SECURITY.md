# Security Policy

Pipeline handles a GitHub personal access token, so security and privacy are
part of the product, not an afterthought.

## Supported versions

Pipeline is a pre-release prototype. There is no production release yet.

| Version | Supported |
| --- | --- |
| `main` (unreleased) | Best effort |
| `0.1.x` prototype | Best effort |

Security fixes are applied to `main`. Once the app ships, this table will list
supported release lines.

## Reporting a vulnerability

Please **do not open a public issue** for a suspected vulnerability.

- If the repository is hosted on GitHub, use **Security → Report a
  vulnerability** to open a private security advisory.
- If private advisories are unavailable, contact the maintainer through the
  private channel used to share this project.

Include:

- A description of the issue and its impact.
- Steps to reproduce, including the device and iOS version.
- Whether a real token was involved. **Never send a live token.**
- Any suggested mitigation.

You can expect an acknowledgement as soon as practical. This is a
maintainer-run project, so response times are best effort.

## Security design

### Token storage

- The token is stored as a generic password in the iOS Keychain.
- The accessibility class is `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`:
  the token is available to background refreshes after the first unlock and is
  not restored to another device from a backup.
- Tokens are never written to `UserDefaults`, source files, logs, or analytics.
- The connect screen uses `SecureField` by default and marks the field
  `.privacySensitive()`.
- **Disconnect** and **Delete all local data** remove the token from the
  Keychain.

### Token validation

The current build performs **local format validation only**. It checks the
GitHub token prefix, rejects whitespace, and enforces a minimum length. It does
not prove that the token is valid, unexpired, or correctly scoped. Network
validation arrives with the GitHub service milestone.

### Network behavior

The current prototype makes no network requests and has no third-party SDKs.
Tapping a GitHub link opens the system browser.

When networking is added:

- Requests must go directly to GitHub over HTTPS.
- The token must be sent only in the `Authorization` header to GitHub hosts.
- Redirects to non-GitHub hosts must not receive the token.
- Request and response bodies containing tokens must never be logged.
- Errors shown to users must not include the token.

### Local preferences

Watched repository IDs, pinned repository IDs, and demo mode are stored in
`UserDefaults`. These values are not secrets, but **Delete all local data**
removes them as well.

## Known limitations

- The prototype has not undergone an independent security audit.
- Tokens can be exposed by the iOS pasteboard, screenshots, or device backups
  outside the app's control. Use a fine-grained, read-only token.
- iOS may retain Keychain items after the app is uninstalled. Use **Delete all
  local data** before removing the app if you want to erase the token.
- There is no certificate pinning because there is no networking yet. Pinning
  will be evaluated when the GitHub client lands.
- Demo mode does not use a token, but the UI is otherwise identical, so do not
  treat a demo screenshot as proof that no token is stored.

## Guidance for contributors

- Never commit real tokens, `.env` files, or captured network traffic.
- Do not add analytics, crash reporting, or third-party SDKs without a privacy
  review and an update to [PRIVACY.md](PRIVACY.md).
- Treat all GitHub response data as untrusted input. Validate URLs before
  opening them and avoid injecting remote strings into logs.
- Add tests for authentication failures, malformed responses, and token
  redaction.
- Keep the token out of SwiftUI previews and test fixtures. Use
  `InMemoryTokenStore` in tests.
