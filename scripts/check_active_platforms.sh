#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"

echo "Checking active platform references for Apple + Safari + web focus"

missing_paths=0
if [[ -d "sonicflow_app/chrome-extension" ]]; then
  echo "Inactive browser target still present: sonicflow_app/chrome-extension"
  missing_paths=1
fi

if [[ -d "sonicflow_app/safari-web-extension" ]]; then
  echo "Legacy Safari web extension path still present: sonicflow_app/safari-web-extension"
  missing_paths=1
fi

if [[ ! -d "sonicflow_app/extensions/safari" ]]; then
  echo "Expected Safari web extension path is missing: sonicflow_app/extensions/safari"
  missing_paths=1
fi

if [[ "$missing_paths" -ne 0 ]]; then
  exit 1
fi

# Legacy Android source folders are kept in the repository for history, but they
# must not be wired into active docs, build targets, warning audits, or product
# copy while SonicFlow is focused on iPhone, Safari, macOS menu bar, and web.
matches_file="$(mktemp)"
trap 'rm -f "$matches_file"' EXIT

rg -n --hidden --glob '!**/.git/**' \
    --glob '!sonicflow_app/android-app/**' \
    --glob '!sonicflow_app/core-android/**' \
    --glob '!**/package-lock.json' \
    --glob '!docs/reports/**' \
    --glob '!docs/superpowers/**' \
    --glob '!scripts/check_active_platforms.sh' \
    --glob '!brand/generated/BrandTokens.kt' \
    --glob '!sonicflow_app/android-app/**' \
    --glob '!sonicflow_app/core-android/**' \
    -e '\bChrome\b' \
    -e '\bchrome\b' \
    -e '\bAndroid\b' \
    -e '\bandroid\b' \
    -e 'sonicflow_app/chrome-extension' \
    -e 'chrome-extension' \
    -e 'Chrome extension' \
    -e 'Chrome popup' \
    -e 'Chrome bundle' \
    -e 'Chrome/Safari' \
    -e 'globalThis\.chrome' \
    -e 'make chrome' \
    -e 'test-chrome' \
    -e 'chrome-build-assets' \
    -e 'CHROME_DIR' \
    -e 'DIST_CHROME' \
    -e 'dist/chrome' \
    -e 'android-app' \
    -e 'core-android' \
    -e 'Android app' \
    -e 'Android targets' \
    -e 'Android SDK' \
    -e 'Android unit' \
    -e 'Android session' \
    -e 'Android external' \
    -e 'make android' \
    -e 'test-android' \
    . >"$matches_file" || true

if [[ -s "$matches_file" ]]; then
  echo "Active Chrome/Android references found:"
  cat "$matches_file"
  exit 1
fi

echo "Active platform reference check passed"
