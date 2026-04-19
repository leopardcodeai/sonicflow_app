# STATUS

Date: 2026-04-19

## Ticket

- Active ticket: `SF-21`
- Branch: `feature/SF-21-linear-github-process`
- Goal: end-to-end Linear-first engineering workflow with PR guards and automation.

## Done

- Added PR governance:
  - `.github/workflows/pr-ticket-guard.yml`
  - `.github/PULL_REQUEST_TEMPLATE.md`
- Added Linear sync automation:
  - `.github/workflows/linear-pr-sync.yml`
  - `scripts/linear/pr_state_sync.mjs`
- Added auto-merge by Linear `Done`:
  - `.github/workflows/linear-done-automerge.yml`
  - `scripts/linear/automerge_done_tickets.mjs`
- Added process docs:
  - `docs/guides/linear-github-process.md`
  - `docs/guides/codex-automation-prompts.md`
- Updated docs index + README links.
- Updated CI branch pattern toward `feature/**`.

## Open

- Ensure repo secret `LINEAR_API_TOKEN` is set in GitHub Actions.
- Add `Preview` workflow state in Linear team (fallback currently uses `In Review`).
- Merge workflow PR and validate first real ticket through the full state machine.

## Verification

- `node scripts/linear/pr_state_sync.mjs` (graceful skip without token): ✅
- `node scripts/linear/automerge_done_tickets.mjs` (graceful skip without token/context): ✅
- `make test-core-js`: ✅
- `make test-core-swift`: ✅
- `make verify`: ✅ (including Android build in this environment)

## Next Step

- Commit + push latest workflow hardening changes.
- Keep/update PR #21 (`[SF-21] ...`) until checks pass.
- Keep ticket in `Preview` when PR is ready; merge path then drives `Done`.
