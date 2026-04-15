# STATUS

## Ticket-ID & Scope
- Active ticket: SF-11
- Linear state: In Progress
- Working branch: sf/SF-11-menu-bar-app-ui
- Worktree: /Users/alexanderbrunker/Coding/soundhealing_sonicflow

## Current Stand
- Frühere unvollständige Arbeit zu SF-11 wurde fortgesetzt (bestehender Branch + handoff).
- PR/Review-Check per `gh` war in dieser Umgebung nicht möglich (Netzwerkzugriff auf api.github.com blockiert).
- Lokale Änderungen vor Start: nur untracked `STATUS.md`.

## Done (this run)
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
- Kein PR in diesem Run erstellt.
- Feinschliff: optional Entfernen nicht mehr benötigter Legacy-WebView/Storyboard-Ressourcen aus dem macOS-App-Target.

## Tests
- Erfolgreich:
- `xcodebuild -project sonicflow_app/safari-extension/FlowTones/FlowTones.xcodeproj -scheme 'FlowTones (macOS)' -configuration Debug -sdk macosx -derivedDataPath /tmp/flowtones-derived CODE_SIGNING_ALLOWED=NO build`
- Ergebnis: `BUILD SUCCEEDED`
- Hinweis:
- Xcode gibt in Sandbox weiterhin CoreSimulator/Log-Warnungen aus, Build war dennoch erfolgreich.

## Affected Files (this run)
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
- /Users/alexanderbrunker/Coding/soundhealing_sonicflow/STATUS.md

## Next Step
- SF-11 auf diesem Branch final reviewen und in PR überführen; danach Linear auf `In Review` setzen.
