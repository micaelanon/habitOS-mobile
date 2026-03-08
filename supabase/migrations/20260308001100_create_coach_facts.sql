-- Migration: Create coach_facts table
-- Model: CoachMemory (CoachMemory.swift)
-- Structured facts the coach AI remembers about the user.

CREATE TABLE IF NOT EXISTS public.coach_facts (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id  UUID NOT NULL REFERENCES public.app_users(id) ON DELETE CASCADE,
    fact_kind   TEXT NOT NULL,
    title       TEXT NOT NULL,
    fact_text   TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_coach_facts_profile_id ON public.coach_facts (profile_id);
CREATE INDEX IF NOT EXISTS idx_coach_facts_kind ON public.coach_facts (profile_id, fact_kind);

-- RLS
ALTER TABLE public.coach_facts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own coach facts"
    ON public.coach_facts FOR SELECT
    TO authenticated
    USING (profile_id IN (SELECT id FROM public.app_users WHERE auth_user_id = auth.uid()));
