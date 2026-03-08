# HabitOS Execution Ledger

Last updated: 2026-03-08 03:15:00 CET

## Purpose

This file is the mandatory operational ledger for all future work on HabitOS.

Every Copilot or AI agent working in this repository must use this file as the single source of truth for pending work, in-progress work, completed work, and execution evidence.

## Non-Negotiable Rules

1. No code change, refactor, bug fix, cleanup, documentation update, or architectural adjustment may be made without being reflected in this file.
2. Before starting work, the agent must review this ledger and either create a new task entry or update an existing one.
3. When work starts, the task must move to `IN PROGRESS`.
4. When work finishes, the task must move to `DONE` and include the real completion timestamp in the format `YYYY-MM-DD HH:MM:SS TZ`.
5. The completion record must include a short evidence note with the files changed, what was done, and any validation performed.
6. If work is partially completed, the task must remain open and its note must explain exactly what remains.
7. Silent changes are forbidden. If it changed in the repo, it must appear in this ledger.
8. If a task discovers new required work, that new work must be added here before the session ends.

## Product and Architecture Baseline

- Canonical visual direction: the brand book is the visual source of truth.
- Product identity: premium nutrition coaching companion, calm and editorial, not a generic fitness or calorie-counting app.
- Target architecture: the `Features/*` + `Repositories/*` + real models layer is the destination architecture.
- Transitional reality: `ContentView + DashboardViewModel + HabitOSDataService` is useful as a temporary demo shell, but should not be expanded as the long-term architectural base.
- Demo mode: keep as a temporary support tool for development, QA, and internal demos unless explicitly redefined later.
- Delivery strategy: refactor enough now so the MVP is built on the correct foundation, instead of finishing a second temporary architecture.

## Task Status Legend

- `TODO`: not started yet
- `IN PROGRESS`: currently being worked on
- `BLOCKED`: cannot continue until an external dependency or decision is resolved
- `DONE`: completed and timestamped

## Active Backlog

| ID | Status | Priority | Area | Task | Opened At | Completed At | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| HBT-001 | DONE | High | Architecture | Replace the root shell dependency on `HabitOSDataService` with repository-backed or feature-backed state orchestration. | 2026-03-07 18:33:46 CET | 2026-03-08 02:30:00 CET | DashboardViewModel now injects AuthRepo, DietRepo, TaskRepo, ChatRepo, JournalRepo. Demo fallback is self-contained via loadDemo(). HabitOSDataService deprecated. Files: DashboardViewModel.swift, ContentView.swift, ChatRepository.swift, HabitOSDataService.swift |
| HBT-002 | DONE | High | Domain Models | Converge duplicated model layers such as `UserProfile` and `AppUser`, `MealPlan` legacy and `NutritionPlan`, `ChatMessage` and `CoachMessage`. | 2026-03-07 18:33:46 CET | 2026-03-08 02:30:00 CET | UserProfile→AppUser, MealPlan→NutritionPlan, ChatMessage→CoachMessage, DailyTask→DailyTaskItem. Added compatibility extensions. Old types deprecated. Files: AppUser.swift, DataModels.swift, DashboardModels.swift, UserProfile.swift, MealPlan.swift, DashboardHomeView.swift, ChatView.swift, MealPlanView.swift, ProfileView.swift |
| HBT-003 | DONE | High | Authentication | Verify and complete the real iPhone magic link flow, including deep-link closure and Supabase auth URL handling. | 2026-03-07 18:33:46 CET | 2026-03-08 03:07:00 CET | Added habitos:// URL scheme (Info.plist), .onOpenURL handler in app entry, redirectTo in signInWithMagicLink, authRedirectURL in Config, INFOPLIST_FILE in pbxproj. Branch: feature/HBT-003-004-auth-schema-fixes, PR #6, Issue #5. NOTE: Supabase dashboard must add habitos://auth-callback as allowed redirect URL. |
| HBT-004 | DONE | High | Backend Schema | Inspect the real Supabase schema and confirm the canonical coach memory table and related backend entities. | 2026-03-07 18:33:46 CET | 2026-03-08 03:07:00 CET | Fixed coach_memories->coach_facts table name, profile_id/fact_kind/title/fact_text column mapping. Added computed category/fact backward-compat properties. Expanded category list. Updated demo data. 8 tables still missing migrations (see HBT-011). Branch: feature/HBT-003-004-auth-schema-fixes, PR #6, Issue #5. |
| HBT-005 | DONE | Medium | Navigation | Integrate the feature-based modules into the main visible navigation so the app shell reflects the real architecture. | 2026-03-07 18:33:46 CET | 2026-03-08 03:12:00 CET | Wired FAB actions to JournalView, MealLogView, WeightLogView, BarcodeScannerView via sheets/fullScreenCover. Added FABAction enum and onAction callback. Branch: feature/HBT-005-wire-fab-navigation, PR #8, Issue #7. |
| HBT-006 | TODO | Medium | Progress Photos | Introduce a storage abstraction for progress photos and prepare later migration from local-only storage to private remote storage. | 2026-03-07 18:33:46 CET |  | Current implementation is local-only and should not hard-code long-term storage assumptions. |
| HBT-007 | TODO | Medium | Demo Mode | Isolate demo-only behavior behind explicit boundaries so it supports development without polluting the production architecture. | 2026-03-07 18:33:46 CET |  | Demo mode is currently useful but should stop driving architectural decisions. |
| HBT-008 | TODO | Medium | Testing | Repair the testing baseline, verify unit test target contents, and establish at least a minimal trustworthy regression suite. | 2026-03-07 18:33:46 CET |  | Test coverage appears weak and one visible test file looked anomalous. |
| HBT-011 | TODO | Medium | Backend Schema | Create SQL migration files for 8 core tables missing from repo: app_users, nutrition_plans, meal_logs, journal_entries, weight_logs, daily_tasks, shopping_lists, food_scans. | 2026-03-08 03:07:00 CET |  | Discovered during HBT-004 audit. These tables are referenced in code but have no CREATE TABLE migrations in the repo. |
| HBT-009 | DONE | High | Project Governance | Create persistent Copilot operating rules, configuration guidance, and a mandatory execution ledger for future sessions. | 2026-03-07 18:33:46 CET | 2026-03-07 18:36:50 CET | Created `HABITOS_EXECUTION_LEDGER.md`, `.github/copilot-instructions.md`, `COPILOT_SETUP_HABITOS.md`, and updated `HABITOS_PROJECT_INTELLIGENCE_REPORT.html`. |
| HBT-010 | DONE | High | Project Governance | Create a direct handoff document for the next Copilot and require future agents to keep the handoff/context documents updated so switching agents stays seamless. | 2026-03-07 18:43:22 CET | 2026-03-07 18:44:14 CET | Created `NEXT_COPILOT_HANDOFF.md` and updated `.github/copilot-instructions.md`, `COPILOT_SETUP_HABITOS.md`, and `HABITOS_PROJECT_INTELLIGENCE_REPORT.html` so future agents keep the shared context current. |

