-- FieldUp Phase 1 MVP — Initial Schema
-- Run via: supabase db push OR psql -f 001_initial_schema.sql
-- All monetary values stored in paise (₹1 = 100 paise)

-- ── Extensions ──────────────────────────────────────────────────────────────────
create extension if not exists "uuid-ossp";
-- Note: PostGIS removed — it puts spatial_ref_sys in public schema which triggers
-- a Supabase RLS advisor warning. Geo queries use lat/lng float columns + in-app distance calc.

-- ── ENUMS ───────────────────────────────────────────────────────────────────────
create type sport_type as enum (
  'cricket', 'football', 'badminton', 'tennis',
  'basketball', 'pickleball', 'volleyball', 'table_tennis'
);

create type skill_level as enum ('beginner', 'medium', 'advanced', 'elite');

create type booking_status as enum (
  'pending', 'confirmed', 'cancelled', 'completed', 'refunded'
);

create type game_visibility as enum ('public', 'private', 'invite_only');

create type player_role as enum ('host', 'co_host', 'player');

create type session_status as enum (
  'pending', 'confirmed', 'cancelled', 'completed'
);

create type reward_action as enum (
  'booking', 'match_completion', 'referral',
  'tournament_participation', 'profile_complete', 'redemption'
);

create type tournament_format as enum (
  'knockout', 'round_robin', 'double_elimination', 'league'
);

create type match_status as enum (
  'scheduled', 'live', 'completed', 'cancelled', 'abandoned'
);

