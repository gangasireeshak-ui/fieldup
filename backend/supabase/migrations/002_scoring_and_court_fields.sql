-- Migration 002: Add scoring fields to matches, pricing fields to courts

alter table matches
  add column if not exists sport       text,
  add column if not exists team1       text,
  add column if not exists team2       text,
  add column if not exists recorded_by uuid references users(id) on delete set null,
  add column if not exists umpire1     text,
  add column if not exists umpire2     text,
  add column if not exists sport_data  jsonb;

create index if not exists idx_matches_recorded_by on matches(recorded_by);

alter table courts
  add column if not exists price_per_hour integer not null default 0,
  add column if not exists surface        text,
  add column if not exists has_lights     boolean not null default false;
