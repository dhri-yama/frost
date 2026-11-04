# Changelog

All notable changes to Frost are recorded here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and the project uses [Semantic Versioning](https://semver.org/): MAJOR for breaking changes to saved settings or behaviour,
MINOR for new features, PATCH for fixes. While the version is 0.x, minor releases may change behaviour.

## [Unreleased]

## [0.8.0] - 2026-11-05

### Added
- Profiles: save which apps are hidden as a named layout and apply it later. Applying drags each icon that is on the wrong side across the divider, re-reading positions before every move. `Profile` and `ProfilePlan` in `FrostCore`, with tests.
- Presenting mode: keeps everything hidden until switched off (General, the chevron's right-click menu, or ⌃⌥P). Not saved across launches.
- Open at login (General), using the system login-item API. If macOS refuses (unsigned builds often do), the switch goes back and says why.
- Profiles tab; the Keys tab lists the presenting shortcut.

### Fixed
- `--snapshot` no longer touches saved settings: it renders with a throwaway defaults suite.
- Tab icons in the settings toolbar are a fixed height, so labels line up.

### Known issues
- Applying a profile relies on the Hide/Show drag, which has not been confirmed on a real menu bar yet.

## [0.7.0] - 2026-11-05

### Added
- Search: ⌃⌥Space (or "Search items…" in the chevron's right-click menu) opens a themed search panel over every menu bar item, hidden or not. Type to filter, ↑ ↓ to choose, Return to click the item, Esc to close. Ranked by name prefix, then name, then title (`ItemSearch` in `FrostCore`, with tests).
- Global shortcut ⌃⌥H shows or hides items, ported from Gazewell's Carbon hotkeys (no extra permission).
- Keys pane with an on/off switch for global shortcuts.

### Known issues
- Shortcuts are fixed; there is no key recorder yet.
- Search and the shortcuts have not been tried on a real menu bar yet. Clicking a result needs Accessibility access.

## [0.6.0] - 2026-11-05

### Added
- Hide and Show buttons in the Layout pane (with Accessibility): Frost expands the bar, performs the ⌘-drag that moves the icon to the other side of its divider, restores the bar and rescans. Previously icons had to be ⌘-dragged by hand, so nothing collapsed until you did.
- `MovePlan` in `FrostCore` (where to press and release for hide/show, and the drag path), with tests.
- A message when an item cannot be moved (some system items are fixed).

### Known issues
- Moving uses synthetic mouse events and has only been checked on paper so far. Keep the mouse still for a second while an item moves.
- Rebuilding with `./bundle.sh` changes the ad-hoc signature, so macOS forgets the Accessibility permission; run `tccutil reset Accessibility local.frost` and allow it again. A release signed with a stable certificate will not have this problem.

## [0.5.0] - 2026-11-05

### Added
- Second-bar panel: hidden items appear as icon tiles in a themed glass panel under the menu bar, right-aligned to Frost's toggle and clamped inside the screen. Clicking a tile clicks the real item (Accessibility), Esc or a click elsewhere closes it, and it never steals focus.
- "Show hidden items" setting (in the menu bar, or in a panel below it). The default stays in the menu bar.
- Panel geometry and reveal mode in `FrostCore`, with tests.
- Panel snapshots for every theme.

### Changed
- The panel shows app icons and names from the scan rather than captured images, so it needs no Screen Recording permission. Capturing the real icon images is deferred.

### Known issues
- The panel and AXPress clicking have not been tried on a real menu bar yet (they depend on the Accessibility scan from 0.4.0).

## [0.4.0] - 2026-11-05

### Added
- Accessibility scan: reads every app's `AXExtrasMenuBar` to list menu bar items with their title, position and owner. Used first when permission is granted; the window-list scan is the fallback.
- Layout pane explains the Accessibility permission (why it is needed and what it cannot do), with Allow and Open Settings buttons, and shows which source found the items.
- Items are grouped by position against Frost's divider, so hidden and visible lists work with either scan source.
- `Frost --scan` reports whether Accessibility is granted and which source it used.

### Known issues
- The Accessibility scan has not been run against a real menu bar yet (it needs the permission, which could not be granted in the development session). Please run `--scan` after allowing your terminal and report the output.

## [0.3.0] - 2026-11-05

### Added
- Item discovery: `MenuBarScan` reads the window server's window list (no permission needed) and splits menu bar items into hidden (left of Frost's divider) and visible, with tests.
- Layout pane listing hidden and visible items with each app's name and icon, plus a Refresh button.
- `Frost --scan` prints the items found, for checking discovery from a terminal.
- Snapshots now cover every pane.

### Known issues
- On macOS 27 (checked on one machine) the window list did not include any status item windows, not even Frost's own, so the Layout pane may be empty. An Accessibility-based scan is planned for 0.4.0.

## [0.2.0] - 2026-11-05

### Added
- Hide/show prototype: a divider item that grows to 10,000pt to push items to its left off-screen, and a chevron toggle (right-click for Settings and Quit).
- Auto-hide timer (never, 5, 10, 30 seconds) and "hide items at launch".
- Four themes (Frost, Midnight, Mono, Paper) on a shared `Style`/`Theme` foundation ported from Gazewell.
- Settings window (General, About) with flat rows, hairlines and a top tab toolbar.
- `Frost --snapshot <folder>` renders each theme's settings to PNG.
- `bundle.sh` builds a universal, ad-hoc signed `Frost.app` using the `VERSION` file.

## [0.1.0] - 2026-11-05

### Added
- Repository, product brief, design direction, plan, SemVer and changelog.
- `FrostCore` with `SemVer` and `DividerState` logic, with tests.
