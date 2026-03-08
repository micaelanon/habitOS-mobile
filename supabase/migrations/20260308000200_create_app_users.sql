-- Migration: Create app_users table
-- Model: AppUser (AppUser.swift)
-- Central user profile table, linked to Supabase Auth via auth_user_id.

CREATE TABLE IF NOT EXISTS public.app_users (
    id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_user_id           UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    coach_profile_id       UUID REFERENCES public.coach_profiles(id) ON DELETE SET NULL,
    first_name             TEXT    NOT NULL,
    last_name              TEXT    NOT NULL,
    email                  TEXT    NOT NULL,
    phone                  TEXT,
    avatar_url             TEXT,
    sex                    TEXT,
    date_of_birth          DATE,
    height_cm              DOUBLE PRECISION,
    current_weight_kg      DOUBLE PRECISION,
    goal                   TEXT,
    activity_level         TEXT,
    food_allergies         TEXT[]  NOT NULL DEFAULT '{}',
    food_dislikes          TEXT[]  NOT NULL DEFAULT '{}',
    diet_type              TEXT,
    medical_conditions     TEXT[]  NOT NULL DEFAULT '{}',
    timezone               TEXT    NOT NULL DEFAULT 'Europe/Madrid',
    locale                 TEXT    NOT NULL DEFAULT 'es',
    notifications_enabled  BOOLEAN NOT NULL DEFAULT TRUE,
    healthkit_enabled      BOOLEAN NOT NULL DEFAULT FALSE,
    onboarding_completed   BOOLEAN NOT NULL DEFAULT FALSE,
    created_at             TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_app_users_auth_user_id ON public.app_users (auth_user_id);
CREATE INDEX IF NOT EXISTS idx_app_users_coach_profile_id ON public.app_users (coach_profile_id);
CREATE INDEX IF NOT EXISTS idx_app_users_email ON public.app_users (email);

-- RLS
ALTER TABLE public.app_users ENABLE ROW LEVEL SECURITY;

-- Users can only read/update their own row
CREATE POLICY "Users can view own profile"
    ON public.app_users FOR SELECT
    TO authenticated
    USING (auth_user_id = auth.uid());

CREATE POLICY "Users can update own profile"
    ON public.app_users FOR UPDATE
    TO authenticated
    USING (auth_user_id = auth.uid())
    WITH CHECK (auth_user_id = auth.uid());

-- Updated-at trigger (reuses function from migration 001)
CREATE TRIGGER trg_app_users_updated_at
    BEFORE UPDATE ON public.app_users
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
