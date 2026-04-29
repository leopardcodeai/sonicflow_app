# SonicFlow Safari Web Extension

## What This Is

Safari wrapper project for the SonicFlow Safari web extension, generated via `safari-web-extension-converter` and pointed at the shared extension sources in `../safari-web-extension`.

Public app name: `SonicFlow`.
The generated Xcode project, paths, and schemes now use `SonicFlow`.

## Build And Run

1. Install and build the shared extension assets:
   - `cd sonicflow_app/safari-web-extension`
   - `npm ci`
   - `npx esbuild content_script.js --bundle --outfile=dist/content_script.js`
2. Open `sonicflow_app/safari-extension/SonicFlow/SonicFlow.xcodeproj`
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

- Safari Web Extension MV3 behavior can vary by iOS and macOS release for service worker lifecycle and host-permission edge cases.
- Messaging and storage APIs should go through the Safari `browser` namespace.
- The project currently links the shared extension files from `../safari-web-extension`, so rebuilding the Safari web extension bundle updates Safari resources too.
