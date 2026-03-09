-- =============================================================================
-- Migration: Tramo 2 — Harden nutrition_plans as canonical plan contract
-- File:      20260309000500_tramo2_harden_nutrition_plans.sql
-- Project:   habitOS-mobile (canonical Supabase project)
-- Date:      2026-03-09
-- Depends on: 20260308000300_create_nutrition_plans.sql (existing table)
--             20260309000400_tramo2_create_assessments.sql (assessments table)
--
-- PURPOSE:
--   Extend nutrition_plans with the fields required for the Coach Console MVP
--   and for n8n to write canonical plans (Tramo 3):
--     - Provenance: origin, author_type, author_coach_profile_id
--     - Versioning: version_no, previous_plan_id
--     - Plan lifecycle: published_at
--     - Assessment linkage: based_on_assessment_id
--
-- EXISTING TABLE STATE (from 20260308000300_create_nutrition_plans.sql):
--   id, user_id, plan_name, status (draft/active/paused/completed/archived),
--   start_date, end_date, daily_calories, daily_protein_g, daily_carbs_g,
--   daily_fats_g, daily_fiber_g, meal_count, guidelines, meal_plan JSONB,
--   ai_generated BOOLEAN NOT NULL DEFAULT FALSE,
--   created_by TEXT, created_at, updated_at
--
-- EXISTING STATUS CHECK:
--   status IN ('draft', 'active', 'paused', 'completed', 'archived')
--   NOTE: V2 spec reduces this to ('draft', 'active', 'archived').
--   'paused' and 'completed' are kept for backward compatibility with iOS.
--   The Coach Console should only use draft/active/archived.
--
-- BACKFILL DECISIONS:
--   - origin: 'ai' for ALL existing rows (conservative default — all plans
--     currently in production are AI-generated; no Coach Console exists yet).
--     The ai_generated BOOLEAN column is preserved and remains the source of
--     truth for iOS until it migrates to reading origin.
--   - author_type: 'system' for ALL existing rows (same rationale).
--   - version_no: 1 for ALL existing rows.
--   - published_at: NULL for all existing rows (backfilling is deferred —
--     there is no reliable way to determine publication time retroactively).
--
-- UNIQUE ACTIVE PLAN INDEX:
--   Goal: enforce at most one plan with status = 'active' per user.
--   Risk: if any user currently has multiple 'active' plans, the unique index
--   will FAIL. A duplicate-detection guard runs first. If duplicates are found,
--   the index is NOT created and a WARNING is raised with the conflicting user_ids.
--
-- IDEMPOTENT: ADD COLUMN IF NOT EXISTS, guarded CREATE INDEX.
-- =============================================================================

BEGIN;

-- =============================================================================
-- STEP 1: Add origin (provenance of the plan)
-- =============================================================================

ALTER TABLE public.nutrition_plans
  ADD COLUMN IF NOT EXISTS origin TEXT NOT NULL DEFAULT 'ai';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'chk_nutrition_plans_origin'
      AND conrelid = 'public.nutrition_plans'::regclass
  ) THEN
    ALTER TABLE public.nutrition_plans
      ADD CONSTRAINT chk_nutrition_plans_origin
      CHECK (origin IN ('ai', 'coach', 'imported'));
    RAISE NOTICE 'TRAMO2 OK: Constraint chk_nutrition_plans_origin added.';
  END IF;
END $$;

COMMENT ON COLUMN public.nutrition_plans.origin IS
  'How this plan was produced: ai = n8n/Gemini, coach = created/edited by a human'
  ' coach in the Coach Console, imported = migrated from external source.';

-- =============================================================================
-- STEP 2: Add author_type
-- =============================================================================

