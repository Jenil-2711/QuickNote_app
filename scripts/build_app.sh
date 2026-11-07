#!/usr/bin/env bash
# Builds a release version and wraps it into dist/Cozy Quick-Note Desk.app
set -euo pipefail
cd "$(dirname "$0")/.."

swift build -c release
BIN="$(swift build -c release --show-bin-path)"
APP="dist/Cozy Quick-Note Desk.app"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN/CozyQuickNoteDesk" "$APP/Contents/MacOS/CozyQuickNoteDesk"
cp -R "$BIN/CozyQuickNoteDesk_CozyQuickNoteDesk.bundle" "$APP/Contents/Resources/"

cat > "$APP/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>Cozy Quick-Note Desk</string>
  <key>CFBundleDisplayName</key><string>Cozy Quick-Note Desk</string>
  <key>CFBundleIdentifier</key><string>dev.cozy.QuickNoteDesk</string>
  <key>CFBundleExecutable</key><string>CozyQuickNoteDesk</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

codesign --force --deep --sign - "$APP" >/dev/null 2>&1 || true
echo "Built: $APP"
