#!/bin/sh
# Builds Frost.app and installs it into /Applications, then opens it. On macOS 27 hiding only works from /Applications.
# Usage: ./install.sh
set -e
cd "$(dirname "$0")"
./bundle.sh
pkill -x Frost 2>/dev/null || true
rm -rf /Applications/Frost.app
cp -R Frost.app /Applications/Frost.app
echo "Installed /Applications/Frost.app"
open /Applications/Frost.app
