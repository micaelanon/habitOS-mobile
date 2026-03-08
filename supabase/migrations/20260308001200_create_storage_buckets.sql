-- Migration: Create storage buckets for photos
-- These buckets are private (RLS-protected).
-- body-photos: progress/transformation photos (HBT-006)
-- meal-photos: meal log photos attached to meal_logs.photo_url

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
    ('body-photos', 'body-photos', FALSE, 10485760, ARRAY['image/jpeg', 'image/png', 'image/heic']),
    ('meal-photos', 'meal-photos', FALSE, 10485760, ARRAY['image/jpeg', 'image/png', 'image/heic'])
ON CONFLICT (id) DO NOTHING;

-- RLS policies for body-photos bucket
CREATE POLICY "Users can upload own body photos"
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (bucket_id = 'body-photos' AND (storage.foldername(name))[1] = auth.uid()::TEXT);

CREATE POLICY "Users can view own body photos"
    ON storage.objects FOR SELECT
    TO authenticated
    USING (bucket_id = 'body-photos' AND (storage.foldername(name))[1] = auth.uid()::TEXT);

CREATE POLICY "Users can delete own body photos"
    ON storage.objects FOR DELETE
    TO authenticated
    USING (bucket_id = 'body-photos' AND (storage.foldername(name))[1] = auth.uid()::TEXT);

-- RLS policies for meal-photos bucket
CREATE POLICY "Users can upload own meal photos"
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (bucket_id = 'meal-photos' AND (storage.foldername(name))[1] = auth.uid()::TEXT);

CREATE POLICY "Users can view own meal photos"
    ON storage.objects FOR SELECT
    TO authenticated
    USING (bucket_id = 'meal-photos' AND (storage.foldername(name))[1] = auth.uid()::TEXT);

CREATE POLICY "Users can delete own meal photos"
    ON storage.objects FOR DELETE
    TO authenticated
    USING (bucket_id = 'meal-photos' AND (storage.foldername(name))[1] = auth.uid()::TEXT);
