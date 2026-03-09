-- =============================================================================
-- Migration: Tramo 1 — Create account_claim_tokens Table
-- File:      20260309000300_tramo1_create_account_claim_tokens.sql
-- Project:   habitOS-mobile (canonical Supabase project)
-- Date:      2026-03-09
-- Depends on: 20260309000200_tramo1_harden_app_users.sql
--
-- PURPOSE:
--   Enables secure, server-side claiming of patient accounts. A claim token
--   bridges the gap between "web lead with email" and "authenticated Supabase
--   user". The token is generated server-side, sent via email (plaintext),
--   and consumed once when the patient logs in and the claim is validated.
--
-- SECURITY REQUIREMENTS:
--   - Only the token_hash is stored here. The plaintext token is NEVER
--     persisted in the database.
--   - Token generation and SHA-256 hashing MUST occur server-side (n8n,
--     Supabase Edge Function, or backend service).
--   - The claim validation function (to be built in Tramo 3) must check:
--       1. Token hash matches
--       2. Token is not expired
--       3. Token has not been consumed
--       4. Token has not been invalidated
--       5. Authenticated user's email_normalized matches token's email_normalized
--
-- RLS:
--   Service role only. Authenticated app users do NOT read this table directly.
--   The claim flow uses a server-side function that runs as service role.
--
--   Future policy needed (Tramo 3):
--     Optionally allow the owning app_user to check if a token exists for
--     their email (for UX purposes), but only after the claim function exists.
--
-- TOKEN LIFECYCLE:
--   issued   → active        (created, not yet consumed, not expired)
--   active   → consumed      (claim succeeded, consumed_at + consumed_by set)
--   active   → expired       (expires_at passed, system/cron detects it)
--   active   → invalidated   (explicitly voided, e.g. new token issued for same user)
--   consumed → (terminal)    no further transitions
--   invalidated → (terminal) no further transitions
--
-- WHAT THIS TABLE DOES NOT DO:
--   - Does not replace auth.users
--   - Does not store sessions or refresh tokens
--   - Does not store plaintext tokens
--   - Does not define product state or account mode
--   - Does not handle general marketing communications
--   - Does not replace a permissions system
--
-- IDEMPOTENT: CREATE TABLE IF NOT EXISTS + CREATE INDEX IF NOT EXISTS.
-- =============================================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.account_claim_tokens (
  -- Identity
  id                       UUID        PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Which patient account this token belongs to
  -- On delete cascade: if the app_user is deleted, all their tokens are removed
  app_user_id              UUID        NOT NULL
                             REFERENCES public.app_users(id) ON DELETE CASCADE,

  -- Normalized email at issuance time (for validation without decrypting a hash)
  -- Must match the authenticated user's normalized email at claim time
  email_normalized         TEXT        NOT NULL,

  -- SHA-256 hash of the plaintext token (hex-encoded)
  -- The plaintext is NEVER stored here
  token_hash               TEXT        NOT NULL,

  -- Why this token was issued
  purpose                  TEXT        NOT NULL
                             CHECK (purpose IN ('assessment_claim', 'coach_invite')),

  -- Which system generated this token
  issued_by_system         TEXT        NOT NULL
                             CHECK (issued_by_system IN (
                               'assessment_web',
                               'n8n',
                               'coach_console',
                               'backend_internal'
                             )),

  -- Token validity window
  expires_at               TIMESTAMPTZ NOT NULL,

  -- Consumption record (set atomically when claim succeeds)
  consumed_at              TIMESTAMPTZ NULL,
  consumed_by_auth_user_id UUID        NULL
                             REFERENCES auth.users(id),

  -- Explicit invalidation (set when a newer token supersedes this one,
  -- or when an admin voids a token for security reasons)
  invalidated_at           TIMESTAMPTZ NULL,

  -- Audit
  created_at               TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Consistency: if consumed, the consuming user must be recorded
  CONSTRAINT chk_act_consumed_integrity
    CHECK (consumed_at IS NULL OR consumed_by_auth_user_id IS NOT NULL)
);

-- =============================================================================
-- Indexes
-- =============================================================================

-- Primary lookup: token validation (most frequent operation)
CREATE UNIQUE INDEX IF NOT EXISTS idx_act_token_hash
  ON public.account_claim_tokens (token_hash);

-- Lookup by app_user to check for active/pending tokens and invalidate old ones
CREATE INDEX IF NOT EXISTS idx_act_app_user_expires
  ON public.account_claim_tokens (app_user_id, expires_at DESC);

-- Cross-system lookup by email (e.g. "is there a pending claim for this email?")
CREATE INDEX IF NOT EXISTS idx_act_email_normalized
  ON public.account_claim_tokens (email_normalized);

-- =============================================================================
-- Row Level Security
-- =============================================================================

ALTER TABLE public.account_claim_tokens ENABLE ROW LEVEL SECURITY;

-- Only service role can access this table.
-- Claim validation must happen inside a server-side function (Edge Function,
-- n8n, or trusted backend) that uses the service role key.
-- Authenticated app users should NEVER query this table directly.
DROP POLICY IF EXISTS "service_role_all_claim_tokens" ON public.account_claim_tokens;
CREATE POLICY "service_role_all_claim_tokens"
  ON public.account_claim_tokens
  FOR ALL
  TO public
  USING (auth.role() = 'service_role')
  WITH CHECK (auth.role() = 'service_role');

-- =============================================================================
-- Verification
-- =============================================================================

DO $$
BEGIN
  RAISE NOTICE
    'TRAMO1 OK [account_claim_tokens]: Table created with purpose/issued_by_system '
    'constraints, token_hash unique index, and service-role-only RLS policy. '
    'Claim flow implementation deferred to Tramo 3.';
END $$;

COMMIT;