-- ── USERS ───────────────────────────────────────────────────────────────────────
create table users (
  id            uuid primary key default uuid_generate_v4(),
  phone         text unique not null,
  name          text,
  email         text,
  avatar_url    text,
  karma_points  integer not null default 0,
  referral_code text unique,
  referral_code_used text,
  sport_preferences sport_type[],
  city          text,
  is_verified   boolean not null default false,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- ── VENUES ──────────────────────────────────────────────────────────────────────
create table venues (
  id            uuid primary key default uuid_generate_v4(),
  owner_id      uuid references users(id) on delete set null,
  name          text not null,
  description   text,
  address       text not null,
  city          text not null,
  state         text,
  lat           double precision,
  lng           double precision,
  sports        sport_type[] not null default '{}',
  amenities     text[] not null default '{}',
  photos        text[] not null default '{}',
  rating        numeric(3,2),
  review_count  integer not null default 0,
  is_verified   boolean not null default false,
  is_active     boolean not null default true,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- ── COURTS ──────────────────────────────────────────────────────────────────────
create table courts (
  id            uuid primary key default uuid_generate_v4(),
  venue_id      uuid not null references venues(id) on delete cascade,
  name          text not null,
  sport         sport_type not null,
  capacity      integer,
  description   text,
  is_active     boolean not null default true,
  created_at    timestamptz not null default now()
);

-- ── SLOTS ───────────────────────────────────────────────────────────────────────
create table slots (
  id              uuid primary key default uuid_generate_v4(),
  court_id        uuid not null references courts(id) on delete cascade,
  date            date not null,
  start_time      time not null,
  end_time        time not null,
  price_paise     integer not null default 0,
  is_blocked      boolean not null default false,
  blocked_reason  text,
  created_at      timestamptz not null default now(),
  unique (court_id, date, start_time)
);

-- ── BOOKINGS ────────────────────────────────────────────────────────────────────
create table bookings (
  id                  uuid primary key default uuid_generate_v4(),
  user_id             uuid not null references users(id) on delete restrict,
  slot_id             uuid not null references slots(id) on delete restrict,
  status              booking_status not null default 'pending',
  original_amount     integer not null,  -- paise
  discount_amount     integer not null default 0,  -- paise
  final_amount        integer not null,  -- paise
  razorpay_order_id   text,
  razorpay_payment_id text,
  notes               text,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

-- ── GAMES ───────────────────────────────────────────────────────────────────────
create table games (
  id              uuid primary key default uuid_generate_v4(),
  organizer_id    uuid not null references users(id) on delete restrict,
  venue_id        uuid references venues(id) on delete set null,
  sport           sport_type not null,
  format          text not null,  -- e.g. "5v5", "2v2", "singles"
  title           text,
  date_time       timestamptz not null,
  duration_mins   integer not null default 60,
  max_players     integer not null,
  skill_level     skill_level not null default 'medium',
  price_paise     integer not null default 0,
  visibility      game_visibility not null default 'public',
  instructions    text,
  is_cancelled    boolean not null default false,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- ── GAME PLAYERS ────────────────────────────────────────────────────────────────
create table game_players (
  id          uuid primary key default uuid_generate_v4(),
  game_id     uuid not null references games(id) on delete cascade,
  user_id     uuid not null references users(id) on delete cascade,
  role        player_role not null default 'player',
  joined_at   timestamptz not null default now(),
  unique (game_id, user_id)
);

-- ── COACHES ─────────────────────────────────────────────────────────────────────
create table coaches (
  id                  uuid primary key default uuid_generate_v4(),
  user_id             uuid not null unique references users(id) on delete cascade,
  sports              sport_type[] not null default '{}',
  bio                 text,
  experience_years    integer not null default 0,
  certifications      text[] not null default '{}',
  hourly_rate_paise   integer not null default 0,
  session_formats     text[] not null default '{}',
  is_verified         boolean not null default false,
  rating              numeric(3,2),
  session_count       integer not null default 0,
  city                text,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

-- ── COACH SESSIONS ───────────────────────────────────────────────────────────────
create table coach_sessions (
  id              uuid primary key default uuid_generate_v4(),
  coach_id        uuid not null references coaches(id) on delete restrict,
  player_id       uuid not null references users(id) on delete restrict,
  date_time       timestamptz not null,
  duration_mins   integer not null default 60,
  status          session_status not null default 'pending',
  amount_paise    integer not null,
  notes           text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- ── TOURNAMENTS ─────────────────────────────────────────────────────────────────
create table tournaments (
  id                    uuid primary key default uuid_generate_v4(),
  organizer_id          uuid not null references users(id) on delete restrict,
  name                  text not null,
  sport                 sport_type not null,
  format                tournament_format not null default 'knockout',
  description           text,
  venue_id              uuid references venues(id) on delete set null,
  start_date            date not null,
  end_date              date,
  registration_deadline timestamptz,
  max_teams             integer,
  entry_fee_paise       integer not null default 0,
  prize_pool_paise      integer not null default 0,
  banner_url            text,
  is_corporate          boolean not null default false,
  is_published          boolean not null default false,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

-- ── TEAMS ───────────────────────────────────────────────────────────────────────
create table teams (
  id              uuid primary key default uuid_generate_v4(),
  tournament_id   uuid not null references tournaments(id) on delete cascade,
  name            text not null,
  captain_id      uuid references users(id) on delete set null,
  logo_url        text,
  created_at      timestamptz not null default now()
);

-- ── TEAM MEMBERS ────────────────────────────────────────────────────────────────
create table team_members (
  id            uuid primary key default uuid_generate_v4(),
  team_id       uuid not null references teams(id) on delete cascade,
  user_id       uuid not null references users(id) on delete cascade,
  joined_at     timestamptz not null default now(),
  unique (team_id, user_id)
);

-- ── MATCHES ─────────────────────────────────────────────────────────────────────
create table matches (
  id              uuid primary key default uuid_generate_v4(),
  tournament_id   uuid references tournaments(id) on delete cascade,
  game_id         uuid references games(id) on delete cascade,
  team1_id        uuid references teams(id) on delete set null,
  team2_id        uuid references teams(id) on delete set null,
  scheduled_at    timestamptz,
  status          match_status not null default 'scheduled',
  round           integer,
  venue_id        uuid references venues(id) on delete set null,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  check (team1_id != team2_id)
);

-- ── SCORES ──────────────────────────────────────────────────────────────────────
create table scores (
  id              uuid primary key default uuid_generate_v4(),
  match_id        uuid not null references matches(id) on delete cascade,
  team1_score     integer not null default 0,
  team2_score     integer not null default 0,
  winner_id       uuid references teams(id) on delete set null,
  recorded_by     uuid references users(id) on delete set null,
  sport_data      jsonb,  -- sport-specific detail (sets, wickets, etc.)
  recorded_at     timestamptz not null default now()
);

-- ── REVIEWS ─────────────────────────────────────────────────────────────────────
create table reviews (
  id            uuid primary key default uuid_generate_v4(),
  reviewer_id   uuid not null references users(id) on delete cascade,
  venue_id      uuid references venues(id) on delete cascade,
  coach_id      uuid references coaches(id) on delete cascade,
  rating        integer not null check (rating between 1 and 5),
  comment       text,
  created_at    timestamptz not null default now(),
  check (
    (venue_id is not null and coach_id is null) or
    (coach_id is not null and venue_id is null)
  )
);

-- ── REFERRALS ────────────────────────────────────────────────────────────────────
create table referrals (
  id              uuid primary key default uuid_generate_v4(),
  referrer_id     uuid not null references users(id) on delete restrict,
  referred_id     uuid not null unique references users(id) on delete restrict,
  reward_points   integer not null default 100,
  is_rewarded     boolean not null default false,
  created_at      timestamptz not null default now(),
  check (referrer_id != referred_id)
);

-- ── REWARDS LOG ──────────────────────────────────────────────────────────────────
create table rewards_log (
  id            uuid primary key default uuid_generate_v4(),
  user_id       uuid not null references users(id) on delete cascade,
  points        integer not null,  -- positive = earn, negative = redeem
  action        reward_action not null,
  reference_id  uuid,  -- booking_id, match_id, etc.
  description   text,
  created_at    timestamptz not null default now()
);

-- ── NOTIFICATIONS ────────────────────────────────────────────────────────────────
create table notifications (
  id            uuid primary key default uuid_generate_v4(),
  user_id       uuid not null references users(id) on delete cascade,
  title         text not null,
  body          text not null,
  data          jsonb,
  is_read       boolean not null default false,
  created_at    timestamptz not null default now()
);

-- ── INDEXES ──────────────────────────────────────────────────────────────────────
create index idx_venues_city on venues(city);
create index idx_venues_sports on venues using gin(sports);
create index idx_slots_court_date on slots(court_id, date);
create index idx_bookings_user on bookings(user_id);
create index idx_bookings_slot on bookings(slot_id);
create index idx_games_datetime on games(date_time);
create index idx_games_sport on games(sport);
create index idx_games_visibility on games(visibility);
create index idx_coaches_sports on coaches using gin(sports);
create index idx_coaches_city on coaches(city);
create index idx_rewards_user on rewards_log(user_id, created_at desc);
create index idx_notifications_user on notifications(user_id, is_read, created_at desc);

-- ── RLS POLICIES ────────────────────────────────────────────────────────────────
alter table users enable row level security;
alter table venues enable row level security;
alter table courts enable row level security;
alter table slots enable row level security;
alter table bookings enable row level security;
alter table games enable row level security;
alter table game_players enable row level security;
alter table coaches enable row level security;
alter table coach_sessions enable row level security;
alter table tournaments enable row level security;
alter table teams enable row level security;
alter table team_members enable row level security;
alter table matches enable row level security;
alter table scores enable row level security;
alter table reviews enable row level security;
alter table referrals enable row level security;
alter table rewards_log enable row level security;
alter table notifications enable row level security;

-- Users: read own row, update own row
create policy "users_select_own" on users for select using (auth.uid() = id);
create policy "users_update_own" on users for update using (auth.uid() = id);
create policy "users_insert_own" on users for insert with check (auth.uid() = id);

-- Venues: public read, owner write
create policy "venues_public_read" on venues for select using (is_active = true);
create policy "venues_owner_insert" on venues for insert with check (auth.uid() = owner_id);
create policy "venues_owner_update" on venues for update using (auth.uid() = owner_id);

-- Courts: public read
create policy "courts_public_read" on courts for select using (true);
create policy "courts_owner_write" on courts for all
  using (exists (select 1 from venues where venues.id = courts.venue_id and venues.owner_id = auth.uid()));

-- Slots: public read
create policy "slots_public_read" on slots for select using (true);
create policy "slots_owner_write" on slots for all
  using (exists (
    select 1 from courts
    join venues on venues.id = courts.venue_id
    where courts.id = slots.court_id and venues.owner_id = auth.uid()
  ));

-- Bookings: user sees own bookings
create policy "bookings_user_select" on bookings for select using (auth.uid() = user_id);
create policy "bookings_user_insert" on bookings for insert with check (auth.uid() = user_id);
create policy "bookings_user_update" on bookings for update using (auth.uid() = user_id);

-- Games: public games readable by all; private only by organiser or player
create policy "games_public_read" on games for select
  using (visibility = 'public' or auth.uid() = organizer_id or
    exists (select 1 from game_players where game_players.game_id = games.id and game_players.user_id = auth.uid()));
create policy "games_auth_insert" on games for insert with check (auth.uid() = organizer_id);
create policy "games_organizer_update" on games for update using (auth.uid() = organizer_id);

-- Game players
create policy "game_players_read" on game_players for select using (true);
create policy "game_players_join" on game_players for insert with check (auth.uid() = user_id);
create policy "game_players_leave" on game_players for delete using (auth.uid() = user_id);

-- Coaches: public read
create policy "coaches_public_read" on coaches for select using (true);
create policy "coaches_own_write" on coaches for all using (auth.uid() = user_id);

-- Coach sessions
create policy "sessions_player_read" on coach_sessions for select
  using (auth.uid() = player_id or
    exists (select 1 from coaches where coaches.id = coach_sessions.coach_id and coaches.user_id = auth.uid()));
create policy "sessions_player_insert" on coach_sessions for insert with check (auth.uid() = player_id);

-- Tournaments: published are public
create policy "tournaments_public_read" on tournaments for select using (is_published = true);
create policy "tournaments_organizer_write" on tournaments for all using (auth.uid() = organizer_id);

-- Reviews: public read, reviewer write
create policy "reviews_public_read" on reviews for select using (true);
create policy "reviews_auth_insert" on reviews for insert with check (auth.uid() = reviewer_id);

-- Rewards: user sees own
create policy "rewards_user_read" on rewards_log for select using (auth.uid() = user_id);

-- Notifications: user sees own
create policy "notifications_user_read" on notifications for select using (auth.uid() = user_id);
create policy "notifications_user_update" on notifications for update using (auth.uid() = user_id);

-- ── FUNCTIONS ────────────────────────────────────────────────────────────────────

-- Auto-create user row on signup
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.users (id, phone, email, referral_code)
  values (
    new.id,
    new.phone,
    new.email,
    upper(substring(replace(new.id::text, '-', ''), 1, 8))
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Add karma points
create or replace function add_karma(
  p_user_id uuid,
  p_points   integer,
  p_action   reward_action,
  p_ref_id   uuid default null,
  p_desc     text default null
) returns void language plpgsql security definer as $$
begin
  insert into rewards_log (user_id, points, action, reference_id, description)
  values (p_user_id, p_points, p_action, p_ref_id, p_desc);

  update users set karma_points = karma_points + p_points
  where id = p_user_id;
end;
$$;

-- Update venue rating after review
create or replace function update_venue_rating()
returns trigger language plpgsql as $$
begin
  update venues
  set
    rating = (select avg(rating) from reviews where venue_id = new.venue_id),
    review_count = (select count(*) from reviews where venue_id = new.venue_id)
  where id = new.venue_id;
  return new;
end;
$$;

create trigger after_venue_review
  after insert on reviews
  for each row when (new.venue_id is not null)
  execute procedure update_venue_rating();

-- updated_at trigger
create or replace function set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger trg_users_updated_at before update on users
  for each row execute procedure set_updated_at();
create trigger trg_venues_updated_at before update on venues
  for each row execute procedure set_updated_at();
create trigger trg_bookings_updated_at before update on bookings
  for each row execute procedure set_updated_at();
create trigger trg_games_updated_at before update on games
  for each row execute procedure set_updated_at();
create trigger trg_coaches_updated_at before update on coaches
  for each row execute procedure set_updated_at();
create trigger trg_sessions_updated_at before update on coach_sessions
  for each row execute procedure set_updated_at();
create trigger trg_tournaments_updated_at before update on tournaments
  for each row execute procedure set_updated_at();
create trigger trg_matches_updated_at before update on matches
  for each row execute procedure set_updated_at();
