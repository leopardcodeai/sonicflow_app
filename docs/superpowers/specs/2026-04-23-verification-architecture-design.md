# Verification Architecture Design

## Summary

Harden SonicFlow's repo-wide verification path so a branch cannot look merge-ready while skipping important test surfaces. The scope is deliberately limited to test and verification architecture: no product runtime behavior, UI behavior, audio behavior, or brand behavior changes.

## Current Context

The monorepo has working platform-level checks, but they are unevenly exposed:

- `make test-core-js`, `make test-chrome`, and `make test-core-swift` run focused test suites.
- Android unit tests and iOS app tests exist, but they are not first-class Makefile targets.
- `make verify` builds several platform surfaces and runs shared core tests, but it does not run Chrome extension tests, Android unit tests, or iOS app tests.
- `scripts/check_warnings.sh` owns the merge warning policy, but its warning classifier is embedded inline and has no direct test coverage.

## Design

The verification architecture will use `scripts/check_warnings.sh` as the single repo-wide merge gate and make its behavior explicit.

The script will:

- keep the existing step runner and warning audit model
- expose a test-only mode for the warning classifier
- run Chrome extension tests after the Chrome extension build
- run Android unit tests when Android prerequisites are configured
- run iOS app tests when a compatible simulator destination is available
- keep iOS and macOS builds in the full audit
- continue filtering known toolchain-only warnings already accepted by the repo

The Makefile will become the discoverable local interface for the same surfaces:

- `make test-core-js`
- `make test-core-swift`
- `make test-chrome`
- `make test-android`
- `make test-ios`
- `make test`
- `make verify`

## Test Strategy

Add a shell test suite for `scripts/check_warnings.sh` that validates the warning classifier before expanding the verification flow. The test will exercise accepted toolchain noise, real warning detection, and mixed logs.

Then run the focused targets and the full `make verify` command to prove the repo still passes the stronger gate.

## Acceptance

- `scripts/check_warnings.sh --self-test` passes.
- `make test` runs the local unit-level test suite across JS, Chrome, Swift, Android when available, and iOS when a simulator is available.
- `make verify` includes the unit-level surfaces plus existing build and warning checks.
- Documentation tells contributors which command to run for focused tests and merge verification.
- The branch is pushed to GitHub as a draft PR after local validation.
