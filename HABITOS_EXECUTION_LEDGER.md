# HabitOS Execution Ledger

Last updated: 2026-03-08 21:00:00 CET

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
| HBT-006 | DONE | Medium | Progress Photos | Introduce a storage abstraction for progress photos and prepare later migration from local-only storage to private remote storage. | 2026-03-07 18:33:46 CET | 2026-03-08 04:10:00 CET | Created PhotoStorageRepositoryProtocol + LocalPhotoStorageRepository. Extracted ProgressPhoto to standalone model. Refactored ProgressPhotosViewModel to use DI. Added 1200px max image downsizing. Added MockPhotoStorageRepository for tests. Branch: feature/HBT-006-photo-storage-abstraction, PR #14, Issue #13. |
| HBT-007 | DONE | Medium | Demo Mode | Isolate demo-only behavior behind explicit boundaries so it supports development without polluting the production architecture. | 2026-03-07 18:33:46 CET | 2026-03-08 03:18:00 CET | CRITICAL: Removed hardcoded demo data from widget. Added isDemo to AppState. DietViewModel now tries Supabase first. Error logging on all demo fallbacks. Branch: feature/HBT-007-demo-isolation, PR #10, Issue #9. |
| HBT-008 | DONE | Medium | Testing | Repair the testing baseline, verify unit test target contents, and establish at least a minimal trustworthy regression suite. | 2026-03-07 18:33:46 CET | 2026-03-08 03:25:00 CET | Deleted corrupted binary test file. Created MockRepositories (5 repos). Added ModelTests (model decoding) + DashboardViewModelTests (15+ cases). Branch: feature/HBT-008-testing-baseline, PR #12, Issue #11. |
| HBT-011 | DONE | Medium | Backend Schema | Create SQL migration files for all core tables: app_users, nutrition_plans, meal_logs, journal_entries, weight_logs, daily_tasks, shopping_lists, food_scans, coach_messages, coach_facts, coach_profiles, plus storage buckets. | 2026-03-08 03:07:00 CET | 2026-03-08 04:30:00 CET | Created 12 migration files covering 11 tables + 2 storage buckets. All include RLS policies, indexes, FK constraints, and CHECK constraints derived from Swift models. Branch: feature/HBT-011-sql-migrations, PR #16, Issue #15. |
| HBT-009 | DONE | High | Project Governance | Create persistent Copilot operating rules, configuration guidance, and a mandatory execution ledger for future sessions. | 2026-03-07 18:33:46 CET | 2026-03-07 18:36:50 CET | Created `HABITOS_EXECUTION_LEDGER.md`, `.github/copilot-instructions.md`, `COPILOT_SETUP_HABITOS.md`, and updated `HABITOS_PROJECT_INTELLIGENCE_REPORT.html`. |
| HBT-010 | DONE | High | Project Governance | Create a direct handoff document for the next Copilot and require future agents to keep the handoff/context documents updated so switching agents stays seamless. | 2026-03-07 18:43:22 CET | 2026-03-07 18:44:14 CET | Created `NEXT_COPILOT_HANDOFF.md` and updated `.github/copilot-instructions.md`, `COPILOT_SETUP_HABITOS.md`, and `HABITOS_PROJECT_INTELLIGENCE_REPORT.html` so future agents keep the shared context current. |
| HBT-012 | DONE | High | UI Wiring | Wire all dead/placeholder UI buttons across the app: chat send, FAB actions, dashboard shortcuts, shopping list, profile nav, progress weight log. | 2026-03-08 05:00:00 CET | 2026-03-08 06:00:00 CET | Fixed SettingsViewModel logout (always resets AppState). ChatView: onSend callback + sendCurrentMessage + auto-scroll. ContentView: onGoToChat/onGoToDiet + demo chat auto-reply using CoachMessage. DashboardHomeView: Ver receta→diet, Ya comí→MealLogView, Ir al chat→chat tab. MealPlanView: fixed nested Button in NavigationLink. ProfileView: Privacidad/Ayuda as NavigationLinks. ProgressChartView: Registrar peso→WeightLogView. PR #19 merged to develop. |
| HBT-013 | DONE | High | Dashboard UX | Remove the false dashboard error state when repository fetches partially fail but the fallback/demo content is still usable. | 2026-03-08 19:30:00 CET | 2026-03-08 21:00:00 CET | Removed `errorMessage` assignment from the catch block in `DashboardViewModel.loadDashboard()`. Error is still printed for observability but demo fallback hydrates silently without triggering the user-facing alert. Files: `DashboardViewModel.swift`. |
| HBT-014 | DONE | High | Chat UX | Fix chat text-entry usability: dismiss keyboard reliably, avoid trapping navigation, and reduce excessive bottom spacing above the tab bar. | 2026-03-08 19:30:00 CET | 2026-03-08 21:00:00 CET | Added `@FocusState` + `.focused()` binding to ChatView text field. Added `.scrollDismissesKeyboard(.interactively)` on the message ScrollView. Added `.contentShape(Rectangle()).onTapGesture` for tap-to-dismiss. Keyboard dismissed on send. Removed the 90pt `.safeAreaInset(edge: .bottom)` from the chat tab in ContentView. Files: `ChatView.swift`, `ContentView.swift`. |
| HBT-015 | DONE | Medium | Profile UX | Enable changing the profile avatar instead of showing a static placeholder circle only. | 2026-03-08 19:30:00 CET | 2026-03-08 21:00:00 CET | Added `PhotosPicker` (PhotosUI) to ProfileView header with camera badge overlay. Selected image is downscaled to 400px max, saved as JPEG to local Documents/habitos_avatar.jpg, and loaded on appear. Static initials circle remains as fallback when no avatar exists. Files: `ProfileView.swift`. |
| HBT-016 | DONE | Medium | CI/CD | Bootstrap GitHub Actions validation for the iOS app and keep the stability backlog visible for the next execution pass. | 2026-03-08 19:30:00 CET | 2026-03-08 19:45:00 CET | Issue #20 opened. Added `.github/workflows/ios-ci.yml` with GitHub Actions bootstrap on `macos-15`, explicit Xcode 26.2 selection, project inspection, and simulator builds for app, tests target, and widget target without code signing. Current limitation documented: test execution still depends on adding a shared `.xcscheme` to the repo. |

