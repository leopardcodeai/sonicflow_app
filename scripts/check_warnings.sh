#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IOS_PROJECT="$ROOT_DIR/sonicflow_app/ios-app/FlowTones.xcodeproj"
IOS_SCHEME="FlowTones"
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
    re.compile(r"The following options were not recognized by any processor: '\[dagger\."),
]

for line in log_path.read_text(errors="ignore").splitlines():
    if any(pattern.search(line) for pattern in warning_patterns):
        if any(pattern.search(line) for pattern in ignore_patterns):
            continue
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
  local gradle_log="$TMP_DIR/gradle.log"
  local kapt_log="$TMP_DIR/kapt.log"
  local swift_warning_log="$TMP_DIR/swift-warning.log"
  local kotlin_warning_log="$TMP_DIR/kotlin-warning.log"

  printf '%s\n' \
    "2026-04-23 appintentsmetadataprocessor[1:1] warning: Metadata extraction skipped. No AppIntents.framework dependency found." \
    >"$appintents_log"
  printf '%s\n' \
    "Deprecated Gradle features were used in this build, making it incompatible with Gradle 9.0." \
    >"$gradle_log"
  printf '%s\n' \
    "warning: The following options were not recognized by any processor: '[dagger.fastInit, kapt.kotlin.generated]'" \
    >"$kapt_log"
  printf '%s\n' \
    "/tmp/File.swift:12:8: warning: variable 'value' was never mutated" \
    >"$swift_warning_log"
  printf '%s\n' \
    "w: /tmp/File.kt: (7, 13): Parameter 'unused' is never used" \
    >"$kotlin_warning_log"

  assert_warnings "accepted AppIntents metadata warning" none "$appintents_log"
  assert_warnings "accepted Gradle deprecation summary" none "$gradle_log"
  assert_warnings "accepted KAPT processor options warning" none "$kapt_log"
  assert_warnings "real Swift warning" some "$swift_warning_log"
  assert_warnings "real Kotlin warning" some "$kotlin_warning_log"

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

  run_step ios_tests xcodebuild -project "$IOS_PROJECT" -scheme "$IOS_SCHEME" -configuration Debug -destination "$destination" CODE_SIGNING_ALLOWED=NO test
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

run_step core_js npm --prefix "$ROOT_DIR/sonicflow_app/core-js" test
check_step core_js

run_step chrome_build bash -lc "cd '$ROOT_DIR/sonicflow_app/chrome-extension' && npm ci && npm run build"
check_step chrome_build

run_step chrome_test bash -lc "cd '$ROOT_DIR/sonicflow_app/chrome-extension' && npm test"
check_step chrome_test

run_step core_swift swift test --package-path "$ROOT_DIR/sonicflow_app/core-swift"
check_step core_swift

run_step ios_build xcodebuild -project "$IOS_PROJECT" -scheme "$IOS_SCHEME" -configuration Debug -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build
check_step ios_build

run_ios_tests_if_available

run_step mac_build xcodebuild -project "$ROOT_DIR/sonicflow_app/safari-extension/FlowTones/FlowTones.xcodeproj" -scheme "FlowTones (macOS)" -configuration Debug -destination "generic/platform=macOS" CODE_SIGNING_ALLOWED=NO build
check_step mac_build

if [[ -z "${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}" && ! -f "$ROOT_DIR/sonicflow_app/android-app/local.properties" ]]; then
  echo "==> android_build"
  echo "Skipping Android warning audit because no Android SDK path is configured."
elif ! command -v java >/dev/null 2>&1; then
  echo "==> android_build"
  echo "Skipping Android warning audit because Java is not available on PATH."
else
  run_step android_unit_tests bash -lc "cd '$ROOT_DIR/sonicflow_app/android-app' && ./gradlew testDebugUnitTest"
  check_step android_unit_tests

  run_step android_build bash -lc "cd '$ROOT_DIR/sonicflow_app/android-app' && ./gradlew assembleDebug"
  check_step android_build
fi