## Session Change Log

Use this section to append one flat entry per completed task. Newest entries first.

- 2026-03-08 03:12:00 CET | HBT-005 | Wired FAB actions: Diario->JournalView, Foto comida->MealLogView, Registrar peso->WeightLogView, Escaner->BarcodeScannerView. Added FABAction enum + onAction callback. | Files: `Core/Components.swift`, `Views/DashboardHomeView.swift`
- 2026-03-08 03:07:00 CET | HBT-003 | Fixed auth magic link flow: URL scheme registration, .onOpenURL handler, redirectTo parameter, Config.authRedirectURL, INFOPLIST_FILE in pbxproj. | Files: `Config/Config.swift`, `Repositories/AuthRepository.swift`, `HabitOSUserDashboardApp.swift`, `Info.plist`, `project.pbxproj`
- 2026-03-08 03:07:00 CET | HBT-004 | Aligned CoachMemory model + ViewModel with real coach_facts schema. Fixed table name, column mapping, demo data. Added backward-compat computed props. | Files: `Features/CoachMemory/Models/CoachMemory.swift`, `Features/CoachMemory/ViewModels/CoachMemoryViewModel.swift`
- 2026-03-08 02:30:00 CET | HBT-001 | Replaced HabitOSDataService with repository-backed DashboardViewModel. Created ChatRepository. Demo fallback is explicit and bounded. | Files: `ViewModels/DashboardViewModel.swift`, `ContentView.swift`, `Repositories/ChatRepository.swift`, `Services/HabitOSDataService.swift`
- 2026-03-08 02:30:00 CET | HBT-002 | Converged all duplicate model types: UserProfile→AppUser, MealPlan→NutritionPlan, ChatMessage→CoachMessage, DailyTask→DailyTaskItem. Added view-compat extensions. Updated all affected views. | Files: `Models/AppUser.swift`, `Models/DataModels.swift`, `Models/DashboardModels.swift`, `Models/UserProfile.swift`, `Models/MealPlan.swift`, `Views/DashboardHomeView.swift`, `Views/ChatView.swift`, `Views/MealPlanView.swift`, `Views/ProfileView.swift`
- 2026-03-07 18:36:50 CET | HBT-009 | Created the persistent Copilot workflow base, including mandatory ledger rules, setup documentation, and report integration. | Files: `HABITOS_EXECUTION_LEDGER.md`, `.github/copilot-instructions.md`, `COPILOT_SETUP_HABITOS.md`, `HABITOS_PROJECT_INTELLIGENCE_REPORT.html`
- 2026-03-07 18:44:14 CET | HBT-010 | Added a direct takeover brief for the next Copilot and required future sessions to maintain the shared context documents. | Files: `NEXT_COPILOT_HANDOFF.md`, `.github/copilot-instructions.md`, `COPILOT_SETUP_HABITOS.md`, `HABITOS_PROJECT_INTELLIGENCE_REPORT.html`

## Update Protocol

When another Copilot completes work, it must update both places below in the same session:

1. The matching row in `Active Backlog`
2. A new line in `Session Change Log`

Minimum completion entry format:

`YYYY-MM-DD HH:MM:SS TZ | TASK-ID | one-line summary | Files: path1, path2, path3`

## Completion Template

Copy this template when closing any task:

| ID | Status | Priority | Area | Task | Opened At | Completed At | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| HBT-XXX | DONE | Priority | Area | Short task description | YYYY-MM-DD HH:MM:SS TZ | YYYY-MM-DD HH:MM:SS TZ | Files changed, validations run, and important outcome. |
