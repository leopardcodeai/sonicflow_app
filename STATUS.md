# STATUS

Date: 2026-04-19

## Ticket

- Active ticket: (none)
- Last ticket: `SF-21` (merged via PR #21 into `main`, commit `1c979ce`)
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
- Validate first real ticket through the full state machine.

## Verification

- `node scripts/linear/pr_state_sync.mjs` (graceful skip without token): ✅
- `node scripts/linear/automerge_done_tickets.mjs` (graceful skip without token/context): ✅
- `make test-core-js`: ✅
- `make test-core-swift`: ✅
- `make verify`: ✅ (including Android build in this environment)

## Next Step

- Confirm GitHub Actions is able to talk to Linear (`LINEAR_API_TOKEN`).
- Optionally add Linear status `Preview`, then run a full ticket cycle: `Todo` → `In Progress` → `In Review`/`Preview` → `Done`.
