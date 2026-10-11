# SonicFlow Safari Web Extension

## What This Is

Safari wrapper project for SonicFlow Web Extension resources. The shared resource directory is `../safari-web-extension`; non-Safari browser product targets are inactive for the current platform focus.

Public app name: `SonicFlow`.
The generated Xcode project, paths, and schemes now use `SonicFlow`.

## Build And Run

1. Install and build the shared extension assets:
   - `cd sonicflow_app/extensions/safari`
   - `npm ci`
   - `npm run build`
2. Open `sonicflow_app/apps/macos/SonicFlow.xcodeproj`
3. Select either the `SonicFlow (iOS)` or `SonicFlow (macOS)` app target and a simulator/device
4. Build and run from Xcode
5. When Safari opens, enable the SonicFlow extension in Safari settings

You can also let the repo prepare those shared resources for you with `make mac` from the repository root.

## Enable Unsigned Extensions

### macOS Safari

1. Open Safari
2. Enable the Develop menu in `Safari > Settings > Advanced`
3. In the Develop menu, allow unsigned extensions for local testing if prompted
4. Go to `Safari > Settings > Extensions` and enable `SonicFlow`

### iOS Simulator

1. Run the iOS host app from Xcode
2. Open `Settings > Apps > Safari > Extensions`
3. Enable `SonicFlow`
4. Allow the extension on test sites if Safari prompts for permission

## Known Safari Limitations

- Safari flagged the legacy manifest `background.type` key during conversion; the wrapper still builds, but MV3 support differs across browsers
- Messaging and storage APIs should go through `browser` when available, with the converter fallback kept only for local compatibility
- The project currently links the shared extension files from `../safari-web-extension`, so rebuilding those resources updates Safari too
- Safari MV3 behavior can differ from other WebExtension engines for service worker lifecycle and some host-permission edge cases
