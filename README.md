# FlowTones Monorepo

FlowTones overlays neural beat modulation on top of user audio across browser and Apple platforms.
The repository is organized around shared audio engines plus platform-specific UI/runtime layers.

## Repository Layout

```text
flowtones/
├── sonicflow_app/
│   ├── core-js/          (SF-1, beatEngine.js)
│   ├── core-swift/       (SF-2, FlowTonesCore Swift Package)
│   ├── core-android/     (SF-3, beatengine Android library module)
│   ├── chrome-extension/ (SF-4, SF-5, SF-6)
│   ├── safari-extension/ (SF-7, SF-10, SF-11)
│   ├── ios-app/          (SF-8, SF-9)
│   └── docs/
├── Makefile
└── README.md
```

## Platform Support

| Platform | Audio sources | System audio capture |
|---|---|---|
| Chrome Extension | YouTube, SoundCloud tab audio | N/A (content script on web audio context) |
| Safari Extension (iOS/macOS) | Web content audio inside extension contexts | macOS target only (see limitations) |
| iOS App | Local audio file + generated beat layer | No |
| macOS App | Local audio file + generated beat layer | Yes (macOS 14.2+ path planned/targeted) |
| Android | Core beat engine module implemented, app UI/service pending | No (app pending) |

## Quick Start

### Chrome

```bash
make chrome
```

Artifacts are copied to `dist/chrome/` for loading as an unpacked extension.

### Safari

```bash
make safari
```

This opens `sonicflow_app/safari-extension/FlowTones/FlowTones.xcodeproj` in Xcode.

### iOS

```bash
make ios
```

Compiles the iOS app for simulator via `xcodebuild`.

### macOS

```bash
make mac
```

Compiles the macOS app target via `xcodebuild`.

### Android

```bash
make android
```

Runs `./gradlew assembleDebug` when an Android app wrapper is present.

## Beat Modes Reference

| Mode | Beat frequency | Use case |
|---|---|---|
| Focus | 40 Hz (gamma) | Deep concentration |
| Flow | 10 Hz (alpha) | Light productivity |
| Meditation | 6 Hz (theta) | Calm and reflection |
| Sleep | 2 Hz (delta) | Wind-down and sleep prep |

## Architecture Overview

- Shared engines: `core-js`, `core-swift`, and `core-android` hold beat synthesis logic.
- Platform UIs: browser extension UI, SwiftUI app surfaces, and future Android app Compose UI.
- Runtime integration: each platform owns playback/session plumbing while reusing the closest shared beat engine.

## Known Limitations

- iOS and Android do not support Spotify/system-output capture in this repo state.
- System audio capture is macOS-only and intended for macOS 14.2+ capable implementations.
- Android app module (`android-app/`) is not in this repository yet; current Android deliverable is `core-android/beatengine`.
