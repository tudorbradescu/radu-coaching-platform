-- ============================================
-- RADU COACHING PLATFORM — Supabase Schema
-- ============================================

-- 1. Profiles (extends Supabase auth.users)
create table profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  full_name text,
  email text,
  role text not null default 'client' check (role in ('admin', 'client')),
  created_at timestamptz default now()
);

-- Auto-create profile on signup
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into profiles (id, email, full_name, role)
  values (new.id, new.email, new.raw_user_meta_data->>'full_name', 'client');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure handle_new_user();

-- 2. Modules
create table modules (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  order_index int not null default 1,
  created_at timestamptz default now()
);

-- 3. Videos
create table videos (
  id uuid primary key default gen_random_uuid(),
  module_id uuid references modules(id) on delete cascade,
  title text not null,
  vimeo_id text not null,
  description text,
  order_index int not null default 1,
  created_at timestamptz default now()
);

-- 4. Client-Module assignments (what each client can see)
create table client_modules (
  id uuid primary key default gen_random_uuid(),
  client_id uuid references auth.users(id) on delete cascade,
  module_id uuid references modules(id) on delete cascade,
  unlocked_at timestamptz default now(),
  unique(client_id, module_id)
);

-- 5. Weekly check-ins
create table checkins (
  id uuid primary key default gen_random_uuid(),
  client_id uuid references auth.users(id) on delete cascade,
  weight numeric(5,2),
  energy_level int check (energy_level between 1 and 5),
  sleep_quality int check (sleep_quality between 1 and 5),
  nutrition_adherence int check (nutrition_adherence between 1 and 5),
  training_adherence int check (training_adherence between 1 and 5),
  wins text,
  challenges text,
  notes text,
  created_at timestamptz default now()
);

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================

alter table profiles enable row level security;
alter table modules enable row level security;
alter table videos enable row level security;
alter table client_modules enable row level security;
alter table checkins enable row level security;

-- Profiles: user sees own, admin sees all
create policy "Users see own profile" on profiles for select using (auth.uid() = id);
create policy "Admin sees all profiles" on profiles for select using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);
create policy "Users update own profile" on profiles for update using (auth.uid() = id);

-- Modules: all authenticated users can read, only admin can write
create policy "Auth users read modules" on modules for select using (auth.role() = 'authenticated');
create policy "Admin manages modules" on modules for all using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);

-- Videos: same as modules
create policy "Auth users read videos" on videos for select using (auth.role() = 'authenticated');
create policy "Admin manages videos" on videos for all using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);

-- Client modules: client sees own, admin sees all + manages
create policy "Client sees own modules" on client_modules for select using (auth.uid() = client_id);
create policy "Admin manages client_modules" on client_modules for all using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);

-- Check-ins: client manages own, admin sees all
create policy "Client manages own checkins" on checkins for all using (auth.uid() = client_id);
create policy "Admin reads all checkins" on checkins for select using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);
