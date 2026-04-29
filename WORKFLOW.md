---
tracker:
  kind: linear
  api_key: "$LINEAR_API_KEY"
  project_slug: "sonicflow"
  active_states:
    - Todo
  terminal_states:
    - Done
    - Closed
    - Cancelled
    - Canceled
    - Duplicate
polling:
  interval_ms: 30000
workspace:
  root: "~/Coding/symphony-workspaces/sonicflow"
hooks:
  after_create: |
    git clone git@github.com:alexanderbrunker-star/sonicflow_app.git .
  before_run: |
    git fetch origin
agent:
  max_concurrent_agents: 1
  max_turns: 12
  max_retry_backoff_ms: 300000
  max_concurrent_agents_by_state:
    todo: 1
codex:
  command: "codex app-server"
  turn_timeout_ms: 3600000
  read_timeout_ms: 5000
  stall_timeout_ms: 300000
---

You are working on SonicFlow issue {{ issue.identifier }}.

Title: {{ issue.title }}

Description:
{{ issue.description }}

Rules:

1. Work only inside the assigned workspace.
2. Keep SonicFlow Apple-first: active targets are iPhone, Safari Web Extension,
   macOS menu bar, and the web app.
3. Do not reactivate Android or Chrome product targets.
4. Use one branch and one draft PR for this issue.
5. Branch format: `sf/{{ issue.identifier }}-short-slug`.
6. PR title format: `[{{ issue.identifier }}] concise outcome`.
7. Include the Linear link and verification output in the PR body.
8. Prefer small, reviewable changes with clear proof of work.
9. Update docs when behavior, architecture, or workflow rules change.
10. If the issue is blocked, leave a clear Linear comment and stop safely.

Required verification before handoff:

- `make test`
- `make verify`

Handoff state:

- Open or update a draft PR.
- Move the Linear issue to `Preview` if available, otherwise `In Review`.
- Summarize changed files, verification evidence, and any remaining risk.
