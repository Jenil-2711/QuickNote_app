#!/usr/bin/env bash
# Builds Cozy Quick-Note Desk as a real macOS app, plus a .dmg and a .zip you can share.
#
#   ./scripts/build_app.sh            builds dist/Cozy Quick-Note Desk.app, .dmg and .zip
#   ./scripts/build_app.sh --install  ...and also copies the app into /Applications and opens it
#
# The app is a universal binary (Apple Silicon and Intel) for macOS 13 or later.
set -euo pipefail
cd "$(dirname "$0")/.."

NAME="Cozy Quick-Note Desk"
EXEC="CozyQuickNoteDesk"
VERSION="$(tr -d '[:space:]' < VERSION)"
APP="dist/$NAME.app"
DMG="dist/CozyQuickNoteDesk-$VERSION.dmg"
ZIP="dist/CozyQuickNoteDesk-$VERSION.zip"
INSTALL=false
[[ "${1:-}" == "--install" ]] && INSTALL=true

echo "▸ Building $NAME $VERSION (Apple Silicon + Intel)…"
swift build -c release --arch arm64 --arch x86_64
BIN="$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)"

echo "▸ Assembling the app…"
rm -rf "dist"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN/$EXEC" "$APP/Contents/MacOS/$EXEC"

# images, textures and the room (SwiftPM puts them in a resource bundle)
BUNDLE="$APP/Contents/Resources/${EXEC}_${EXEC}.bundle"
cp -R "$BIN/${EXEC}_${EXEC}.bundle" "$BUNDLE"
if [[ ! -f "$BUNDLE/Info.plist" ]]; then
  cat > "$BUNDLE/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleIdentifier</key><string>dev.cozy.QuickNoteDesk.resources</string>
  <key>CFBundleName</key><string>${EXEC}_${EXEC}</string>
  <key>CFBundlePackageType</key><string>BNDL</string>
</dict></plist>
PLIST
fi

echo "▸ Making the app icon…"
ICONSET="$(mktemp -d)/AppIcon.iconset"
mkdir -p "$ICONSET"
for size in 16 32 128 256 512; do
  sips -z "$size" "$size" assets/AppIcon-1024.png --out "$ICONSET/icon_${size}x${size}.png" > /dev/null
  sips -z "$((size * 2))" "$((size * 2))" assets/AppIcon-1024.png --out "$ICONSET/icon_${size}x${size}@2x.png" > /dev/null
done
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"

cat > "$APP/Contents/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>$NAME</string>
  <key>CFBundleDisplayName</key><string>$NAME</string>
  <key>CFBundleIdentifier</key><string>dev.cozy.QuickNoteDesk</string>
  <key>CFBundleExecutable</key><string>$EXEC</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>$VERSION</string>
  <key>CFBundleVersion</key><string>$VERSION</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSApplicationCategoryType</key><string>public.app-category.productivity</string>
  <key>NSHumanReadableCopyright</key><string>Copyright © 2026 Jenil Charadva. MIT License.</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

echo "▸ Signing (ad-hoc, so it runs on Apple Silicon)…"
codesign --force --sign - "$BUNDLE" 2>&1 || echo "  (note: could not sign the resource bundle)"
codesign --force --sign - "$APP" 2>&1 || echo "  (note: could not sign the app)"
if codesign --verify --strict "$APP" 2>/dev/null; then echo "  ✓ signature valid"; else echo "  ⚠ signature check failed (the app may still run on your own Mac)"; fi

echo "▸ Packing the disk image and zip…"
STAGE="$(mktemp -d)"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
hdiutil create -volname "$NAME" -srcfolder "$STAGE" -ov -format UDZO "$DMG" > /dev/null
ditto -c -k --keepParent "$APP" "$ZIP"

if $INSTALL; then
  echo "▸ Installing into /Applications…"
  osascript -e "tell application \"$NAME\" to quit" > /dev/null 2>&1 || true
  sleep 1
  rm -rf "/Applications/$NAME.app"
  cp -R "$APP" "/Applications/"
  xattr -dr com.apple.quarantine "/Applications/$NAME.app" 2>/dev/null || true
  open "/Applications/$NAME.app"
fi

echo ""
echo "Done:"
echo "  $APP"
echo "  $DMG"
echo "  $ZIP"
$INSTALL && echo "  Installed in /Applications. Find it in Launchpad or Spotlight." || echo "  Run './scripts/build_app.sh --install' to put it in /Applications."
