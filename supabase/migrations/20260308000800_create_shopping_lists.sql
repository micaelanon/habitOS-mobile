-- Migration: Create shopping_lists table
-- Model: ShoppingList + ShoppingItem (DataModels.swift)
-- Weekly shopping list, optionally auto-generated from the nutrition plan.
-- Items stored as JSONB array (ShoppingItem structs).

CREATE TABLE IF NOT EXISTS public.shopping_lists (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES public.app_users(id) ON DELETE CASCADE,
    plan_id         UUID REFERENCES public.nutrition_plans(id) ON DELETE SET NULL,
    week_start      DATE NOT NULL,
    items           JSONB NOT NULL DEFAULT '[]'::JSONB,
    auto_generated  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_shopping_lists_user_week ON public.shopping_lists (user_id, week_start DESC);

-- RLS
ALTER TABLE public.shopping_lists ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own shopping lists"
    ON public.shopping_lists FOR SELECT
    TO authenticated
    USING (user_id IN (SELECT id FROM public.app_users WHERE auth_user_id = auth.uid()));

CREATE POLICY "Users can update own shopping lists"
    ON public.shopping_lists FOR UPDATE
    TO authenticated
    USING (user_id IN (SELECT id FROM public.app_users WHERE auth_user_id = auth.uid()))
    WITH CHECK (user_id IN (SELECT id FROM public.app_users WHERE auth_user_id = auth.uid()));

-- Updated-at trigger
CREATE TRIGGER trg_shopping_lists_updated_at
    BEFORE UPDATE ON public.shopping_lists
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
