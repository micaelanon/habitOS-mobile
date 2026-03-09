-- =============================================================================
-- Migration: Tramo 1 — Email Normalization
-- File:      20260309000100_tramo1_email_normalization.sql
-- Project:   habitOS-mobile (canonical Supabase project)
-- Date:      2026-03-09
--
-- BUSINESS RULE DOCUMENTED:
--   ONE EMAIL = ONE PATIENT.
--   email_normalized = lower(trim(email)) is the canonical identity key for
--   pre-authentication matching. This constraint is the foundation of the
--   claim flow and the cross-system identity resolution.
--
-- SCOPE:
--   1. Add email_normalized to public.app_users. Backfill. Create unique index
--      only if no duplicates are detected. If duplicates exist, log them and
--      skip the index — they must be resolved manually before Tramo 2.
--   2. Handle public.users (legacy web table) defensively. If the table exists
--      in this same DB instance, apply the same normalization. No-op otherwise.
--
-- OUT OF SCOPE:
--   - public.assessments (Tramo 2)
--   - public.nutrition_plans (Tramo 2)
--   - n8n / one-page-assessment writers (Tramo 2)
--   - claim flow (Tramo 3)
--
-- IDEMPOTENT: safe to re-run. ADD COLUMN IF NOT EXISTS, index IF NOT EXISTS.
-- =============================================================================

BEGIN;

-- =============================================================================
-- SECTION 1: public.app_users — add and index email_normalized
-- =============================================================================

-- 1a. Add column (no-op if already present)
ALTER TABLE public.app_users
  ADD COLUMN IF NOT EXISTS email_normalized TEXT;

-- 1b. Backfill: app_users.email is NOT NULL so this covers all rows
UPDATE public.app_users
  SET email_normalized = lower(trim(email))
  WHERE email_normalized IS NULL;

-- 1c. Enforce NOT NULL after backfill
ALTER TABLE public.app_users
  ALTER COLUMN email_normalized SET NOT NULL;

-- 1d. Detect duplicates; create unique index only when safe
DO $$
DECLARE
  v_dup_count BIGINT := 0;
  r           RECORD;
BEGIN
  SELECT count(*) INTO v_dup_count
  FROM (
    SELECT email_normalized
    FROM public.app_users
    GROUP BY email_normalized
    HAVING count(*) > 1
  ) AS sub;

  IF v_dup_count > 0 THEN
    RAISE WARNING
      'TRAMO1 BLOCKER [app_users.email_normalized]: % distinct value(s) appear more than once. '
      'Unique index NOT created. Resolve duplicates manually, then re-run this migration.',
      v_dup_count;
    -- Log each conflicting value so the operator knows exactly what to fix
    FOR r IN
      SELECT email_normalized, count(*) AS cnt
      FROM public.app_users
      GROUP BY email_normalized
      HAVING count(*) > 1
      ORDER BY email_normalized
    LOOP
      RAISE WARNING
        'TRAMO1 DUPLICATE [app_users]: email_normalized=''%'' appears % time(s).',
        r.email_normalized, r.cnt;
    END LOOP;
  ELSE
    CREATE UNIQUE INDEX IF NOT EXISTS idx_app_users_email_normalized
      ON public.app_users (email_normalized);
    RAISE NOTICE
      'TRAMO1 OK [app_users]: No duplicates found. '
      'Unique index idx_app_users_email_normalized created successfully.';
  END IF;
END $$;

-- =============================================================================
-- SECTION 2: public.users (legacy web table) — defensive normalization
--
-- NOTE: public.users may live in a separate Supabase project (one-page-assessment).
--       If so, this section is a no-op. A separate migration for the web project
--       is provided at: one-page-assessment/supabase/migrations/202603090001_*.sql
--
-- If both tables are in the same DB (unified backend scenario), this block
-- handles the users table with the same duplicate-detection guard.
-- =============================================================================

DO $$
DECLARE
  v_table_exists BOOLEAN;
  v_col_exists   BOOLEAN;
  v_dup_count    BIGINT := 0;
  r              RECORD;
BEGIN
  -- Check if public.users exists in this DB
  SELECT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'users'
  ) INTO v_table_exists;

  IF NOT v_table_exists THEN
    RAISE NOTICE 'TRAMO1 SKIP [users]: public.users not found in this DB. No action taken.';
    RETURN;
  END IF;

  -- Add column if not already present
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'users'
      AND column_name  = 'email_normalized'
  ) INTO v_col_exists;

  IF NOT v_col_exists THEN
    EXECUTE 'ALTER TABLE public.users ADD COLUMN email_normalized TEXT';
    RAISE NOTICE 'TRAMO1 OK [users]: email_normalized column added.';
  END IF;

  -- Backfill (idempotent: only touches NULL rows)
  EXECUTE 'UPDATE public.users SET email_normalized = lower(trim(email)) WHERE email_normalized IS NULL';

  -- Set NOT NULL (users.email is NOT NULL per schema)
  EXECUTE 'ALTER TABLE public.users ALTER COLUMN email_normalized SET NOT NULL';

  RAISE NOTICE 'TRAMO1 OK [users]: email_normalized backfilled and NOT NULL enforced.';

  -- Detect duplicates
  EXECUTE
    'SELECT count(*) FROM ('
    '  SELECT email_normalized FROM public.users'
    '  GROUP BY email_normalized HAVING count(*) > 1'
    ') AS sub'
  INTO v_dup_count;

  IF v_dup_count > 0 THEN
    RAISE WARNING
      'TRAMO1 BLOCKER [users.email_normalized]: % duplicate value(s) found. '
      'Unique index NOT created. Resolve manually.',
      v_dup_count;
    FOR r IN
      EXECUTE
        'SELECT email_normalized, count(*)::bigint AS cnt'
        ' FROM public.users'
        ' GROUP BY email_normalized'
        ' HAVING count(*) > 1'
        ' ORDER BY email_normalized'
    LOOP
      RAISE WARNING
        'TRAMO1 DUPLICATE [users]: email_normalized=''%'' appears % time(s).',
        r.email_normalized, r.cnt;
    END LOOP;
  ELSE
    EXECUTE 'CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email_normalized ON public.users (email_normalized)';
    RAISE NOTICE 'TRAMO1 OK [users]: Unique index idx_users_email_normalized created.';
  END IF;

END $$;

COMMIT;
