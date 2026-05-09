# STATUS

Date: 2026-04-28

## Platform Focus

- Active product targets: iPhone app, Safari Web Extension, macOS menu-bar app, and Apple-look web app/PWA.
- Removed product targets: legacy non-Safari browser and non-iOS mobile surfaces.
- Safari Web Extension resources now live in `sonicflow_app/extensions/safari`.
- Native macOS menu-bar app now lives beside iOS under `sonicflow_app/apps/macos`.

## Current Work

- Runtime beat-engine hot paths were tightened in JS and Swift by removing per-frame angle/gain recomputation.
- Web Extension playback now tracks scheduled sources so stop/start cycles clean up active audio nodes.
- Default build/test architecture now follows the active Apple/Safari target set.
- Warning audits pass `ENABLE_APP_INTENTS_METADATA_GENERATION=NO` for Xcode builds so toolchain metadata warnings are treated as real warnings, not ignored noise.
- Safari Web Extension resource dependencies were refreshed, including `esbuild`.

## Verification Scope

- `make test` covers JS core, Swift core, Safari Web Extension resources, GitHub workflow guards, and available iOS tests.
- `make verify` runs the zero-warning audit across active Apple/Safari build and test surfaces.
- Removed legacy browser/mobile product targets are excluded from default verification.

## Next Step

- Add a streaming renderer to `SonicFlowCore` so iOS and macOS can share realtime beat generation instead of maintaining a macOS-local engine fork.
