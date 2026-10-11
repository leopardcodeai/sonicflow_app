# Cinematic Liquid Glass Leopard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the SF-32 Cinematic Leopard Hero redesign for the native iOS and macOS SonicFlow surfaces.

**Architecture:** Keep the implementation low-risk by refactoring existing SwiftUI files instead of adding new Xcode project files. Add small private SwiftUI subviews inside the current root view files, keep all existing audio/session state paths intact, and use token-backed colors plus material/glass-ready surfaces for the new hierarchy.

**Tech Stack:** SwiftUI, SonicFlowCore, Xcode iOS/macOS targets, generated `BrandTokens`, local `make test-ios` and `make mac` verification.

---

## File Map

- Modify: `sonicflow_app/ios-app/SonicFlow/FlowMode+UI.swift`
  - Add mode ritual copy used by the hero.
- Modify: `sonicflow_app/ios-app/SonicFlowTests/FlowModePresentationTests.swift`
  - Lock the new ritual labels/summaries.
- Modify: `sonicflow_app/ios-app/SonicFlow/LeopardBackgroundView.swift`
  - Make the leopard layer more cinematic while preserving text safety through gradients.
- Modify: `sonicflow_app/ios-app/SonicFlow/ModeCard.swift`
  - Make inactive modes more compact and the active mode more visibly selected.
- Modify: `sonicflow_app/ios-app/SonicFlow/ContentView.swift`
  - Recompose the iOS screen around hero, visualizer, primary transport, mode selector, and compact controls.
- Modify: `sonicflow_app/safari-extension/SonicFlow/macOS (App)/FlowMode+UI.swift`
  - Mirror mode ritual copy for macOS.
- Modify: `sonicflow_app/safari-extension/SonicFlow/macOS (App)/LeopardBackgroundView.swift`
  - Increase cinematic depth in the procedural macOS layer.
- Modify: `sonicflow_app/safari-extension/SonicFlow/macOS (App)/ModeCard.swift`
  - Make popover mode cards compact and active-state forward.
- Modify: `sonicflow_app/safari-extension/SonicFlow/macOS (App)/SonicFlowPopoverView.swift`
  - Recompose the popover around the same hero hierarchy at macOS density.

No new Swift files are planned, which avoids manual `.pbxproj` edits.

---

### Task 1: Add Mode Ritual Presentation Contract

**Files:**
- Modify: `sonicflow_app/ios-app/SonicFlow/FlowMode+UI.swift`
- Modify: `sonicflow_app/ios-app/SonicFlowTests/FlowModePresentationTests.swift`
- Modify: `sonicflow_app/safari-extension/SonicFlow/macOS (App)/FlowMode+UI.swift`

- [ ] **Step 1: Write the failing iOS presentation test**

Add these assertions to `testFlowModePresentationValuesMatchDesignSpec()` in `sonicflow_app/ios-app/SonicFlowTests/FlowModePresentationTests.swift`:

```swift
XCTAssertEqual(FlowMode.focus.ritualTitle, "Focus Ritual")
XCTAssertEqual(FlowMode.flow.ritualTitle, "Flow Ritual")
XCTAssertEqual(FlowMode.meditation.ritualTitle, "Meditation Ritual")
XCTAssertEqual(FlowMode.sleep.ritualTitle, "Sleep Ritual")
XCTAssertEqual(FlowMode.focus.ritualSummary, "Gamma clarity for deep work and bright attention.")
XCTAssertEqual(FlowMode.flow.ritualSummary, "Alpha momentum for creative rhythm and smooth concentration.")
XCTAssertEqual(FlowMode.meditation.ritualSummary, "Theta spaciousness for breath, stillness, and recovery.")
XCTAssertEqual(FlowMode.sleep.ritualSummary, "Delta softness for slow unwinding and rest.")
```

- [ ] **Step 2: Run the focused failing test**

Run:

```sh
make test-ios
```

Expected: FAIL because `ritualTitle` and `ritualSummary` do not exist yet.

- [ ] **Step 3: Add ritual copy to iOS FlowMode presentation**

Add this extension content in `sonicflow_app/ios-app/SonicFlow/FlowMode+UI.swift`:

```swift
var ritualTitle: String {
    switch self {
    case .focus:
        return "Focus Ritual"
    case .flow:
        return "Flow Ritual"
    case .meditation:
        return "Meditation Ritual"
    case .sleep:
        return "Sleep Ritual"
    }
}

var ritualSummary: String {
    switch self {
    case .focus:
        return "Gamma clarity for deep work and bright attention."
    case .flow:
        return "Alpha momentum for creative rhythm and smooth concentration."
    case .meditation:
        return "Theta spaciousness for breath, stillness, and recovery."
    case .sleep:
        return "Delta softness for slow unwinding and rest."
    }
}
```

