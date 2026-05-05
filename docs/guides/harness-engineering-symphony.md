# Harness Engineering And Symphony Plan

This guide maps OpenAI's harness engineering practices and the Symphony
orchestration spec onto SonicFlow's Apple-first platform work.

Sources:

- OpenAI, "Harness engineering: leveraging Codex in an agent-first world": https://openai.com/index/harness-engineering/
- OpenAI, "An open-source spec for Codex orchestration: Symphony": https://openai.com/index/open-source-codex-orchestration-symphony/
- `openai/symphony` repository: https://github.com/openai/symphony
- Symphony service spec: https://github.com/openai/symphony/blob/main/SPEC.md

## What We Can Use

### 1. Repo Knowledge As System Of Record

Harness engineering argues for a short agent entry point that maps to deeper
repo-owned docs, instead of a giant instruction file. SonicFlow should keep
agent-facing truth in versioned files:

- `docs/README.md` as the docs table of contents
- `docs/architecture/*.md` for platform and runtime boundaries
- `docs/guides/*.md` for workflows and operating rules
- `docs/superpowers/plans/*.md` for larger execution plans
- `WORKFLOW.md` for Symphony-style issue execution policy

Rule: if a workflow decision matters for future agent runs, it belongs in the
repo, not only in chat, Linear comments, or a PR thread.

### 2. Agent-Legible Verification

SonicFlow already has a useful verification surface:

- `make test`
- `make verify`
- iOS simulator tests through `scripts/check_warnings.sh --ios-tests`
- Safari Web Extension resource tests
- macOS build verification

Next improvement: every Linear issue should name the expected verification
commands in its acceptance criteria. Symphony can then hand Codex a concrete
definition of proof instead of a vague "make it good."

### 3. Mechanical Architecture Boundaries

The harness article emphasizes constraints that agents can check mechanically.
For SonicFlow, the current boundaries are:

- Active product targets: iPhone, Safari Web Extension, macOS menu bar, web app.
- Removed product targets: Android and Chrome.
- Shared engine code: `core-js` and `core-swift`.
- Safari resources: `sonicflow_app/extensions/safari`.
- Native Apple surfaces: `sonicflow_app/apps/ios` and `sonicflow_app/apps/macos/macOS (App)`.

Useful next checks:

- A script that fails on active references to removed Android/Chrome product trees.
- A docs freshness check that keeps active platform paths current.
- A docs freshness check that requires `docs/README.md` to link every active
  guide.

### 4. Small PRs With Proof Of Work

Symphony is designed to turn tracker work into isolated implementation runs:
poll Linear, prepare a workspace per issue, run Codex, collect proof, and hand
off through PRs. For SonicFlow this means:

- one Linear issue per coherent change
- one branch per issue
- one draft PR per issue
- PR body includes Linear link and verification output
- `Preview`/`In Review` is the handoff state, not silent completion

### 5. Continuous Garbage Collection

The article calls out recurring cleanup for entropy. SonicFlow should track
cleanup as first-class Linear work, not as occasional manual sweeps:

- docs drift cleanup
- inactive platform reference cleanup
- architecture boundary checks
- stale generated asset cleanup
- test warning cleanup

## Symphony Adoption Shape

We should not vendor the prototype blindly. The Symphony README describes the
Elixir implementation as prototype software for evaluation and recommends a
hardened implementation based on `SPEC.md`.

Recommended SonicFlow path:

1. Add repo-owned `WORKFLOW.md` as the Symphony contract.
2. Keep current Makefile and warning audit as the proof commands.
3. Use Linear as the source of dispatchable work.
4. Use isolated workspaces under `~/Coding/symphony-workspaces/sonicflow`.
5. Start with `max_concurrent_agents: 1` or `2` until PR hygiene is stable.
6. Require every Symphony-run issue to produce a draft PR and verification log.

## Linear Issue Templates

### Issue 1: Add Symphony Workflow Contract

Title: Add Symphony WORKFLOW.md for SonicFlow agent runs

Labels: documentation, automation

Description:

```md
Create a repo-owned Symphony workflow contract for SonicFlow.

Acceptance criteria:
- `WORKFLOW.md` exists at repo root.
- Workflow references Linear as tracker and the SonicFlow project slug.
- Workflow limits concurrency for early rollout.
- Workflow instructs Codex to create one branch/PR per issue.
- Workflow requires `make test` and `make verify` evidence in the PR body.
- Docs link to the workflow from `docs/README.md`.

Verification:
- `make test`
- `make verify`
```

### Issue 2: Add Agent-Legibility Checks

Title: Add active-platform reference checks for Apple-only focus

Labels: documentation, automation, architecture

Description:

```md
Add mechanical checks that protect the Apple-only platform focus.

Acceptance criteria:
- Add a script that fails on active references to removed Android/Chrome product trees.
- Add a docs freshness check that keeps active platform paths current.
- Wire the check into `make verify` or a focused docs/architecture audit.
- Document allowed exceptions.

Verification:
- `make verify`
```

### Issue 3: Pilot Symphony With Documentation-Only Work

Title: Pilot Symphony on documentation-only SonicFlow issues

Labels: documentation, automation

Description:

```md
Run a low-risk Symphony pilot against documentation-only issues.

Acceptance criteria:
- Use isolated workspaces.
- Dispatch only documentation-labeled issues.
- Require draft PR output.
- Require verification evidence in PR body.
- Record failure modes and update `WORKFLOW.md`.

Verification:
- PR includes Symphony run notes.
- `make test`
- `make verify`
```

## GitHub PR Documentation Template

Use this body for the documentation PR:

```md
## Summary
- Adds SonicFlow's Harness Engineering and Symphony adoption guide.
- Adds a repo-owned Symphony `WORKFLOW.md` contract.
- Documents Linear issue templates for follow-up automation work.

## Linear
- Ticket: <Linear issue id>
- Link: <Linear issue URL>

## Verification
- [ ] `make test`
- [ ] `make verify`

## Notes
- Symphony should start as documentation/automation-only until isolated workspace and PR hygiene are proven.
- The OpenAI Elixir implementation is treated as an evaluation reference, not vendored production infrastructure.
```
