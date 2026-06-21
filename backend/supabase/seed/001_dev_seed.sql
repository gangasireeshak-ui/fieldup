-- FieldUp Seed Data — dev/test environment
-- Run in Supabase SQL Editor after the migration

-- ── Test venues ──────────────────────────────────────────────────────────────
insert into venues (id, name, description, address, city, state, sports, amenities, is_verified, is_active)
values
  ('00000000-0000-0000-0000-000000000001',
   'Feather Touch Arena',
   'Premium indoor badminton facility with 4 courts',
   '12 Sports Complex, JP Nagar Phase 5', 'Bangalore', 'Karnataka',
   array['badminton','cricket']::sport_type[],
   array['Parking','Changing Rooms','Lights','Cafeteria'],
   true, true),
  ('00000000-0000-0000-0000-000000000002',
   'KickOff Arena',
   'Professional football turf with floodlights',
   '45 Ring Road, BTM Layout', 'Bangalore', 'Karnataka',
   array['football']::sport_type[],
   array['Parking','Lights','First Aid'],
   true, true),
  ('00000000-0000-0000-0000-000000000003',
   'The Green Pitch',
   'Multi-sport facility with cricket nets',
   '7 Outer Ring Road, Koramangala', 'Bangalore', 'Karnataka',
   array['cricket','football','basketball']::sport_type[],
   array['Parking','Changing Rooms','Equipment Rental'],
   false, true)
on conflict (id) do nothing;

-- ── Courts for Feather Touch Arena ───────────────────────────────────────────
insert into courts (id, venue_id, name, sport, capacity, is_active)
values
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Court A',       'badminton'::sport_type,   4,  true),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'Court B',       'badminton'::sport_type,   4,  true),
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'Football Turf', 'football'::sport_type,   14,  true),
  ('10000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', 'Basketball',    'basketball'::sport_type, 10,  true)
on conflict (id) do nothing;

-- ── Today's slots for Court A (hourly 6AM–10PM) ───────────────────────────────
insert into slots (court_id, date, start_time, end_time, price_paise)
select
  '10000000-0000-0000-0000-000000000001',
  current_date,
  (lpad(h::text, 2, '0') || ':00')::time,
  (lpad((h + 1)::text, 2, '0') || ':00')::time,
  60000
from generate_series(6, 21) as h
on conflict (court_id, date, start_time) do nothing;

-- ── Today's slots for Court B ─────────────────────────────────────────────────
insert into slots (court_id, date, start_time, end_time, price_paise)
select
  '10000000-0000-0000-0000-000000000002',
  current_date,
  (lpad(h::text, 2, '0') || ':00')::time,
  (lpad((h + 1)::text, 2, '0') || ':00')::time,
  60000
from generate_series(6, 21) as h
on conflict (court_id, date, start_time) do nothing;

-- ── Today's slots for Football Turf ──────────────────────────────────────────
insert into slots (court_id, date, start_time, end_time, price_paise)
select
  '10000000-0000-0000-0000-000000000003',
  current_date,
  (lpad(h::text, 2, '0') || ':00')::time,
  (lpad((h + 1)::text, 2, '0') || ':00')::time,
  120000
from generate_series(6, 21) as h
on conflict (court_id, date, start_time) do nothing;

-- ── Block slot 9AM–10AM on Court A to simulate a real booking ────────────────
update slots set is_blocked = true, blocked_reason = 'Club Practice'
where court_id = '10000000-0000-0000-0000-000000000001'
  and date = current_date
  and start_time = '09:00';
