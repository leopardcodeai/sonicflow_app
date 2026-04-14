# SonicFlow Execution Log

## Goal

Build the SonicFlow app as a monorepo with three shared core beat engines first, then platform implementations that import those cores.

## Delivery Order

1. `SF-1` Shared JS beat engine
2. `SF-2` Swift beat engine package
3. `SF-3` Kotlin/Android beat engine module
4. `SF-4` to `SF-6` Chrome extension
5. `SF-7` Safari Web Extension
6. `SF-8` to `SF-9` iOS app
7. `SF-10` to `SF-11` macOS app
8. `SF-12` to `SF-13` Android app
9. `SF-14` parity pass, root README, Makefile

## Current Working Set

### In Progress

- `SF-8` iOS audio engine

### Deferred Until Core Is Stable

- `SF-7` Safari conversion
- `SF-9` iOS UI
- `SF-10` macOS system audio
- `SF-11` macOS menu bar UI
- `SF-12` Android app/service
- `SF-13` Android UI
- `SF-14` parity, docs, Makefile

## Repository Structure

```text
sonicflow_app/
  core-js/
  core-swift/
  core-android/
  chrome-extension/
  safari-extension/
  ios-app/
  mac-app/
  android-app/
  docs/
```

## Implementation Notes

- The JS core is the first source of truth and the quickest path to a testable Chrome first win.
- The Swift and Kotlin cores must match the same mode constants, envelope, and AM synthesis formula.
- Platform work stays intentionally light until the core APIs are verified.
- Active agent split:
- `SF-1` local implementation in `core-js`
- `SF-2` worker agent in `core-swift`
- `SF-3` worker agent in `core-android`
- GitHub pipeline is being established in parallel so each issue can land as its own branch and PR.
- `SF-4` now provides the first Chrome extension skeleton with MV3 wiring, content-script messaging, placeholder popup, and icon assets.
- `SF-5` layers in the interactive popup: mode cards, beat volume slider, storage persistence, and tab messaging hooks.
- `SF-6` moves the extension onto the shared JS core and bundles the content script through `esbuild`, with chunk scheduling for continuous playback.
- `SF-7` wraps the Chrome extension in a Safari Xcode project and aligns the shared JS to `browser`/`chrome` compatible messaging.
- `SF-8` now has an iOS SwiftUI/Xcode project generated with `xcodegen`, wired to the local `FlowTonesCore` package and building for the iOS simulator.
