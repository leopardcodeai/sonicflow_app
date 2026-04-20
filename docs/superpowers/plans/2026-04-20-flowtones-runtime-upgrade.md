# FlowTones Runtime Upgrade Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade SonicFlow toward the latest standalone FlowTones runtime and UI across all supported platforms while documenting capability limits honestly.

**Architecture:** Keep Swift-native runtime adoption closest to upstream, mirror the supported settings model in Android and browser surfaces, and migrate platform UIs in slices so every surface remains buildable and testable throughout the rollout.

**Tech Stack:** SwiftUI, AVFoundation, XcodeGen/Xcode, Kotlin/Compose, Android foreground services, browser extension HTML/CSS/JS, Node test runner, Markdown docs

---

## File Structure

- Modify: `README.md`
- Create/modify: `docs/superpowers/specs/2026-04-20-flowtones-runtime-upgrade-design.md`
- Create/modify: `sonicflow_app/ios-app/FlowTones/*.swift`
- Create/modify: `sonicflow_app/ios-app/FlowTonesTests/*.swift`
- Create/modify: `sonicflow_app/safari-extension/FlowTones/macOS (App)/*.swift`
- Create/modify: `sonicflow_app/android-app/app/src/main/java/com/sonicflow/app/**/*.kt`
- Create/modify: `sonicflow_app/android-app/app/src/test/**/*.kt`
- Create/modify: `sonicflow_app/android-app/app/src/androidTest/**/*.kt`
- Create/modify: `sonicflow_app/chrome-extension/*`
- Create/modify: `sonicflow_app/safari-extension/FlowTones/Shared (App)/Resources/*`

### Task 1: Land the cross-platform settings model slice

**Files:**
- Modify: `sonicflow_app/chrome-extension/popup-model.js`
- Modify: `sonicflow_app/chrome-extension/popup.test.js`
- Modify: `sonicflow_app/android-app/app/src/main/java/com/sonicflow/app/ui/FlowModeUi.kt`
- Modify: `sonicflow_app/android-app/app/src/test/java/com/sonicflow/app/ui/FlowModeUiTest.kt`
- Create: `sonicflow_app/ios-app/FlowTones/FlowToneSettings.swift`
- Create: `sonicflow_app/ios-app/FlowTonesTests/FlowToneSettingsTests.swift`

- [ ] **Step 1: Write the failing tests**

```swift
func testStandardSettingsUsePresetDefaults() {
    let settings = FlowToneSettings.standard(for: .flow, durationMinutes: 5)
    XCTAssertEqual(settings.durationMinutes, 5)
    XCTAssertEqual(settings.ambientMix, FlowMode.flow.defaultAmbientMix)
}
```

```javascript
test("popup model exposes supported FlowTones settings defaults", () => {
  assert.deepEqual(DEFAULT_SETTINGS, {
    mode: "focus",
    volume: 15,
    active: false,
    durationMinutes: 25,
    ambientMix: 45,
    pulseDepth: 95
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd sonicflow_app/chrome-extension && node --test popup.test.js`
Expected: FAIL because the new settings keys are missing

Run: `xcodebuild test -project sonicflow_app/ios-app/FlowTones.xcodeproj -scheme FlowTones -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:FlowTonesTests/FlowToneSettingsTests`
Expected: FAIL because `FlowToneSettings` is not defined

- [ ] **Step 3: Write the minimal implementation**

```javascript
export const DEFAULT_SETTINGS = {
  mode: "focus",
  volume: 15,
  active: false,
  durationMinutes: 25,
  ambientMix: 45,
  pulseDepth: 95
};
```

```swift
struct FlowToneSettings: Equatable {
    var mode: FlowMode
    var durationMinutes: Int
    var ambientMix: Double
    var pulseDepth: Double

    static func standard(for mode: FlowMode, durationMinutes: Int = 25) -> Self {
        Self(
            mode: mode,
            durationMinutes: durationMinutes,
            ambientMix: mode.defaultAmbientMix,
            pulseDepth: mode.defaultPulseDepth
        )
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd sonicflow_app/chrome-extension && node --test popup.test.js`
Expected: PASS

