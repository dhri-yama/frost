# Design direction

Frost shares Gazewell's foundation: blurred glass, one accent per theme, and a `Style` value that every view reads. Its default is cold and light rather than warm and green.

## Themes
Frost (default, icy), Midnight (deep blue), Mono (near-black, lime accent), Paper (warm light). A theme is a `Style` in `Theme.swift` (ink, veil, accent, glows, backdrop, radii, display font design, material). Views read `Theme`; nothing else hard-codes colour. New themes are about ten lines of data.

## Surfaces
- **Menu popover:** blurred glass, one hero (hidden item count and a row of the hidden icons), plain rows with shortcuts on the right.
- **Second bar:** matches the system menu bar height and blur, a hairline border, a subtle accent glow under the hovered item. Notch-aware padding. Items spring in briefly; Reduce Motion gives a fade.
- **Settings:** toolbar of tabs (General, Layout, Rules, Profiles, Keys, About), large page title with a one-line description, flat rows separated by hairlines. No boxes, no sidebar.
- **First-run permissions:** one calm screen per permission saying exactly why it is needed.

## Rules
- Text over blur keeps 4.5:1 contrast.
- Respect Reduce Motion everywhere; animation is time-driven.
- Controls share one height (30pt).
- Never recolour another app's icon.
- All features stay reachable from Settings.
