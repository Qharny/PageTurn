-- ============================================================
-- PageTurn – Reviews, Reading Stats & Cloud Library
-- Run in the Supabase SQL Editor (Dashboard → SQL Editor → New query)
-- ============================================================

-- ── 1. REVIEWS TABLE ─────────────────────────────────────────
create table if not exists public.reviews (
  id          uuid primary key default gen_random_uuid(),
  book_id     text not null,
  profile_id  uuid not null references public.profiles(id) on delete cascade,
  rating      smallint not null check (rating between 1 and 5),
  comment     text not null default '',
  created_at  timestamptz default now(),
  updated_at  timestamptz default now(),
  unique (book_id, profile_id)
);

alter table public.reviews enable row level security;

create policy "Reviews are viewable by everyone"
  on public.reviews for select
  using (true);

-- Anonymous guest sessions can read but not write reviews — a review is
-- tied to a real identity, same gate used for club membership.
create policy "Real users can write their own reviews"
  on public.reviews for insert
  with check (
    auth.uid() = profile_id
    and coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false) = false
  );

create policy "Users can update their own reviews"
  on public.reviews for update
  using (auth.uid() = profile_id);

create policy "Users can delete their own reviews"
  on public.reviews for delete
  using (auth.uid() = profile_id);

drop trigger if exists reviews_set_updated_at on public.reviews;
create trigger reviews_set_updated_at
  before update on public.reviews
  for each row execute procedure public.set_updated_at();


-- ── 2. READING SESSIONS TABLE ────────────────────────────────
-- One row per reader session, logged when a signed-in user closes the
-- reader. Drives "hours read", the daily streak, and the weekly chart.
create table if not exists public.reading_sessions (
  id           uuid primary key default gen_random_uuid(),
  profile_id   uuid not null references public.profiles(id) on delete cascade,
  book_id      text not null,
  minutes      integer not null check (minutes > 0),
  session_date date not null default (now() at time zone 'utc')::date,
  created_at   timestamptz default now()
);

alter table public.reading_sessions enable row level security;

create policy "Users can view their own reading sessions"
  on public.reading_sessions for select
  using (auth.uid() = profile_id);

create policy "Real users can log their own reading sessions"
  on public.reading_sessions for insert
  with check (
    auth.uid() = profile_id
    and coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false) = false
  );


-- ── 3. CLOUD LIBRARY TABLE ───────────────────────────────────
-- Mirrors a signed-in user's on-device library (bookmarked/downloaded
-- books, reading progress, finished status) so it survives reinstalls
-- and syncs across devices. Guests keep using local-only storage.
create table if not exists public.library_books (
  id          uuid primary key default gen_random_uuid(),
  profile_id  uuid not null references public.profiles(id) on delete cascade,
  book_id     text not null,
  book_data   jsonb not null,
  progress    numeric,
  is_finished boolean not null default false,
  added_at    timestamptz default now(),
  updated_at  timestamptz default now(),
  unique (profile_id, book_id)
);

alter table public.library_books enable row level security;

create policy "Users can view their own library"
  on public.library_books for select
  using (auth.uid() = profile_id);

create policy "Real users can add to their own library"
  on public.library_books for insert
  with check (
    auth.uid() = profile_id
    and coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false) = false
  );

create policy "Users can update their own library rows"
  on public.library_books for update
  using (auth.uid() = profile_id);

create policy "Users can delete their own library rows"
  on public.library_books for delete
  using (auth.uid() = profile_id);

drop trigger if exists library_books_set_updated_at on public.library_books;
create trigger library_books_set_updated_at
  before update on public.library_books
  for each row execute procedure public.set_updated_at();


-- ── 4. READING GOAL (on profiles) ────────────────────────────
alter table public.profiles
  add column if not exists reading_goal_target integer not null default 12;
