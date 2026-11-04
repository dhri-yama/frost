# Product

## Platform

macOS (native). SwiftUI + AppKit, Swift Package, macOS 13+. Distributed outside the Mac App Store (needs Accessibility, so no sandbox).

## Users

Mac users with crowded menu bars, especially notched MacBooks where icons vanish behind the camera cutout. Sees the app dozens of times a day, for a second at a time; it must be invisible when idle.

## Product Purpose

Frost: a menu bar organiser. It hides the icons you do not need all the time, shows them on demand, and keeps everything reachable by search and keyboard. Success: the menu bar is tidy and the user never wonders where an icon went or whether the app is trustworthy.

## Capabilities and Constraints

Hide and show items via a divider item; list and rearrange items (Accessibility); second-bar panel (optional Screen Recording); rules, profiles, presenting mode, global search hotkey. No accounts, no telemetry, no network calls except an optional signed update check. Fragile OS-specific code lives in one isolated layer.

## Brand Commitments

Name: Frost. Open source, transparent about every permission. Same family look as Gazewell (blurred glass, switchable themes), but its own default: icy and cold.

## Product Principles

- Invisible when idle: no animation, no CPU, nothing to look at.
- Never lose an icon: hidden items are always one click or one hotkey away.
- Say why: every permission is explained before it is requested, and the app works without the optional ones.
- Fail loudly, not silently: if an item cannot be controlled, say so.
- Never touch other apps' icons: the theme styles only Frost's own chrome.

## Accessibility & Inclusion

Respect Reduce Motion and Increase Contrast; full keyboard control; VoiceOver labels on controls; 4.5:1 contrast for text over blur.