Run: `xcodebuild test -project sonicflow_app/ios-app/FlowTones.xcodeproj -scheme FlowTones -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:FlowTonesTests/FlowToneSettingsTests`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add sonicflow_app/chrome-extension/popup-model.js sonicflow_app/chrome-extension/popup.test.js sonicflow_app/ios-app/FlowTones/FlowToneSettings.swift sonicflow_app/ios-app/FlowTonesTests/FlowToneSettingsTests.swift
git commit -m "SF-31: add shared FlowTones settings model slice"
```

### Task 2: Upgrade the iOS native FlowTones screen

**Files:**
- Modify: `sonicflow_app/ios-app/FlowTones/ContentView.swift`
- Modify: `sonicflow_app/ios-app/FlowTones/AudioManager.swift`
- Modify: `sonicflow_app/ios-app/FlowTones/ModeCard.swift`
- Modify: `sonicflow_app/ios-app/FlowTones/LeopardBackgroundView.swift`
- Modify: `sonicflow_app/ios-app/FlowTonesTests/FlowScreenStateTests.swift`

- [ ] **Step 1: Write the failing tests**

```swift
func testScreenStateShowsDurationAmbientAndPulseControls() {
    let state = FlowScreenState.preview()
    XCTAssertTrue(state.showsAdvancedControls)
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `xcodebuild test -project sonicflow_app/ios-app/FlowTones.xcodeproj -scheme FlowTones -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:FlowTonesTests/FlowScreenStateTests`
Expected: FAIL because advanced control state does not exist

- [ ] **Step 3: Write minimal implementation**

```swift
struct FlowScreenState {
    var showsAdvancedControls: Bool
}
```

Add FlowTones-style sections for:
- preset hero
- duration
- ambient mix
- pulse depth

- [ ] **Step 4: Run tests to verify they pass**

Run: `xcodebuild test -project sonicflow_app/ios-app/FlowTones.xcodeproj -scheme FlowTones -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:FlowTonesTests/FlowScreenStateTests`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add sonicflow_app/ios-app/FlowTones sonicflow_app/ios-app/FlowTonesTests
git commit -m "SF-31: upgrade iOS FlowTones screen"
```

### Task 3: Upgrade the native macOS Safari wrapper app

**Files:**
- Modify: `sonicflow_app/safari-extension/FlowTones/macOS (App)/AudioManager.swift`
- Modify: `sonicflow_app/safari-extension/FlowTones/macOS (App)/FlowTonesPopoverView.swift`
- Modify: `sonicflow_app/safari-extension/FlowTones/macOS (App)/ModeCard.swift`

- [ ] **Step 1: Write the failing tests or preview assertions**

Document the expected popover states and add any Swift testable state helpers first.

- [ ] **Step 2: Run verification to confirm failure**

Run: `xcodebuild build -project sonicflow_app/safari-extension/FlowTones/FlowTones.xcodeproj -scheme 'FlowTones (macOS)'`
Expected: build/test gap or missing state helpers

- [ ] **Step 3: Write minimal implementation**

Add the supported subset of:
- richer native settings state
- FlowTones-style popover layout
- Leopard wallpaper treatment

- [ ] **Step 4: Run verification to confirm success**

Run: `xcodebuild build -project sonicflow_app/safari-extension/FlowTones/FlowTones.xcodeproj -scheme 'FlowTones (macOS)'`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add sonicflow_app/safari-extension/FlowTones/macOS\ \(App\)
git commit -m "SF-31: upgrade macOS FlowTones wrapper app"
```

### Task 4: Upgrade Android session model and UI

**Files:**
- Modify: `sonicflow_app/android-app/app/src/main/java/com/sonicflow/app/ui/MainScreen.kt`
- Modify: `sonicflow_app/android-app/app/src/main/java/com/sonicflow/app/ui/FlowTonesViewModel.kt`
- Modify: `sonicflow_app/android-app/app/src/main/java/com/sonicflow/app/audio/SessionState.kt`
- Modify: `sonicflow_app/android-app/app/src/main/java/com/sonicflow/app/audio/SessionCommand.kt`
- Modify: `sonicflow_app/android-app/app/src/test/java/com/sonicflow/app/ui/FlowTonesViewModelTest.kt`
- Modify: `sonicflow_app/android-app/app/src/androidTest/java/com/sonicflow/app/ui/MainScreenTest.kt`

- [ ] **Step 1: Write the failing tests**

```kotlin
@Test
fun startSessionUsesCurrentDurationAmbientAndPulseSettings() {
    // assert new session state fields are forwarded
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd sonicflow_app/android-app && ./gradlew testDebugUnitTest --tests '*FlowTonesViewModelTest*'`
Expected: FAIL because richer session settings are absent

- [ ] **Step 3: Write minimal implementation**

Add Kotlin-native settings/state fields and wire them through the view model and UI.

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd sonicflow_app/android-app && ./gradlew testDebugUnitTest connectedDebugAndroidTest`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add sonicflow_app/android-app/app
git commit -m "SF-31: upgrade Android FlowTones session UI"
```

### Task 5: Upgrade Chrome and Safari extension web shells

**Files:**
- Modify: `sonicflow_app/chrome-extension/popup.html`
- Modify: `sonicflow_app/chrome-extension/popup.js`
- Modify: `sonicflow_app/chrome-extension/popup-model.js`
- Modify: `sonicflow_app/chrome-extension/popup-behavior.test.js`
- Modify: `sonicflow_app/safari-extension/FlowTones/Shared (App)/Resources/Base.lproj/Main.html`
- Modify: `sonicflow_app/safari-extension/FlowTones/Shared (App)/Resources/Style.css`
- Modify: `sonicflow_app/safari-extension/FlowTones/Shared (App)/Resources/Script.js`

- [ ] **Step 1: Write the failing tests**

```javascript
test("popup renders FlowTones-style advanced controls for supported settings", async () => {
  assert.match(document.body.textContent, /Ambient Mix/);
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd sonicflow_app/chrome-extension && node --test`
Expected: FAIL because the new controls are not rendered

- [ ] **Step 3: Write minimal implementation**

Add supported advanced controls and FlowTones-style layout, while omitting unsupported native-only features.

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd sonicflow_app/chrome-extension && node --test`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add sonicflow_app/chrome-extension sonicflow_app/safari-extension/FlowTones/Shared\ \(App\)/Resources
git commit -m "SF-31: upgrade browser FlowTones shells"
```

### Task 6: Update README and verification guidance

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Write the failing doc expectation**

Add a checklist to verify README covers:
- adopted runtime concepts
- per-platform support matrix
- brand asset usage
- verification commands

- [ ] **Step 2: Verify the gap exists**

Run: `rg -n "ambient mix|pulse depth|render|leopard_wallpaper|singing bowl|support matrix" README.md`
Expected: missing or incomplete coverage

- [ ] **Step 3: Write minimal implementation**

Update `README.md` with the new capability matrix and asset usage notes.

- [ ] **Step 4: Verify the doc update**

Run: `rg -n "ambient mix|pulse depth|render|leopard_wallpaper|support matrix" README.md`
Expected: matches new documentation

- [ ] **Step 5: Commit**

```bash
git add README.md
git commit -m "SF-31: document FlowTones platform capabilities"
```
