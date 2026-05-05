#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IOS_PROJECT="$ROOT_DIR/sonicflow_app/apps/ios/SonicFlow.xcodeproj"
IOS_SCHEME="SonicFlow"
MACOS_PROJECT="$ROOT_DIR/sonicflow_app/apps/macos/SonicFlow.xcodeproj"
MACOS_SCHEME="SonicFlow (macOS)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
XCODE_WARNING_CLEAN_SETTINGS=(CODE_SIGNING_ALLOWED=NO ENABLE_APP_INTENTS_METADATA_GENERATION=NO EXTRACT_APP_INTENTS_METADATA=NO "OTHER_LDFLAGS=-framework AppIntents")

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
for line in log_path.read_text(errors="ignore").splitlines():
    if any(pattern.search(line) for pattern in warning_patterns):
        print(line)
PY
}

assert_warnings() {
  local name="$1"
  local expected="$2"
  local log_file="$3"
  local warnings
  warnings="$(collect_warnings "$log_file")"

  case "$expected" in
    none)
      if [[ -n "$warnings" ]]; then
        echo "Self-test failed: ${name} produced unexpected warnings"
        printf '%s\n' "$warnings"
        exit 1
      fi
      ;;
    some)
      if [[ -z "$warnings" ]]; then
        echo "Self-test failed: ${name} did not produce expected warnings"
        exit 1
      fi
      ;;
    *)
      echo "Unknown self-test expectation: ${expected}"
      exit 1
      ;;
  esac
}

run_self_test() {
  local appintents_log="$TMP_DIR/appintents.log"
  local swift_warning_log="$TMP_DIR/swift-warning.log"

  printf '%s\n' \
    "2026-04-23 appintentsmetadataprocessor[1:1] warning: Metadata extraction skipped. No AppIntents.framework dependency found." \
    >"$appintents_log"
  printf '%s\n' \
    "/tmp/File.swift:12:8: warning: variable 'value' was never mutated" \
    >"$swift_warning_log"

  assert_warnings "AppIntents metadata warning" some "$appintents_log"
  assert_warnings "real Swift warning" some "$swift_warning_log"

  echo "check_warnings self-test passed"
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

find_ios_test_destination() {
  local destinations
  destinations="$(xcodebuild -project "$IOS_PROJECT" -scheme "$IOS_SCHEME" -showdestinations 2>/dev/null || true)"

  DESTINATIONS="$destinations" python3 - <<'PY'
import re
import os

preferred = None
fallback = None

for line in os.environ["DESTINATIONS"].splitlines():
    if "platform:iOS Simulator" not in line or "placeholder" in line:
        continue

    identifier = re.search(r"id:([^,}]+)", line)
    if not identifier:
        continue

    destination = f"id={identifier.group(1).strip()}"

    if "name:iPhone 17 Pro" in line:
        preferred = destination
        break

    if fallback is None:
        fallback = destination

print(preferred or fallback or "")
PY
}

run_ios_tests_if_available() {
  local destination
  destination="$(find_ios_test_destination)"

  if [[ -z "$destination" ]]; then
    echo "==> ios_tests"
    echo "Skipping iOS tests because no iOS simulator destination is available."
    return 0
  fi

  run_step ios_tests xcodebuild -project "$IOS_PROJECT" -scheme "$IOS_SCHEME" -configuration Debug -destination "$destination" "${XCODE_WARNING_CLEAN_SETTINGS[@]}" test
  check_step ios_tests
}

if [[ "${1:-}" == "--self-test" ]]; then
  run_self_test
  exit 0
fi

if [[ "${1:-}" == "--ios-tests" ]]; then
  run_ios_tests_if_available
  exit 0
fi

run_self_test

run_step core_js npm --prefix "$ROOT_DIR/sonicflow_app/shared/core-js" test
check_step core_js

run_step safari_web_assets bash -lc "cd '$ROOT_DIR/sonicflow_app/extensions/safari' && npm ci && npm run build"
check_step safari_web_assets

run_step web_app npm --prefix "$ROOT_DIR/sonicflow_app/apps/web" test
check_step web_app

run_step core_swift swift test --package-path "$ROOT_DIR/sonicflow_app/shared/core-swift"
check_step core_swift

run_step ios_build xcodebuild -project "$IOS_PROJECT" -scheme "$IOS_SCHEME" -configuration Debug -destination "generic/platform=iOS Simulator" "${XCODE_WARNING_CLEAN_SETTINGS[@]}" build
check_step ios_build

run_ios_tests_if_available

run_step mac_build xcodebuild -project "$MACOS_PROJECT" -scheme "$MACOS_SCHEME" -configuration Debug -destination "platform=macOS,arch=arm64" "${XCODE_WARNING_CLEAN_SETTINGS[@]}" build
check_step mac_build
