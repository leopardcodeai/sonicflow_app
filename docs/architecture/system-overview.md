# System Overview

This document explains how shared beat-generation cores map into the active SonicFlow platform runtimes: iPhone, Safari, macOS menu bar, and the web app.

## Component Topology

```mermaid
flowchart TB
    subgraph Shared["Shared Beat Engines"]
        JS["core-js (Safari Web Extension resources)"]
        SW["core-swift (SonicFlowCore)"]
    end

    subgraph Safari["Safari Layer"]
        WEBEXT["safari-web-extension resources"]
        SAF["safari-extension Xcode wrapper"]
    end

    subgraph Web["Web App"]
        PWA["web-app"]
    end

    subgraph Apple["Apple Apps"]
        IOS["ios-app (iPhone)"]
        MAC["macOS menu-bar target"]
    end

    JS --> WEBEXT
    JS --> PWA
    WEBEXT --> SAF
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

- The JS core is consumed by Safari Web Extension resources and the active Apple-look web app.
- The Swift core powers active native Apple targets.
- Playback and session-control logic remains platform-specific by design.
- Android and Chrome product code are removed from the active platform tree and excluded from default verification.
- Architecture note: iOS already links `SonicFlowCore`; the macOS menu app still has a local beat-engine fork. The next core cleanup is a shared streaming renderer in `SonicFlowCore` that both iOS and macOS can call from their realtime audio nodes.
