# Project Structure Guide

## Top Level

```text
soundhealing_sonicflow/
├── docs/            # architecture, guides, graphics, reports
├── scripts/         # repo-wide automation and audits
├── sonicflow_app/   # product code (shared cores + platform runtimes)
├── Makefile         # common developer entry points
└── STATUS.md        # latest project snapshot
```

## Product Code Layout

```text
sonicflow_app/
├── core-js/           # shared JS beat engine
├── core-swift/        # shared Swift package beat engine
├── safari-web-extension/  # Safari web extension runtime
├── safari-extension/  # Safari extension + macOS target
└── ios-app/           # native iOS app
```

## Organization Principles

- Shared signal-generation logic lives in `core-*` directories.
- Platform-specific session/playback and UI logic stays in platform runtime directories.
- Repo-level docs and reports belong under `docs/` at the root, not inside platform folders.
- Cross-platform checks and scripts stay in `scripts/`.
- Legacy non-Apple source folders are not active build, verification, or product targets.

## Recommended Workflow

1. Use `make help` to discover entry points.
2. Use platform-specific build/test targets while iterating.
3. Run `make verify` before sharing changes.
