# HabitOS Workspace Instructions for GitHub Copilot

These instructions apply to all work in this repository.

## Mandatory Reading Order

Before making changes, always read these files first when relevant:

1. `HABITOS_EXECUTION_LEDGER.md`
2. `HABITOS_PROJECT_INTELLIGENCE_REPORT.html`
3. `Docs/brand-manual.html`
4. `Docs/HABITOS-IOS-APP-SPEC.md`

## Non-Negotiable Workflow

1. Never make repository changes without updating `HABITOS_EXECUTION_LEDGER.md`.
2. If the requested work does not exist in the ledger, add it before changing code.
3. When beginning work, mark the task as `IN PROGRESS`.
4. When finishing work, mark the task as `DONE` with a real completion timestamp in the format `YYYY-MM-DD HH:MM:SS TZ`.
5. Record evidence in the ledger: files changed, short summary, and validations performed.
6. If the work reveals new follow-up items, add them to the ledger before ending the session.
7. Silent refactors are forbidden. If code changed, the ledger must reflect it.

## Product Truths

- HabitOS is a premium nutrition coaching companion for existing clients of a coach or nutritionist.
- The product is about adherence, follow-through, calm accountability, and premium service experience.
- It is not a generic fitness app, not a social app, and not a manual calorie counter.

## Canonical Visual Direction

- The visual source of truth is `Docs/brand-manual.html`.
- The product should remain clear, warm, mediterranean, editorial, and calm.
- Do not push the app toward a dark, aggressive, neon, or generic fitness aesthetic.
- When the spec conflicts with the brand book on visual direction, follow the brand book and document the mismatch.

## Canonical Architecture Direction

- Treat `Features/*` + `Repositories/*` + real domain models as the target architecture.
- Treat `ContentView + DashboardViewModel + HabitOSDataService` as transitional unless explicitly required otherwise.
- Avoid expanding the legacy demo layer when the same behavior can be implemented in the target architecture.
- Prefer convergence over duplication. If two parallel implementations exist, bias toward unifying them.

## Demo Mode Policy

- Demo mode is allowed as a temporary support tool for development, QA, and internal demos.
- Do not let demo-only shortcuts become the permanent architecture by accident.
- Any new demo-only logic should be clearly bounded and easy to remove or replace.

## Data and Backend Guidance

- Do not assume the spec matches the real backend schema until verified.
- If a table, bucket, or backend entity is uncertain, isolate the uncertainty behind protocols or repositories.
- Call out unresolved schema mismatches explicitly in the ledger and in change notes.

## Delivery Strategy

- The goal is to reach a real MVP on a clean enough base.
- Do not freeze progress with a huge rewrite.
- Do not keep piling features onto the temporary architecture.
- Prefer targeted refactors that improve the foundation while moving visible MVP work forward.

## Expected Behavior for Future Sessions

- Start by checking what is open in `HABITOS_EXECUTION_LEDGER.md`.
- Reuse the project context from `HABITOS_PROJECT_INTELLIGENCE_REPORT.html` instead of rediscovering what HabitOS is.
- Use `NEXT_COPILOT_HANDOFF.md` as the fast-start operational brief for taking over work.
- Keep decisions explicit.
- Leave the repo easier to understand than before.

## Mandatory Context Maintenance

- If your work changes the project understanding, backlog state, architectural direction, or Copilot operating assumptions, update the relevant shared documents in the same session.
- Keep `HABITOS_EXECUTION_LEDGER.md` current at all times.
- Update `HABITOS_PROJECT_INTELLIGENCE_REPORT.html` when the product or architecture picture materially changes.
- Update `COPILOT_SETUP_HABITOS.md` and `NEXT_COPILOT_HANDOFF.md` when the Copilot setup or takeover guidance changes.
- Do not leave stale handoff documents behind after meaningful changes.
