# Accessibility

Pipeline should be usable by every developer, including people who use
VoiceOver, Dynamic Type, Reduce Motion, or cannot distinguish red from green.

Accessibility is treated as part of the component contract: status components
own their labels, rows combine noisy metadata, and destructive actions are
confirmed. This document describes the patterns, the verification checklist,
and the gaps that remain.

## Core commitments

1. **Status is never color alone.** Every status has an icon, a written label,
   and a VoiceOver value.
2. **Everything meaningful is reachable.** Interactive controls are at least
   44 × 44 points and have accessible names.
3. **Text scales.** Layouts use Dynamic Type styles and avoid fixed heights.
4. **Motion is optional.** Non-essential animation respects Reduce Motion.
5. **Actions are predictable.** Destructive actions use a destructive role and a
   confirmation dialog.

## Status accessibility

The `RunState` mapping is the single source of truth.

| State | Icon | Written label | VoiceOver exposure |
| --- | --- | --- | --- |
| Success | Checkmark | Success | Status badge value |
| Failure | Xmark | Failure | Status badge value |
| Running | Rotating arrows | Running | Status badge value |
| Queued | Clock | Queued | Status badge value |
| Cancelled | Minus | Cancelled | Status badge value |
| Skipped | Forward end | Skipped | Status badge value |
| Neutral | Equals | Neutral | Status badge value |
| Timed out | Hourglass | Timed out | Status badge value |
| Unknown | Question mark | Unknown | Status badge value |

Implementation details:

- `StatusGlyph` is decorative and marked `.accessibilityHidden(true)`.
- `StatusBadge` exposes label "Status" and value equal to the state title.
- `RepositoryCard` combines its children into one element whose label includes
  the repository, provider, workflow, branch, status, and update time.
- `RunRow` combines workflow, status, branch, SHA, commit message, update time,
  actor, and duration into one element.
- `SummaryCard` combines the summary into one sentence.
- The dashboard summary and status badges are never the only place a status
  appears; repository and run rows repeat it in their combined labels.

## VoiceOver

### Labels and hints

- Icon-only buttons have labels: refresh, show/hide token, repository actions,
  open on GitHub, dismiss error.
- Navigation links to repository and run details have hints describing the
  destination ("Opens repository details", "Opens run details").
- The connect button has a hint explaining that the token is saved securely and
  the dashboard opens.
- The token field has a label and a hint describing the required permissions.
- The watch toggles have labels that include the repository name and a hint
  explaining the effect.

### Grouping

Cards and rows use `.accessibilityElement(children: .ignore)` plus a custom
label, or `.combine` where a sentence is appropriate. This prevents VoiceOver
from stopping on every fragment of metadata.

Decorative separators, icons, and the "•" glyphs are hidden. Text such as
"Updated 4 minutes ago" is read as part of the parent element rather than as a
separate stop.

### Headings

Section titles ("Watched repositories", "Recent runs", "Run details") use
`.accessibilityAddTraits(.isHeader)`, as do screen-level titles such as the run
status and About title. This makes the rotor useful for navigating long screens.

### Focus and announcements

- The connect screen moves focus to the token field only through normal user
  interaction; it does not steal focus on launch.
- The error text under the token field is combined into one element labeled
  "Error: …".
- **Known gap:** errors are not posted as an accessibility announcement. A
  VoiceOver user may need to navigate back to the field to hear the message.
  Consider `AccessibilityNotification.Announcement` when the connect flow is
  refined.

## Dynamic Type

- All meaningful text uses system text styles (`.largeTitle`, `.title3`,
  `.headline`, `.subheadline`, `.caption`, and so on).
- Cards grow vertically; there are no fixed row heights.
- Primary content is inside `ScrollView` or `List`, so it remains reachable at
  large sizes.
- Buttons use `.controlSize(.large)` and full-width labels, so their text can
  grow.
- Icon-only status glyphs use fixed point sizes. They are decorative and are
  always paired with scalable text.
- The token field uses a monospaced body style and can scroll horizontally at
  large sizes.
- At accessibility sizes, the dashboard summary stacks its glyph above the text
  and its refresh footer vertically. The repository picker moves the watch
  toggle below the repository name and shows a visible "Watch" label.
- The repository search field uses an always-visible navigation bar placement so
  it does not collapse into an unreachable control.

**Known gap:** the app has been visually checked at the largest accessibility
size on an iPhone 18 Pro simulator, but not at every intermediate size. A full
Dynamic Type pass is a release blocker for the App Store milestone.

