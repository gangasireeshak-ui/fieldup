-- FieldUp Seed Data — dev/test environment
-- Run in Supabase SQL Editor after the migration

-- ── Test venues ──────────────────────────────────────────────────────────────
insert into venues (id, name, description, address, city, state, sports, amenities, is_verified, is_active)
values
  ('00000000-0000-0000-0000-000000000001', 'Feather Touch Arena', 'Premium indoor badminton facility with 4 courts', '12 Sports Complex, JP Nagar Phase 5', 'Bangalore', 'Karnataka', array['badminton','cricket'], array['Parking','Changing Rooms','Lights','Cafeteria'], true, true),
  ('00000000-0000-0000-0000-000000000002', 'KickOff Arena', 'Professional football turf with floodlights', '45 Ring Road, BTM Layout', 'Bangalore', 'Karnataka', array['football'], array['Parking','Lights','First Aid'], true, true),
  ('00000000-0000-0000-0000-000000000003', 'The Green Pitch', 'Multi-sport facility with cricket nets', '7 Outer Ring Road, Koramangala', 'Bangalore', 'Karnataka', array['cricket','football','basketball'], array['Parking','Changing Rooms','Equipment Rental'], false, true)
on conflict (id) do nothing;

-- ── Courts for Feather Touch Arena ───────────────────────────────────────────
insert into courts (id, venue_id, name, sport, capacity, price_per_hour, surface, has_lights, is_active)
values
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Court A', 'badminton', 4, 60000, 'Synthetic', true, true),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'Court B', 'badminton', 4, 60000, 'Synthetic', true, true),
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'Football Turf', 'football', 14, 120000, 'Grass', true, true),
  ('10000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', 'Basketball', 'basketball', 10, 80000, 'Hardcourt', false, true)
on conflict (id) do nothing;

-- ── Today's slots for Court A ─────────────────────────────────────────────────
insert into slots (court_id, date, start_time, end_time, price_paise)
select
  '10000000-0000-0000-0000-000000000001',
  current_date,
  (h || ':00')::time,
  ((h + 1) || ':00')::time,
  60000
from generate_series(6, 21) as h
on conflict (court_id, date, start_time) do nothing;

-- ── Today's slots for Football Turf ──────────────────────────────────────────
insert into slots (court_id, date, start_time, end_time, price_paise)
select
  '10000000-0000-0000-0000-000000000003',
  current_date,
  (h || ':00')::time,
  ((h + 1) || ':00')::time,
  120000
from generate_series(6, 21) as h
on conflict (court_id, date, start_time) do nothing;

-- ── Sample verified coach ─────────────────────────────────────────────────────
-- (requires a real auth user — run after creating a test account)
-- insert into coaches (user_id, sports, bio, experience_years, hourly_rate_paise, is_verified, city)
-- values ('<YOUR_USER_ID>', array['badminton'], 'BWF Level 2 certified coach with 8 years experience', 8, 150000, true, 'Bangalore');
