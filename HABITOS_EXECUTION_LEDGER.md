# HabitOS Execution Ledger

Last updated: 2026-03-08 18:05:00 CET

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
| HBT-001 | TODO | High | Architecture | Replace the root shell dependency on `HabitOSDataService` with repository-backed or feature-backed state orchestration. | 2026-03-07 18:33:46 CET |  | Root shell still depends on demo service according to the intelligence report. |
| HBT-002 | TODO | High | Domain Models | Converge duplicated model layers such as `UserProfile` and `AppUser`, `MealPlan` legacy and `NutritionPlan`, `ChatMessage` and `CoachMessage`. | 2026-03-07 18:33:46 CET |  | Current codebase carries parallel domain shapes and duplicate maintenance cost. |
| HBT-003 | TODO | High | Authentication | Verify and complete the real iPhone magic link flow, including deep-link closure and Supabase auth URL handling. | 2026-03-07 18:33:46 CET |  | Flow appears only partially closed from current app entry analysis. |
| HBT-004 | TODO | High | Backend Schema | Inspect the real Supabase schema and confirm the canonical coach memory table and related backend entities. | 2026-03-07 18:33:46 CET |  | `coach_memories` and `coach_facts` are inconsistent between code and spec. |
| HBT-005 | TODO | Medium | Navigation | Integrate the feature-based modules into the main visible navigation so the app shell reflects the real architecture. | 2026-03-07 18:33:46 CET |  | Several features exist but are only partially surfaced in the visible shell. |
| HBT-006 | TODO | Medium | Progress Photos | Introduce a storage abstraction for progress photos and prepare later migration from local-only storage to private remote storage. | 2026-03-07 18:33:46 CET |  | Current implementation is local-only and should not hard-code long-term storage assumptions. |
| HBT-007 | TODO | Medium | Demo Mode | Isolate demo-only behavior behind explicit boundaries so it supports development without polluting the production architecture. | 2026-03-07 18:33:46 CET |  | Demo mode is currently useful but should stop driving architectural decisions. |
| HBT-008 | TODO | Medium | Testing | Repair the testing baseline, verify unit test target contents, and establish at least a minimal trustworthy regression suite. | 2026-03-07 18:33:46 CET |  | Test coverage appears weak and one visible test file looked anomalous. |
| HBT-009 | DONE | High | Project Governance | Create persistent Copilot operating rules, configuration guidance, and a mandatory execution ledger for future sessions. | 2026-03-07 18:33:46 CET | 2026-03-07 18:36:50 CET | Created `HABITOS_EXECUTION_LEDGER.md`, `.github/copilot-instructions.md`, `COPILOT_SETUP_HABITOS.md`, and updated `HABITOS_PROJECT_INTELLIGENCE_REPORT.html`. |
| HBT-010 | DONE | High | Project Governance | Create a direct handoff document for the next Copilot and require future agents to keep the handoff/context documents updated so switching agents stays seamless. | 2026-03-07 18:43:22 CET | 2026-03-07 18:44:14 CET | Created `NEXT_COPILOT_HANDOFF.md` and updated `.github/copilot-instructions.md`, `COPILOT_SETUP_HABITOS.md`, and `HABITOS_PROJECT_INTELLIGENCE_REPORT.html` so future agents keep the shared context current. |
| HBT-012 | DONE | High | UI Wiring | Wire all dead/placeholder UI buttons found during user testing: FAB actions, chat send, quick replies, "Ir al chat", "Ver receta", "Ya comí", "Registrar peso", shopping list, Privacidad, Ayuda, and fix logout bug. | 2026-03-08 17:00:00 CET | 2026-03-08 18:05:00 CET | 8 files changed across Views, Core, ContentView, and SettingsViewModel. Issue #17, PR #18, commit `53bfc4b`. |

## Session Change Log

Use this section to append one flat entry per completed task. Newest entries first.

- 2026-03-07 18:36:50 CET | HBT-009 | Created the persistent Copilot workflow base, including mandatory ledger rules, setup documentation, and report integration. | Files: `HABITOS_EXECUTION_LEDGER.md`, `.github/copilot-instructions.md`, `COPILOT_SETUP_HABITOS.md`, `HABITOS_PROJECT_INTELLIGENCE_REPORT.html`
- 2026-03-08 18:05:00 CET | HBT-012 | Wired all dead/placeholder UI buttons: FAB actions → sheets, chat send + quick replies → demo auto-reply, Ir al chat → tab switch, Ver receta → diet tab, Ya comí → MealLogView, Registrar peso → WeightLogView, shopping list NavigationLink fix, Privacidad/Ayuda → placeholder views, logout bug fix (appState.signOut always runs). | Files: `ContentView.swift`, `Components.swift`, `SettingsViewModel.swift`, `ChatView.swift`, `DashboardHomeView.swift`, `MealPlanView.swift`, `ProfileView.swift`, `ProgressChartView.swift`
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
