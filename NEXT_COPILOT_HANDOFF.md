# Start Here: HabitOS Handoff For The Next Copilot

You are taking over work on HabitOS. Do not start by rediscovering the project from scratch.

Read and follow this document first.

## Your First Job

Before making any change:

1. Read `HABITOS_EXECUTION_LEDGER.md`.
2. Read `HABITOS_PROJECT_INTELLIGENCE_REPORT.html`.
3. Read `.github/copilot-instructions.md`.
4. Read `Docs/brand-manual.html`.
5. Read `Docs/HABITOS-IOS-APP-SPEC.md` only after the files above, and treat it carefully when it conflicts with the real code or the brand book.

## Non-Negotiable Project Truths

- HabitOS is a premium nutrition coaching companion for existing clients of a coach or nutritionist.
- The product is about adherence, calm accountability, and premium service quality.
- It is not a generic fitness app, not a social app, and not a manual calorie counter.
- The visual source of truth is the brand book, not the older dark-mode assumptions in the spec.
- The target architecture is the feature-based layer with repositories and real domain models.
- The current root shell driven by `ContentView + DashboardViewModel + HabitOSDataService` is transitional unless verified otherwise.
- Demo mode is allowed as temporary support for development, QA, and internal demo workflows, but it must not quietly become the permanent product architecture.

## Mandatory Operating Workflow

You must use `HABITOS_EXECUTION_LEDGER.md` as the execution control file.

Rules:

1. If the task you are about to do is not in the ledger, add it first.
2. Mark the task as `IN PROGRESS` before editing files.
3. When you finish, mark it as `DONE` with the real completion timestamp in the format `YYYY-MM-DD HH:MM:SS TZ`.
4. Add evidence: files changed, short summary, validations run, and any follow-up work discovered.
5. If you change code, docs, architecture notes, or project understanding, reflect that in the ledger in the same session.
6. Silent refactors are forbidden.

## Mandatory Context Maintenance

Part of your job is not only changing code, but also keeping the project handoff accurate for the next agent.

Whenever your work changes project understanding, architecture direction, completed work, or operating rules, update the relevant documents before ending your session:

1. `HABITOS_EXECUTION_LEDGER.md` for task state and evidence.
2. `HABITOS_PROJECT_INTELLIGENCE_REPORT.html` if the product/architecture understanding materially changes.
3. `COPILOT_SETUP_HABITOS.md` if the Copilot operating setup changes.
4. `NEXT_COPILOT_HANDOFF.md` if the next Copilot would need different startup guidance than what is written here.
5. `.github/copilot-instructions.md` if repository-wide rules change.

If your session reveals new truths and you do not update these files, you are leaving stale context behind. Do not do that.

## How To Choose Work

Unless the user explicitly redirects you, continue from the highest-priority open task in `HABITOS_EXECUTION_LEDGER.md`.

Current strategic direction:

- improve the base while moving toward the MVP
- reduce duplication instead of adding more parallel layers
- prefer targeted refactors over a massive rewrite
- move visible flows away from demo-only data when the real repository layer already exists

## What To Avoid

- Do not expand the legacy demo architecture if the feature layer can absorb the work.
- Do not introduce new visual direction that conflicts with the brand book.
- Do not assume the spec matches the real Supabase schema until verified.
- Do not leave undocumented follow-up tasks in your head; add them to the ledger.
- Do not finish a session without updating the execution record.

## If You Need A Safe Default

If the user simply says to continue, your default sequence is:

1. Read the ledger.
2. Pick the highest-priority open item.
3. Mark it `IN PROGRESS`.
4. Read the minimum relevant files.
5. Implement carefully.
6. Validate.
7. Update ledger, report, and handoff docs if needed.
8. Stop only when the task is actually complete or genuinely blocked.

## Current Highest-Value Areas

At the time of this handoff, the likely top-value areas are:

- removing root-shell dependence on `HabitOSDataService` (HBT-001, PR #4 pending merge)
- converging duplicated models (HBT-002, PR #4 pending merge)
- verifying and closing the real iPhone magic-link flow (HBT-003, PR #6 pending merge)
- confirming the real Supabase schema for coach memory (HBT-004, PR #6 pending merge)
- strengthening the testing baseline (HBT-008, PR #12 pending merge)
- merging the 8 open PRs (#4, #6, #8, #10, #12, #14, #16, #18) to develop in sequence
- replacing the demo chat auto-reply in ContentView with real ChatViewModel + Supabase once model convergence (HBT-002) is merged
- the day selector in MealPlanView works but shows all meals flat (not per-day) — needs per-day filtering once NutritionPlan model is adopted
- profile avatar photo editing (not yet wired, deferred)
- progress time period filtering (buttons animate but don't filter chart data, deferred)

## Final Requirement

Your output should leave the repository easier to resume from than you found it.

That means code progress and context progress.
