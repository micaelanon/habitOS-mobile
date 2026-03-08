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

At the time of this handoff (2026-03-08), ALL backlog tasks are DONE and merged to develop:

- **DONE + MERGED**: HBT-001+002 — Architecture convergence
- **DONE + MERGED**: HBT-003+004 — Auth magic link + coach_facts schema
- **DONE + MERGED**: HBT-005 — FAB navigation wiring
- **DONE + MERGED**: HBT-006 — Photo storage abstraction with DI
- **DONE + MERGED**: HBT-007 — Demo mode isolation
- **DONE + MERGED**: HBT-008 — Testing baseline: mocks + 15+ tests
- **DONE + MERGED**: HBT-009+010 — Project governance + handoff docs
- **DONE + MERGED**: HBT-011 — SQL migrations for 11 tables + 2 storage buckets
- **DONE + MERGED**: HBT-012 — Wire all dead/placeholder UI buttons

Zero open PRs remain. All work is unified on develop.

The immediate next-value areas are now bug-fix and stability only:

- **HBT-013 Dashboard false error** — `DashboardViewModel.loadDashboard()` currently raises `"No pudimos cargar tu dashboard"` on partial repository failure even after loading usable fallback/demo data. Next pass should degrade gracefully without blocking alert spam.
- **HBT-014 Chat keyboard + spacing** — `ChatView` lacks focus dismissal / keyboard escape routes, which can trap navigation, and `ContentView` still applies a blunt `safeAreaInset(height: 90)` that creates excessive bottom spacing in chat.
- **HBT-015 Avatar editing** — `ProfileView` still renders a static initials circle; there is no bounded path to update `app_users.avatar_url` yet.
- **Supabase dashboard config** — Add `habitos://auth-callback` as allowed redirect URL (manual step).

Secondary follow-ups after the bug pass:

- **Shared scheme for tests** — CI is bootstrapped, but full test execution still needs a versioned shared `.xcscheme`.
- **Remote photo storage** — Create `SupabasePhotoStorageRepository` when `body-photos` bucket is provisioned.
- **ShoppingRepository implementation** — Protocol exists but no Supabase implementation.
- **App Group + widget data** — Widget shows placeholder until shared data layer is implemented.
- **Time period filtering** — `ProgressChartView` time range buttons animate but do not filter data yet.

## Git Branch State

Active working branch for the next pass may differ, but `develop` contains all merged product work through HBT-016. NEVER merge to main.

Zero open PRs at the moment this handoff was updated. `develop` contains all HBT-001 through HBT-016 work.

Note: PR #16 (SQL migrations) was a squash merge that included all stacked commits from HBT-001 through HBT-011. PRs #4, #6, #8, #10, #12, #14 were closed as their changes were already included. HBT-012 was rebased onto the new develop and merged via PR #19. HBT-016 then added `.github/workflows/ios-ci.yml`, which performs GitHub Actions bootstrap validation with explicit Xcode 26.2 selection and simulator builds, but still does not run tests because no shared scheme is versioned in the repo.

## Final Requirement

Your output should leave the repository easier to resume from than you found it.

That means code progress and context progress.
