# Apple Liquid Glass Platform Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Optimize SonicFlow around iPhone, Safari, macOS menu bar, and the web app with a shared Apple-first architecture and Liquid Glass visual language.

**Architecture:** Keep Android and Chrome inactive. Keep `chrome-extension/` only as the temporary Safari Web Extension resource source. Consolidate active Apple builds around `core-swift`/`core-js`, keep platform shells thin, and make the web app a real active Apple-look surface again.

**Tech Stack:** SwiftUI, Xcode projects, Swift Package Manager, vanilla ES modules, Web Audio, CSS Liquid Glass-style material primitives, Node test runner.

---

### Task 1: Active Platform Build Surface

**Files:**
- Modify: `Makefile`
- Modify: `scripts/check_warnings.sh`
- Modify: `.github/workflows/warning-audit.yml`
- Modify: `README.md`
- Modify: `docs/guides/project-structure.md`
- Modify: `docs/architecture/system-overview.md`
- Modify: `docs/graphics/system-overview.mmd`
- Modify: `docs/guides/github-workflow.md`
- Modify: `STATUS.md`

- [ ] Restore `web`, `web-dev`, and `test-web` as active targets while keeping `chrome`, `test-chrome`, `android`, and `test-android` as inactive explicit failure targets.
- [ ] Update `make test` to cover `test-core-js`, `test-core-swift`, `test-safari-web-extension`, `test-web`, `test-github-workflows`, and available iOS tests.
- [ ] Link AppIntents in Xcode build invocations with `OTHER_LDFLAGS=-framework AppIntents` so the warning audit remains strict and warning-free without log filtering.
- [ ] Update docs and diagrams to state active targets as iPhone, Safari, macOS menu bar, and web app.
- [ ] Run `make help` and verify the target list matches the active platform story.

### Task 2: Web App Architecture Split

**Files:**
- Create: `sonicflow_app/web-app/src/webSessionStore.js`
- Create: `sonicflow_app/web-app/src/SonicFlowPlayer.js`
- Create: `sonicflow_app/web-app/src/renderApp.js`
- Create: `sonicflow_app/web-app/src/renderApp.test.js`
- Modify: `sonicflow_app/web-app/src/app.js`
- Modify: `sonicflow_app/web-app/index.html`

- [ ] Move localStorage defaults, load, and persist logic into `webSessionStore.js` with schema-safe object checks.
- [ ] Move Web Audio scheduling into `SonicFlowPlayer.js` without changing playback behavior.
- [ ] Move HTML generation into `renderApp.js`; export pure helpers for status/progress snapshots.
- [ ] Reduce `app.js` to state wiring, event routing, persistence, playback sync, and service-worker registration.
- [ ] Remove `aria-live` from the whole app shell and expose only playback status updates as live text.
- [ ] Add tests for render semantics: selected product mode buttons have `role="tab"`/`aria-selected`, transport status is present, and escaped text cannot inject markup.

### Task 3: Web Liquid Glass Visual System

**Files:**
- Modify: `sonicflow_app/web-app/src/styles.css`
- Modify: `sonicflow_app/web-app/src/renderApp.js`

- [ ] Create CSS sections for tokens, base layout, material primitives, components, and responsive behavior.
- [ ] Implement reusable `.glass-surface` and `.glass-control` primitives with `backdrop-filter` support and non-blur fallbacks.
- [ ] Rework the first viewport into a Cinematic Leopard Hero: current ritual title, mode metadata, dominant Start/Pause, and secondary control cluster.
- [ ] Keep the leopard image visible as a brand layer without placing body text directly on raw texture.
- [ ] Add `prefers-reduced-motion` and `prefers-reduced-transparency` handling.
- [ ] Run `npm --prefix sonicflow_app/web-app test`.

### Task 4: Apple Architecture Documentation And Next Core Step

**Files:**
- Modify: `docs/architecture/system-overview.md`
- Modify: `STATUS.md`

- [ ] Document that iOS already uses `SonicFlowCore`, while macOS/Safari still has a local beat-engine fork to remove next.
- [ ] Record the next architecture step: add a streaming renderer to `SonicFlowCore` and route iOS/macOS realtime audio through it.
- [ ] Keep native Liquid Glass changes scoped to platform UI files unless Xcode project changes are needed.

### Task 5: Verification

**Commands:**
- `npm --prefix sonicflow_app/web-app test`
- `npm --prefix sonicflow_app/core-js test`
- `make test`
- `make verify`

- [ ] Run web and core JS tests first.
- [ ] Run `make test` for the active platform matrix.
- [ ] Run `make verify` for the zero-warning audit.
- [ ] If Xcode simulator availability blocks iOS tests, keep the script’s skip behavior and report the exact skip message.
