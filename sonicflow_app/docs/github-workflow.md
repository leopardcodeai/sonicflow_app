# GitHub Workflow

## Repository

- Owner: `alexanderbrunker-star`
- Repository: `sonicflow_app`
- Default branch: `main`

## Branch Convention

- `sf/SF-1-shared-js-engine`
- `sf/SF-2-swift-core-package`
- `sf/SF-3-kotlin-core-module`
- follow the same pattern for later tickets

## Pull Request Convention

- One branch per Linear issue
- One draft PR per branch until verification is complete
- PR title format: `[SF-x] concise outcome`

## Verification Rules

- `SF-1`: `cd sonicflow_app/core-js && npm test`
- `SF-2`: `cd sonicflow_app/core-swift && swift test`
- `SF-3`: blocked locally until Java/Gradle toolchain is present

## Current Core Status

- `SF-1`: implemented and locally verified
- `SF-2`: implemented and locally verified
- `SF-3`: implemented, verification blocked by missing Java runtime and Gradle wrapper
