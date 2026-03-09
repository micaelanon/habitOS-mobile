-- =============================================================================
-- Migration: Tramo 2 — Create canonical assessments table (mobile project)
-- File:      20260309000400_tramo2_create_assessments.sql
-- Project:   habitOS-mobile (canonical Supabase project)
-- Date:      2026-03-09
-- Depends on: 20260309000200_tramo1_harden_app_users.sql
--
-- PURPOSE:
--   Create the canonical assessments table in the habitOS-mobile Supabase
--   project. This is the intended long-term home for assessment data once:
--     a) The backend projects unify (one Supabase project), OR
--     b) n8n is adapted (Tramo 3) to write directly here after the web form
--
--   Currently (Tramo 2), this table is created but empty. It serves as:
--   - The schema contract that Tramo 3 will write to
--   - The target for the data sync/migration from the web project
--   - A table iOS can eventually query for assessment history
--
-- FIELD DESIGN:
--   - app_user_id is NOT NULL: every canonical assessment must belong to a
--     patient. Pre-claim assessments from the web project are created in the
--     web project's table until they are claimed and backfilled here.
--   - raw_payload JSONB NULL: intentionally nullable in this canonical table.
--     New rows written by n8n (Tramo 3) will always populate it. Historical
--     rows migrated from the web project may populate it from web payload.
--   - source TEXT: canonical name for what submission_channel covers in the
--     web project.
--
-- RLS:
--   - Authenticated users can read their own assessments (via app_user_id →
--     app_users → auth_user_id = auth.uid())
--   - Service role has full access
--   - No INSERT policy for authenticated users: assessments are written by
--     the system (n8n, backend), not directly by the app
--
-- IDEMPOTENT: CREATE TABLE IF NOT EXISTS, CREATE INDEX IF NOT EXISTS.
-- =============================================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.assessments (
  -- Identity
  id                   UUID        PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Ownership: every canonical assessment belongs to one patient
  -- app_user_id can be NULL iff the row was migrated from the web project
  -- and the patient has not yet been claimed. Once claimed, it must be set.
  app_user_id          UUID        NULL
                         REFERENCES public.app_users(id) ON DELETE SET NULL,

  -- Assessment schema version (increment when form changes materially)
  assessment_version   INTEGER     NOT NULL DEFAULT 1,

  -- Origin of this assessment
  source               TEXT        NOT NULL DEFAULT 'web_assessment'
                         CHECK (source IN (
                           'web_assessment',
                           'coach_console',
                           'app_reassessment',
                           'imported'
                         )),

  -- Pipeline status (mirrors web project processing_status for operational parity)
  processing_status    TEXT        NOT NULL DEFAULT 'received'
                         CHECK (processing_status IN (
                           'received',
                           'sent_to_n8n',
                           'n8n_failed',
                           'processed',
                           'completed'
                         )),

  -- Structured top-level fields (mirrored from web submission for querying)
  -- These are intentionally limited to fields useful for filtering/analytics.
  -- The full submission lives in raw_payload.
  first_name           TEXT        NULL,
  last_name            TEXT        NULL,
  email                TEXT        NULL,
  phone                TEXT        NULL,
  goal                 TEXT        NULL,

  -- Full submission snapshot (raw form payload)
  -- NULL is allowed for rows imported before raw payload was captured.
  -- New rows written by n8n (Tramo 3+) MUST populate this field.
  -- BACKFILL NOTE: For rows migrated from the web project, raw_payload is
  -- populated from the web assessments.payload column.
  raw_payload          JSONB       NULL,

  -- Audit
  created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =============================================================================
-- Indexes
-- =============================================================================

-- Primary patient lookup
CREATE INDEX IF NOT EXISTS idx_assessments_app_user_id
  ON public.assessments (app_user_id)
  WHERE app_user_id IS NOT NULL;

-- Patient history ordered by time (iOS query pattern)
CREATE INDEX IF NOT EXISTS idx_assessments_app_user_created
  ON public.assessments (app_user_id, created_at DESC)
  WHERE app_user_id IS NOT NULL;

-- Assessment source filtering
CREATE INDEX IF NOT EXISTS idx_assessments_source
  ON public.assessments (source);

-- Processing pipeline status
CREATE INDEX IF NOT EXISTS idx_assessments_processing_status
  ON public.assessments (processing_status)
  WHERE processing_status NOT IN ('processed', 'completed');

-- GIN index on raw_payload for JSONB queries (n8n, Coach Console)
CREATE INDEX IF NOT EXISTS idx_assessments_raw_payload_gin
  ON public.assessments USING GIN (raw_payload)
  WHERE raw_payload IS NOT NULL;

-- =============================================================================
-- Updated-at trigger (reuses set_updated_at function from migration 001)
-- =============================================================================

CREATE TRIGGER trg_assessments_updated_at
  BEFORE UPDATE ON public.assessments
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- =============================================================================
-- Row Level Security
-- =============================================================================

ALTER TABLE public.assessments ENABLE ROW LEVEL SECURITY;

-- Authenticated users can read their own assessments
CREATE POLICY "Users can view own assessments"
  ON public.assessments FOR SELECT
  TO authenticated
  USING (
    app_user_id IN (
      SELECT id FROM public.app_users WHERE auth_user_id = auth.uid()
    )
  );

-- Service role has full access (used by n8n, backend functions, Coach Console)
-- No INSERT policy for authenticated users: the app does not write assessments.
CREATE POLICY "Service role full access"
  ON public.assessments FOR ALL
  TO public
  USING (auth.role() = 'service_role')
  WITH CHECK (auth.role() = 'service_role');

-- =============================================================================
-- Verification
-- =============================================================================

DO $$
BEGIN
  RAISE NOTICE
    'TRAMO2 OK [assessments canonical]: Table created in habitOS-mobile project. '
    'Currently empty — will be populated in Tramo 3 when n8n writers are adapted. '
    'iOS can read via RLS policy (own assessments via app_user_id). '
    'raw_payload is nullable to support historical migration rows.';
END $$;

COMMIT;
