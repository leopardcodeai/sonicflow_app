# STATUS

## Ticket-ID & Scope
- Active ticket: SF-12
- Linear state: In Progress
- Working branch: sf/SF-12-android-app
- Worktree: /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app
- PR: not opened yet

## Current Stand
- Android App Modul `sonicflow_app/android-app` neu erstellt.
- Gradle Wrapper (`./gradlew`) vorhanden und ausführbar.
- BeatEngine-Modul als lokales Gradle-Modul eingebunden.
- Foreground `AudioService` + `FlowTonesViewModel` + Hilt + Compose Main Screen implementiert.

## Done
- Projekt-/Build-Setup:
  - `android-app/settings.gradle.kts` + `build.gradle.kts` + `gradle.properties`
  - `app/build.gradle.kts` inkl. Compose, Hilt, Coroutines, Material
  - Gradle Wrapper Dateien (`gradlew`, `gradlew.bat`, `gradle/wrapper/*`)
- App-Implementierung:
  - `AudioService` mit Foreground Notification, AudioFocusRequest, Beat-Loop, optional MediaPlayer-Datei
  - `FlowTonesSessionController` + `AudioServiceController` (start/stop + bind/unbind)
  - `FlowTonesViewModel` mit `StateFlow` + `pickFile()` Event
  - `MainActivity` + Compose UI (Mode, Volume, File Pick, Start/Stop)
  - Manifest-Permissions + Service-Declaration `foregroundServiceType="mediaPlayback"`
- Tests:
  - Unit-Tests für `FlowTonesViewModel` geschrieben und grün gemacht.

## Open
- PR erstellen und SF-12 auf `In Review` setzen.
- Nächstes Ticket danach: SF-13 (Compose UI Vertiefung auf Android).

## Tests
- Erfolgreich:
  - `cd sonicflow_app/android-app && ./gradlew --version`
  - `cd sonicflow_app/android-app && ./gradlew :app:testDebugUnitTest :app:assembleDebug --no-daemon`
- Hinweis:
  - Hilt/Kapt gibt nicht-blockierende Warnung zu unrecognized options in Unit-Test-Task aus.

## Affected Files (SF-12)
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/.gitignore
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/build.gradle.kts
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/settings.gradle.kts
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/gradle.properties
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/gradlew
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/gradlew.bat
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/gradle/wrapper/gradle-wrapper.jar
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/gradle/wrapper/gradle-wrapper.properties
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/app/build.gradle.kts
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/app/proguard-rules.pro
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/app/src/main/AndroidManifest.xml
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/app/src/main/java/com/sonicflow/app/FlowTonesApplication.kt
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/app/src/main/java/com/sonicflow/app/MainActivity.kt
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/app/src/main/java/com/sonicflow/app/audio/AudioService.kt
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/app/src/main/java/com/sonicflow/app/audio/AudioServiceController.kt
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/app/src/main/java/com/sonicflow/app/audio/FlowTonesSessionController.kt
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/app/src/main/java/com/sonicflow/app/audio/SessionCommand.kt
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/app/src/main/java/com/sonicflow/app/audio/SessionState.kt
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/app/src/main/java/com/sonicflow/app/di/AudioModule.kt
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/app/src/main/java/com/sonicflow/app/ui/FlowTonesViewModel.kt
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/app/src/main/res/drawable/ic_music.xml
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/app/src/main/res/values/strings.xml
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/app/src/main/res/values/themes.xml
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/app/src/test/java/com/sonicflow/app/ui/FlowTonesViewModelTest.kt
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/android-app/app/src/test/java/com/sonicflow/app/ui/MainDispatcherRule.kt
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/sonicflow_app/core-android/beatengine/build.gradle.kts
- /Users/alexanderbrunker/.config/superpowers/worktrees/soundhealing_sonicflow/sf-SF-12-android-app/STATUS.md

## Next Step
- PR für SF-12 öffnen, Linear kommentieren, auf `In Review` setzen.
