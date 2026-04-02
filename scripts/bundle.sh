#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="SnapIt"
APP_BUNDLE="$PROJECT_DIR/$APP_NAME.app"
BINARY="$PROJECT_DIR/.build/release/$APP_NAME"
PLIST="$PROJECT_DIR/Sources/$APP_NAME/Info.plist"

if [ ! -f "$BINARY" ]; then
    echo "Error: Binary not found at $BINARY"
    echo "Run 'swift build -c release' first."
    exit 1
fi

echo "Creating $APP_NAME.app bundle..."

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$BINARY" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
cp "$PLIST" "$APP_BUNDLE/Contents/Info.plist"
cp "$PROJECT_DIR/Sources/$APP_NAME/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"

# Ad-hoc code sign
codesign --force --sign - "$APP_BUNDLE"

echo "Done: $APP_BUNDLE"
