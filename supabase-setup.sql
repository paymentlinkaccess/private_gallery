-- Run once in Supabase SQL Editor. Never paste a service-role key into GitHub.
create table if not exists public.feed_memberships (
 user_id uuid primary key references auth.users(id) on delete cascade,
 role text not null default 'member' check(role in ('member','admin')),
 lifetime boolean not null default false,
 access_until timestamptz,
 created_at timestamptz not null default now()
);
create table if not exists public.feed_posts (
 id bigint generated always as identity primary key,
 title text not null,
 description text not null default '',
 category text not null default 'Daily Updates',
 video_path text not null unique,
 created_at timestamptz not null default now()
);
alter table public.feed_memberships enable row level security;
alter table public.feed_posts enable row level security;
create or replace function public.feed_has_access() returns boolean language sql stable security definer set search_path='' as $$
 select exists(select 1 from public.feed_memberships m where m.user_id=(select auth.uid()) and (m.lifetime or m.access_until>now()))
$$;
create or replace function public.feed_is_admin() returns boolean language sql stable security definer set search_path='' as $$
 select exists(select 1 from public.feed_memberships m where m.user_id=(select auth.uid()) and m.role='admin')
$$;
revoke all on function public.feed_has_access() from public;
revoke all on function public.feed_is_admin() from public;
grant execute on function public.feed_has_access() to authenticated;
grant execute on function public.feed_is_admin() to authenticated;
create policy "Read own membership" on public.feed_memberships for select to authenticated using(user_id=(select auth.uid()));
create policy "Members read posts" on public.feed_posts for select to authenticated using((select public.feed_has_access()) or (select public.feed_is_admin()));
create policy "Admins insert posts" on public.feed_posts for insert to authenticated with check((select public.feed_is_admin()));
insert into storage.buckets(id,name,public) values('feed-videos','feed-videos',false) on conflict(id) do update set public=false;
create policy "Members can view feed videos" on storage.objects for select to authenticated using(bucket_id='feed-videos' and ((select public.feed_has_access()) or (select public.feed_is_admin())));
create policy "Admins upload feed videos" on storage.objects for insert to authenticated with check(bucket_id='feed-videos' and (select public.feed_is_admin()));
-- IMPORTANT: Admin memberships and paid memberships must be granted by trusted
-- server-side Stripe webhook / manual Supabase SQL, NEVER by browser code.
-- Example after admin signs in once:
-- insert into public.feed_memberships(user_id,role,lifetime)
-- values ('ADMIN_AUTH_USER_UUID','admin',true)
-- on conflict(user_id) do update set role='admin', lifetime=true;
