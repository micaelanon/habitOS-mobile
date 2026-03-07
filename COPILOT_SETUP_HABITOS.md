# Copilot Setup for HabitOS

This document explains how another GitHub Copilot instance should be configured and used in this repository so you do not need to repeat the same project rules in every prompt.

## Objective

The goal is that any future Copilot session starts with the correct product context, architecture direction, and execution discipline already loaded.

## Required Workspace Files

These files now define the operating base for Copilot in HabitOS:

1. `NEXT_COPILOT_HANDOFF.md`
2. `.github/copilot-instructions.md`
3. `HABITOS_EXECUTION_LEDGER.md`
4. `HABITOS_PROJECT_INTELLIGENCE_REPORT.html`
5. `Docs/brand-manual.html`
6. `Docs/HABITOS-IOS-APP-SPEC.md`

## What Is Already Configured

- `.github/copilot-instructions.md` is the always-on workspace instruction file that VS Code GitHub Copilot uses for repository-wide behavior.
- `HABITOS_EXECUTION_LEDGER.md` is the mandatory backlog and execution log that every future session must update.
- `HABITOS_PROJECT_INTELLIGENCE_REPORT.html` is the product and architecture briefing so Copilot does not need to rediscover what HabitOS is.
- `NEXT_COPILOT_HANDOFF.md` is the direct startup brief for the next Copilot, written so a new agent can begin work immediately.

## How To Verify It In VS Code

1. Open the repository root in VS Code.
2. Open the Chat Customizations editor from the Command Palette if needed.
3. Confirm that `.github/copilot-instructions.md` appears under workspace instructions.
4. If Copilot seems to ignore the instructions, open Chat diagnostics and verify the file is loaded without syntax errors.
5. Use `NEXT_COPILOT_HANDOFF.md` as the first reading document for fast takeover.

## Mandatory Operating Rules For Any Future Copilot

1. Read `HABITOS_EXECUTION_LEDGER.md` before making changes.
2. If the requested task is not in the ledger, add it first.
3. Mark the task as `IN PROGRESS` before editing code.
4. Mark it as `DONE` when finished and include the real completion timestamp.
5. Add evidence: files changed, short summary, and validations run.
6. If new pending work appears, add it to the ledger before ending the session.
7. Never make silent refactors.
8. If your session changes the project understanding or the recommended takeover guidance, update `HABITOS_PROJECT_INTELLIGENCE_REPORT.html` and `NEXT_COPILOT_HANDOFF.md` before ending the session.

## Product Context That Copilot Must Assume

- HabitOS is a premium nutrition coaching companion.
- The app is for existing clients of a coach or nutritionist.
- The visual direction is clear, warm, mediterranean, editorial, and calm.
- The brand book overrides dark-mode assumptions from the older technical spec when they conflict.
- The long-term architecture is the feature layer plus repositories and real domain models.
- The current demo-driven shell is transitional and should not keep growing without reason.

## Recommended First Prompt For A Fresh Session

This prompt should only be needed if you want to force an especially disciplined start:

`Read NEXT_COPILOT_HANDOFF.md first, then HABITOS_EXECUTION_LEDGER.md and HABITOS_PROJECT_INTELLIGENCE_REPORT.html. Continue from the highest-priority open HabitOS task, update the ledger before and after code changes, and keep all work aligned with .github/copilot-instructions.md.`

## When To Add More Customization

Add more files only if there is a concrete need:

- Add `.github/instructions/*.instructions.md` for file-type-specific rules.
- Add `.github/prompts/*.prompt.md` for repeatable workflows.
- Add `.github/agents/*.agent.md` only if you want specialized personas.

For now, the current setup is enough to make project context and execution discipline persistent across prompts.
