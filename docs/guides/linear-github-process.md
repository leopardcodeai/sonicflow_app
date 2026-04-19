# Linear + GitHub Process

Dieses Projekt arbeitet ticket-driven:

`Backlog -> Todo -> In Progress -> Preview -> Done`

## Soll-Verhalten

1. Neue Tickets landen in `Backlog` und bleiben dort.
2. Nur manuell (oder auf Aufforderung) nach `Todo` verschieben.
3. Codex arbeitet nur `Todo`-Tickets ab (ein Ticket gleichzeitig).
4. Für jedes Ticket:
   - Branch: `feature/TICKET-ID-desc`
   - PR-Titel: `[TICKET-ID] ...`
   - PR-Body enthält Linear-Link
5. Fertige Umsetzung:
   - Ticket auf `Preview` (Fallback: `In Review`, wenn `Preview` nicht existiert)
   - PR ist ready to merge
6. Abschlusspfade:
   - PR wird gemerged -> Ticket wird automatisch `Done`
   - Ticket wird manuell `Done` -> Automation merged den offenen PR

## Implementierte Repo-Automationen

- `.github/workflows/pr-ticket-guard.yml`
  - erzwingt Branch-/PR-Format und Linear-Link
- `.github/workflows/linear-pr-sync.yml`
  - synchronisiert Linear-State aus PR-Events
- `.github/workflows/linear-done-automerge.yml`
  - prüft alle 15 Minuten, ob offene PRs zu `Done`-Tickets gemerged werden können
- `.github/PULL_REQUEST_TEMPLATE.md`
  - standardisiert Linear- und Testdokumentation

## Erforderliche GitHub Einstellungen

1. Repository Secret setzen:
   - `LINEAR_API_TOKEN` (Linear API Token mit Schreibrechten)
2. Branch Protection auf `main`:
   - required checks:
     - `CI / core-js`
     - `CI / core-swift`
     - `PR Ticket Guard / guard`
3. Optional empfohlen:
   - squash merge als Standard
   - direct pushes auf `main` verbieten

## Erforderliche Linear Einstellungen

1. Team-Workflow-State `Preview` anlegen (falls noch nicht vorhanden).
2. GitHub-Integration aktiv lassen (Linking/Referencing).
3. Ticket-Key in PR-Title verwenden (`[SF-123] ...`).

Wenn `Preview` nicht existiert, nutzt die PR-Sync-Automation automatisch `In Review`.
