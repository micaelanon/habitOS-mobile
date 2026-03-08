-- Migration: Create nutrition_plans table
-- Model: NutritionPlan (NutritionPlan.swift)
-- Contains the user's assigned meal plan with JSONB weekly meal structure.

CREATE TABLE IF NOT EXISTS public.nutrition_plans (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES public.app_users(id) ON DELETE CASCADE,
    plan_name       TEXT NOT NULL,
    status          TEXT NOT NULL DEFAULT 'draft'
                        CHECK (status IN ('draft', 'active', 'paused', 'completed', 'archived')),
    start_date      DATE NOT NULL,
    end_date        DATE,
    daily_calories  INTEGER,
    daily_protein_g INTEGER,
    daily_carbs_g   INTEGER,
    daily_fats_g    INTEGER,
    daily_fiber_g   INTEGER,
    meal_count      INTEGER NOT NULL DEFAULT 5,
    guidelines      TEXT,
    meal_plan       JSONB NOT NULL DEFAULT '{}'::JSONB,
    ai_generated    BOOLEAN NOT NULL DEFAULT FALSE,
    created_by      TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_nutrition_plans_user_id ON public.nutrition_plans (user_id);
CREATE INDEX IF NOT EXISTS idx_nutrition_plans_status ON public.nutrition_plans (user_id, status)
    WHERE status = 'active';

-- RLS
ALTER TABLE public.nutrition_plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own plans"
    ON public.nutrition_plans FOR SELECT
    TO authenticated
    USING (user_id IN (SELECT id FROM public.app_users WHERE auth_user_id = auth.uid()));

-- Updated-at trigger
CREATE TRIGGER trg_nutrition_plans_updated_at
    BEFORE UPDATE ON public.nutrition_plans
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
