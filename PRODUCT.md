# Product

## Platform

macOS (native). SwiftUI + AppKit, Swift Package, deployment target macOS 13. Distributed outside the Mac App Store (it needs Accessibility and a private API, so no sandbox).

## Users

Mac users with crowded menu bars, especially notched MacBooks where icons vanish behind the camera cutout. Sees the app dozens of times a day, for a second at a time; it must be invisible when idle.

## Product Purpose

Frost: a menu bar organiser. It hides the icons you do not need all the time, shows them on demand, and keeps everything reachable by search and keyboard. Success: the menu bar is tidy and the user never wonders where an icon went or whether the app is trustworthy.

## Capabilities and Constraints

- **Hiding.** macOS 27+: the system menu bar allow-list (private `MenuBarClientCore`), per app, no permission. Earlier macOS: a wide divider that pushes icons off the edge. Hide the apps you choose, or everything except the apps you choose.
- **Revealing.** Click the chevron or a shortcut; icons return in the bar or in a themed panel below it. Auto-hide timer.
- **Finding.** Search over every item (hidden or not), clicking through Accessibility.
- **Layouts.** Profiles, presenting mode, remappable global shortcuts, open at login.
- **Setup.** First-run walkthrough; one-click chevron placement.
- No accounts, no telemetry, no network calls. Settings stay on the Mac.
- Hiding is per app, hides the Focus and camera indicators while on, needs Frost in /Applications on macOS 27, and rests on a private API that a macOS update can remove (Frost checks at launch and falls back to the divider).

## Brand Commitments

Name: Frost. Open source, transparent about every permission. Same family look as Gazewell (blurred glass, switchable themes), but its own default: icy and cold. Credits to the projects whose findings it builds on are in `CREDITS.md`.

## Product Principles

- Invisible when idle: no animation, no polling, no pointer watching.
- Never lose an icon: hidden items are always one click or one shortcut away, and Frost never hides itself.
- Say why: every permission is explained before it is requested, and the app works without the optional ones.
- Fail loudly, not silently: if hiding fails or an item cannot be controlled, say so.
- Never touch other apps' icons: the theme styles only Frost's own chrome.

## Accessibility & Inclusion

Respect Reduce Motion and Increase Contrast; full keyboard control; VoiceOver labels on controls; 4.5:1 contrast for text over blur.
