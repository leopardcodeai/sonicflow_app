# sonicflow_app

Monorepo for the SonicFlow core engines and platform clients.

## Current Scope

- `sonicflow_app/core-js`: shared JavaScript beat engine
- `sonicflow_app/core-swift`: shared Swift beat engine package
- `sonicflow_app/core-android`: shared Kotlin/Android beat engine module
- platform folders are reserved for Chrome, Safari, iOS, macOS, and Android app work

## Delivery Pipeline

1. Build and verify `SF-1`, `SF-2`, `SF-3`
2. Use the core packages to unlock platform tickets
3. Open one branch and one PR per Linear issue wherever practical
4. Run CI for JavaScript and Swift on every PR

## GitHub Workflow

- Default branch: `main`
- Issue branches: `sf/<issue-id>-<slug>`
- PR titles: `[SF-x] short summary`
- Linear ticket status is updated as work moves from `Backlog` to `In Progress`, then `In Review`

