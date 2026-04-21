#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_PATH="$HOME/Library/Developer/Xcode/DerivedData/FlowTones-babuujbpsmeqmygbvfdnenuwvhfv/Build/Products/Debug/SonicFlow.app"
APP_BINARY="$APP_PATH/Contents/MacOS/SonicFlow"

cd "$ROOT_DIR"

make mac

open "$APP_PATH"
sleep 2

if ! pgrep -f "$APP_BINARY" >/dev/null; then
    echo "SonicFlow macOS smoke launch failed: process not running"
    exit 1
fi

echo "SonicFlow macOS smoke launch passed"
