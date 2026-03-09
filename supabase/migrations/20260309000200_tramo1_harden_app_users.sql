-- =============================================================================
-- Migration: Tramo 1 — Harden app_users as Canonical Patient Entity
-- File:      20260309000200_tramo1_harden_app_users.sql
-- Project:   habitOS-mobile (canonical Supabase project)
-- Date:      2026-03-09
-- Depends on: 20260309000100_tramo1_email_normalization.sql
--
-- PURPOSE:
--   Convert app_users from "iOS-only profile table" into the canonical patient
--   entity for the entire habitOS domain. This enables:
--   - Pre-claim accounts (auth_user_id = NULL) for web-sourced leads
--   - Account mode tracking (solo_ai / hybrid_transition / coach_connected)
--   - Origin tracking (web_assessment / coach_invite / manual_admin / mobile_signup)
--   - Claim timestamp
--   - Linkage back to legacy public.users rows during transition
--
-- CHANGES:
--   1. auth_user_id: NOT NULL -> nullable (partial unique index replaces full unique constraint)
--   2. Add account_mode TEXT NOT NULL DEFAULT 'solo_ai'
--   3. Add origin TEXT NOT NULL DEFAULT 'mobile_signup'
--   4. Add claimed_at TIMESTAMPTZ NULL
--   5. Add legacy_user_id UUID NULL (partial unique where not null)
--   6. Backfill account_mode from existing coach_profile_id
--   7. Add CHECK constraints on account_mode and origin
--
-- iOS COMPATIBILITY:
--   All new columns have defaults or are nullable.
--   Existing iOS SELECT queries on app_users will not break.
--   The existing RLS policy "Users can view own profile" (auth_user_id = auth.uid())
--   continues to work for authenticated users.
--
-- RLS GAP DOCUMENTED:
--   Pre-claim rows (auth_user_id IS NULL) are NOT accessible to authenticated
--   app users via existing RLS policies. This is intentional: pre-claim rows
--   should only be created and read by the service role (n8n, assessment web,
--   backend functions). A dedicated claim function will bridge this gap in
--   Tramo 3 when the server-side claim flow is activated.
--
--   Ownership expectations (to be implemented as policies in Tramo 2/3):
--   ┌──────────────────────┬────────────────────────────────┬──────────────────┐
--   │ Row state            │ Read/write access              │ Via               │
--   ├──────────────────────┼────────────────────────────────┼──────────────────┤
--   │ auth_user_id IS NULL │ service_role only              │ n8n, backend fns │
--   │ auth_user_id = uid() │ authenticated user (own row)   │ iOS, web (future)│
--   │ any row              │ service_role full access       │ always            │
--   └──────────────────────┴────────────────────────────────┴──────────────────┘
--
-- COHERENCE CONSTRAINT (deferred):
--   The following constraint is intentionally NOT applied yet:
--     CHECK (account_mode != 'coach_connected' OR coach_profile_id IS NOT NULL)
--   Reason: existing insert paths (iOS, demo data) do not guarantee this invariant.
--   Will be added in Tramo 2 once writer adaptation is complete.
--
-- IDEMPOTENT: safe to re-run.
-- =============================================================================

BEGIN;

-- =============================================================================
-- STEP 1: Make auth_user_id nullable (support pre-claim accounts)
-- =============================================================================

-- 1a. Drop NOT NULL — allows web leads with no auth account yet
ALTER TABLE public.app_users
  ALTER COLUMN auth_user_id DROP NOT NULL;

-- 1b. Drop the full unique constraint (created by the UNIQUE keyword inline)
--     The backing index is also dropped. The FK constraint remains.
ALTER TABLE public.app_users
  DROP CONSTRAINT IF EXISTS app_users_auth_user_id_key;

-- 1c. Replace with a partial unique index (NULLs are excluded — multiple
--     pre-claim rows with auth_user_id = NULL are allowed; once claimed,
--     the auth_user_id must be unique per Supabase auth guarantee).
CREATE UNIQUE INDEX IF NOT EXISTS idx_app_users_auth_user_id_unique
  ON public.app_users (auth_user_id)
  WHERE auth_user_id IS NOT NULL;

-- NOTE: The existing non-unique index idx_app_users_auth_user_id is kept.
-- The partial unique index above covers authenticated lookups. The non-unique
-- index can be dropped during a future cleanup pass once Tramo 2 is stable.

