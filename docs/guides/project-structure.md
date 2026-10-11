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
├── apps/
│   ├── ios/           # native iPhone app
│   ├── macos/         # native macOS menu-bar app
│   └── web/           # active Apple-look web app/PWA surface
├── extensions/
│   └── safari/        # Safari Web Extension resources
└── shared/
    ├── core-js/       # shared JS beat engine
    └── core-swift/    # shared Swift package beat engine
```

## Organization Principles

- Shared signal-generation logic for active targets lives in `sonicflow_app/shared/core-js/` and `sonicflow_app/shared/core-swift/`.
- Safari Web Extension JavaScript resources live in `sonicflow_app/extensions/safari/`.
- Platform-specific session/playback and UI logic stays in the active iOS, Safari, macOS, and web runtime directories.
- Repo-level docs and reports belong under `docs/` at the root, not inside platform folders.
- Cross-platform checks and scripts stay in `scripts/`.
- Legacy non-Safari browser and non-iOS mobile product code are removed from the active platform tree and are not part of default verification.

## Recommended Workflow

1. Use `make help` to discover entry points.
2. Use `make safari-web-assets`, `make web`, `make ios`, `make mac`, and `make test` while iterating on active targets.
3. Run `make verify` before sharing changes.
