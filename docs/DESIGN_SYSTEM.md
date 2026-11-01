# Design System

Pipeline uses a small, deliberate design system. The goal is a calm,
developer-tool interface where status is the loudest thing on screen and
everything else stays out of the way.

## Principles

1. **Status first.** The overall health summary is the first meaningful content
   on the dashboard.
2. **Calm surfaces.** Grouped backgrounds, soft cards, and restrained color keep
   failures meaningful.
3. **Semantic color.** Colors come from system semantics or named tokens so light
   mode, dark mode, and increased contrast work without per-screen overrides.
4. **Accessible by default.** Every status includes an icon and a written label.
   Components own their VoiceOver representation.
5. **One shape language.** Cards, controls, and badges share a small set of radii
   and spacing values.

## Tokens

All tokens live in `pipeline/Core/DesignSystem/Theme.swift` and
`pipeline/Core/Extensions/Color+App.swift`.

### Spacing

| Token | Value | Typical use |
| --- | --- | --- |
| `Theme.Spacing.xxs` | 4 pt | Icon-to-text gaps, tight metadata |
| `Theme.Spacing.xs` | 8 pt | Badge padding, inline groups |
| `Theme.Spacing.sm` | 12 pt | Row spacing, compact stacks |
| `Theme.Spacing.md` | 16 pt | Screen padding, card padding |
| `Theme.Spacing.lg` | 24 pt | Section spacing, card interiors |
| `Theme.Spacing.xl` | 32 pt | Empty states, onboarding rhythm |

### Radius

| Token | Value | Use |
| --- | --- | --- |
| `Theme.Radius.control` | 12 pt | Text fields, banners, controls |
| `Theme.Radius.card` | 18 pt | Cards and grouped surfaces |
| `Theme.Radius.card + 4` | 22 pt | Hero and summary cards |

### Color

| Token | Source | Use |
| --- | --- | --- |
| `Theme.accent` | `AccentColor` asset | Primary actions, selection, links |
| `Color.appBackground` | `systemGroupedBackground` | Page background |
| `Color.cardBackground` | `secondarySystemGroupedBackground` | Card surfaces |
| `Color.cardBorder` | `primary` at 8% | Hairline card outline |
| `RunState.tint` | System colors | Status glyphs and badge fills |

The accent is indigo: approximately `#4F46E5` in light mode and `#818CF8` in
dark mode. Both variants are defined in the asset catalog, so no manual color
scheme branching is needed.

Status tints:

| State | Tint |
| --- | --- |
| Success | Green |
| Failure | Red |
| Running | Blue |
| Queued | Orange |
| Timed out | Orange |
| Cancelled | Gray |
| Skipped | Gray |
| Neutral | Gray |
| Unknown | Secondary |

Tints are used as accents behind an icon and as a low-opacity badge fill. Text
always uses `.primary` or `.secondary`, never the tint, so contrast does not
depend on the status color.

### Typography

Pipeline uses the system font and Dynamic Type text styles exclusively.

| Style | Use |
| --- | --- |
| `.largeTitle.weight(.bold)` | App title on connect |
| `.title2.weight(.bold)` | Run status hero, About title |
| `.title3.weight(.bold)` | Summary title, card titles |
| `.headline` | Section headings, repository names |
| `.subheadline` | Metadata, descriptions, rows |
| `.caption` / `.caption2` | Timestamps, SHA, secondary metadata |
| `.body.monospaced()` | Token field |

Rules:

- Use relative text styles, not fixed point sizes, for anything that carries
  meaning. Icon-only glyphs may use fixed sizes because they scale with the
  surrounding layout and are decorative.
- Avoid fixed row heights; let text wrap or truncate intentionally.
- Use `.lineLimit(1)` only for non-critical metadata such as workflow names,
  branches, and commit messages.
- Use `.fixedSize(horizontal: false, vertical: true)` for explanatory copy that
  must not be truncated.

## Components

All reusable components live in `Core/DesignSystem/Components/`.

| Component | Responsibility |
| --- | --- |
| `card(padding:)` | Standard rounded surface with border and soft shadow |
| `StatusGlyph` | Decorative circular status icon; hidden from VoiceOver |
| `StatusBadge` | Capsule with icon, label, and VoiceOver status value |
| `SummaryCard` | Dashboard health summary with last-refresh metadata |
| `RepositoryCard` | Watched repository with latest workflow and status |
| `RunRow` | Compact run row with workflow, SHA, branch, time, and duration |
| `EmptyStateView` | Icon, title, message, and optional action |
| `ErrorBanner` | Dismissible inline error surface |
| `RelativeTimeText` | Self-updating relative timestamp |

### Card

```swift
VStack { ... }
    .card()
```

