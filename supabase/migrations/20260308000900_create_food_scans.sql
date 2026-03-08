-- Migration: Create food_scans table
-- Model: FoodScan (DataModels.swift)
-- Records barcode scans with nutritional data from OpenFoodFacts.

CREATE TABLE IF NOT EXISTS public.food_scans (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID NOT NULL REFERENCES public.app_users(id) ON DELETE CASCADE,
    barcode                 TEXT NOT NULL,
    product_name            TEXT,
    brand                   TEXT,
    nutriscore_grade        TEXT,
    nova_group              INTEGER CHECK (nova_group BETWEEN 1 AND 4),
    calories_per_100g       DOUBLE PRECISION,
    allergens               TEXT[] NOT NULL DEFAULT '{}',
    is_compatible           BOOLEAN,
    incompatibility_reason  TEXT,
    scanned_at              TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_food_scans_user_id ON public.food_scans (user_id);
CREATE INDEX IF NOT EXISTS idx_food_scans_barcode ON public.food_scans (barcode);
CREATE INDEX IF NOT EXISTS idx_food_scans_scanned_at ON public.food_scans (user_id, scanned_at DESC);

-- RLS
ALTER TABLE public.food_scans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own food scans"
    ON public.food_scans FOR SELECT
    TO authenticated
    USING (user_id IN (SELECT id FROM public.app_users WHERE auth_user_id = auth.uid()));

CREATE POLICY "Users can insert own food scans"
    ON public.food_scans FOR INSERT
    TO authenticated
    WITH CHECK (user_id IN (SELECT id FROM public.app_users WHERE auth_user_id = auth.uid()));
