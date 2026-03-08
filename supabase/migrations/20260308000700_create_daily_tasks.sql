-- Migration: Create daily_tasks table
-- Model: DailyTaskItem (DataModels.swift)
-- Checklist items for the user's daily routine (nutrition, hydration, etc.)

CREATE TABLE IF NOT EXISTS public.daily_tasks (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES public.app_users(id) ON DELETE CASCADE,
    task_date       DATE NOT NULL,
    title           TEXT NOT NULL,
    category        TEXT CHECK (category IN ('nutrition', 'hydration', 'activity', 'sleep', 'supplement', 'habit', 'other')),
    is_completed    BOOLEAN NOT NULL DEFAULT FALSE,
    completed_at    TIMESTAMPTZ,
    sort_order      INTEGER NOT NULL DEFAULT 0,
    auto_generated  BOOLEAN NOT NULL DEFAULT FALSE,
    source          TEXT NOT NULL DEFAULT 'system'
                        CHECK (source IN ('plan', 'coach', 'user', 'system')),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_daily_tasks_user_date ON public.daily_tasks (user_id, task_date DESC);
CREATE INDEX IF NOT EXISTS idx_daily_tasks_incomplete ON public.daily_tasks (user_id, task_date)
    WHERE is_completed = FALSE;

-- RLS
ALTER TABLE public.daily_tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own tasks"
    ON public.daily_tasks FOR SELECT
    TO authenticated
    USING (user_id IN (SELECT id FROM public.app_users WHERE auth_user_id = auth.uid()));

CREATE POLICY "Users can insert own tasks"
    ON public.daily_tasks FOR INSERT
    TO authenticated
    WITH CHECK (user_id IN (SELECT id FROM public.app_users WHERE auth_user_id = auth.uid()));

CREATE POLICY "Users can update own tasks"
    ON public.daily_tasks FOR UPDATE
    TO authenticated
    USING (user_id IN (SELECT id FROM public.app_users WHERE auth_user_id = auth.uid()))
    WITH CHECK (user_id IN (SELECT id FROM public.app_users WHERE auth_user_id = auth.uid()));
