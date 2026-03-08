-- Migration: Create meal_logs table
-- Model: MealLog (DataModels.swift)
-- Records actual meals consumed by the user, optionally linked to a plan.

CREATE TABLE IF NOT EXISTS public.meal_logs (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES public.app_users(id) ON DELETE CASCADE,
    plan_id             UUID REFERENCES public.nutrition_plans(id) ON DELETE SET NULL,
    meal_type           TEXT NOT NULL
                            CHECK (meal_type IN ('breakfast', 'mid_morning', 'lunch', 'snack', 'dinner', 'extra')),
    actual_description  TEXT,
    photo_url           TEXT,
    followed_plan       BOOLEAN,
    deviation_reason    TEXT,
    logged_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_meal_logs_user_id ON public.meal_logs (user_id);
CREATE INDEX IF NOT EXISTS idx_meal_logs_logged_at ON public.meal_logs (user_id, logged_at DESC);

-- RLS
ALTER TABLE public.meal_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own meal logs"
    ON public.meal_logs FOR SELECT
    TO authenticated
    USING (user_id IN (SELECT id FROM public.app_users WHERE auth_user_id = auth.uid()));

CREATE POLICY "Users can insert own meal logs"
    ON public.meal_logs FOR INSERT
    TO authenticated
    WITH CHECK (user_id IN (SELECT id FROM public.app_users WHERE auth_user_id = auth.uid()));
