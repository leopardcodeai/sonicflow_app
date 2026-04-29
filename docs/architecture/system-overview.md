# System Overview

This document explains how shared beat-generation cores map into each SonicFlow platform runtime.

## Component Topology

```mermaid
flowchart TB
    subgraph Shared["Shared Beat Engines"]
        JS["core-js"]
        SW["core-swift (SonicFlowCore)"]
    end

    subgraph Browser["Browser Layer"]
        CH["safari-web-extension"]
        SAF["safari-extension"]
    end

    subgraph Apple["Apple Apps"]
        IOS["ios-app"]
        MAC["macOS app target"]
    end

    JS --> CH
    JS --> SAF
    SW --> IOS
    SAF --> MAC
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
- The Swift core mirrors beat mode constants and synthesis shape for Apple-native parity.
- Playback and session-control logic remains platform-specific by design.
