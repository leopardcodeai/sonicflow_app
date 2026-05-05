# GitHub Workflow

## Repository

- Owner: `alexanderbrunker-star`
- Repository: `sonicflow_app`
- Default branch: `main`

## Branch Convention

- `sf/SF-1-shared-js-engine`
- `sf/SF-2-swift-core-package`
- `sf/SF-3-iphone-safari-mac-slice`
- Follow the same `sf/SF-<ticket>-<short-slug>` pattern for later tickets.

## Pull Request Convention

- One branch per Linear issue
- One draft PR per branch until verification is complete
- PR title format: `[SF-x] concise outcome`

## Verification Rules

- `SF-1`: `cd sonicflow_app/shared/core-js && npm test`
- `SF-2`: `cd sonicflow_app/shared/core-swift && swift test`
- `SF-3`: `make safari-web-assets && make web && make ios && make mac`
- Fast local confidence before opening a PR: `make test`
- All PRs touching shipped code: `make verify`

## Warning Standard

- PRs are expected to merge with zero project warnings across active JS, Swift, iOS, Safari Web Extension resources, web app, and macOS menu-bar build/test surfaces.
- `./scripts/check_warnings.sh` is the shared audit entry point for local verification and CI enforcement.
- Toolchain warnings should be resolved through build settings when possible. If a warning cannot be acted on in repo code, document and filter it explicitly in the script instead of ignoring it in review.
