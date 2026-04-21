#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SAFARI_PROJECT="sonicflow_app/safari-extension/FlowTones/FlowTones.xcodeproj"
SAFARI_SCHEME="FlowTones (macOS)"

cd "$ROOT_DIR"

make mac

BUILD_SETTINGS="$(
    xcodebuild \
        -project "$SAFARI_PROJECT" \
        -scheme "$SAFARI_SCHEME" \
        -configuration Debug \
        -sdk macosx \
        CODE_SIGNING_ALLOWED=NO \
        -showBuildSettings
)"

TARGET_BUILD_DIR="$(printf '%s\n' "$BUILD_SETTINGS" | awk -F ' = ' '/TARGET_BUILD_DIR = / {print $2; exit}')"
FULL_PRODUCT_NAME="$(printf '%s\n' "$BUILD_SETTINGS" | awk -F ' = ' '/FULL_PRODUCT_NAME = / {print $2; exit}')"

if [[ -z "$TARGET_BUILD_DIR" || -z "$FULL_PRODUCT_NAME" ]]; then
    echo "SonicFlow macOS smoke launch failed: could not resolve build product path"
    exit 1
fi

APP_PATH="$TARGET_BUILD_DIR/$FULL_PRODUCT_NAME"
APP_BINARY="$APP_PATH/Contents/MacOS/${FULL_PRODUCT_NAME%.app}"

open "$APP_PATH"
sleep 2

if ! pgrep -f "$APP_BINARY" >/dev/null; then
    echo "SonicFlow macOS smoke launch failed: process not running"
    exit 1
fi

osascript -e 'tell application "SonicFlow" to quit' >/dev/null 2>&1 || true

echo "SonicFlow macOS smoke launch passed"
