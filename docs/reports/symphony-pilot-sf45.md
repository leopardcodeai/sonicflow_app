# SF-45 Symphony Documentation Pilot

Date: 2026-04-29

Linear issue: SF-45, "Pilot Symphony on documentation-only SonicFlow issues"

## Scope

This pilot uses a Symphony-style run shape for documentation work only. It does
not vendor the OpenAI Symphony runtime or add orchestration dependencies. The
goal is to prove that SonicFlow can keep agent work inspectable, small, and
reviewable before using the pattern for larger implementation tasks.

## Inputs

- OpenAI Harness Engineering article: https://openai.com/index/harness-engineering/
- OpenAI Symphony announcement: https://openai.com/index/open-source-codex-orchestration-symphony/
- OpenAI Symphony repository: https://github.com/openai/symphony
- Active SonicFlow Linear tickets: SF-43, SF-44, SF-45
- Existing local verification commands: `make test`, `make verify`, `git diff --check`

## Run Contract

### Coordinator

The coordinator owns the Linear issue, PR scope, acceptance criteria, and final
verification. It must not merge unrelated dirty workspace changes into the PR.

### Explorer

The explorer inventories open tickets and PRs, then reports blockers and the
recommended order of work. In this pilot, the explorer found:

- SF-43 has PR #42 open, but GitHub checks fail before any workflow step starts.
- SF-44 needs a separate active-platform guard PR.
- SF-45 should remain docs-only and depend on the SF-43/SF-44 findings.

### Worker

The worker writes only the report for this issue. Any code changes discovered
during the pilot become separate Linear issues or PRs.

## Execution Notes

1. Keep one branch per Linear ticket.
2. Prefer isolated worktrees when the main checkout has unrelated platform work.
3. Record external sources and their role in the PR body.
4. Add a Linear comment with verification evidence and any blockers.
5. Treat GitHub Actions failures with empty job steps and no runner name as
   infrastructure blockers, not test failures.

## Verification

For this documentation-only pilot:

- `git diff --check`
- `node --test scripts/github/*.test.mjs`

Full platform verification is covered by SF-44 because that PR changes active
build and platform wiring.

## Follow-Up Rules

- Use the Symphony-style role split for future multi-issue runs only when the
  tasks are independent enough to avoid shared-file conflicts.
- Keep implementation PRs separate from documentation/process PRs.
- Before marking an issue complete, rerun the smallest command that proves the
  claim being made and paste the result into Linear or the PR.
