-- Run in Supabase SQL Editor once to support photos and videos in Gallery Feed.
alter table public.feed_posts add column if not exists media_type text not null default 'video';
alter table public.feed_posts drop constraint if exists feed_posts_media_type_check;
alter table public.feed_posts add constraint feed_posts_media_type_check check (media_type in ('image','video'));
-- Existing posts default to video. Photos use the existing private feed-videos bucket.
