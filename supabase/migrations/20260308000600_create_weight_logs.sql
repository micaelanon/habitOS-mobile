-- Migration: Create weight_logs table
-- Model: WeightLog (DataModels.swift)
-- Body composition tracking: weight, body fat, muscle, waist, hip.

CREATE TABLE IF NOT EXISTS public.weight_logs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES public.app_users(id) ON DELETE CASCADE,
    weight_kg       DOUBLE PRECISION NOT NULL,
    body_fat_pct    DOUBLE PRECISION,
    muscle_mass_kg  DOUBLE PRECISION,
    waist_cm        DOUBLE PRECISION,
    hip_cm          DOUBLE PRECISION,
    notes           TEXT,
    source          TEXT NOT NULL DEFAULT 'manual'
                        CHECK (source IN ('manual', 'healthkit', 'smart_scale')),
    logged_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_weight_logs_user_logged ON public.weight_logs (user_id, logged_at DESC);

-- RLS
ALTER TABLE public.weight_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own weight logs"
    ON public.weight_logs FOR SELECT
    TO authenticated
    USING (user_id IN (SELECT id FROM public.app_users WHERE auth_user_id = auth.uid()));

CREATE POLICY "Users can insert own weight logs"
    ON public.weight_logs FOR INSERT
    TO authenticated
    WITH CHECK (user_id IN (SELECT id FROM public.app_users WHERE auth_user_id = auth.uid()));

CREATE POLICY "Users can delete own weight logs"
    ON public.weight_logs FOR DELETE
    TO authenticated
    USING (user_id IN (SELECT id FROM public.app_users WHERE auth_user_id = auth.uid()));
