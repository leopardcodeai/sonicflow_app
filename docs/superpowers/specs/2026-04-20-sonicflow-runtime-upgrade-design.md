# SF-31 SonicFlow Runtime Upgrade Design

## Summary

Upgrade SonicFlow across iOS, macOS/Safari app shell, Android, Chrome, and Safari extension surfaces using the latest standalone `SonicFlow` module from `Sound-Healing-Assistant-iOS`.

The design goal is:
- adopt the newer SonicFlow runtime concepts where each platform can support them
- move each product surface toward the standalone SonicFlow UI
- retain the SonicFlow Leopard identity through the existing wallpaper and singing-bowl asset
- document exact platform capability boundaries in the repo README

## Current Context

The upstream `SonicFlow` module adds a richer runtime model than the current SonicFlow implementations:
- `SonicFlowPreset`
- `SonicFlowSettings`
- `SonicFlowBeatEngine`
- `SonicFlowAmbientEngine`
- `SonicFlowRenderer`
- `SonicFlowCache`
- `SonicFlowExample`

Current SonicFlow surfaces are inconsistent:
- iOS and macOS provide a simple beat layer plus optional file/system layer
- Android has a lighter session/service model
- Chrome and Safari web shells only expose popup state and browser-safe controls
- README still describes the pre-upgrade capability matrix

## Design Principles

1. Use upstream SonicFlow semantics instead of inventing parallel models.
2. Keep the product name `SonicFlow`, while allowing `SonicFlow` to remain in internal module paths where renaming would create churn.
3. Keep browser surfaces honest about what they can and cannot do.
4. Reuse existing repo brand assets instead of creating new brand sources in this ticket.
5. Roll out the runtime in slices that preserve working builds on each platform.

## Architecture

### Shared Runtime Direction

The upgrade will create a common conceptual model across platforms:
- preset metadata: labels, descriptions, beat/carrier defaults, ambient defaults, accent mapping
- settings state: duration, ambient mix, pulse depth, beat/carrier overrides where supported
- examples/starter sessions
- cache/export concepts only on platforms that can support them natively

The implementation does not require a single cross-platform source file for every runtime type. Instead:
- Swift-native code should stay close to the upstream module for iOS/macOS
- Android gets a Kotlin-native equivalent model
- browser extensions get a reduced JS state model that mirrors supported settings only

### UI Direction

All platforms should converge toward the standalone SonicFlow app structure:
- clear header/status area
- preset-first selection
- richer session controls when supported
- calmer, more editorial visual hierarchy than the current utility-first Leopard pass

Leopard identity is layered on top through:
- `brand/assets/wallpapers/leopard_wallpaper.png` as the primary atmospheric backdrop, cropped per surface
- the premium golden Tibetan singing bowl PNG as hero/iconography where bitmap assets are appropriate

### Platform Capability Boundaries

#### iOS

Highest-parity target:
- native `SonicFlowPreset` and `SonicFlowSettings`
- ambient synthesis support
- pulse depth and duration support
- offline render/cache flow where the app can support it
- SonicFlow-style main screen

#### macOS / Safari wrapper app

Near-parity native target:
- shared Swift runtime concepts with iOS where practical
- improved popover/app shell presentation
- native-only features clearly separated from the Safari web extension shell

#### Android

Supported subset target:
- Kotlin equivalent of presets and richer session settings
- SonicFlow-style screen hierarchy
- audio runtime improvements that fit the existing foreground-service architecture
- no fake export parity if the underlying implementation is not worth the complexity in this ticket

#### Chrome extension

Browser-safe subset target:
- updated preset metadata and popup model
- SonicFlow-style popup layout and content hierarchy
- no native render/export promises

#### Safari extension web shell

Same browser-safe subset target as Chrome, while staying visually aligned with the native Apple surfaces.

## Testing Strategy

The rollout should be test-first by platform slice:
- Swift: unit tests around settings, preset mapping, and any renderer/cache helpers
- Android: unit tests for new session model plus UI/instrumentation smoke tests for new controls
- Chrome/Safari web shell: popup model and DOM behavior tests
- README and docs: verified against actual supported features after implementation

## Risks

- Trying to force full native parity into browser surfaces will create misleading UI.
- Directly replacing all platform UIs in one shot is risky unless the runtime model lands in small slices.
- Asset integration can sprawl if app icons, hero art, and wallpaper treatment are not kept intentionally scoped.

## Delivery Shape

Implementation should land in these broad phases:
1. shared runtime model uplift
2. iOS/macOS native adoption
3. Android adoption
4. Chrome/Safari web-surface adoption
5. README/documentation alignment

## Acceptance

- SonicFlow uses the latest SonicFlow runtime concepts where support is real.
- All user-facing platforms move toward the standalone SonicFlow UI.
- Leopard wallpaper and singing-bowl art are integrated intentionally.
- README accurately documents the final support matrix and limits.
