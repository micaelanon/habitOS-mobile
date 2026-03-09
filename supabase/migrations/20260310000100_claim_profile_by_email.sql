-- ============================================================================
-- Migration: claim_profile_by_email RPC
-- Purpose:   Bridge web-created patients (auth_user_id = NULL) to iOS auth.
--            When a patient fills the web assessment, app_users is created with
--            email but no auth_user_id. When they log in on iOS with the same
--            email, this function links the auth identity to the existing profile.
-- Safety:    SECURITY DEFINER — bypasses RLS to access unclaimed rows.
--            Uses auth.uid() and auth.jwt()->>'email' — cannot be spoofed.
--            Idempotent — re-calling for an already-claimed user returns existing.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.claim_profile_by_email()
RETURNS SETOF public.app_users
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_auth_id   UUID := auth.uid();
  v_email     TEXT := lower(trim((auth.jwt()->>'email')::TEXT));
  v_claimed   app_users;
BEGIN
  -- Must be authenticated
  IF v_auth_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF v_email IS NULL OR v_email = '' THEN
    RAISE EXCEPTION 'No email in auth token';
  END IF;

  -- 1. Already claimed? Return existing profile (idempotent).
  SELECT * INTO v_claimed
    FROM app_users
   WHERE auth_user_id = v_auth_id
   LIMIT 1;

  IF FOUND THEN
    RETURN NEXT v_claimed;
    RETURN;
  END IF;

  -- 2. Find unclaimed profile by normalized email and claim it.
  UPDATE app_users
     SET auth_user_id         = v_auth_id,
         claimed_at           = now(),
         onboarding_completed = true,
         updated_at           = now()
   WHERE email_normalized = v_email
     AND auth_user_id IS NULL
  RETURNING * INTO v_claimed;

  IF FOUND THEN
    RETURN NEXT v_claimed;
    RETURN;
  END IF;

  -- 3. No matching profile — return empty set.
  --    Caller should handle account creation or show appropriate UI.
  RETURN;
END;
$$;

-- Grant execute to authenticated users (needed for RPC calls from iOS client)
GRANT EXECUTE ON FUNCTION public.claim_profile_by_email() TO authenticated;

COMMENT ON FUNCTION public.claim_profile_by_email() IS
  'Claims an unclaimed app_users profile by matching the authenticated user''s '
  'email to email_normalized. Sets auth_user_id, claimed_at, and '
  'onboarding_completed. Idempotent: returns existing profile if already claimed.';