- [ ] **Step 4: Mirror ritual copy for macOS**

Add the same `ritualTitle` and `ritualSummary` computed properties to `sonicflow_app/safari-extension/SonicFlow/macOS (App)/FlowMode+UI.swift`.

- [ ] **Step 5: Run the focused passing test**

Run:

```sh
make test-ios
```

Expected: PASS.

- [ ] **Step 6: Commit**

```sh
git add sonicflow_app/ios-app/SonicFlow/FlowMode+UI.swift sonicflow_app/ios-app/SonicFlowTests/FlowModePresentationTests.swift "sonicflow_app/safari-extension/SonicFlow/macOS (App)/FlowMode+UI.swift"
git commit -m "SF-32: add cinematic mode copy"
```

---

### Task 2: Build The iOS Cinematic Hero Surface

**Files:**
- Modify: `sonicflow_app/ios-app/SonicFlow/LeopardBackgroundView.swift`
- Modify: `sonicflow_app/ios-app/SonicFlow/ModeCard.swift`
- Modify: `sonicflow_app/ios-app/SonicFlow/ContentView.swift`

- [ ] **Step 1: Strengthen the iOS leopard background safely**

Replace the current `LeopardBackgroundView.body` layering with a stronger wallpaper treatment:

```swift
ZStack {
    Image("LeopardWallpaper")
        .resizable()
        .scaledToFill()
        .saturation(1.16)
        .contrast(1.08)
        .overlay(Color.black.opacity(0.2))

    LinearGradient(
        colors: [
            Color.black.opacity(0.05),
            BrandTokens.Neutral.ink.opacity(0.52),
            Color.black.opacity(0.82)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    RadialGradient(
        colors: [
            BrandTokens.Accent.gold.opacity(0.26),
            Color.clear
        ],
        center: .topTrailing,
        startRadius: 16,
        endRadius: 320
    )
}
```

- [ ] **Step 2: Make iOS mode cards compact and active-forward**

Update `ModeCard` so the button content uses:

```swift
.frame(maxWidth: .infinity, minHeight: isSelected ? 104 : 84, alignment: .leading)
.padding(BrandTokens.Spacing.md)
.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: BrandTokens.Radius.lg, style: .continuous))
.overlay(
    RoundedRectangle(cornerRadius: BrandTokens.Radius.lg, style: .continuous)
        .stroke(isSelected ? mode.accentColor : Color.white.opacity(0.14), lineWidth: isSelected ? 2 : 1)
)
.shadow(color: isSelected ? mode.accentColor.opacity(0.48) : .clear, radius: 30)
```

Keep visible labels for `mode.displayName`, beat frequency, and `mode.shortDescription`.

- [ ] **Step 3: Recompose `ContentView.body` around the hero hierarchy**

Refactor the `VStack` order in `ContentView.swift` to this hierarchy:

```swift
hero(for: screenState)

VisualizerView(
    isPlaying: audioManager.isPlaying,
    mode: screenState.selectedMode
)

transportPanel(for: screenState)

modeSelector(for: screenState)

sessionPanel(for: screenState)

starterPack

Text(screenState.selectedFileLabel)
```

Use `.safeAreaPadding(.bottom, BrandTokens.Spacing.lg)` on the scroll content if needed to preserve bottom breathing room.

- [ ] **Step 4: Replace the iOS header with cinematic hero copy**

Replace `header(for:)` with a `hero(for:)` helper that renders:

```swift
Text("SonicFlow")
    .font(.caption.weight(.semibold))
    .foregroundStyle(BrandTokens.Accent.gold)
    .textCase(.uppercase)

Text(screenState.selectedMode.ritualTitle)
    .font(.system(size: 48, weight: .black, design: .rounded))
    .foregroundStyle(BrandTokens.Neutral.fg)
    .minimumScaleFactor(0.72)

Text(screenState.selectedMode.ritualSummary)
    .font(.subheadline)
    .foregroundStyle(BrandTokens.Neutral.fg.opacity(0.78))

Text("\(Int(screenState.selectedMode.beatHz)) Hz • \(screenState.durationLabel)")
    .font(.caption.weight(.semibold))
    .foregroundStyle(screenState.selectedMode.accentColor)
```

Place the status chip inside the same hero block:

```swift
Label(screenState.statusLabel, systemImage: audioManager.isPlaying ? "waveform.circle.fill" : "waveform.circle")
    .font(.caption.weight(.semibold))
    .foregroundStyle(audioManager.isPlaying ? BrandTokens.Accent.success : BrandTokens.Neutral.muted)
```

