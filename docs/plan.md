# Plan

## Decisions
1. Native Swift (AppKit + SwiftUI), no Electron.
2. Open source, no telemetry; optional signed update check only.
3. Notch-first second bar.
4. Minimal, explained permissions; Screen Recording optional.
5. Rules instead of manual dragging (hide unused items, show on notification).
6. Global search hotkey over all items.
7. Profiles by display, Focus mode or Wi-Fi.
8. Presenting mode.
9. One isolated layer for fragile OS hacks, with a self-check.
10. Distributed outside the App Store (GitHub releases, Homebrew cask), signed and notarised.
11. Design: Gazewell's glass + `Style` architecture, Frost icy default, four themes.
12. Versioning: SemVer in `VERSION`, Keep a Changelog, every step committed.

## Phases
0. Repo, docs, versioning, theme, settings components. (0.1.0)
1. Prototype: divider that hides/shows items on click. (0.2.0)
2. Item discovery (Accessibility). (0.3.0)
3. Rearranging between Visible / Hidden / Never. (0.4.0)
4. Second-bar panel (Screen Recording). (0.5.0)
5. Settings UI, hotkeys, search. (0.6.0)
6. Rules and profiles. (0.7.0)
7. Polish and release: launch at login, multi-display, notarisation. (1.0.0)
