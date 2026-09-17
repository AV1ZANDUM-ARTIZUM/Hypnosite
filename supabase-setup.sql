-- Hypnosite Community Media setup
-- Run this in the Supabase SQL Editor for your project.

create table if not exists public.media_uploads (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  display_name text not null default 'Anonymous',
  tags text not null default '',
  kind text not null check (kind in ('mp3','mp4')),
  size_bytes bigint not null default 0,
  storage_path text not null unique,
  plays integer not null default 0,
  created_at timestamptz not null default now()
);

alter table public.media_uploads enable row level security;

drop policy if exists "Anyone can read community media metadata" on public.media_uploads;
create policy "Anyone can read community media metadata"
on public.media_uploads for select using (true);

drop policy if exists "Anyone can publish community media metadata" on public.media_uploads;
create policy "Anyone can publish community media metadata"
on public.media_uploads for insert with check (true);

drop policy if exists "Anyone can update play counts" on public.media_uploads;
create policy "Anyone can update play counts"
on public.media_uploads for update using (true) with check (true);

insert into storage.buckets (id,name,public)
values ('community-media','community-media',true)
on conflict (id) do update set public=true;

drop policy if exists "Public can read community media files" on storage.objects;
create policy "Public can read community media files"
on storage.objects for select using (bucket_id='community-media');

drop policy if exists "Public can upload community media files" on storage.objects;
create policy "Public can upload community media files"
on storage.objects for insert with check (bucket_id='community-media');

-- IMPORTANT: this intentionally allows public uploads. If the site grows,
-- add authentication, file-size limits, moderation, and abuse/rate controls.
