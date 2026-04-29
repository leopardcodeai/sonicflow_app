# STATUS

Date: 2026-04-19

## Ticket

- Active ticket: `SF-23`
- Parent ticket: `SF-22` (Leopard Look redesign)
- Branch: `feature/SF-23-brand-foundation`
- Goal: establish the shared Leopard AI brand foundation consumed by follow-up platform tickets.

## Done

### SF-23 — brand foundation
- `brand/tokens.json` — canonical source of truth (chakra palette, mode-to-chakra mapping, neutral surfaces, accents, typography, radius, spacing, elevation, leopard parameters).
- `brand/BRAND.md` — human-readable guidelines (identity, mode↔chakra, leopard pattern rules, logo/clearspace, glow formula, do/don't).
- `brand/generated/` — deterministic per-platform outputs:
  - `tokens.css` (CSS custom properties)
  - `BrandTokens.swift` (Swift enum tree)
  - `README.md` (do-not-edit notice, regen command)
- `scripts/brand/generate-tokens.mjs` — idempotent generator, verified byte-identical on repeated runs.
- `docs/guides/codex-automation-prompts.md` — worker prompt hardened to re-check active `Todo` / `In Progress` / `In Review` issues directly from Linear issue details.

## Verification (this session)

- `node scripts/brand/generate-tokens.mjs` → byte-identical twice. ✅
- `cd sonicflow_app/core-js && npm test` → 5/5 pass. ✅
- `cd sonicflow_app/safari-web-extension && npm test` → 10/10 pass. ✅
- `./scripts/check_warnings.sh` → blocked in `core_swift` by sandboxed Swift toolchain cache access (`sandbox_apply: Operation not permitted`), not by an SF-23 code failure.

## Open / Flags

- `SF-24` through `SF-29` remain follow-up tickets that consume this foundation and should be split into their own branches/PRs after SF-23 is pushed.
- GitHub PR listing/comment inspection is currently blocked from this sandbox (`api.github.com` unreachable).
- Prefer moving `SF-23` to `Preview` if that Linear state exists; otherwise use `In Review`.

## Next Step

- Commit and push SF-23 branch contents.
- Open PR titled `[SF-23] ...` with the Linear link and the verification notes above.
- Move the ticket to `Preview` / `In Review`, then start the next platform slice on its own branch.
