-- Migration: Create coach_profiles table
-- Model: CoachProfile (CoachProfile in DataModels.swift)
-- This table is read-only from the iOS app. Managed by the coach/admin dashboard.

CREATE TABLE IF NOT EXISTS public.coach_profiles (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    display_name  TEXT    NOT NULL,
    coach_name    TEXT    NOT NULL,
    coach_mode    TEXT    NOT NULL DEFAULT 'default',
    is_active     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index for active coaches lookup
CREATE INDEX IF NOT EXISTS idx_coach_profiles_active ON public.coach_profiles (is_active) WHERE is_active = TRUE;

-- RLS
ALTER TABLE public.coach_profiles ENABLE ROW LEVEL SECURITY;

-- Authenticated users can read active coach profiles
CREATE POLICY "Users can view active coaches"
    ON public.coach_profiles FOR SELECT
    TO authenticated
    USING (is_active = TRUE);

-- Updated-at trigger
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_coach_profiles_updated_at
    BEFORE UPDATE ON public.coach_profiles
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
