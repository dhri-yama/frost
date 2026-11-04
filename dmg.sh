#!/bin/sh
# Builds Frost.app and wraps it in Frost-<version>.dmg (drag-to-Applications layout). Usage: ./dmg.sh
set -e
cd "$(dirname "$0")"
VERSION="$(tr -d '[:space:]' < VERSION)"
./bundle.sh
STAGE="$(mktemp -d)"
cp -R Frost.app "$STAGE/"
ln -s /Applications "$STAGE/Applications"
rm -f "Frost-$VERSION.dmg"
hdiutil create -volname Frost -srcfolder "$STAGE" -ov -format UDZO "Frost-$VERSION.dmg" >/dev/null
rm -rf "$STAGE"
echo "Built Frost-$VERSION.dmg"
