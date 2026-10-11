# System Overview

This document explains how shared beat-generation cores map into the active SonicFlow platform runtimes: iPhone, Safari, macOS menu bar, and the web app.

## Component Topology

```mermaid
flowchart TB
    subgraph Shared["Shared Beat Engines"]
        JS["shared/core-js (Safari/Web resources)"]
        SW["shared/core-swift (SonicFlowCore)"]
    end

    subgraph Safari["Safari Layer"]
        WEBEXT["extensions/safari resources"]
        SAF["apps/macos Safari wrapper"]
    end

    subgraph Web["Web App"]
        PWA["apps/web"]
    end

    subgraph Apple["Apple Apps"]
        IOS["apps/ios (iPhone)"]
        MAC["apps/macos menu-bar target"]
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
- Legacy non-Safari browser and non-iOS mobile product code are removed from the active platform tree and excluded from default verification.
- Architecture note: iOS already links `SonicFlowCore`; the macOS menu app still has a local beat-engine fork. The next core cleanup is a shared streaming renderer in `SonicFlowCore` that both iOS and macOS can call from their realtime audio nodes.