- Background: `Color.cardBackground`
- Border: 1 pt `Color.cardBorder`
- Radius: `Theme.Radius.card`
- Shadow: black at 3.5%, radius 10, y-offset 4
- Default padding: `Theme.Spacing.md`

Use `.card(padding: 0)` for a list of rows that manage their own padding, as in
the recent-runs section.

### StatusGlyph and StatusBadge

`StatusGlyph` is decorative. It always appears next to a written status
elsewhere, or inside a row whose combined accessibility label includes the
status. It is marked `.accessibilityHidden(true)`.

`StatusBadge` is the accessible status primitive:

- Icon (hidden from VoiceOver)
- Written label
- Accessibility label: "Status"
- Accessibility value: the localized state title

Never introduce a status treatment that drops either the icon or the label.

### SummaryCard

The summary card uses a subtle gradient from the status tint to the card
background. It combines its children into one VoiceOver element with a sentence
that includes the title, message, and last refresh time.

At accessibility text sizes, the status glyph moves above the text and the
refresh footer stacks vertically. This gives the title and message the full card
width instead of squeezing them into a narrow column.

### RepositoryCard and RunRow

Both rows combine their children into a single accessibility element and
provide a custom label containing the important metadata. This avoids a long
series of fragmented VoiceOver stops.

In the repository picker, accessibility text sizes move the watch toggle below
the repository name and show a visible "Watch" label. At standard sizes the
toggle stays on the trailing edge and relies on its accessibility label.

### EmptyStateView

Use for "no repositories watched", "no runs yet", and missing detail screens.
Provide a recovery action when one exists. Keep the message specific and
actionable.

### ErrorBanner

Use for refresh failures on the dashboard. The banner combines its content into
one element labeled "Error: …" and provides a 44 × 44 dismiss button. The last
successful data remains visible underneath.

## Layout rules

- Screen horizontal padding: `Theme.Spacing.md` (16 pt) on tab screens; the
  connect flow uses `Theme.Spacing.lg` (24 pt).
- Section spacing: `Theme.Spacing.lg` (24 pt).
- Card internal spacing: `Theme.Spacing.md` to `Theme.Spacing.lg`.
- Content max width on connect: 560 pt, centered.
- Floating tab bar clearance: 96 pt of bottom padding on scrollable content.
  Lists use `.contentMargins(.bottom, 96, for: .scrollContent)`.
- Controls: at least 44 × 44 pt. Icon-only toolbar buttons rely on the system
  hit target and add explicit frames where needed.
- Primary actions use `.borderedProminent` with `.controlSize(.large)`.
- Secondary actions use `.bordered`; destructive actions use the destructive
  role and a confirmation dialog.

## Status mapping

`RunState` is the single source of truth for how a GitHub status and conclusion
become UI.

| RunState | Icon | Tint | Written label |
| --- | --- | --- | --- |
| Success | `checkmark` | Green | Success |
| Failure | `xmark` | Red | Failure |
| Running | `arrow.triangle.2.circlepath` | Blue | Running |
| Queued | `clock` | Orange | Queued |
| Cancelled | `minus` | Gray | Cancelled |
| Skipped | `forward.end` | Gray | Skipped |
| Neutral | `equal` | Gray | Neutral |
| Timed out | `hourglass` | Orange | Timed out |
| Unknown | `questionmark` | Secondary | Unknown |

The summary rolls these up with a fixed priority:
**failure/timed out → running → queued → unknown → success**.

## Motion

- Animate only state changes that would otherwise be jarring, such as the
  connect-to-dashboard transition.
- Duration is 0.2–0.25 seconds with `easeInOut`.
- When `accessibilityReduceMotion` is on, skip the animation entirely.
- Do not animate status changes for decoration. A refresh should feel immediate.

## Dark mode

- Surfaces come from system grouped colors and adapt automatically.
- Status tints are system colors and remain legible on dark backgrounds.
- The accent has a dedicated dark variant.
- Shadows are subtle in both modes; borders carry most of the separation.
- Avoid hard-coded white or black in new components.

## Adding a component

1. Confirm the pattern appears in at least two places, or that it encodes an
   accessibility rule.
2. Put it in `Core/DesignSystem/Components/`.
3. Use `Theme` tokens for spacing and radius.
4. Combine children for VoiceOver and provide a custom label if the default
   traversal would be noisy.
5. Add a `#Preview` covering success, failure, and a long string.
6. Verify light mode, dark mode, and an accessibility text size.

## Known gaps

- The app icon asset slot exists but has no artwork.
- The 96-point tab-bar clearance is repeated in code; it should become a shared
  layout token once the tab bar treatment is final.
- There is no formal snapshot or visual regression suite.
- Dark mode and large Dynamic Type were reviewed on an iPhone 18 Pro simulator
  but are not captured in the repository.
- The design system has no button or list-row component yet; native styles are
  used directly.
