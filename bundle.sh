#!/bin/sh
# Builds a universal (Apple silicon + Intel) release binary and wraps it into Frost.app (menu bar only, ad-hoc signed).
# The version comes from the VERSION file. Usage: ./bundle.sh && open Frost.app
set -e
cd "$(dirname "$0")"
VERSION="$(tr -d '[:space:]' < VERSION)"
BUILD="$(git rev-list --count HEAD 2>/dev/null || echo 1)"
ARCHS="--arch arm64 --arch x86_64"
swift build -c release $ARCHS
BIN="$(swift build -c release $ARCHS --show-bin-path)/Frost"
rm -rf Frost.app
mkdir -p Frost.app/Contents/MacOS
cp "$BIN" Frost.app/Contents/MacOS/Frost
mkdir -p Frost.app/Contents/Resources
[ -f Resources/AppIcon.icns ] && cp Resources/AppIcon.icns Frost.app/Contents/Resources/AppIcon.icns
cat > Frost.app/Contents/Info.plist <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleExecutable</key><string>Frost</string>
  <key>CFBundleIdentifier</key><string>local.frost</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundleName</key><string>Frost</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>$VERSION</string>
  <key>CFBundleVersion</key><string>$BUILD</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSUIElement</key><true/>
</dict></plist>
PLIST
# A stable identity keeps the Accessibility permission across rebuilds; ad-hoc signing changes it every build.
# Use FROST_SIGN_IDENTITY, else the "Frost Dev" certificate from ./make-dev-cert.sh if it exists, else ad-hoc.
IDENTITY="${FROST_SIGN_IDENTITY:-}"
if [ -z "$IDENTITY" ] && security find-certificate -c "Frost Dev" >/dev/null 2>&1; then IDENTITY="Frost Dev"; fi
if [ -n "$IDENTITY" ]; then
  codesign --force --sign "$IDENTITY" Frost.app && echo "Signed with: $IDENTITY"
else
  codesign --force --sign - Frost.app
  echo "Ad-hoc signed: macOS will forget the Accessibility permission on every rebuild (see ./make-dev-cert.sh)."
fi
echo "Built Frost.app $VERSION ($BUILD)"
