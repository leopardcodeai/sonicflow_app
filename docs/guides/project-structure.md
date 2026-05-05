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
├── safari-web-extension/  # Safari Web Extension resources
├── safari-extension/  # Safari-only extension notes/resources
├── ios-app/           # native iPhone app
├── macos-app/         # native macOS menu-bar app
└── web-app/           # active Apple-look web app/PWA surface
```

## Organization Principles

- Shared signal-generation logic for active targets lives in `core-js/` and `core-swift/`.
- Safari Web Extension JavaScript resources live in `safari-web-extension/`.
- Platform-specific session/playback and UI logic stays in the active iOS, Safari, macOS, and web runtime directories.
- Repo-level docs and reports belong under `docs/` at the root, not inside platform folders.
- Cross-platform checks and scripts stay in `scripts/`.
- Android and Chrome product code are removed from the active platform tree and are not part of default verification.

## Recommended Workflow

1. Use `make help` to discover entry points.
2. Use `make safari-web-assets`, `make web`, `make ios`, `make mac`, and `make test` while iterating on active targets.
3. Run `make verify` before sharing changes.
