-- Run once in Supabase SQL Editor to authorize admin-only deletion.
DROP POLICY IF EXISTS "Admins delete posts" ON public.feed_posts;
CREATE POLICY "Admins delete posts" ON public.feed_posts
FOR DELETE TO authenticated USING ((select public.feed_is_admin()));

DROP POLICY IF EXISTS "Admins delete feed media" ON storage.objects;
CREATE POLICY "Admins delete feed media" ON storage.objects
FOR DELETE TO authenticated
USING (bucket_id = 'feed-videos' AND (select public.feed_is_admin()));
