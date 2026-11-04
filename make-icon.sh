#!/bin/sh
# Regenerates Resources/AppIcon.icns from Tools/make-icon.swift. The result is committed, so this only needs to run when the design changes.
set -e
cd "$(dirname "$0")"
SET="$(mktemp -d)/AppIcon.iconset"
swift Tools/make-icon.swift "$SET"
mkdir -p Resources
iconutil -c icns "$SET" -o Resources/AppIcon.icns
echo "Wrote Resources/AppIcon.icns"
