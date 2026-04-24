# SF-32 Cinematic Liquid Glass Leopard Design

## Goal

Move the native SonicFlow experience from "dark cards on a leopard wallpaper" to a state-of-the-art **Cinematic Leopard Hero** interface for iOS and macOS.

The redesign should feel more premium, more Apple-native, and more immediately branded while preserving the existing SonicFlow session model and audio behavior.

## Selected Direction

The chosen direction is **Cinematic Leopard Hero**:

- The current mode becomes the screen's visual hero.
- Leopard imagery is more visible and emotionally present.
- Text and controls sit on glass or material surfaces, never directly on the leopard texture.
- The primary action is a large Start/Pause control.
- Secondary controls are compact, grouped, and readable.

This direction intentionally prioritizes a memorable brand impression over a dense control-console layout.

## Platforms In Scope

### iOS App

Update `sonicflow_app/ios-app/SonicFlow`:

- `ContentView.swift`
- `ModeCard.swift`
- `LeopardBackgroundView.swift`
- new small SwiftUI helper views as needed

### macOS Menu-Bar App

Update `sonicflow_app/safari-extension/SonicFlow/macOS (App)`:

- `SonicFlowPopoverView.swift`
- `ModeCard.swift`
- `LeopardBackgroundView.swift`
- new small SwiftUI helper views as needed

Chrome, Safari web-extension shell, and Android are intentionally out of scope for this implementation round. They should inherit the visual language later after the native direction is proven.

## Product Hierarchy

### Hero

The selected mode drives the top-level visual language:

- Focus: `Focus Ritual`
- Flow: `Flow Ritual`
- Meditation: `Meditation Ritual`
- Sleep: `Sleep Ritual`

The hero should show:

- product name `SonicFlow`
- current mode ritual title
- beat frequency and preset metadata
- active/off status
- a short mode-specific sentence

The legacy `SonicFlow` name may remain as small runtime/context metadata, but it should not lead the UI.

### Primary Action

Start/Pause becomes the dominant action:

- iOS: large circular or rounded prominent control near the lower portion of the first screen.
- macOS: compact but still visually primary inside the popover.

The action should use the current mode accent for state, glow, or tint.

### Secondary Controls

Session duration, neural layer, ambient mix, pulse depth, source, and file status should be grouped into compact glass/material clusters.

The UI should avoid stacking many full-width opaque cards. Controls may remain visible, but the visual hierarchy should make them secondary to the hero and transport action.

### Mode Selection

Mode selection should feel like switching rituals, not selecting equal data cards.

Recommended treatment:

- The active mode receives the strongest glass/accent treatment.
- Inactive modes are smaller chips or compact cards.
- Existing mode labels, beat frequencies, and short descriptions remain unchanged.

## Visual System

### Leopard Layer

The leopard image or procedural texture is a brand layer, not a content layer.

Rules:

- Keep it visible enough to define the product at first glance.
- Add darker gradients where text density increases.
- Do not place body text directly over raw leopard imagery.
- Do not animate the leopard layer.

### Glass Surfaces

Use native Liquid Glass APIs where available and material fallbacks where not available.

Guidelines from Apple docs:

- Standard SwiftUI controls should be allowed to pick up the newest platform appearance first.
- Custom glass elements should use `glassEffect(_:in:)` where supported.
- Multiple nearby custom glass elements should share a `GlassEffectContainer`.
- Interactive glass should be used only for tappable/focusable elements.
- Earlier OS versions should fall back to `.ultraThinMaterial` or `.thinMaterial` inside the same shapes.

References:

- Apple Liquid Glass overview: https://developer.apple.com/documentation/TechnologyOverviews/liquid-glass
- Apple `glassEffect(_:in:)`: https://developer.apple.com/documentation/swiftui/view/glasseffect%28_%3Ain%3A%29
- Apple `GlassEffectContainer`: https://developer.apple.com/documentation/swiftui/glasseffectcontainer

### Shape And Density

- Use large, cinematic radii for hero surfaces.
- Use tighter radii for dense macOS controls.
- Keep buttons and chips stable in size so status text does not resize the layout.
- Keep text readable at small popover widths.

### Color

Use existing generated brand tokens:

- gold for brand identity
- current mode color for state and focus
- success only for active/playing state
- neutral foreground/muted colors for text

Do not introduce new hex values outside the token source of truth.

## Architecture

Introduce only small, local SwiftUI helpers if they reduce duplication:

- `GlassSurface`: wraps content in native Liquid Glass on new OS versions and material fallback on older versions.
- `HeroModeHeader`: renders product name, ritual title, status, and current-mode metadata.
- `SessionControlPanel`: groups duration, neural layer, and atmosphere controls.
- `ModeSelector`: renders active/inactive mode selection in the new hierarchy.

These helpers can be duplicated per target if sharing them through a package creates project churn. The implementation should prefer a low-risk native UI refactor over broad build-system changes.

## Interaction And State

No audio/session behavior changes are planned.

The redesign must preserve:

- mode switching
- starter-session application
- duration updates
- beat volume updates
- ambient mix updates
- pulse depth updates
- play/pause behavior
- file picking and source status
- macOS system-audio capture availability messaging

## Accessibility

- Preserve visible text labels for controls.
- Keep sufficient contrast by placing text on glass/material surfaces.
- Use semantic SwiftUI controls instead of purely decorative custom gestures.
- Avoid relying on glow alone to communicate active state.

## Verification

Run targeted native checks after implementation:

```sh
make test-ios
make mac
```

If shared verification surfaces are touched or warnings change, run:

```sh
make verify
```

## Out Of Scope

- Audio engine changes.
- New brand token generation.
- Chrome extension redesign.
- Safari web-extension shell redesign.
- Android Compose redesign.
- New animation systems beyond lightweight SwiftUI transitions or native glass interaction.

## Acceptance Criteria

- iOS main screen clearly reads as a Cinematic Leopard Hero experience.
- macOS popover mirrors the same direction without becoming cramped.
- The current mode is the dominant visual context.
- Start/Pause is the dominant action.
- Secondary controls remain discoverable and readable.
- Liquid Glass usage follows Apple's custom-view guidance where available.
- Older OS fallbacks compile and retain the same information hierarchy.
- Existing native tests/build gates pass.
