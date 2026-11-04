# Changelog

All notable changes to Frost are recorded here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and the project uses [Semantic Versioning](https://semver.org/): MAJOR for breaking changes to saved settings or behaviour,
MINOR for new features, PATCH for fixes. While the version is 0.x, minor releases may change behaviour.

## [Unreleased]

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