Put the hero content on `.ultraThinMaterial` with a large continuous radius and an accent stroke.

- [ ] **Step 5: Add iOS transport panel**

Add a private helper in `ContentView.swift`:

```swift
private func transportPanel(for screenState: FlowScreenState) -> some View {
    HStack(spacing: BrandTokens.Spacing.md) {
        Button {
            audioManager.togglePlayback()
        } label: {
            Label(screenState.transportLabel, systemImage: audioManager.isPlaying ? "pause.fill" : "play.fill")
                .font(.headline.weight(.bold))
                .frame(width: 128, height: 58)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .tint(screenState.selectedMode.accentColor)

        FilePickerButton(playerManager: playerManager)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
    .padding(BrandTokens.Spacing.md)
    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
}
```

- [ ] **Step 6: Add iOS mode selector and compact session panel helpers**

Extract the existing mode grid into:

```swift
private func modeSelector(for screenState: FlowScreenState) -> some View {
    VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
        Text("Choose ritual")
            .font(.headline)
            .foregroundStyle(BrandTokens.Neutral.fg)

        LazyVGrid(columns: columns, spacing: BrandTokens.Spacing.md) {
            ForEach(FlowMode.allCases, id: \.self) { mode in
                ModeCard(mode: mode, isSelected: mode == screenState.selectedMode) {
                    audioManager.currentMode = mode
                }
            }
        }
    }
}
```

Group duration, neural layer, ambient mix, and pulse depth into one material-backed `sessionPanel(for:)`. Keep the same bindings:

```swift
Binding(
    get: { audioManager.sessionSettings.durationMinutes },
    set: audioManager.updateDuration
)
Binding(
    get: { audioManager.sessionSettings.ambientMix },
    set: audioManager.updateAmbientMix
)
Binding(
    get: { audioManager.sessionSettings.pulseDepth },
    set: audioManager.updatePulseDepth
)
```

- [ ] **Step 7: Run iOS tests**

Run:

```sh
make test-ios
```

Expected: PASS.

- [ ] **Step 8: Commit**

```sh
git add sonicflow_app/ios-app/SonicFlow/ContentView.swift sonicflow_app/ios-app/SonicFlow/LeopardBackgroundView.swift sonicflow_app/ios-app/SonicFlow/ModeCard.swift
git commit -m "SF-32: redesign iOS cinematic hero"
```

---

### Task 3: Build The macOS Popover Parity

**Files:**
- Modify: `sonicflow_app/safari-extension/SonicFlow/macOS (App)/LeopardBackgroundView.swift`
- Modify: `sonicflow_app/safari-extension/SonicFlow/macOS (App)/ModeCard.swift`
- Modify: `sonicflow_app/safari-extension/SonicFlow/macOS (App)/SonicFlowPopoverView.swift`

- [ ] **Step 1: Increase macOS procedural leopard depth**

In `LeopardBackgroundView.swift`, keep deterministic Canvas spots but add a richer overlay after the Canvas:

```swift
.overlay(
    LinearGradient(
        colors: [
            Color.black.opacity(0.05),
            BrandTokens.Neutral.ink.opacity(0.46),
            Color.black.opacity(0.78)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
)
.overlay(
    RadialGradient(
        colors: [BrandTokens.Accent.gold.opacity(0.2), Color.clear],
        center: .topTrailing,
        startRadius: 12,
        endRadius: 260
    )
)
```

- [ ] **Step 2: Make macOS mode cards popover-dense**

Update `ModeCard` to use `.thinMaterial`, tighter typography, and active glow:

```swift
.frame(maxWidth: .infinity, minHeight: isSelected ? 78 : 66, alignment: .leading)
.padding(BrandTokens.Spacing.sm)
.background(.thinMaterial, in: RoundedRectangle(cornerRadius: BrandTokens.Radius.md, style: .continuous))
.overlay(
    RoundedRectangle(cornerRadius: BrandTokens.Radius.md, style: .continuous)
        .stroke(isSelected ? mode.accentColor : Color.white.opacity(0.14), lineWidth: isSelected ? 2 : 1)
)
.shadow(color: isSelected ? mode.accentColor.opacity(0.42) : .clear, radius: 24)
```

- [ ] **Step 3: Recompose macOS popover root order**

In `SonicFlowPopoverView.swift`, reorder the main stack to:

```swift
hero
transportCluster
modeGrid
sessionCluster
starterSessionsPanel
sourceSection
sourceStatus
```

Keep the outer `.frame(width: 360, height: 620)`.

- [ ] **Step 4: Replace macOS hero**

Replace the current `hero` with:

