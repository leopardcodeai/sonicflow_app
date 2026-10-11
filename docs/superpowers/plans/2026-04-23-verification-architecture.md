# Verification Architecture Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Strengthen SonicFlow's local and merge verification path so existing tests are first-class and warning policy is covered by tests.

**Architecture:** Keep `scripts/check_warnings.sh` as the merge gate, extract its warning classifier into a callable function, and add test-mode coverage before expanding the command sequence. Use the Makefile as the friendly entry point for focused platform tests and full verification.

**Tech Stack:** Bash, Python 3, GNU Make, Node test runner, SwiftPM, xcodebuild, Gradle

---

## File Structure

- Modify: `scripts/check_warnings.sh`
  - Owns repo-wide verification, warning classification, optional simulator detection, and self-test mode.
- Modify: `Makefile`
  - Exposes focused test targets and keeps `make verify` as the full merge gate.
- Modify: `README.md`
  - Documents the updated local test and verification commands.
- Modify: `docs/guides/github-workflow.md`
  - Aligns merge rules with the stronger verification gate.

### Task 1: Add warning-classifier self-test support

**Files:**
- Modify: `scripts/check_warnings.sh`

- [ ] **Step 1: Write the failing test mode**

Add a `--self-test` mode to `scripts/check_warnings.sh` that writes sample logs to a temporary directory and asserts that the classifier returns:

```text
empty output for accepted AppIntents metadata noise
empty output for accepted Gradle deprecation summary
non-empty output for a real Swift warning
non-empty output for a real Kotlin warning line
```

- [ ] **Step 2: Run test to verify it fails**

Run: `./scripts/check_warnings.sh --self-test`

Expected: fail because `--self-test` is not implemented on the current branch.

- [ ] **Step 3: Implement the classifier function**

Move the existing inline Python warning classifier behind a `collect_warnings()` function that can be called both by `check_step()` and by `--self-test`.

- [ ] **Step 4: Run the self-test**

Run: `./scripts/check_warnings.sh --self-test`

Expected: pass with a concise self-test confirmation.

### Task 2: Expand the merge verification gate

**Files:**
- Modify: `scripts/check_warnings.sh`

- [ ] **Step 1: Add Chrome extension tests to the audit**

Add a `chrome_test` step:

```bash
run_step chrome_test bash -lc "cd '$ROOT_DIR/sonicflow_app/chrome-extension' && npm test"
check_step chrome_test
```

- [ ] **Step 2: Add Android unit tests when prerequisites exist**

Inside the existing Android prerequisite branch, run:

```bash
run_step android_unit_tests bash -lc "cd '$ROOT_DIR/sonicflow_app/android-app' && ./gradlew testDebugUnitTest"
check_step android_unit_tests
run_step android_build bash -lc "cd '$ROOT_DIR/sonicflow_app/android-app' && ./gradlew assembleDebug"
check_step android_build
```

- [ ] **Step 3: Add iOS simulator tests when a destination exists**

Add helper logic that uses `xcodebuild -showdestinations` to find an `iPhone 17 Pro` simulator if present, otherwise the first available iOS simulator. If no simulator exists, print a skip reason. When one exists, run:

```bash
run_step ios_tests xcodebuild -project "$ROOT_DIR/sonicflow_app/ios-app/SonicFlow.xcodeproj" -scheme SonicFlow -configuration Debug -destination "$IOS_TEST_DESTINATION" CODE_SIGNING_ALLOWED=NO test
check_step ios_tests
```

- [ ] **Step 4: Run the full gate**

Run: `make verify`

Expected: all configured steps pass with accepted toolchain-only warnings filtered.

### Task 3: Expose focused test targets

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Add `test-android`, `test-ios`, and aggregate `test` targets**

Add phony targets that run Android unit tests when Gradle is available, iOS simulator tests through the verification script destination helper, and all unit-level test suites together.

- [ ] **Step 2: Run the aggregate target**

Run: `make test`

Expected: focused unit-level suites pass or skip only when prerequisites are missing.

### Task 4: Update contributor documentation

**Files:**
- Modify: `README.md`
- Modify: `docs/guides/github-workflow.md`

- [ ] **Step 1: Document focused and full commands**

Update the command lists so contributors know `make test` is the fast cross-platform test command and `make verify` is the full merge gate.

- [ ] **Step 2: Confirm docs mention the same target names as the Makefile**

Run: `rg -n "make test|make verify|test-android|test-ios" README.md docs/guides/github-workflow.md Makefile`

Expected: output shows matching target names in docs and Makefile.

### Task 5: Final validation and publish

**Files:**
- All modified files

- [ ] **Step 1: Run formatting/diff sanity**

Run: `git diff --check`

Expected: no whitespace errors.

- [ ] **Step 2: Run focused tests**

Run: `make test`

Expected: all configured focused tests pass.

- [ ] **Step 3: Run full verification**

Run: `make verify`

Expected: all configured verification steps pass.

- [ ] **Step 4: Commit and publish**

Run:

```bash
git add scripts/check_warnings.sh Makefile README.md docs/guides/github-workflow.md docs/superpowers/specs/2026-04-23-verification-architecture-design.md docs/superpowers/plans/2026-04-23-verification-architecture.md
git commit -m "chore: harden verification architecture"
git push -u origin codex/optimize-code-test-architecture
```

Open a draft pull request against `main` titled `[codex] Harden verification architecture`.
