# Design direction

Frost shares Gazewell's foundation: blurred glass, one accent per theme, and a `Style` value that every view reads. Its default is cold and light rather than warm and green. The app icon follows it: an icy squircle holding a menu-bar pill whose icons fade out before a chevron.

## Themes
Frost (default, icy), Midnight (deep blue), Mono (near-black, lime accent), Paper (warm light). A theme is a `Style` in `Theme.swift` (ink, veil, accent, glows, swatch, radii, display font design, material). Views read `Theme`; nothing else hard-codes colour. A new theme is about ten lines of data. Themes style only Frost's own windows, never other apps' icons.

## Surfaces
- **Chevron:** Frost's only permanent menu bar item (a divider as well before macOS 27). Click toggles; right-click gives the menu (show or hide, presenting mode, search, settings, quit).
- **Panel (optional):** hidden apps as icon tiles in a glass panel under the menu bar, right-aligned to the chevron and clamped inside the screen. Clicking a tile clicks the real item.
- **Search:** a centred glass panel with a field and a ranked list; arrow keys and Return, Esc closes.
- **Settings:** a toolbar of tabs (General, Layout, Profiles, Keys, About), a large page title with a one-line description, and flat rows separated by hairlines. No boxes, no sidebar.
- **First-run setup:** five short steps with a progress strip; each requirement is explained before it is asked for.
- **Snapshots:** `Frost --snapshot <folder>` renders every pane and setup step in every theme to PNG, which is how the README screenshots are made.

## Rules
- Text over blur keeps 4.5:1 contrast.
- Respect Reduce Motion everywhere; animation is time-driven.
- Controls share one height (30pt).
- Never recolour another app's icon.
- All features stay reachable from Settings.
