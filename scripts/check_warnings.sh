#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

run_step() {
  local name="$1"
  shift
  local log_file="$TMP_DIR/${name}.log"

  echo "==> ${name}"
  if ! (
    cd "$ROOT_DIR"
    "$@"
  ) >"$log_file" 2>&1; then
    cat "$log_file"
    echo
    echo "Step failed: ${name}"
    exit 1
  fi

  cat "$log_file"
}

collect_warnings() {
  local log_file="$1"
  python3 - "$log_file" <<'PY'
import re
import sys
from pathlib import Path

log_path = Path(sys.argv[1])
warning_patterns = [
    re.compile(r"warning:", re.IGNORECASE),
    re.compile(r"^w:\s", re.IGNORECASE),
]
ignore_patterns = [
    re.compile(r"Metadata extraction skipped\. No AppIntents\.framework dependency found\."),
    re.compile(r"Deprecated Gradle features were used in this build, making it incompatible with Gradle 9\.0\."),
]

for line in log_path.read_text(errors="ignore").splitlines():
    if any(pattern.search(line) for pattern in warning_patterns):
        if any(pattern.search(line) for pattern in ignore_patterns):
            continue
        print(line)
PY
}

check_step() {
  local name="$1"
  local log_file="$TMP_DIR/${name}.log"
  local warnings
  warnings="$(collect_warnings "$log_file")"
  if [[ -n "$warnings" ]]; then
    echo
    echo "Warnings found in ${name}:"
    printf '%s\n' "$warnings"
    exit 1
  fi
}

run_step core_js npm --prefix "$ROOT_DIR/sonicflow_app/core-js" test
check_step core_js

run_step chrome_build bash -lc "cd '$ROOT_DIR/sonicflow_app/chrome-extension' && npm ci && npm run build"
check_step chrome_build

run_step core_swift swift test --package-path "$ROOT_DIR/sonicflow_app/core-swift"
check_step core_swift

run_step ios_build xcodebuild -project "$ROOT_DIR/sonicflow_app/ios-app/FlowTones.xcodeproj" -scheme FlowTones -configuration Debug -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build
check_step ios_build

run_step mac_build xcodebuild -project "$ROOT_DIR/sonicflow_app/safari-extension/FlowTones/FlowTones.xcodeproj" -scheme "FlowTones (macOS)" -configuration Debug -destination "generic/platform=macOS" CODE_SIGNING_ALLOWED=NO build
check_step mac_build

if [[ -n "${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}" || -f "$ROOT_DIR/sonicflow_app/android-app/local.properties" ]]; then
  run_step android_build bash -lc "cd '$ROOT_DIR/sonicflow_app/android-app' && ./gradlew assembleDebug"
  check_step android_build
else
  echo "==> android_build"
  echo "Skipping Android warning audit because no Android SDK path is configured."
fi
