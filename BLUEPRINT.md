# FieldUp — Master Blueprint

> **Last updated:** June 2026  
> **Supabase project:** `nweibhcjqnumxcpwnrvo`  
> **GitHub repo:** [gangasireeshak-ui/fieldup](https://github.com/gangasireeshak-ui/fieldup)  
> **Platform:** Flutter (iOS · Android · Web) — Supabase backend

---

## Table of Contents

1. [What is FieldUp?](#1-what-is-fieldup)
2. [Architecture Overview](#2-architecture-overview)
3. [Repository Structure](#3-repository-structure)
4. [Tech Stack](#4-tech-stack)
5. [Supabase — Database & Backend](#5-supabase--database--backend)
6. [How to Run Locally](#6-how-to-run-locally)
7. [How to Test Locally](#7-how-to-test-locally)
8. [App-by-App Guide](#8-app-by-app-guide)
9. [What is Connected (Live)](#9-what-is-connected-live)
10. [What is Pending (Hardcoded / Not Yet Built)](#10-what-is-pending-hardcoded--not-yet-built)
11. [Step-by-Step Guide to Complete Pending Work](#11-step-by-step-guide-to-complete-pending-work)
12. [Design System](#12-design-system)
13. [Domain Models](#13-domain-models)
14. [Repository Layer](#14-repository-layer)
15. [Edge Functions](#15-edge-functions)
16. [Payments — Razorpay](#16-payments--razorpay)
17. [Push Notifications — Firebase](#17-push-notifications--firebase)
18. [CI/CD](#18-cicd)
19. [Environment Variables & Secrets](#19-environment-variables--secrets)
20. [Releasing to App Store / Play Store](#20-releasing-to-app-store--play-store)
21. [Key Decisions & Conventions](#21-key-decisions--conventions)

---

## 1. What is FieldUp?

FieldUp is a **Sports OS** — a platform for India (metro-first, Tier-2 expansion) where:

- **Players** discover and book sports venues, hire coaches, join open games, and score live matches.
- **Vendors** (venue owners) manage their arenas, set pricing, track bookings, and analyse revenue.
- **Admins** (FieldUp team) approve venues/coaches, control tournaments, push notifications, and monitor platform health.

**Three separate Flutter apps** share a single monorepo and a single Supabase project.

---

## 2. Architecture Overview

```
┌───────────────────────────────────────────────────────────────────┐
│                        Flutter Apps                               │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────────────┐  │
│  │  user_app    │   │  vendor_app  │   │     admin_app        │  │
│  │  (mobile)    │   │  (mobile)    │   │  (web / tablet)      │  │
│  └──────┬───────┘   └──────┬───────┘   └──────────┬───────────┘  │
│         │                  │                       │              │
│         └──────────────────┴───────────────────────┘             │
│                            │                                      │
│         ┌──────────────────▼──────────────────────┐              │
│         │          Shared Packages                 │              │
│         │  fieldup_core  ·  fieldup_design_system  │              │
│         │  fieldup_supabase_client                 │              │
│         └──────────────────┬──────────────────────┘              │
└────────────────────────────┼──────────────────────────────────────┘
                             │  Supabase Flutter SDK
                 ┌───────────▼───────────┐
                 │   Supabase Cloud      │
                 │  nweibhcjqnumxcpwnrvo │
                 │                       │
                 │  PostgreSQL (18 tbls) │
                 │  Auth (Phone OTP)     │
                 │  Storage (buckets)    │
                 │  Edge Functions       │
                 │    ├ create-payment   │
                 │    └ razorpay-webhook │
                 │  Realtime             │
                 └───────────────────────┘
                             │
                 ┌───────────▼───────────┐
                 │       Razorpay        │
                 │  (payments — India)   │
                 └───────────────────────┘
```

**State management:** Riverpod (`@riverpod` code-gen + `FutureProvider` / `StreamProvider`)  
**Navigation:** `go_router` with redirect guards based on Supabase session  
**Money:** all amounts stored in **paise** (₹1 = 100 paise), formatted via `formatRupees()`

---

## 3. Repository Structure

```
fieldup_user/
├── apps/
│   ├── user_app/           ← Player-facing mobile app
│   │   ├── lib/
│   │   │   ├── main.dart
│   │   │   ├── app.dart
│   │   │   ├── app_router.dart
│   │   │   └── features/
│   │   │       ├── auth/presentation/
│   │   │       ├── home/presentation/
│   │   │       ├── venues/presentation/
│   │   │       ├── coaches/presentation/
│   │   │       ├── games/presentation/
│   │   │       ├── scoring/presentation/
│   │   │       └── profile/presentation/
│   │   └── android/ · ios/ · web/ · …
│   │
│   ├── vendor_app/         ← Venue owner app
│   │   └── lib/
│   │       ├── main.dart · app.dart · app_router.dart
│   │       ├── providers.dart          ← all Riverpod providers
│   │       └── screens/                ← 9 screens
│   │
│   └── admin_app/          ← FieldUp ops team (web)
│       └── lib/
│           ├── main.dart · app.dart · app_router.dart
│           ├── providers.dart
│           └── screens/                ← 8 screens
│
├── packages/
│   ├── core/               ← Pure Dart: models + money utils
│   │   └── lib/
│   │       ├── fieldup_core.dart       ← barrel export
│   │       ├── models/                 ← FieldUpUser, Venue, Court, Slot, Booking, Coach, MatchRecord
│   │       └── utils/money.dart
│   │
│   ├── design_system/      ← Flutter: AppTheme, AppColors, AppTextStyles
│   │   └── lib/
│   │       ├── fieldup_design_system.dart
│   │       ├── tokens/app_colors.dart
│   │       ├── tokens/app_text_styles.dart
│   │       └── theme/app_theme.dart
│   │
│   └── supabase_client/    ← Flutter: repos + Supabase config
│       └── lib/
│           ├── fieldup_supabase_client.dart
│           ├── supabase_config.dart
│           └── repositories/
│               ├── auth_repository.dart
│               ├── user_repository.dart
│               ├── venue_repository.dart
│               ├── booking_repository.dart
│               ├── coach_repository.dart
│               └── match_repository.dart
│
├── backend/
│   └── supabase/
│       ├── migrations/
│       │   ├── 001_initial_schema.sql  ← 18 tables, enums, RLS, triggers
│       │   └── 002_scoring_and_court_fields.sql
│       ├── functions/
│       │   ├── create-payment-order/index.ts
│       │   └── razorpay-webhook/index.ts
│       └── seed/
│           └── 001_dev_seed.sql        ← 3 venues, 4 courts, 48 slots
│
└── .github/
    └── copilot-instructions/           ← 6 AI agent instruction files
```

---

## 4. Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Mobile framework | Flutter | latest-stable |
| Language | Dart | ≥ 3.3.0 |
| State management | Riverpod (code-gen) | ^2.5.1 |
| Navigation | go_router | ^14.2.7 |
| Backend | Supabase | ^2.5.3 (Flutter SDK) |
| Payments | Razorpay Flutter | ^1.3.5 |
| Push notifications | Firebase Messaging | ^15.1.0 |
| Image loading | cached_network_image | ^3.3.1 |
| Local storage | Hive + shared_preferences | - |
| Secure storage | flutter_secure_storage | ^9.2.2 |
| HTTP | Dio | ^5.7.0 |
| Fonts | Barlow Condensed + Inter | via google_fonts |
| Edge Functions | Deno (TypeScript) | Supabase-hosted |

---

## 5. Supabase — Database & Backend

### Project Details

| | |
|---|---|
| **Project URL** | `https://nweibhcjqnumxcpwnrvo.supabase.co` |
| **Region** | (check dashboard — should be ap-south-1 Mumbai) |
| **Dashboard** | [supabase.com/dashboard/project/nweibhcjqnumxcpwnrvo](https://supabase.com/dashboard/project/nweibhcjqnumxcpwnrvo) |

### Database Tables (18)

| Table | Purpose |
|-------|---------|
| `users` | Player profiles, karma points, sport preferences |
| `venues` | Sports facilities with location, sports, amenities |
| `courts` | Individual courts within a venue |
| `slots` | Hourly time slots per court per date |
| `bookings` | Slot bookings with Razorpay IDs |
| `games` | Open community games (join-to-play) |
| `game_players` | Who has joined each game |
| `coaches` | Coach profiles, rates, certifications |
| `coach_sessions` | Booking records for coaching sessions |
| `tournaments` | Organised tournaments with teams |
| `teams` | Teams within tournaments |
| `team_members` | Players in each team |
| `matches` | Individual match records (tournament + freeform scoring) |
| `scores` | Match score outcomes |
| `reviews` | Venue + coach ratings |
| `referrals` | Referral tracking |
| `rewards_log` | Karma point history |
| `notifications` | In-app notification inbox |

### Key Enums
- `sport_type`: cricket, football, badminton, tennis, basketball, pickleball, volleyball, table_tennis
- `booking_status`: pending, confirmed, cancelled, completed, refunded
- `skill_level`: beginner, medium, advanced, elite
- `match_status`: scheduled, live, completed, cancelled, abandoned

### Auth Setup
- **Phone OTP** (primary — Indian +91 numbers)
- **Email + password** (admin login)
- `sms_autoconfirm = true` in dev (no real SMS needed)
- Test numbers: `+919999999999`, `+919999999998`, `+919999999997` → OTP **123456**
- Auto-creates a row in `users` table on first sign-in (via `handle_new_user()` trigger)

### Edge Functions (deployed)
- `create-payment-order` — creates Razorpay order server-side
- `razorpay-webhook` — confirms/cancels bookings after payment events

---

## 6. How to Run Locally

### Prerequisites

```bash
# Flutter (latest stable)
flutter --version     # should be ≥ 3.22

# Dart
dart --version        # should be ≥ 3.3.0

# Supabase CLI
supabase --version    # ≥ 2.75.0

# Node.js (for Playwright testing)
node --version        # ≥ 18
```

### Step 1 — Clone and Get Dependencies

```bash
git clone https://github.com/gangasireeshak-ui/fieldup.git
cd fieldup

# Install deps for all 3 apps and 2 packages
cd packages/core && dart pub get && cd ../..
cd packages/supabase_client && flutter pub get && cd ../..
cd apps/user_app && flutter pub get && cd ../..
cd apps/vendor_app && flutter pub get && cd ../..
cd apps/admin_app && flutter pub get && cd ../..
```

### Step 2 — Regenerate Code-gen Files

The `.g.dart` files are gitignored. Run this inside each app that uses `@riverpod`:

```bash
# user_app
cd apps/user_app
dart run build_runner build --delete-conflicting-outputs
cd ../..
```

### Step 3 — Run the User App (mobile)

**On Android emulator:**
```bash
# Launch emulator first
flutter emulators --launch Medium_Phone_API_36.0

# Wait for it to boot, then:
cd apps/user_app
flutter run -d emulator-5554
```

**On Chrome (web — fastest for dev):**
```bash
cd apps/user_app
flutter run -d chrome
```

**On iOS simulator (requires Xcode):**
```bash
cd apps/user_app
open -a Simulator
flutter run -d <simulator-id>
```

### Step 4 — Run the Vendor App

```bash
cd apps/vendor_app
flutter run -d chrome          # or -d emulator-5554
```

### Step 5 — Run the Admin App

```bash
cd apps/admin_app
flutter run -d chrome          # Admin is designed for web
```

### Android NDK Issue (first-time Android build)

The NDK version is already pinned in `apps/user_app/android/app/build.gradle.kts`:
```
ndkVersion = "27.0.12077973"
```
If you see NDK warnings, run `flutter clean` first then rebuild.

### Supabase Credentials

Credentials are **already baked in** as `--dart-define` defaults in all three `main.dart` files. You do not need to pass any flags to run against the live dev project. The defaults are:

```
SUPABASE_URL    = https://nweibhcjqnumxcpwnrvo.supabase.co
SUPABASE_ANON_KEY = eyJhbGci...O4LNQOY2Ub69K...
```

To override (e.g. for a different environment):
```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co \
            --dart-define=SUPABASE_ANON_KEY=eyJ...
```

---

## 7. How to Test Locally

### Test Login (User App)

1. Run the user app on Chrome or emulator
2. Skip onboarding (click Next × 3)
3. Enter phone: **9999999999** (the +91 is added automatically)
4. OTP screen appears — enter **123456**
5. Complete Create Account → Interests → lands on Home

### Test Login (Vendor App)

Same phone OTP flow with the same test numbers. The vendor app has its own login screen but connects to the same Supabase Auth.

### Test Login (Admin App)

Admin uses email + password. Create an admin user via Supabase Dashboard:
1. Go to Authentication → Users → Add user
2. Email: `admin@fieldup.com`, Password: your choice
3. Use those credentials in the admin login screen

### Test Venue Booking Flow

1. Log in on user app
2. Tap **Venues** in bottom nav
3. You should see: Feather Touch Arena, KickOff Arena, The Green Pitch (from seed data)
4. Tap a venue → Venue Detail → Tap **BOOK VENUE**
5. Slot picker shows today's hourly slots (seeded) — 9AM slot on Court A is blocked (shows BOOKED)
6. Select a time, pick a court → booking summary
7. Payment currently shows Razorpay sheet (requires real/test Razorpay keys to complete)

### Test Scoring

1. Log in → Tap **Scoring** in bottom nav
2. Select Cricket (or any sport)
3. Add players (max 3 per team), fill match venue + umpire
4. Complete toss → select XI → start innings → score balls
5. Results are saved to the `matches` table via `MatchRepository.saveMatch()`

### Running Automated Tests

```bash
# Unit tests
cd apps/user_app && flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests (requires running emulator)
flutter test integration_test/app_test.dart
```

### Checking Database State

Use the Supabase Dashboard SQL Editor at:
`https://supabase.com/dashboard/project/nweibhcjqnumxcpwnrvo/sql`

Useful queries:
```sql
-- See all venues
select name, city, sports, is_verified, is_active from venues;

-- See today's slots
select c.name as court, s.start_time, s.end_time, s.is_blocked 
from slots s join courts c on c.id = s.court_id
where s.date = current_date order by c.name, s.start_time;

-- See all users
select id, phone, name, karma_points from users;

-- See all bookings
select b.id, u.phone, b.status, b.final_amount 
from bookings b join users u on u.id = b.user_id order by b.created_at desc;

-- See all matches
select id, sport, team1, team2, status, recorded_by from matches order by created_at desc;
```

---

## 8. App-by-App Guide

### User App — Screens & Routes

| Route | Screen | Status |
|-------|--------|--------|
| `/` | OnboardingScreen | ✅ Built |
| `/auth/login` | LoginScreen | ✅ Real OTP |
| `/auth/otp` | OtpScreen | ✅ Real verify |
| `/auth/create-account` | CreateAccountScreen | ✅ Real upsert |
| `/auth/interests` | InterestsScreen | ✅ Real save |
| `/home` | HomeScreen | ⚠️ UI built, data hardcoded |
| `/coaches` | CoachesScreen | ⚠️ UI built, data hardcoded |
| `/coaches/:coachId` | CoachDetailScreen | ⚠️ UI built |
| `/venues` | VenuesScreen | ✅ Real data from DB |
| `/venues/:venueId` | VenueDetailScreen | ✅ Built (no real photos yet) |
| `/venues/:venueId/slots` | SlotPickerScreen | ✅ Real slot availability |
| `/venues/:venueId/booking-summary` | BookingSummaryScreen | ⚠️ UI built, no payment |
| `/community` | GamesScreen | ⚠️ UI built, data hardcoded |
| `/community/:gameId` | GameDetailScreen | ⚠️ UI built |
| `/account` | ProfileScreen | ⚠️ UI built, data hardcoded |
| `/scoring` | ScoringScreen | ✅ Full workflow, saves to DB |

### Vendor App — Screens & Routes

| Route | Screen | Status |
|-------|--------|--------|
| `/login` | VendorLoginScreen | ✅ Real OTP auth |
| `/dashboard` | VendorDashboardScreen | ✅ Real revenue/bookings |
| `/arena` | ArenaManagementScreen | ⚠️ Court grid hardcoded |
| `/arena/add-venue` | AddVenueScreen | ✅ Saves to DB |
| `/pricing` | PricingScreen | ⚠️ No save to DB |
| `/availability` | AvailabilityScreen | ⚠️ No DB read/write |
| `/bookings` | BookingsScreen | ⚠️ Data hardcoded |
| `/revenue` | RevenueScreen | ⚠️ Chart hardcoded |
| `/insights` | CustomerInsightsScreen | ⚠️ Data hardcoded |

### Admin App — Screens & Routes

| Route | Screen | Status |
|-------|--------|--------|
| `/login` | AdminLoginScreen | ✅ Real email/password |
| `/command` | CommandCenterScreen | ✅ Real KPIs from DB |
| `/approvals` | VenueApprovalsScreen | ⚠️ UI built, data hardcoded |
| `/tournaments` | TournamentControlScreen | ⚠️ Data hardcoded |
| `/banners` | BannerStudioScreen | ⚠️ UI only (no publish) |
| `/analytics` | AnalyticsScreen | ⚠️ Charts hardcoded |
| `/rewards` | RewardsScreen | ⚠️ Data hardcoded |
| `/notifications` | NotificationsScreen | ⚠️ No FCM push yet |

---

## 9. What is Connected (Live)

### ✅ Supabase Auth
- Phone OTP send (`auth.signInWithOtp`)
- OTP verification (`auth.verifyOTP`)
- Email + password (`auth.signInWithPassword`)
- Sign out
- Session-based route guards in all 3 apps
- Auto-create user profile row on signup (DB trigger)

### ✅ Database — Live Reads/Writes
- `venues` — list fetch (filtered by city/sport), single venue fetch
- `courts` — fetch by venue
- `slots` — fetch with live booking overlap detection (marks booked slots)
- `bookings` — create booking, confirm (post-payment), cancel
- `matches` — save match result + ball-by-ball sport_data from scoring screen
- `users` — upsert profile, save sport interests, fetch karma points

### ✅ Vendor App — Live Data
- `myVenuesProvider` — real venues owned by logged-in vendor
- Revenue today/week, booking count today — real from DB
- Today's bookings list — real from DB with player name + court
- Add Venue form — submits to `venues` + `courts` tables (pending approval)

### ✅ Admin App — Live Data
- Platform KPIs: total users, today bookings, revenue, live matches, pending venues — real DB counts
- Pending venue/coach counts drive badge on approval tab

### ✅ Seed Data (Live in DB)
- Feather Touch Arena (Bangalore) — 4 courts
- KickOff Arena (Bangalore) — football turf
- The Green Pitch (Bangalore) — multi-sport
- 48 hourly slots seeded for today (Court A, Court B, Football Turf)
- Court A 9AM slot blocked (simulates real booking)

### ✅ Edge Functions (Deployed)
- `create-payment-order` — deployed, awaiting Razorpay keys in Supabase secrets
- `razorpay-webhook` — deployed, awaiting webhook secret

---

## 10. What is Pending (Hardcoded / Not Yet Built)

### User App — Pending

| Screen | What's Missing |
|--------|---------------|
| **HomeScreen** | User's real name, location, karma from DB. Nearby venues, live games, occupancy feed — all from DB. Announcement banner from DB/admin panel. |
| **CoachesScreen** | Real coaches from `coaches` table. Currently 4 fake UK-based coaches. Filter chips don't query DB. |
| **CoachDetailScreen** | Real coach data, reviews, session booking flow |
| **GamesScreen** | Real games from `games` table. USD prices, fake venues. |
| **GameDetailScreen** | Real game data, join flow, payment |
| **ProfileScreen** | Real user name, stats, match history, karma from DB |
| **BookingSummaryScreen** | Razorpay payment integration (UI exists, no payment call) |
| **Booking history** | No screen showing past bookings yet |

### Vendor App — Pending

| Screen | What's Missing |
|--------|---------------|
| **ArenaManagementScreen** | Court grid reads real courts from DB. Active toggle writes to DB. |
| **BookingsScreen** | Read from `bookings` table via `vendorBookingRepoProvider` |
| **PricingScreen** | Write slider values to `slots.price_paise` on save |
| **AvailabilityScreen** | Read slots from DB, write `is_blocked` toggles |
| **RevenueScreen** | Real weekly revenue chart from booking aggregates |
| **CustomerInsightsScreen** | Real player stats from booking/user data |

### Admin App — Pending

| Screen | What's Missing |
|--------|---------------|
| **VenueApprovalsScreen** | Wire to `pendingVenuesProvider` + `pendingCoachesProvider` (providers exist in `providers.dart`, screen still reads static list). Approve/Reject call `adminAuthRepoProvider` methods. |
| **AnalyticsScreen** | Real platform analytics from DB aggregates |
| **TournamentControlScreen** | Real tournaments from `tournaments` table |
| **NotificationsScreen** | Real FCM push via Firebase Admin SDK in Edge Function |
| **BannerStudioScreen** | Publish to DB or Supabase Storage, user app reads it |

### Platform-Wide — Not Yet Built

- **Firebase / FCM push notifications** — Firebase project not configured, `google-services.json` + `GoogleService-Info.plist` missing
- **Razorpay keys** — Edge Functions deployed but secrets not set in Supabase dashboard
- **Real venue photos** — Supabase Storage buckets exist in schema but no photo uploads wired
- **CI/CD** — No GitHub Actions workflows at all
- **App Store / Play Store submission** — Release signing, fastlane, flavors not configured
- **Venue slot generation** — No automated daily slot creation (currently manual seed)
- **Search / map** — No location-based search (PostGIS was removed; currently city text only)
- **Admin: Banner publish** — No flow to push a banner from admin to user app home screen
- **Referral system** — `referrals` table exists, no UI flow for earning/sharing referral codes

---

## 11. Step-by-Step Guide to Complete Pending Work

Each step below is self-contained and can be worked on independently.

---

### Step A — Wire HomeScreen to Real Data

**File:** `apps/user_app/lib/features/home/presentation/home_screen.dart`

1. Create `apps/user_app/lib/features/home/presentation/home_provider.dart`:

```dart
@riverpod
Future<List<Venue>> nearbyVenues(Ref ref) =>
    ref.watch(venueRepositoryProvider).fetchVenues(city: 'Bangalore', limit: 5);

@riverpod
Future<FieldUpUser?> homeUser(Ref ref) =>
    ref.watch(userRepositoryProvider).fetchCurrentUser();
```

2. Run `dart run build_runner build --delete-conflicting-outputs`

3. In `HomeScreen` make it a `ConsumerWidget`, replace:
   - Hardcoded username → `ref.watch(homeUserProvider).asData?.value?.name ?? 'Player'`
   - Hardcoded karma → `ref.watch(homeUserProvider).asData?.value?.karmaPoints ?? 0`
   - `_venueOccupancy` list → `ref.watch(nearbyVenuesProvider)`

---

### Step B — Wire CoachesScreen to Real Data

**File:** `apps/user_app/lib/features/coaches/presentation/coaches_screen.dart`

1. Create `coaches_provider.dart` next to the screen:

```dart
@riverpod
Future<List<Coach>> coachesList(Ref ref, {String? sport, String? city}) =>
    ref.watch(coachRepositoryProvider).fetchCoaches(sport: sport, city: city);
```

2. Replace `_coaches` static list with `ref.watch(coachesListProvider())` and wrap in `.when()`

3. The `Coach` model is already in `packages/core/lib/models/coach.dart` — use it directly.

---

### Step C — Wire GamesScreen to Real Data

**File:** `apps/user_app/lib/features/games/presentation/games_screen.dart`

1. Create a games provider (no repository exists yet — add to `supabase_client`):

```dart
// In packages/supabase_client/lib/repositories/games_repository.dart
class GamesRepository {
  GamesRepository(this._db);
  final SupabaseClient _db;

  Future<List<Map<String, dynamic>>> fetchPublicGames({String? sport}) async {
    var query = _db.from('games')
        .select('*, venues(name, city), users!inner(name)')
        .eq('is_cancelled', false)
        .eq('visibility', 'public')
        .gte('date_time', DateTime.now().toIso8601String());
    if (sport != null) query = query.eq('sport', sport);
    return ((await query.order('date_time').limit(20)) as List)
        .cast<Map<String, dynamic>>();
  }

  Future<void> joinGame(String gameId, String userId) async {
    await _db.from('game_players').insert({'game_id': gameId, 'user_id': userId});
  }
}
```

2. Add `GamesRepository` to the barrel export and to `auth_provider.dart` providers.

3. Wire screen to `ref.watch(gamesListProvider())`.

---

### Step D — Wire ProfileScreen to Real Data

**File:** `apps/user_app/lib/features/profile/presentation/profile_screen.dart`

The `currentUserProfile` provider already exists in `auth_provider.dart`. Replace the hardcoded fields:

```dart
// Replace hardcoded "ALEX REYNOLDS" etc. with:
final userAsync = ref.watch(currentUserProfileProvider);
final user = userAsync.asData?.value;

// Then in build:
Text(user?.name?.toUpperCase() ?? 'PLAYER')
Text('Karma: ${user?.karmaPoints ?? 0}')
```

For match stats, add a provider that queries `matches` where `recorded_by = currentUser.id`.

---

### Step E — Wire Vendor BookingsScreen

**File:** `apps/vendor_app/lib/screens/bookings_screen.dart`

`todaysBookingsProvider` already exists in `providers.dart`. Get the venue ID from `myVenuesProvider`:

```dart
class BookingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venues = ref.watch(myVenuesProvider).asData?.value ?? [];
    final venueId = venues.isNotEmpty ? venues.first.id : null;
    final bookingsAsync = venueId != null
        ? ref.watch(todaysBookingsProvider(venueId))
        : const AsyncValue<List<Map<String, dynamic>>>.data([]);
    ...
  }
}
```

---

### Step F — Wire Vendor ArenaManagementScreen to Real Courts

**File:** `apps/vendor_app/lib/screens/arena_management_screen.dart`

Add `go_router` import (already present) and add a provider in `providers.dart`:

```dart
final venueCourtsFamilyProvider =
    FutureProvider.family<List<Court>, String>((ref, venueId) =>
        ref.watch(vendorVenueRepoProvider).fetchCourts(venueId));
```

Change `ArenaManagementScreen` to `ConsumerStatefulWidget`, watch `myVenuesProvider` to get the venue ID, then watch `venueCourtsFamilyProvider(venueId)` for the court list. Replace the hardcoded `_courts` const.

---

### Step G — Wire Admin VenueApprovalsScreen

**File:** `apps/admin_app/lib/screens/venue_approvals_screen.dart`

The providers already exist (`pendingVenuesProvider`, `pendingCoachesProvider`, `AdminAuthRepository`). Only the screen needs updating:

1. Change `VenueApprovalsScreen` to `ConsumerStatefulWidget`
2. Replace `_venues` static list with `ref.watch(pendingVenuesProvider)` using `.when()`
3. Replace `_coaches` static list with `ref.watch(pendingCoachesProvider).asData?.value ?? []`
4. Wire APPROVE button: `ref.read(adminAuthRepoProvider).approveVenue(venue.id)` then `ref.invalidate(pendingVenuesProvider)`
5. Wire REJECT button: `ref.read(adminAuthRepoProvider).rejectVenue(venue.id)`

---

### Step H — Set Up Razorpay Payments

1. Get Razorpay test keys from [dashboard.razorpay.com/app/keys](https://dashboard.razorpay.com/app/keys)

2. Add secrets to the Edge Functions in Supabase Dashboard:
   - Go to: **Edge Functions → create-payment-order → Secrets**
   - Add: `RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET`
   - Add: `SUPABASE_SERVICE_ROLE_KEY` (your service_role key)
   - Repeat for `razorpay-webhook`, also add: `RAZORPAY_WEBHOOK_SECRET`

3. Wire `BookingSummaryScreen` to call the Edge Function:

```dart
// In booking_summary_screen.dart
Future<void> _pay() async {
  final bookingId = ...; // from the created booking
  // Call Edge Function
  final response = await Supabase.instance.client.functions.invoke(
    'create-payment-order',
    body: {'booking_id': bookingId, 'amount_paise': finalAmount},
  );
  final orderId = response.data['order_id'] as String;
  final keyId  = response.data['key_id'] as String;
  
  // Open Razorpay checkout
  final options = {
    'key': keyId,
    'amount': finalAmount,
    'order_id': orderId,
    'currency': 'INR',
  };
  _razorpay.open(options);
}
```

4. Handle `_razorpay.onPaymentSuccess` → call `BookingRepository.confirmBooking()`

---

### Step I — Set Up Firebase Push Notifications

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)

2. Add Android app (`com.fieldup.fieldup_user_app`) → download `google-services.json` → place at `apps/user_app/android/app/google-services.json`

3. Add iOS app → download `GoogleService-Info.plist` → place at `apps/user_app/ios/Runner/GoogleService-Info.plist`

4. In `apps/user_app/lib/main.dart`, initialize Firebase before Supabase:
```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
final fcmToken = await FirebaseMessaging.instance.getToken();
// Store fcmToken in users table: profiles.update({'fcm_token': fcmToken})
```

5. Create an Edge Function `send-notification` that uses Firebase Admin SDK to send targeted push via Supabase's Edge Function environment.

---

### Step J — Automated Daily Slot Generation

Currently slots are seeded manually. For production, create a Supabase scheduled function or a cron-triggered Edge Function:

```typescript
// functions/generate-daily-slots/index.ts
// Runs daily at midnight — creates 16 hourly slots for each active court
const tomorrow = new Date();
tomorrow.setDate(tomorrow.getDate() + 1);

const courts = await supabase.from('courts').select('id, price_per_hour').eq('is_active', true);
for (const court of courts.data) {
  for (let h = 6; h <= 21; h++) {
    await supabase.from('slots').upsert({
      court_id: court.id,
      date: tomorrow.toISOString().split('T')[0],
      start_time: `${h.toString().padStart(2,'0')}:00`,
      end_time:   `${(h+1).toString().padStart(2,'0')}:00`,
      price_paise: court.price_per_hour,
    }, { onConflict: 'court_id,date,start_time' });
  }
}
```

Deploy and set up a daily cron trigger in the Supabase dashboard under Edge Functions → Schedules.

---

### Step K — CI/CD (GitHub Actions)

Create `.github/workflows/ci.yml`:

```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: 'stable' }
      - run: cd apps/user_app && flutter pub get
      - run: cd apps/user_app && flutter analyze
      - run: cd apps/user_app && flutter test
```

For release builds, add fastlane lanes for TestFlight (iOS) and Play Internal (Android).

---

## 12. Design System

**Package:** `packages/design_system` → imported as `fieldup_design_system`

### Color Palette (Dark-first "Neon Punch")

| Token | Hex | Use |
|-------|-----|-----|
| `AppColors.primary` (brandGreen400) | `#C8F23A` | Primary CTA buttons, active states, lime accent |
| `AppColors.onPrimary` (brandGreen700) | `#1A2800` | Text on lime buttons |
| `AppColors.background` | `#000000` | Night Pitch scaffold |
| `AppColors.surface` | `#111111` | Cards, panels |
| `AppColors.neutral900` | `#F5F5F5` | Primary text |
| `AppColors.neutral700` | `#9E9E9E` | Secondary text |
| `AppColors.teal400` | `#58B48F` | Success, active |
| `AppColors.blue400` | `#3A8DCC` | Vendor accent (Turf Blue) |
| `AppColors.error` (red500) | `#E34B34` | Errors, destructive |
| `AppColors.warning` (orange500) | `#F2AD25` | Warnings, pending |

### Typography

| Token | Font | Size | Weight |
|-------|------|------|--------|
| `AppTextStyles.displayLG` | Barlow Condensed | 48sp | Bold italic |
| `AppTextStyles.headingXL` | Barlow Condensed | 32sp | Bold |
| `AppTextStyles.headingLG` | Barlow Condensed | 28sp | Bold |
| `AppTextStyles.headingMD` | Barlow Condensed | 22sp | SemiBold |
| `AppTextStyles.bodyLG` | Inter | 16sp | Regular |
| `AppTextStyles.bodyMD` | Inter | 14sp | Regular |
| `AppTextStyles.label` | Inter | 13sp | Medium |
| `AppTextStyles.caption` | Inter | 12sp | Regular |

**Rule:** Always use `AppColors.*` and `AppTextStyles.*` — never hardcode hex values or font sizes inline.

---

## 13. Domain Models

All in `packages/core/lib/models/`. Import via `package:fieldup_core/fieldup_core.dart`.

| Model | Key Fields |
|-------|-----------|
| `FieldUpUser` | id, phone, name, email, karmaPoints, sportPreferences[], city |
| `Venue` | id, name, address, city, sports[], amenities[], photos[], rating, isVerified, isActive |
| `Court` | id, venueId, name, sport, capacity, pricePerHour (paise), surface, hasLights |
| `Slot` | id, courtId, date, startTime, endTime, pricePaise, isBlocked, isBooked |
| `Booking` | id, userId, slotId, status (BookingStatus), finalAmount (paise), razorpayOrderId |
| `Coach` | id, userId, name, sports[], hourlyRatePaise, certifications[], rating |
| `MatchRecord` | id, sport, team1, team2, status, umpire1, umpire2, sportData (jsonb) |

**Money rule:** All amounts in `int` paise. Display with `formatRupees(paise)` from `money.dart`.

---

## 14. Repository Layer

All repositories are in `packages/supabase_client/lib/repositories/`.

Repositories are provided via `@riverpod` in `apps/user_app/lib/features/auth/presentation/auth_provider.dart`:

```dart
// Access in any ConsumerWidget:
final venues = await ref.read(venueRepositoryProvider).fetchVenues(city: 'Bangalore');
final auth   = ref.read(authRepositoryProvider);
final bookings = await ref.read(bookingRepositoryProvider).fetchMyBookings(uid);
```

Vendor and admin apps have their own providers in `providers.dart` in each app's `lib/` folder.

---

## 15. Edge Functions

Both functions are deployed at:
```
https://nweibhcjqnumxcpwnrvo.supabase.co/functions/v1/<name>
```

### Calling from Flutter

```dart
final response = await Supabase.instance.client.functions.invoke(
  'create-payment-order',
  body: {'booking_id': id, 'amount_paise': amount},
);
```

### Required Secrets (set in Supabase Dashboard → Edge Functions → Secrets)

| Secret | For Function | Value |
|--------|-------------|-------|
| `RAZORPAY_KEY_ID` | create-payment-order | From Razorpay dashboard |
| `RAZORPAY_KEY_SECRET` | create-payment-order | From Razorpay dashboard |
| `RAZORPAY_WEBHOOK_SECRET` | razorpay-webhook | From Razorpay webhook settings |
| `SUPABASE_SERVICE_ROLE_KEY` | Both | Your service_role key |
| `SUPABASE_URL` | Both | `https://nweibhcjqnumxcpwnrvo.supabase.co` |

---

## 16. Payments — Razorpay

**Flow:**
1. User taps **Pay** on Booking Summary screen
2. Flutter calls `create-payment-order` Edge Function → gets `order_id`
3. Flutter opens Razorpay checkout sheet (key_id only — never key_secret in Flutter)
4. User completes UPI/card payment
5. Razorpay sends webhook to `razorpay-webhook` Edge Function
6. Webhook verifies HMAC signature → updates booking to `confirmed` → adds 5 karma points
7. Supabase Realtime pushes update → Flutter shows confirmation screen

**Never pass `key_secret` to Flutter.** It lives only in the Edge Function environment variable.

---

## 17. Push Notifications — Firebase

**Status:** ⚠️ Not yet configured.

**What's needed:**
1. Firebase project with Android + iOS apps registered
2. `google-services.json` at `apps/user_app/android/app/`
3. `GoogleService-Info.plist` at `apps/user_app/ios/Runner/`
4. `FCM_SERVICE_ACCOUNT_JSON` secret in Supabase Edge Functions
5. `send-notification` Edge Function using Firebase Admin SDK
6. Store FCM token in `users.fcm_token` on app launch
7. Trigger push from: booking confirmation, score update, promo campaigns

---

## 18. CI/CD

**Status:** ⚠️ Not yet implemented.

**Planned setup:**

| Pipeline | Trigger | Action |
|----------|---------|--------|
| `ci.yml` | Every push / PR | `flutter analyze` + `flutter test` |
| `deploy-staging.yml` | Push to `main` | Build `.apk` / `.ipa`, upload to TestFlight + Play Internal |
| `deploy-prod.yml` | Tag `v*` | Build release, submit to App Store + Play Store |

Tool: **Fastlane** for signing and submission. Secrets: `MATCH_PASSWORD`, `APP_STORE_CONNECT_API_KEY`, `PLAY_STORE_SERVICE_ACCOUNT`.

---

## 19. Environment Variables & Secrets

### Flutter apps (`--dart-define` or already baked in as defaults)

| Variable | Default value in code | Override via |
|----------|----------------------|-------------|
| `SUPABASE_URL` | `https://nweibhcjqnumxcpwnrvo.supabase.co` | `--dart-define` |
| `SUPABASE_ANON_KEY` | `eyJhbGci...O4LNQOY2...` | `--dart-define` |
| `RAZORPAY_KEY_ID` | None | `--dart-define` (test key safe to expose) |

### Supabase Edge Function Secrets (set in Dashboard)

| Secret | Status |
|--------|--------|
| `SUPABASE_URL` | ⚠️ Need to add |
| `SUPABASE_SERVICE_ROLE_KEY` | ⚠️ Need to add |
| `RAZORPAY_KEY_ID` | ⚠️ Need to add |
| `RAZORPAY_KEY_SECRET` | ⚠️ Need to add |
| `RAZORPAY_WEBHOOK_SECRET` | ⚠️ Need to add |

> **Security:** The `service_role` key and Razorpay `key_secret` must **never** be placed in Flutter source code. They belong only in Edge Function environment secrets.

---

## 20. Releasing to App Store / Play Store

### Android Release Build

```bash
cd apps/user_app

# Generate a keystore (one-time)
keytool -genkey -v -keystore upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000

# Add to android/key.properties:
# storePassword=...
# keyPassword=...
# keyAlias=upload
# storeFile=../upload-keystore.jks

# Build release AAB
flutter build appbundle --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... --dart-define=RAZORPAY_KEY_ID=rzp_live_xxx
```

Upload `build/app/outputs/bundle/release/app-release.aab` to Play Console → Internal Testing.

### iOS Release Build (requires Xcode + Apple Developer account)

```bash
flutter build ipa --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
# Then upload via Xcode or Transporter to App Store Connect → TestFlight
```

### App IDs

| App | Bundle ID |
|-----|-----------|
| user_app | `com.fieldup.fieldup_user_app` |
| vendor_app | `com.fieldup.fieldup_vendor_app` |
| admin_app | `com.fieldup.fieldup_admin_app` |

---

## 21. Key Decisions & Conventions

### Code Conventions
- **All amounts in paise** (`int`) — display via `formatRupees(int paise)`
- **Images:** always `CachedNetworkImage` — never `Image.network`
- **Navigation:** always `context.go()` / `context.push()` — never `Navigator.push()`
- **Supabase calls:** only in Repositories — never directly in providers or widgets
- **AsyncValue:** always handle all 3 states: `.when(loading: ..., error: ..., data: ...)`
- **Design tokens:** always `AppColors.*` and `AppTextStyles.*` — no hardcoded hex or sizes

### File Naming
- Screens: `feature_name_screen.dart` → class `FeatureNameScreen`
- Providers: `feature_name_provider.dart`
- Repositories: `feature_repository.dart`
- Models: `model_name.dart`

### Scoring Module
The scoring module (`scoring_screen.dart`) is a single-file implementation containing all sport scorers (Cricket, Badminton, Tennis, Football, Basketball, Volleyball, Paddleball, Pickleball). Cricket has a full multi-step workflow: Team Setup → Toss → Playing XI → Live Innings → Innings Break → Result. Completed matches are saved via `MatchRepository.saveMatch()`.

### Sports Supported
Cricket, Football, Badminton, Basketball, Tennis, Volleyball, Pickleball, Paddle Ball

### India-Specific Rules
- Currency: INR only, UPI primary
- Phone: +91 prefix mandatory
- Min iOS: 13.0 · Min Android: API 21
- Data region: Supabase ap-south-1 (Mumbai) — verify in dashboard settings
- Apple Sign-In mandatory on iOS when Google login is offered (App Store rule)

---

*This document reflects the state of the codebase as of June 2026.*  
*GitHub: [gangasireeshak-ui/fieldup](https://github.com/gangasireeshak-ui/fieldup) · Supabase: [nweibhcjqnumxcpwnrvo](https://supabase.com/dashboard/project/nweibhcjqnumxcpwnrvo)*
