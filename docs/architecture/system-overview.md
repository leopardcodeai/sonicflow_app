# System Overview

This document explains how shared beat-generation cores map into each SonicFlow platform runtime.

## Component Topology

```mermaid
flowchart TB
    subgraph Shared["Shared Beat Engines"]
        JS["core-js"]
        SW["core-swift (FlowTonesCore)"]
        KT["core-android/beatengine"]
    end

    subgraph Browser["Browser Layer"]
        CH["chrome-extension"]
        SAF["safari-extension"]
    end

    subgraph Apple["Apple Apps"]
        IOS["ios-app"]
        MAC["macOS app target"]
    end

    subgraph Android["Android App"]
        APP["android-app"]
    end

    JS --> CH
    JS --> SAF
    SW --> IOS
    SAF --> MAC
    KT --> APP
```

## Runtime Audio Flow

```mermaid
sequenceDiagram
    participant UI as "Platform UI"
    participant Core as "Beat Core"
    participant Mixer as "Playback Mixer"
    participant Output as "Audio Output"

    UI->>Core: Select mode + gain + duration
    Core-->>UI: PCM beat layer
    UI->>Mixer: Combine source audio + beat layer
    Mixer->>Output: Stream mixed signal
```

## Notes

- The JS core is consumed by browser extension surfaces.
- The Swift and Kotlin cores mirror beat mode constants and synthesis shape for platform parity.
- Playback and session-control logic remains platform-specific by design.