ALTER TABLE public.nutrition_plans
  ADD COLUMN IF NOT EXISTS author_type TEXT NOT NULL DEFAULT 'system';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'chk_nutrition_plans_author_type'
      AND conrelid = 'public.nutrition_plans'::regclass
  ) THEN
    ALTER TABLE public.nutrition_plans
      ADD CONSTRAINT chk_nutrition_plans_author_type
      CHECK (author_type IN ('system', 'coach', 'admin'));
    RAISE NOTICE 'TRAMO2 OK: Constraint chk_nutrition_plans_author_type added.';
  END IF;
END $$;

COMMENT ON COLUMN public.nutrition_plans.author_type IS
  'Who authored this plan: system = automated (n8n/AI), coach = human professional,'
  ' admin = internal ops. When author_type = coach, author_coach_profile_id should be set.';

-- =============================================================================
-- STEP 3: Add author_coach_profile_id
-- =============================================================================

ALTER TABLE public.nutrition_plans
  ADD COLUMN IF NOT EXISTS author_coach_profile_id UUID NULL
    REFERENCES public.coach_profiles(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_nutrition_plans_author_coach
  ON public.nutrition_plans (author_coach_profile_id)
  WHERE author_coach_profile_id IS NOT NULL;

COMMENT ON COLUMN public.nutrition_plans.author_coach_profile_id IS
  'Set when author_type = coach. References the coach profile that created or'
  ' last published this plan. NULL for AI-generated plans.';

-- =============================================================================
-- STEP 4: Add version_no + backfill
-- =============================================================================

ALTER TABLE public.nutrition_plans
  ADD COLUMN IF NOT EXISTS version_no INTEGER NOT NULL DEFAULT 1;

-- All existing rows are version 1 (default covers inserts; explicit update for safety)
UPDATE public.nutrition_plans
  SET version_no = 1
  WHERE version_no IS DISTINCT FROM 1;

COMMENT ON COLUMN public.nutrition_plans.version_no IS
  'Monotonically increasing version per user. Each new plan for a user should'
  ' increment this. version_no = 1 for all plans that predate this migration.';

-- =============================================================================
-- STEP 5: Add previous_plan_id (version chain)
-- =============================================================================

ALTER TABLE public.nutrition_plans
  ADD COLUMN IF NOT EXISTS previous_plan_id UUID NULL
    REFERENCES public.nutrition_plans(id) ON DELETE SET NULL;

COMMENT ON COLUMN public.nutrition_plans.previous_plan_id IS
  'Points to the plan this one supersedes. NULL for the first plan of a user.'
  ' When a new plan is activated, the previous active plan is archived and'
  ' previous_plan_id is set to its id. Allows full version chain traversal.';

-- =============================================================================
-- STEP 6: Add based_on_assessment_id
-- =============================================================================

ALTER TABLE public.nutrition_plans
  ADD COLUMN IF NOT EXISTS based_on_assessment_id UUID NULL
    REFERENCES public.assessments(id) ON DELETE SET NULL;

COMMENT ON COLUMN public.nutrition_plans.based_on_assessment_id IS
  'References the assessment this plan was generated from. NULL for plans'
  ' created before the assessments table existed in this project, or for'
  ' plans created without an associated assessment (e.g. direct coach edits).';

-- =============================================================================
-- STEP 7: Add published_at
-- =============================================================================

ALTER TABLE public.nutrition_plans
  ADD COLUMN IF NOT EXISTS published_at TIMESTAMPTZ NULL;

COMMENT ON COLUMN public.nutrition_plans.published_at IS
  'Timestamp when this plan was activated and made available to the patient.'
  ' NULL means the plan is still a draft. Set atomically with status = active'
  ' by the publishing operation (n8n or Coach Console). Not backfilled for'
  ' plans existing before this migration.';

-- =============================================================================
-- STEP 8: Backfill origin and author_type from ai_generated
--
-- CONSERVATIVE DECISION: all existing rows get origin = 'ai', author_type = 'system'
-- regardless of ai_generated value. Rationale: ai_generated defaults to FALSE but
-- no human coach has ever published a plan (Coach Console does not exist yet).
-- Any row with ai_generated = FALSE is either demo data or an edge case.
-- The ai_generated column is preserved — iOS continues to use it until it
-- migrates to reading origin.
-- =============================================================================

UPDATE public.nutrition_plans
  SET
    origin      = 'ai',
    author_type = 'system'
  WHERE origin IS DISTINCT FROM 'ai'
     OR author_type IS DISTINCT FROM 'system';

-- =============================================================================
-- STEP 9: Unique active plan per user — guarded index creation
--
-- CANNOT use CREATE INDEX CONCURRENTLY inside a transaction block.
-- Using DO block with duplicate detection guard instead.
-- If duplicates exist, the index is SKIPPED and a WARNING is raised.
-- Resolve by archiving duplicate active plans before re-running.
-- =============================================================================

DO $$
DECLARE
  v_dup_count BIGINT := 0;
  r           RECORD;
BEGIN
  -- Count users who have more than one plan with status = 'active'
  SELECT count(*) INTO v_dup_count
  FROM (
    SELECT user_id
    FROM public.nutrition_plans
    WHERE status = 'active'
    GROUP BY user_id
    HAVING count(*) > 1
  ) AS sub;

  IF v_dup_count > 0 THEN
    RAISE WARNING
      'TRAMO2 BLOCKER [nutrition_plans]: % user(s) have multiple active plans. '
      'Unique index NOT created. Archive duplicate active plans, then re-run.',
      v_dup_count;
    FOR r IN
      SELECT user_id, count(*) AS cnt
      FROM public.nutrition_plans
      WHERE status = 'active'
      GROUP BY user_id
      HAVING count(*) > 1
      ORDER BY user_id
    LOOP
      RAISE WARNING
        'TRAMO2 DUPLICATE [nutrition_plans]: user_id=% has % active plans.',
        r.user_id, r.cnt;
    END LOOP;
  ELSE
    -- Drop the old non-unique partial index first (it's superseded by the unique one)
    DROP INDEX IF EXISTS idx_nutrition_plans_status;

    -- Create the enforcing unique index
    CREATE UNIQUE INDEX idx_nutrition_plans_one_active_per_user
      ON public.nutrition_plans (user_id)
      WHERE status = 'active';

    RAISE NOTICE
      'TRAMO2 OK [nutrition_plans]: No duplicate active plans found. '
      'Unique index idx_nutrition_plans_one_active_per_user created. '
      'Old non-unique idx_nutrition_plans_status dropped.';
  END IF;
END $$;

-- =============================================================================
-- STEP 10: Verification summary
-- =============================================================================

DO $$
DECLARE
  v_total      BIGINT;
  v_active     BIGINT;
  v_draft      BIGINT;
  v_ai         BIGINT;
  v_with_prev  BIGINT;
  v_published  BIGINT;
BEGIN
  SELECT count(*)
    INTO v_total FROM public.nutrition_plans;
  SELECT count(*)
    INTO v_active FROM public.nutrition_plans WHERE status = 'active';
  SELECT count(*)
    INTO v_draft FROM public.nutrition_plans WHERE status = 'draft';
  SELECT count(*)
    INTO v_ai FROM public.nutrition_plans WHERE origin = 'ai';
  SELECT count(*)
    INTO v_with_prev FROM public.nutrition_plans WHERE previous_plan_id IS NOT NULL;
  SELECT count(*)
    INTO v_published FROM public.nutrition_plans WHERE published_at IS NOT NULL;

  RAISE NOTICE
    'TRAMO2 SUMMARY [nutrition_plans]: total=%, active=%, draft=%, origin_ai=%, '
    'with_previous_plan_id=%, with_published_at=%',
    v_total, v_active, v_draft, v_ai, v_with_prev, v_published;

  RAISE NOTICE
    'TRAMO2 REMINDER: published_at is NULL for all existing rows (not backfilled). '
    'Tramo 3 writer adaptation will populate it on new plan activations. '
    'Coach Console must set published_at atomically with status = active.';
END $$;

COMMIT;