-- =============================================================================
-- STEP 2: Add account_mode
-- =============================================================================

-- All existing rows get 'solo_ai' as default. Rows with coach_profile_id
-- are backfilled to 'coach_connected' in Step 5 below.
ALTER TABLE public.app_users
  ADD COLUMN IF NOT EXISTS account_mode TEXT NOT NULL DEFAULT 'solo_ai';

-- =============================================================================
-- STEP 3: Add origin
-- =============================================================================

-- All existing rows are presumed to originate from iOS mobile signup.
-- Web-sourced leads will get 'web_assessment' when the writer is adapted.
ALTER TABLE public.app_users
  ADD COLUMN IF NOT EXISTS origin TEXT NOT NULL DEFAULT 'mobile_signup';

-- =============================================================================
-- STEP 4: Add claimed_at
-- =============================================================================

-- NULL for all existing rows. The claim flow (Tramo 3) will populate this
-- when an account_claim_token is consumed and auth_user_id is linked.
-- Existing rows with auth_user_id NOT NULL are "implicitly claimed" (created
-- before the claim flow existed); backfilling claimed_at is deferred to Tramo 2
-- once the policy is confirmed.
ALTER TABLE public.app_users
  ADD COLUMN IF NOT EXISTS claimed_at TIMESTAMPTZ NULL;

-- =============================================================================
-- STEP 5: Add legacy_user_id (partial unique — allows multiple NULLs)
-- =============================================================================

-- References public.users (legacy web table).
-- FK reference is NOT added here: public.users may live in a different Supabase
-- project (one-page-assessment). The FK will be added in Tramo 2 if/when the
-- projects share the same DB.
ALTER TABLE public.app_users
  ADD COLUMN IF NOT EXISTS legacy_user_id UUID NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_app_users_legacy_user_id_unique
  ON public.app_users (legacy_user_id)
  WHERE legacy_user_id IS NOT NULL;

-- =============================================================================
-- STEP 6: Backfill account_mode from existing coach_profile_id
-- =============================================================================

UPDATE public.app_users
  SET account_mode = 'coach_connected'
  WHERE coach_profile_id IS NOT NULL
    AND account_mode = 'solo_ai';

-- =============================================================================
-- STEP 7: Add CHECK constraints (idempotent via DO block)
-- =============================================================================

DO $$
BEGIN
  -- account_mode constraint
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'chk_app_users_account_mode'
      AND conrelid = 'public.app_users'::regclass
  ) THEN
    ALTER TABLE public.app_users
      ADD CONSTRAINT chk_app_users_account_mode
      CHECK (account_mode IN ('solo_ai', 'hybrid_transition', 'coach_connected'));
    RAISE NOTICE 'TRAMO1 OK: Constraint chk_app_users_account_mode added.';
  ELSE
    RAISE NOTICE 'TRAMO1 SKIP: Constraint chk_app_users_account_mode already exists.';
  END IF;

  -- origin constraint
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'chk_app_users_origin'
      AND conrelid = 'public.app_users'::regclass
  ) THEN
    ALTER TABLE public.app_users
      ADD CONSTRAINT chk_app_users_origin
      CHECK (origin IN ('web_assessment', 'coach_invite', 'manual_admin', 'mobile_signup'));
    RAISE NOTICE 'TRAMO1 OK: Constraint chk_app_users_origin added.';
  ELSE
    RAISE NOTICE 'TRAMO1 SKIP: Constraint chk_app_users_origin already exists.';
  END IF;
END $$;

-- =============================================================================
-- STEP 8: Verification summary
-- =============================================================================

DO $$
DECLARE
  v_total        BIGINT;
  v_coach        BIGINT;
  v_solo         BIGINT;
  v_pre_claim    BIGINT;
BEGIN
  SELECT count(*) INTO v_total FROM public.app_users;
  SELECT count(*) INTO v_coach FROM public.app_users WHERE account_mode = 'coach_connected';
  SELECT count(*) INTO v_solo  FROM public.app_users WHERE account_mode = 'solo_ai';
  SELECT count(*) INTO v_pre_claim FROM public.app_users WHERE auth_user_id IS NULL;

  RAISE NOTICE 'TRAMO1 SUMMARY [app_users]: total=%, coach_connected=%, solo_ai=%, pre_claim_null_auth=%',
    v_total, v_coach, v_solo, v_pre_claim;
END $$;

COMMIT;
