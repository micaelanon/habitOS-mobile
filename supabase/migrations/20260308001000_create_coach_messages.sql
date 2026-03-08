-- Migration: Create coach_messages table
-- Model: CoachMessage (DataModels.swift)
-- Chat messages between coach AI and user, across channels (app, telegram, web).

CREATE TABLE IF NOT EXISTS public.coach_messages (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id   UUID NOT NULL REFERENCES public.app_users(id) ON DELETE CASCADE,
    role         TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    channel      TEXT NOT NULL DEFAULT 'app'
                     CHECK (channel IN ('telegram', 'app', 'web')),
    message_text TEXT NOT NULL,
    media_type   TEXT,
    media_url    TEXT,
    metadata     JSONB,
    expires_at   TIMESTAMPTZ,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_coach_messages_profile_id ON public.coach_messages (profile_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_coach_messages_channel ON public.coach_messages (profile_id, channel);

-- RLS
ALTER TABLE public.coach_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own messages"
    ON public.coach_messages FOR SELECT
    TO authenticated
    USING (profile_id IN (SELECT id FROM public.app_users WHERE auth_user_id = auth.uid()));

CREATE POLICY "Users can send messages"
    ON public.coach_messages FOR INSERT
    TO authenticated
    WITH CHECK (profile_id IN (SELECT id FROM public.app_users WHERE auth_user_id = auth.uid()));
