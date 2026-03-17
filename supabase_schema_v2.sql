-- ============================================
-- RADU COACHING PLATFORM — Schema V2 (new tables)
-- Run this AFTER the original schema
-- ============================================

-- 6. Feed Posts
create table posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade not null,
  content text not null,
  created_at timestamptz default now()
);

-- 7. Post Comments
create table post_comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references posts(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  content text not null,
  created_at timestamptz default now()
);

-- 8. Post Reactions
create table post_reactions (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references posts(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  reaction_type text not null check (reaction_type in ('heart', 'clap', 'fire', 'muscle')),
  created_at timestamptz default now(),
  unique(post_id, user_id, reaction_type)
);

-- 9. Live Sessions (Suport LIVE)
create table live_sessions (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  meet_link text not null,
  scheduled_at timestamptz not null,
  created_at timestamptz default now()
);

-- 10. Live Session RSVPs
create table live_session_rsvps (
  id uuid primary key default gen_random_uuid(),
  session_id uuid references live_sessions(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  created_at timestamptz default now(),
  unique(session_id, user_id)
);

-- ============================================
-- ROW LEVEL SECURITY for new tables
-- ============================================

alter table posts enable row level security;
alter table post_comments enable row level security;
alter table post_reactions enable row level security;
alter table live_sessions enable row level security;
alter table live_session_rsvps enable row level security;

-- Posts: all authenticated can read and create, users delete own, admin deletes any
create policy "Auth users read posts" on posts for select using (auth.role() = 'authenticated');
create policy "Auth users create posts" on posts for insert with check (auth.uid() = user_id);
create policy "Users delete own posts" on posts for delete using (auth.uid() = user_id);
create policy "Admin deletes any post" on posts for delete using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);

-- Post Comments: all authenticated read, users create own, delete own
create policy "Auth users read comments" on post_comments for select using (auth.role() = 'authenticated');
create policy "Auth users create comments" on post_comments for insert with check (auth.uid() = user_id);
create policy "Users delete own comments" on post_comments for delete using (auth.uid() = user_id);
create policy "Admin deletes any comment" on post_comments for delete using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);

-- Post Reactions: all authenticated read, users manage own
create policy "Auth users read reactions" on post_reactions for select using (auth.role() = 'authenticated');
create policy "Users manage own reactions" on post_reactions for insert with check (auth.uid() = user_id);
create policy "Users remove own reactions" on post_reactions for delete using (auth.uid() = user_id);

-- Live Sessions: all authenticated read, admin manages
create policy "Auth users read live sessions" on live_sessions for select using (auth.role() = 'authenticated');
create policy "Admin manages live sessions" on live_sessions for all using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);

-- Live Session RSVPs: all authenticated read, users manage own
create policy "Auth users read rsvps" on live_session_rsvps for select using (auth.role() = 'authenticated');
create policy "Users manage own rsvps" on live_session_rsvps for insert with check (auth.uid() = user_id);
create policy "Users remove own rsvps" on live_session_rsvps for delete using (auth.uid() = user_id);