## Session Change Log

Use this section to append one flat entry per completed task. Newest entries first.

- 2026-03-08 21:00:00 CET | HBT-013 | Removed false error alert from dashboard. The catch block in `DashboardViewModel.loadDashboard()` no longer sets `errorMessage` when falling back to demo data — only logs the error for observability. | Files: `DashboardViewModel.swift`
- 2026-03-08 21:00:00 CET | HBT-014 | Fixed chat keyboard UX: added @FocusState focus management, scrollDismissesKeyboard(.interactively), tap-to-dismiss on message area, keyboard dismiss on send. Removed the excessive 90pt safeAreaInset from chat tab to fix double-spacing. | Files: `ChatView.swift`, `ContentView.swift`
- 2026-03-08 21:00:00 CET | HBT-015 | Added avatar editing to ProfileView via PhotosPicker. Camera badge on avatar circle. Image downscaled to 400px, saved locally as JPEG. Loaded from disk on appear. Initials fallback preserved. | Files: `ProfileView.swift`

- 2026-03-08 19:45:00 CET | HBT-016 | Added first GitHub Actions workflow for iOS validation on macOS runners. The workflow now checks out the repo, selects Xcode 26.2, runs `xcodebuild -list`, and builds app/test/widget targets for `iphonesimulator` with `CODE_SIGNING_ALLOWED=NO`. Also registered the new stability backlog (HBT-013/014/015). | Files: `.github/workflows/ios-ci.yml`, `HABITOS_EXECUTION_LEDGER.md`

- 2026-03-08 06:00:00 CET | HBT-012 | Wired all dead UI buttons on converged architecture. SettingsViewModel logout fix. ChatView onSend + sendCurrentMessage + auto-scroll. ContentView demo chat auto-reply with CoachMessage. DashboardHomeView: Ver receta→diet, Ya comí→MealLogView, Ir al chat→chat. MealPlanView nested Button fix. ProfileView Privacidad/Ayuda as NavigationLinks. ProgressChartView Registrar peso→WeightLogView sheet. | Files: `ContentView.swift`, `SettingsViewModel.swift`, `ChatView.swift`, `DashboardHomeView.swift`, `MealPlanView.swift`, `ProfileView.swift`, `ProgressChartView.swift`
- 2026-03-08 05:45:00 CET | PR-CONSOLIDATION | Discovered PR #16 squash merge had brought ALL HBT-001-011 work into develop (branches were stacked). Closed 6 obsolete PRs (#4,#6,#8,#10,#12,#14). Rebased HBT-012 onto new develop. Created PR #19, merged. Zero open PRs remain. | PRs closed: #4,#6,#8,#10,#12,#14,#18. PR merged: #19.
- 2026-03-08 04:30:00 CET | HBT-011 | Created 12 SQL migration files: 11 tables (coach_profiles, app_users, nutrition_plans, meal_logs, journal_entries, weight_logs, daily_tasks, shopping_lists, food_scans, coach_messages, coach_facts) + 2 storage buckets (body-photos, meal-photos). All with RLS, indexes, FK constraints. | Files: `supabase/migrations/20260308000100-001200*.sql`
- 2026-03-08 04:10:00 CET | HBT-006 | Created PhotoStorageRepositoryProtocol with save/load/delete. Implemented LocalPhotoStorageRepository (FileManager + 1200px downsizing). Extracted ProgressPhoto model. Refactored ViewModel to use protocol via DI. Added mock for tests. | Files: `Features/ProgressPhotos/Models/ProgressPhoto.swift`, `Repositories/PhotoStorageRepository.swift`, `Repositories/RepositoryProtocols.swift`, `Features/ProgressPhotos/ViewModels/ProgressPhotosViewModel.swift`, `Features/ProgressPhotos/Views/ProgressPhotosView.swift`, `habitOS-mobileTests/Mocks/MockRepositories.swift`
- 2026-03-08 03:25:00 CET | HBT-008 | Deleted corrupted binary test file. Created 5 mock repos. Added ModelTests + DashboardViewModelTests (15+ tests). | Files: `habitOS-mobileTests/ModelTests.swift`, `habitOS-mobileTests/DashboardViewModelTests.swift`, `habitOS-mobileTests/Mocks/MockRepositories.swift`
- 2026-03-08 03:18:00 CET | HBT-007 | Removed hardcoded widget demo data (CRITICAL). Added isDemo flag to AppState. DietViewModel tries Supabase before fallback. Added error logging to Chat, CoachMemory, Diet, Dashboard demo paths. | Files: `HabitOSWidget.swift`, `AppState.swift`, `ContentView.swift`, `HabitOSUserDashboardApp.swift`, `DashboardViewModel.swift`, `DietViewModel.swift`, `ChatViewModel.swift`, `CoachMemoryViewModel.swift`
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
