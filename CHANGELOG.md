# Changelog

All notable changes to Pipeline are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
for released builds.

## [Unreleased]

### Added

- Project documentation: product overview, architecture, design system,
  accessibility, roadmap, testing, contributing, security, and privacy guides.
- `.gitignore` for Xcode, Swift Package Manager, and CI artifacts.

### Fixed

- Added bottom scroll margins so the last Settings and Repositories rows can
  clear the floating tab bar.
- Moved the Run detail GitHub action above the metadata card so it is visible
  without scrolling.
- Kept the repository search field visible instead of letting it collapse.
- Let the dashboard summary and repository picker adapt at accessibility text
  sizes.

## [0.1.0] - 2026-11-01

First UI prototype. This build uses realistic sample data and does not contact
GitHub.

### Added

- Connect screen with a secure token field, show/hide control, local format
  validation, token creation instructions, and a demo mode.
- Keychain-backed token storage using
  `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`.
- Dashboard with overall health summary, watched repository cards, loading and
  error states, and pull-to-refresh.
- Repository picker with search, watch toggles, and pinned-to-widget status.
- Repository detail with latest run summary, recent runs, and watch, pin, and
  open-on-GitHub actions.
- Run detail with status hero, metadata, and GitHub link.
- Settings with connection status, disconnect, delete all local data, refresh
  information, and an About screen.
- Design system with spacing and radius tokens, cards, status glyphs and badges,
  empty states, error banners, and relative timestamps.
- Accessibility support: icon plus written label for every status, VoiceOver
  labels and hints, Dynamic Type-friendly layouts, 44-point controls, and
  Reduce Motion handling.
- 20 unit tests covering app state, run-state mapping, and token validation.
- 1 UI test covering the demo flow from launch to dashboard.
- App display name changed to Pipeline and accent color updated.

### Changed

- Replaced the Xcode template UI with a feature-organized SwiftUI app.
- Replaced the template's Core Data stack with Keychain and `UserDefaults`
  persistence.

### Removed

- Template `ContentView`, `Persistence` controller, app entry point, and the
  `pipeline.xcdatamodeld` Core Data model.