## Color and contrast

- Status color is always paired with an icon and a label.
- Status badge text uses `.primary` on a low-opacity tint, not the tint itself.
- Cards use system grouped backgrounds and a hairline border, so separation does
  not depend on shadow alone.
- The accent has separate light and dark asset variants.
- No information is encoded by red/green alone. Failure also has an X icon and
  the word "Failure"; success has a checkmark and "Success".
- **Known gap:** a formal contrast audit against WCAG 2.2 AA has not been
  completed. The low-opacity status fills are decorative, but any new text
  color must be checked in both appearances.

## Touch targets

- Show/hide token: 44 × 44 pt.
- Error banner dismiss: 44 × 44 pt.
- Toolbar buttons: system-provided hit targets, with 44 × 44 frames where a
  custom label is used.
- Watch toggles: native `Toggle` hit target.
- Cards and rows: full row is tappable via `.contentShape(Rectangle())`.
- Destructive buttons: full-width list rows or prominent buttons.

## Motion

- The connect-to-dashboard transition animates with a 0.25-second ease-in-out.
- Error appearance animates with a 0.2-second ease-in-out.
- Both check `@Environment(\.accessibilityReduceMotion)` and skip animation when
  it is enabled.
- Pull-to-refresh and loading indicators use system behavior.
- No auto-playing or looping decorative animation exists.

## Forms

The connect screen is the only form.

- The token field is labeled "GitHub personal access token".
- The field is a `SecureField` by default; the show/hide button has a clear
  label and 44-point target.
- The field is marked `.privacySensitive()` so it is redacted in screen
  recordings and app switcher snapshots where the system supports it.
- The keyboard uses ASCII, disables autocapitalization, and dismisses
  interactively.
- The submit button is disabled when the field is empty.
- Validation errors are shown inline next to the field.
- Token creation instructions are in a disclosure group and include a link to
  GitHub.

## Testing checklist

Run this checklist on a real device when possible, and at minimum on the
smallest and largest supported iPhone simulators.

### VoiceOver

- [ ] Every screen has a meaningful first focus target.
- [ ] Status is announced for the summary, repository cards, and run rows.
- [ ] Repository and run rows are single stops, not a stream of fragments.
- [ ] Show/hide token announces its state and purpose.
- [ ] Connect errors are discoverable.
- [ ] Destructive confirmation dialogs are readable.
- [ ] The tab bar announces all three tabs and the selected tab.
- [ ] No unlabeled buttons or images remain.

### Dynamic Type

- [ ] All content is reachable at the largest accessibility size.
- [ ] No text is clipped in cards, buttons, or list rows.
- [ ] The connect button and token field remain usable.
- [ ] The tab bar labels remain readable.
- [ ] The run details values wrap instead of truncating critical data.

### Visual

- [ ] Light and dark mode both have sufficient separation between cards and
      background.
- [ ] Increase Contrast improves borders and text.
- [ ] Differentiate Without Color still communicates every status.
- [ ] Color filters (protanopia, deuteranopia, tritanopia) preserve meaning.
- [ ] Reduce Motion removes the connect and error animations.
- [ ] Landscape layout is usable (the app supports landscape on iPhone).

### Assistive control

- [ ] Voice Control can reach and activate every primary action.
- [ ] Switch Control can traverse the connect flow and dashboard.
- [ ] Full Keyboard Access can reach the token field and buttons.

### Automated

- [ ] UI tests use accessibility identifiers rather than visible text where
      possible.
- [ ] New interactive elements have stable identifiers.
- [ ] No test depends on color or animation timing.

## Known gaps

- No independent accessibility audit has been performed.
- Initial light mode, dark mode, and largest-Dynamic-Type checks were completed
  on an iPhone 18 Pro simulator. Intermediate sizes, Increase Contrast, and
  color-filter checks remain pending.
- Connect errors are not announced automatically.
- The app has not been tested with Voice Control or Switch Control.
- Localization and right-to-left layout have not been verified.
- The app icon and launch screen are placeholders.
- Automated accessibility audits (for example Xcode's Accessibility Inspector)
  are not part of CI.

## References

- [Apple Human Interface Guidelines: Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)
- [Apple Accessibility Inspector](https://developer.apple.com/accessibility/)
- [WCAG 2.2 Quick Reference](https://www.w3.org/WAI/WCAG22/quickref/)
- [SwiftUI accessibility documentation](https://developer.apple.com/documentation/swiftui/accessibility)
