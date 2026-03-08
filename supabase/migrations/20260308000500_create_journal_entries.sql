-- Migration: Create journal_entries table
-- Model: JournalEntry (DataModels.swift)
-- Daily wellness journal: mood, energy, sleep, hydration, training, meals, free text.

CREATE TABLE IF NOT EXISTS public.journal_entries (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES public.app_users(id) ON DELETE CASCADE,
    entry_date      DATE NOT NULL,
    mood            TEXT CHECK (mood IN ('great', 'good', 'neutral', 'bad', 'terrible')),
    energy_level    INTEGER CHECK (energy_level BETWEEN 1 AND 5),
    sleep_hours     DOUBLE PRECISION,
    sleep_quality   TEXT CHECK (sleep_quality IN ('great', 'good', 'fair', 'poor')),
    water_liters    DOUBLE PRECISION,
    steps           INTEGER,
    training_done   BOOLEAN NOT NULL DEFAULT FALSE,
    training_notes  TEXT,
    meals_followed  INTEGER,
    meals_total     INTEGER,
    cravings        TEXT,
    symptoms        TEXT,
    free_text       TEXT,
    highlight       TEXT,
    tags            TEXT[] NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- One entry per user per day
    UNIQUE (user_id, entry_date)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_journal_entries_user_date ON public.journal_entries (user_id, entry_date DESC);

-- RLS
ALTER TABLE public.journal_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own journal"
    ON public.journal_entries FOR SELECT
    TO authenticated
    USING (user_id IN (SELECT id FROM public.app_users WHERE auth_user_id = auth.uid()));

CREATE POLICY "Users can insert own journal"
    ON public.journal_entries FOR INSERT
    TO authenticated
    WITH CHECK (user_id IN (SELECT id FROM public.app_users WHERE auth_user_id = auth.uid()));

CREATE POLICY "Users can update own journal"
    ON public.journal_entries FOR UPDATE
    TO authenticated
    USING (user_id IN (SELECT id FROM public.app_users WHERE auth_user_id = auth.uid()))
    WITH CHECK (user_id IN (SELECT id FROM public.app_users WHERE auth_user_id = auth.uid()));

-- Updated-at trigger
CREATE TRIGGER trg_journal_entries_updated_at
    BEFORE UPDATE ON public.journal_entries
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
