# Frost

A macOS menu bar organiser. Frost hides the icons you do not need all the time, shows them on demand, and keeps every one of them reachable by search and keyboard. It is built for crowded and notched menu bars.

Open source, no accounts, no telemetry, no network calls. Settings stay on your Mac.

## Features
- **Hide and show:** a divider and chevron in the menu bar. Everything left of the divider is hidden until you click the chevron (or press ⌃⌥H). Revealed items hide again after a delay you choose.
- **Panel mode:** show hidden items in a themed panel under the menu bar instead of the bar itself. Click a tile to click the real item.
- **Layout:** the Layout tab lists every item, hidden or visible, with **Hide** and **Show** buttons that move the icon for you.
- **Search:** ⌃⌥Space lists every item. Type to filter, ↑ ↓ to choose, Return to click it.
- **Profiles:** save which apps are hidden as a named layout and apply it later.
- **Presenting mode:** keep everything hidden for screen sharing (⌃⌥P).
- **Themes:** Frost, Midnight, Mono and Paper. A theme only styles Frost's own windows, never other apps' icons.
- Open at login, global shortcuts you can switch off.

## Permissions
Frost asks for **Accessibility** and explains why before you grant it: it needs to read which icons are in the menu bar, click them for you and move them. It cannot see your screen or what you type. Without it Frost still hides and shows items, but cannot list, search or rearrange them.

## Build
Requires macOS 13+ and the Swift toolchain (Command Line Tools are enough).

```sh
./test.sh          # run the tests
./bundle.sh        # build Frost.app (universal, signed)
open Frost.app
./dmg.sh           # build Frost-<version>.dmg
```

### Keeping the Accessibility permission across rebuilds
Ad-hoc signed builds change identity on every build, so macOS forgets the permission. Run `./make-dev-cert.sh` once to create a local "Frost Dev" certificate; `./bundle.sh` then uses it automatically. After the first signed build, reset once with `tccutil reset Accessibility local.frost` and allow Frost again.

## Diagnostics
- `Frost --scan` prints the menu bar items Frost can find and which method it used.
- `Frost --snapshot <folder>` renders every settings pane in every theme to PNG.

## Releasing
`./release.sh <major|minor|patch>` bumps `VERSION`, stamps the `[Unreleased]` section of `CHANGELOG.md` and tags the release. Versions follow [Semantic Versioning](https://semver.org/); see `CHANGELOG.md`.

## Design
See `PRODUCT.md`, `docs/design-direction.md` and `docs/plan.md`.
