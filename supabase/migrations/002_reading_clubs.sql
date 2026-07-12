-- ============================================================
-- PageTurn – Reading Clubs & Realtime Chat
-- Run in the Supabase SQL Editor (Dashboard → SQL Editor → New query)
-- ============================================================

-- ── 1. CLUBS TABLE ──────────────────────────────────────────
create table if not exists public.clubs (
  id           text primary key,
  name         text not null,
  description  text not null default '',
  icon         text not null,
  icon_color   text not null,
  bg_color     text not null,
  moderator_id uuid references public.profiles(id) on delete set null,
  rules        text[] not null default '{}',
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);

-- Enable RLS
alter table public.clubs enable row level security;

-- Policies for public.clubs
create policy "Clubs are viewable by everyone"
  on public.clubs for select
  using (true);

create policy "Moderators can update their own clubs"
  on public.clubs for update
  using (auth.uid() = moderator_id);


-- ── 2. CLUB MEMBERS TABLE ───────────────────────────────────
create table if not exists public.club_members (
  club_id    text references public.clubs(id) on delete cascade,
  profile_id uuid references public.profiles(id) on delete cascade,
  joined_at  timestamptz default now(),
  primary key (club_id, profile_id)
);

-- Enable RLS
alter table public.club_members enable row level security;

-- Policies for public.club_members
create policy "Club memberships are viewable by everyone"
  on public.club_members for select
  using (true);

create policy "Authenticated users can join clubs"
  on public.club_members for insert
  with check (auth.uid() = profile_id);

create policy "Members can leave clubs"
  on public.club_members for delete
  using (auth.uid() = profile_id);


-- ── 3. CLUB MESSAGES TABLE ──────────────────────────────────
create table if not exists public.club_messages (
  id          uuid primary key default gen_random_uuid(),
  club_id     text references public.clubs(id) on delete cascade,
  sender_id   uuid references public.profiles(id) on delete cascade,
  text        text not null default '',
  shared_book jsonb, -- Stores rich book metadata { id, title, author, coverUrl, sourceType, etc. }
  created_at  timestamptz default now()
);

-- Enable RLS
alter table public.club_messages enable row level security;

-- Policies for public.club_messages
create policy "Members can view messages in their clubs"
  on public.club_messages for select
  using (
    exists (
      select 1 from public.club_members
      where club_members.club_id = club_messages.club_id
      and club_members.profile_id = auth.uid()
    )
  );

create policy "Members can post messages to their clubs"
  on public.club_messages for insert
  with check (
    auth.uid() = sender_id
    and exists (
      select 1 from public.club_members
      where club_members.club_id = club_messages.club_id
      and club_members.profile_id = auth.uid()
    )
  );


-- ── 4. SEED BASELINE CLUBS ──────────────────────────────────
insert into public.clubs (id, name, description, icon, icon_color, bg_color, rules)
values
  (
    'classics',
    'The Classics Circle',
    'Exploring timeless works from Dickens to Dostoevsky. Read alongside fellow classics enthusiasts, debate themes, and uncover historical contexts.',
    'menu_book',
    '#2D6A4F',
    '#E8F0EC',
    array[
      'Respect fellow members and their interpretations.',
      'No spoilers outside the designated discussion threads.',
      'Participate in the monthly live debate sessions.'
    ]
  ),
  (
    'afrofuturism',
    'Afrofuturism Hub',
    'Where African imagination meets the future of literature. Discover science fiction, fantasy, and speculative fiction by African writers.',
    'rocket_launch',
    '#D97706',
    '#FDF0E9',
    array[
      'Focus on works by writers of the African continent and diaspora.',
      'Keep discussions constructive and encouraging.',
      'Support indie and emerging sci-fi authors.'
    ]
  ),
  (
    'scifi',
    'Sci-Fi Collective',
    'For those who dream beyond the stars and between galaxies. Hard science, cyberpunk, space opera, and dystopian futures are all explored here.',
    'blur_on',
    '#1565C0',
    '#E3F2FD',
    array[
      'All sci-fi subgenres are welcome.',
      'Keep post titles clear of spoilers.',
      'No hate speech or gatekeeping.'
    ]
  ),
  (
    'mystery',
    'Mystery Minds',
    'Unraveling clues, suspects, and unexpected twists together. Dedicated to murder mysteries, thrillers, noir, and classic whodunits.',
    'search',
    '#6A1B9A',
    '#F3E5F5',
    array[
      'Do not spoil the solution to the mystery!',
      'Share your theories in the speculation channel.',
      'Suggest monthly read choices in the polls.'
    ]
  ),
  (
    'history',
    'Historical Horizons',
    'Journeying through history, one page at a time. From ancient civilizations to recent history, we explore novels and narrative non-fiction.',
    'history_edu',
    '#4E342E',
    '#EFEBE9',
    array[
      'Cite historical sources where appropriate.',
      'Discuss historical events objectively.',
      'Recommendations should have a historical core.'
    ]
  )
on conflict (id) do nothing;


-- ── 5. REALTIME REPLICATION ─────────────────────────────────
-- Enable Realtime replication for messages and memberships
do $$
begin
  -- Check and add public.club_messages to publication if not present
  if not exists (
    select 1 from pg_publication_rel pr
    join pg_class c on pr.prrelid = c.oid
    join pg_publication p on pr.prpubid = p.oid
    where p.pubname = 'supabase_realtime' and c.relname = 'club_messages'
  ) then
    alter publication supabase_realtime add table public.club_messages;
  end if;

  -- Check and add public.club_members to publication if not present
  if not exists (
    select 1 from pg_publication_rel pr
    join pg_class c on pr.prrelid = c.oid
    join pg_publication p on pr.prpubid = p.oid
    where p.pubname = 'supabase_realtime' and c.relname = 'club_members'
  ) then
    alter publication supabase_realtime add table public.club_members;
  end if;
end $$;