```swift
private var hero: some View {
    VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
        HStack {
            Text("SonicFlow")
                .font(.caption.weight(.semibold))
                .foregroundStyle(BrandTokens.Accent.gold)
                .textCase(.uppercase)
            Spacer()
            Label(audioManager.isPlaying ? "Active" : "Off", systemImage: audioManager.isPlaying ? "waveform.circle.fill" : "waveform.circle")
                .font(.caption.weight(.medium))
                .foregroundStyle(audioManager.isPlaying ? BrandTokens.Accent.success : BrandTokens.Neutral.muted)
        }

        Text(audioManager.currentMode.ritualTitle)
            .font(.system(size: 30, weight: .black, design: .rounded))
            .foregroundStyle(BrandTokens.Neutral.fg)

        Text(audioManager.currentMode.ritualSummary)
            .font(.caption)
            .foregroundStyle(BrandTokens.Neutral.fg.opacity(0.76))

        Text("\(Int(audioManager.currentPreset.beatFrequencyHz)) Hz • \(Int(audioManager.currentPreset.carrierFrequencyHz)) Hz • \(audioManager.durationMinutes) min")
            .font(.caption.weight(.semibold))
            .foregroundStyle(audioManager.currentMode.accentColor)
    }
    .padding(BrandTokens.Spacing.md)
    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: BrandTokens.Radius.lg, style: .continuous))
    .overlay(
        RoundedRectangle(cornerRadius: BrandTokens.Radius.lg, style: .continuous)
            .stroke(audioManager.currentMode.accentColor.opacity(0.5), lineWidth: 1)
    )
}
```

- [ ] **Step 5: Split macOS controls into transport and session clusters**

Replace the bottom full-width `Button` and old `controlPanel`/`atmospherePanel` sequence with:

```swift
private var transportCluster: some View {
    HStack(spacing: BrandTokens.Spacing.sm) {
        Button {
            audioManager.togglePlayback()
        } label: {
            Label(audioManager.isPlaying ? "Pause" : "Start", systemImage: audioManager.isPlaying ? "pause.fill" : "play.fill")
                .font(.headline.weight(.bold))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(audioManager.currentMode.accentColor)

        Picker("Source", selection: $audioManager.selectedSource) {
            Text("System").tag(AudioSource.system)
            Text("File").tag(AudioSource.file)
        }
        .pickerStyle(.segmented)
        .frame(width: 132)
    }
    .padding(BrandTokens.Spacing.sm)
    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: BrandTokens.Radius.lg, style: .continuous))
}
```

Create `sessionCluster` by combining the existing duration stepper, beat volume slider, ambient mix slider, and pulse depth slider in one material-backed `VStack`.

- [ ] **Step 6: Run macOS build**

Run:

```sh
make mac
```

Expected: BUILD SUCCEEDED.

- [ ] **Step 7: Commit**

```sh
git add "sonicflow_app/safari-extension/SonicFlow/macOS (App)/SonicFlowPopoverView.swift" "sonicflow_app/safari-extension/SonicFlow/macOS (App)/LeopardBackgroundView.swift" "sonicflow_app/safari-extension/SonicFlow/macOS (App)/ModeCard.swift"
git commit -m "SF-32: redesign macOS cinematic popover"
```

---

### Task 4: Final Verification And PR Prep

**Files:**
- Verify all touched files.

- [ ] **Step 1: Run formatting/syntax checks**

Run:

```sh
git diff --check
```

Expected: no output.

- [ ] **Step 2: Run targeted native gates**

Run:

```sh
make test-ios
make mac
```

Expected: iOS tests pass and macOS build succeeds.

- [ ] **Step 3: Run full warning audit if targeted gates pass**

Run:

```sh
make verify
```

Expected: warning audit passes or reports only pre-accepted toolchain warnings already filtered by `scripts/check_warnings.sh`.

- [ ] **Step 4: Push branch and open PR**

Use this PR metadata:

```sh
git push -u origin feature/SF-32-cinematic-liquid-glass-leopard
gh pr create \
  --base main \
  --head feature/SF-32-cinematic-liquid-glass-leopard \
  --title "[SF-32] Cinematic Liquid Glass Leopard redesign" \
  --body "## Ticket
- SF-32: https://linear.app/captain-leopard-ai-engineering/issue/SF-32/cinematic-liquid-glass-leopard-redesign-for-ios-and-macos

## Summary
- redesign iOS around a mode-driven Cinematic Leopard Hero
- mirror the native visual hierarchy in the macOS menu-bar popover
- preserve existing audio/session behavior while improving native glass/material hierarchy

## Verification
- make test-ios
- make mac
- make verify"
```

Expected: PR opens in GitHub and uses repo-required ticket title/body format.
