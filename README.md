# FlowTones Monorepo

FlowTones overlays neural beat modulation on top of user audio across browser and Apple/Android platforms.
The repository is organized around shared audio engines plus platform-specific UI/runtime layers.

## Repository Layout

```text
soundhealing_sonicflow/
├── sonicflow_app/
│   ├── core-js/          (SF-1, beatEngine.js)
│   ├── core-swift/       (SF-2, FlowTonesCore Swift Package)
│   ├── core-android/     (SF-3, beatengine Android library module)
│   ├── chrome-extension/ (SF-4, SF-5, SF-6)
│   ├── safari-extension/ (SF-7)
│   ├── ios-app/          (SF-8, SF-9)
│   ├── android-app/      (SF-12, SF-13, SF-20)
│   ├── mac-app/          (macOS app module placeholder)
│   └── docs/
├── Makefile
└── README.md
```

## Platform Support

| Platform | Audio sources | System audio capture |
|---|---|---|
| Chrome Extension | YouTube, SoundCloud tab audio | N/A (content script on web audio context) |
| Safari Extension (iOS/macOS) | Web content audio inside extension contexts | No dedicated system capture path |
| iOS App | Local audio file + generated beat layer | No |
| macOS App | Local audio file + generated beat layer | Partial/limited path only |
| Android App | Local audio service + generated beat layer (`android-app`) | No |

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

Builds debug APK from `sonicflow_app/android-app`.

Manual install/run (optional):

```bash
cd sonicflow_app/android-app
./gradlew installDebug
adb shell am start -n com.sonicflow.app/.MainActivity
```

## Beat Modes Reference

| Mode | Beat frequency | Use case |
|---|---|---|
| Focus | 40 Hz (gamma) | Deep concentration |
| Flow | 10 Hz (alpha) | Light productivity |
| Meditation | 6 Hz (theta) | Calm and reflection |
| Sleep | 2 Hz (delta) | Wind-down and sleep prep |

## Architecture Overview

- Shared engines: `core-js`, `core-swift`, and `core-android` hold beat synthesis logic.
- Platform UIs: browser extensions, SwiftUI app surfaces, and Jetpack Compose Android UI.
- Runtime integration: each platform owns playback/session plumbing while reusing the closest shared beat engine.

## Known Limitations

- iOS and Android do not support Spotify/system-output capture in this repository.
- Safari extension behavior can differ between iOS Safari and macOS Safari due to Web Extension API differences.
- Android emulator/device setup must match installed SDK/platform tools (common failure: missing or mismatched API image).
