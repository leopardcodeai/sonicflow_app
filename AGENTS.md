# SonicFlow AI Agent Instructions

This file encodes project-specific conventions for AI agents working on SonicFlow.

## 1. Skill-Based Navigation

Before writing any code, always check if a skill exists:
- iOS Simulator: `conorluddy/ios-simulator-skill` — use for UI navigation, accessibility tree dump, app launching
- Brainstorming: Use before any creative work (features, components, UI)
- TDD: Use when implementing features or bugfixes
- Debugging: Use for bugs, test failures, unexpected behavior

Install: `npx skills add <owner/repo@skill> -g -y`

## 2. Accessibility Tree > Pixel Coordinates

Never use cliclick/mouse coordinates for UI testing.
- XCUITest: `app.buttons["identifier"].tap()` via accessibility identifiers
- iOS Simulator: `screen_mapper.py --udid <UDID>` → show all UI elements
- Use .accessibilityIdentifier on all interactive elements

## 3. Mock Mode for Simulator Testing

Simulator cameras don't work. Use mock transport:
- MockSessionTransport for in-process protocol testing
- Firebase RTDB as bridge between simulator instances
- E2E tests use MockTransport (in-process, no real device needed)

## 4. Project Structure (Feature-First)

```
SonicFlow/
  Features/
    Host/       → Audio management, visualization
    Home/       → ContentView, ModeCard, FlowScreenState
    Session/    → Presets, settings
    Profile/    → Examples, mode UI
  Core/
    DesignSystem/ → BrandTokens, Color+Hex, LeopardBackgroundView
    Models/       → Data models, LiveActivity
  App/
    SonicFlowApp.swift
```

Tests mirror the same structure under SonicFlowTests/.

## 5. DesignLabels > Hardcoded Strings

ALL user-facing strings in DesignLabels.swift (shared SonicFlowCore package):
- English = Source of Truth (in `DesignLabels.text(.key)`)
- German translations alongside
- `.accessibilityIdentifier(DesignLabels.Accessibility.hostStartCrewPhoto)`
- No hardcoded strings in SwiftUI views

## 6. Testing 3-Layers

Layer 1 — XCTest (Swift):
- Unit tests for models, view models, services
- MockSessionTransport for end-to-end protocol
- Closure injection for engine overrides

Layer 2 — XCUITest (Swift):
- Button taps via accessibility, not coordinates
- `app.buttons[DesignLabels.Accessibility.playButton].tap()`
- Runs on simulator, mockMode needed

Layer 3 — Playwright (TypeScript):
- Web app E2E tests
- Mock Firebase RTDB via `page.route()`
- Viewports: 390x844 (Mobile), 820x1180 (Tablet)

## 7. CI/CD

iOS CI: macos-14 runner, xcodegen → xcodebuild
- `brew install xcodegen xcbeautify swiftlint`
- `-only-testing:SonicFlowTests` for unit
- `-only-testing:SonicFlowUITests` for UI

Webapp CI: Playwright chromium before E2E
- `npx playwright install chromium`

## 8. TDD: Write Tests Before Code

- Write failing test before implementation
- Run `make test` and `make verify` before handoff
- All tests must pass before claiming completion

## 9. SwiftUI Conventions

- #Preview blocks go at file END (not inside struct body)
- No `let` expressions in Preview body → call View directly
- `Color.clear.overlay { }` for stable layout during image transitions
- `.safeAreaPadding(.top)` only on iOS 17+; prefer ZStack with natural safe area

## 10. Always Search Skills First (1% Rule)

Before any implementation:
1. Ask "Is there a skill for this?"
2. Even 1% chance → check skill
3. Skill > own implementation

## 11. Branch + PR Workflow

- Branch format: `sf/TICKET-ID-short-slug`
- PR title: `[TICKET-ID] concise outcome`
- Include Linear link and verification output in PR body
- Run `make test` + `make verify` before handoff

## 12. Multi-Device Testing

- XCUITest can test ONE app instance at a time
- Multi-device: idb + screen_mapper + navigator (Python)
- Or: Firebase RTDB as bridge between simulators
- Or: E2E happy path with MockTransport (in-process)
