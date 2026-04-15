# STATUS

## Ticket-ID & Scope
- Active ticket: SF-11
- Linear state: In Review
- Working branch: sf/SF-11-menu-bar-app-ui
- Worktree: /Users/alexanderbrunker/Coding/soundhealing_sonicflow
- PR: https://github.com/alexanderbrunker-star/sonicflow_app/pull/11

## Current Stand
- Frühere unvollständige Arbeit zu SF-11 wurde fortgesetzt (bestehender Branch + handoff).
- SF-11 ist implementiert, gebaut, committed und in PR #11.
- PR-Labels gesetzt: `codex`, `codex-automation`.
- Linear-Kommentar mit PR + Build-Validierung wurde hinzugefügt.
- Linear-Status wurde erfolgreich von `In Progress` auf `In Review` gesetzt.

## Done
- Menu-Bar-App Verhalten umgesetzt:
- `NSStatusItem` mit SF Symbol `waveform`.
- Click öffnet/schließt `NSPopover` mit `FlowTonesPopoverView` (300x400).
- Dock-Icon ausgeblendet via `LSUIElement = YES`.
- SwiftUI Popover UI umgesetzt:
- Mode Grid (2-spaltig) mit `ModeCard`.
- Source-Toggle `System audio` / `File` (segmented).
- System audio: Permission-Status + `Start Capture` Button.
- File: `NSOpenPanel` Picker + Dateiname.
- Beat-Volume Slider + Statuszeile (`Active – ...` oder `Stopped`).
- Shortcut-Handling umgesetzt:
- `Cmd+Shift+F` toggelt FlowTones über `NSEvent.addGlobalMonitorForEvents` (+ local monitor für Fokusfall).
- Projektintegration:
- neue macOS-App-Dateien in `FlowTones.xcodeproj` eingebunden.
- macOS Deployment Target für App auf `13.0` gesetzt.

## Open
- Optionaler Feinschliff: Entfernen nicht mehr benötigter Legacy-WebView/Storyboard-Ressourcen aus dem macOS-App-Target.
- Warten auf Reviewer-Feedback in PR #11.

## Tests
- Erfolgreich:
- `xcodebuild -project sonicflow_app/safari-extension/FlowTones/FlowTones.xcodeproj -scheme 'FlowTones (macOS)' -configuration Debug -sdk macosx -derivedDataPath /tmp/flowtones-derived CODE_SIGNING_ALLOWED=NO build`
- Ergebnis: `BUILD SUCCEEDED`
- Hinweis:
- Xcode gibt weiterhin CoreSimulator/Log-Warnungen in dieser Umgebung aus; Build war dennoch erfolgreich.

## Affected Files (SF-11)
- /Users/alexanderbrunker/Coding/soundhealing_sonicflow/sonicflow_app/safari-extension/FlowTones/macOS (App)/AppDelegate.swift
- /Users/alexanderbrunker/Coding/soundhealing_sonicflow/sonicflow_app/safari-extension/FlowTones/macOS (App)/AudioManager.swift
- /Users/alexanderbrunker/Coding/soundhealing_sonicflow/sonicflow_app/safari-extension/FlowTones/macOS (App)/BeatEngine.swift
- /Users/alexanderbrunker/Coding/soundhealing_sonicflow/sonicflow_app/safari-extension/FlowTones/macOS (App)/Color+Hex.swift
- /Users/alexanderbrunker/Coding/soundhealing_sonicflow/sonicflow_app/safari-extension/FlowTones/macOS (App)/FlowMode+UI.swift
- /Users/alexanderbrunker/Coding/soundhealing_sonicflow/sonicflow_app/safari-extension/FlowTones/macOS (App)/FlowTonesPopoverView.swift
- /Users/alexanderbrunker/Coding/soundhealing_sonicflow/sonicflow_app/safari-extension/FlowTones/macOS (App)/Info.plist
- /Users/alexanderbrunker/Coding/soundhealing_sonicflow/sonicflow_app/safari-extension/FlowTones/macOS (App)/MacMenuCommands.swift
- /Users/alexanderbrunker/Coding/soundhealing_sonicflow/sonicflow_app/safari-extension/FlowTones/macOS (App)/ModeCard.swift
- /Users/alexanderbrunker/Coding/soundhealing_sonicflow/sonicflow_app/safari-extension/FlowTones/macOS (App)/PlayerManager.swift
- /Users/alexanderbrunker/Coding/soundhealing_sonicflow/sonicflow_app/safari-extension/FlowTones/FlowTones.xcodeproj/project.pbxproj

## Next Step
- Auf Reviewer-Feedback der PR #11 reagieren und nur bei konkreten Änderungswünschen nachschärfen.
