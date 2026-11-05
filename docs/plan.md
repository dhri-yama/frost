# Plan and status

## Decisions
1. Native Swift (AppKit + SwiftUI), no Electron.
2. Open source, no telemetry, no network calls.
3. Minimal, explained permissions. Hiding on macOS 27 needs none; Accessibility is optional.
4. **Hiding method follows the OS.** The wide-divider trick stopped working on macOS 27, so Frost uses the system allow-list there (a private API, found by the Ellipsis project) and keeps the divider for older versions. See `CREDITS.md`.
5. Isolate fragile OS code behind small types (`MenuBarRestriction`, `AccessibilityScan`, `ItemMover`) with a visible failure path.
6. Distributed outside the App Store.
7. Design: Gazewell's glass and `Style` architecture, two themes (Night and Day) taken from a bar, no neon.
8. Versioning: SemVer in `VERSION`, Keep a Changelog, `release.sh` tags, every step committed.
9. **No pointer watching.** Hover reveal was built, found to need constant mouse monitoring on macOS 27, and removed. Icons appear on click, shortcut or search.

## Done
Repository and docs; hide/show; themes and settings; item scan (Accessibility, with a window-list fallback before macOS 27); panel; search; profiles; presenting mode; open at login; remappable shortcuts; first-run setup; chevron placement; app icon; macOS 27 allow-list hiding with "everything except" mode; visible hiding failures; stable local signing; DMG and release scripts.

## Not confirmed on a real menu bar yet
The panel and click-through, search, profiles, the setup window and "Move it for me", and the shortcut recorder were built and unit-tested but only the allow-list hiding, the reveal click and the chevron position have been checked by hand.

## Left
- Multi-display and notch polish for the panel.
- Rules (for example hide apps after a period unused). Frost cannot see other apps' clicks, so this needs a design first.
- Release: choose a license, sign with a Developer ID and notarise, publish to GitHub, Homebrew cask, update checks.
- Per-icon hiding is impossible with the allow-list; revisit if Apple adds an API.
