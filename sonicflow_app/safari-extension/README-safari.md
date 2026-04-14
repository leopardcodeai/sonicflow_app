# FlowTones Safari Web Extension

## What This Is

Safari wrapper project for the FlowTones Chrome extension, generated via `safari-web-extension-converter` and pointed at the shared extension sources in `../chrome-extension`.

## Build And Run

1. Open `/Users/alexanderbrunker/Coding/soundhealing_sonicflow/sonicflow_app/safari-extension/FlowTones/FlowTones.xcodeproj`
2. Select either the `FlowTones (iOS)` or `FlowTones (macOS)` app target and a simulator/device
3. Build and run from Xcode
4. When Safari opens, enable the FlowTones extension in Safari settings

## Enable Unsigned Extensions

### macOS Safari

1. Open Safari
2. Enable the Develop menu in `Safari > Settings > Advanced`
3. In the Develop menu, allow unsigned extensions for local testing if prompted
4. Go to `Safari > Settings > Extensions` and enable `FlowTones`

### iOS Simulator

1. Run the iOS host app from Xcode
2. Open `Settings > Apps > Safari > Extensions`
3. Enable `FlowTones`
4. Allow the extension on test sites if Safari prompts for permission

## Known Safari Limitations

- Safari flagged the Chrome manifest `background.type` key during conversion; the wrapper still builds, but MV3 support differs from Chrome
- Messaging and storage APIs should go through `browser` when available and fall back to `chrome`
- The project currently links the shared extension files from `../chrome-extension`, so rebuilding the Chrome bundle updates Safari resources too
- Safari MV3 behavior can differ from Chrome for service worker lifecycle and some host-permission edge cases
