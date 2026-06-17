# FieldUp — Project Context
# ==========================================
# Every agent reads this file before doing anything.
# This file defines the full technical and product context
# for the FieldUp sports booking platform.
# Keep ALREADY_BUILT updated as features ship.
# ==========================================


# ──────────────────────────────────────────
# 1. WHAT IS THIS APP?
# ──────────────────────────────────────────

APP_NAME: FieldUp

APP_PURPOSE:
# A sports facility booking and community platform for India (similar to Playo).
# Users discover and book courts, hire coaches, join academies, note live match
# scores, and connect with other players. Three separate apps in one monorepo.

PLATFORM_APPS:
  user_app:    Mobile (iOS + Android) — end-user booking, coaching, scoring, community
  vendor_app:  Mobile/tablet (iOS + Android) — court owners, coaches, academies
  admin_app:   Web / tablet (Flutter Web) — FieldUp super-admin panel

PHASE: greenfield
SCALE: startup
TARGET_MARKET: India (metro launch, Tier-2 expansion)


# ──────────────────────────────────────────
# 2. USER APP — SCREEN INVENTORY (from Figma Hi-Fidelity)
# ──────────────────────────────────────────
# Figma file key : kIBysfIfh8sucmvVa6PGPW
# Hi-Fidelity page: 126:106
# Wireframes page : 64:120

SCREENS:

  onboarding:
    description: Carousel with 3 slides + dot indicators, Skip and Next buttons
    slides:
      1: title="Book & Join Sports Venues Instantly"
         body="Find and book arenas, join tournaments, and connect with players in your area"
      2: title="Train with coaches who know the game"
         body="Book trusted coaches across sports with flexible sessions and fair pricing."
      3: title="Surround yourself with competition"
         body="Match with players at your level or higher to improve your game."

  auth_flow:
    # Sequential screens — not separate routes for each state, one screen handles states
    screens:
      welcome_phone:
        content: "Welcome! Let's get you started", mobile number field (+91 prefix), Next button, Google login option
      otp_entry:
        content: "Enter OTP", "Sent to +91 XXXXXX", 6-digit OTP input, countdown "Retry in 00:24"
        states: [empty, filling, incorrect="Entered OTP is incorrect", success="You're in. Let's play."]
      create_account:
        content: Name, Mobile Number, Email (Optional), Referral Code
        consent: "I agree to the Terms of Service and Privacy Policy", notifications opt-in
        action: Next button
      interests:
        content: "Interests" heading, Search bar
        sports: Basketball, Box Cricket, Badminton, Cricket, Football, Shooting, Boxing (+ more)
        actions: Skip, Confirm

  home:
    top_bar: location selector, notifications icon, FieldUp logo
    sections:
      - Sport filter chips (horizontal scroll)
      - Featured / nearby venues
      - Coaches section
      - Community / Games section
    bottom_nav: Home, Venues, Scoring, Games, Profile

  venues:
    screens:
      list:
        filters: sport, location, sort, price range, availability
        card: venue name, location, rating, sport tag, price
      detail:
        sections: photo gallery, name, location, sport, amenities, available games, rating, book CTA
        note: "Earn 5 points every booking" (karma)
      slot_picker:
        elements: calendar month view, time slot grid, slot states (available/booked/selected)
      booking_summary:
        fields: Sport, Venue, Date & Time, Team & Player Details, Fare Breakup, Karma Points, Coupon Code
      payment:     Razorpay checkout sheet
      confirmation: booking confirmed screen

  coaches:
    screens:
      list:
        filters: Sport, Skill level, Training type (1-on-1/Group/Team), Location/Online, Price, Availability
        card: photo, name, sport, experience, rating, price/session, availability badge
      detail:
        sections: photo, name, sport, experience, rating, specialties, reviews, book/interest CTA
        specialties: Speed & Agility, Match Strategy, Injury Prevention, Youth Training (examples)
      interest_sent: success popup "Interest shared. You're all set. Expect a call or message soon."

  scoring:
    screens:
      setup:    select sport, select players (max 3 per side), set rules
      live:     live scoring UI, score entry, Add a Break, Pause/End buttons
      history:  match results, score history

  games:
    screens:
      list:           open games / challenges list
      create:         which sport, time & date, location, fees & instructions, team & player details
      detail:         game info, players list, join CTA
      booking_summary: fare breakup, karma points, coupon, payment method
      profile:
        stats: Games Played, Hours Played, Skill Level, Leaderboard, Karma Points, Last Rating
        streak: Games Played Streak
        team_tinder: swipe-style team matching ("Team Tinder")

  player_profile:
    sections:
      header: Name, Profile Photo, Primary Sport, Member Since, Last Played
      stats:  Games Played, Hours Played, Skill Level Overall, Leaderboard rank, Karma Points
      experience_timeline: Year | Team/Academy | Level | Matches | Achievements (table view)
      skill_assessment: Core skills rated 1-5 (Tactical Awareness, Mental Strength, Discipline)

  account:
    screens: settings, notifications preferences, referral program, support/feedback
    support_prompt: "Got questions or ideas? Let us know to help improve the game experience."

  skill_tiers:
    # Used across home, games, profile, scoring
    - Rookie
    - Contender
    - Playmaker
    - Competitive
    - Elite


# ──────────────────────────────────────────
# 3. FRONTEND — FLUTTER
# ──────────────────────────────────────────

MOBILE_FRAMEWORK: flutter
FLUTTER_VERSION: latest-stable

STATE_MANAGEMENT: riverpod
# Use @riverpod code generation (riverpod_annotation + build_runner)
# AsyncNotifierProvider for async data, NotifierProvider for sync state
# Never mix with Provider, GetX, or BLoC

NAVIGATION: go_router
# Declarative routing, deep-link ready
# All routes in lib/app_router.dart
# Always context.go() / context.push() — never Navigator.push()

UI_STYLE: material3-custom
# Material 3 base with FieldUp design system
# Never hardcode colors — always use AppColors / AppTextStyles tokens
# AppTheme applied at MaterialApp level

HTTP_CLIENT: dio
# Dio with AuthInterceptor for Supabase token injection
# Never use the raw http package

LOCAL_STORAGE: hive + shared_preferences
# Hive: structured cache (user profile, recent searches, offline court data)
# shared_preferences: simple flags (onboarding_done, theme_mode)

IMAGE_HANDLING: cached_network_image
# Never Image.network — always CachedNetworkImage with shimmer placeholder

KEY_PACKAGES:
  flutter_riverpod: ^2.0.0
  riverpod_annotation: ^2.0.0
  go_router: ^14.0.0
  supabase_flutter: ^2.0.0
  razorpay_flutter: ^1.3.0
  cached_network_image: ^3.3.0
  hive_flutter: ^1.1.0
  firebase_messaging: ^15.0.0    # Push notifications (FCM)
  geolocator: ^11.0.0
  flutter_secure_storage: ^9.0.0
  lottie: ^3.1.0
  intl: ^0.19.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  image_picker: ^1.1.0
  flutter_image_compress: ^2.2.0
  shimmer: ^3.0.0
  dio: ^5.4.0


# ──────────────────────────────────────────
# 4. DESIGN SYSTEM — FIGMA TOKENS
# ──────────────────────────────────────────

FIGMA_FILE: https://www.figma.com/design/kIBysfIfh8sucmvVa6PGPW/FieldUp
FIGMA_PAGES:
  hi_fidelity:      126:106   # Main UI screens
  wireframes:       64:120    # Flow wireframes
  colors:           209:24    # Full design token system
  sport_illustrations: 370:852

COLORS_LIGHT:
  # Brand (primary CTA — lime green)
  brand_green_50:  "#FBFEF5"
  brand_green_100: "#F1FCD3"
  brand_green_200: "#E2F89A"
  brand_green_300: "#D7F66F"
  brand_green_400: "#CEF445"   # PRIMARY — buttons, active states
  brand_green_500: "#B1DB23"   # Pressed state
  brand_green_600: "#95BA25"
  brand_green_700: "#5F7D17"   # Text on brand green
  brand_green_800: "#374412"
  brand_green_900: "#1F240E"

  # Neutrals
  neutral_50:  "#F9FAFA"
  neutral_100: "#F2F4F5"
  neutral_200: "#E9ECEE"
  neutral_300: "#DEE3E6"
  neutral_400: "#C8D0D4"   # Borders, dividers
  neutral_500: "#A3ADB2"   # Placeholder text
  neutral_600: "#7E8A90"
  neutral_700: "#59666C"   # Secondary text
  neutral_800: "#2F3A3F"
  neutral_900: "#161B1D"   # Primary text

  # Backgrounds
  background:  "#F2F2F2"
  surface:     "#FFFFFF"

  # Semantic
  teal_500:   "#4EAD8D"   # Success, active
  red_500:    "#E34B34"   # Error, destructive
  blue_500:   "#3A7BEE"   # Info, links
  orange_500: "#F2AD25"   # Warning, premium

COLORS_DARK:
  brand_green_primary: "#ACE967"
  background: "#0D0D0D"
  surface: "#1C2223"
  neutral_900: "#F0F3F2"   # Primary text in dark mode

TYPOGRAPHY:
  # Confirm exact font family from Figma during first build
  heading_xl:  28sp / bold
  heading_lg:  24sp / semibold
  heading_md:  20sp / semibold
  body_lg:     16sp / regular
  body_md:     14sp / regular
  caption:     12sp / regular
  label:       13sp / medium

BOTTOM_NAV:
  tabs: [Home, Venues, Scoring, Games, Profile]
  icons: [home, location, whistle/score, people-community, account-circle]

BUTTON_VARIANTS: Primary, Secondary, Tertiary
BUTTON_SIZES: Large, Mid
BUTTON_STATES: Active, Inactive


# ──────────────────────────────────────────
# 5. BACKEND — SUPABASE
# ──────────────────────────────────────────

BACKEND: supabase
# No separate Node.js server — Supabase Edge Functions handle all server-side logic

SUPABASE_PROJECTS:
  development: fieldup-dev    # Free plan — local dev and staging
  production:  fieldup-prod   # Pro plan ($25/mo)

EDGE_FUNCTIONS:
  create-payment-order:  Creates Razorpay order (secret key stays server-side)
  razorpay-webhook:      Verifies HMAC, confirms booking on payment.captured
  send-notification:     Triggers FCM push via Firebase Admin SDK

API_STYLE: supabase-client + rpc
# CRUD via Supabase Flutter client
# Complex multi-step operations via Postgres RPC functions


# ──────────────────────────────────────────
# 6. DATABASE
# ──────────────────────────────────────────

PRIMARY_DB: supabase-postgres
MIGRATION_PATH: backend/supabase/migrations/

SCHEMA_CONVENTIONS:
  - snake_case for all table and column names
  - UUID primary keys: gen_random_uuid()
  - created_at / updated_at on every table (trigger-managed)
  - Soft deletes via deleted_at (never hard delete booking or user data)
  - RLS MUST be enabled on every single table

MONEY_CONVENTION: paise
# Store as INTEGER in paise. ₹1 = 100 paise. Format via formatRupees(int paise).
# Never use DECIMAL or FLOAT for money columns.

CORE_TABLES:
  # Auth & Users
  profiles, user_preferences

  # Vendors
  vendors, vendor_documents

  # Facilities
  sports, courts, court_slots, court_amenities, court_images

  # Coaches & Academies
  coaches, coach_availability, academies, academy_batches, academy_packages

  # Bookings & Payments
  bookings, booking_items, booking_participants, payments, transactions, refunds

  # Scores & Gamification
  matches, match_scores, player_stats, leaderboards, karma_points

  # Platform
  reviews, notifications, app_config

ROW_LEVEL_SECURITY:
  - Users: own profile + own bookings only
  - Vendors: own courts/slots/coaches only
  - sports + courts: public readable (unauthenticated browse)
  - vendor_documents: vendor (own) + admin only
  - Admins: service role key in Edge Functions only — never in Flutter

REALTIME_TABLES:
  - court_slots    # Live slot availability on booking screen
  - bookings       # Status updates: pending_payment → confirmed (post-webhook)
  - match_scores   # Live score updates during games


# ──────────────────────────────────────────
# 7. AUTH
# ──────────────────────────────────────────

AUTH: supabase-auth
PRIMARY_AUTH: phone-otp         # +91 Indian phone numbers
SECONDARY_AUTH:
  - google-oauth
  - apple-sign-in               # MANDATORY for iOS App Store (when Google is offered)

OTP_RULES:
  - Max 3 failed attempts → 15-minute lockout
  - 60-second countdown shown before resend
  - Mask phone in logs: +91****XX

USER_ROLES: user, vendor, admin
# Stored in profiles.role. RLS policies enforce boundaries.
# vendor and admin roles assigned separately — not self-serve.


# ──────────────────────────────────────────
# 8. PAYMENTS — RAZORPAY
# ──────────────────────────────────────────

PAYMENT_GATEWAY: razorpay
CURRENCY: INR
PAYMENT_METHODS: UPI, cards, netbanking, wallets

RAZORPAY_FEATURES:
  - Gateway:       Court / coach / academy bookings
  - Route:         Auto-split vendor share + platform commission per booking
  - Subscriptions: Monthly/quarterly academy packages
  - Payouts:       Vendor settlements to bank accounts

PAYMENT_FLOW:
  1. Flutter calls Edge Function → creates Razorpay order
  2. razorpay_flutter opens checkout sheet (public key_id only in Flutter)
  3. User pays
  4. Razorpay webhook → Edge Function verifies HMAC → updates booking to confirmed
  5. Supabase Realtime pushes confirmed status → Flutter shows confirmation

SECURITY:
  - Razorpay key_secret: Edge Function env vars ONLY — never in Flutter
  - Flutter success callback: navigate to "processing" screen only — never confirm booking
  - Webhook: always verify X-Razorpay-Signature with HMAC-SHA256 before processing


# ──────────────────────────────────────────
# 9. STORAGE
# ──────────────────────────────────────────

FILE_STORAGE: supabase-storage

BUCKETS:
  court-images:     public    # Venue/court photos
  coach-avatars:    public    # Coach and user profile photos
  user-avatars:     public    # User profile photos
  vendor-documents: private   # KYC (Aadhaar/PAN) — signed URLs, max 5min expiry

UPLOAD_RULES:
  - Max 5MB per file
  - Validate by magic bytes (JPEG/PNG) — not just extension
  - Compress client-side before upload: max 800px wide, 80% quality


# ──────────────────────────────────────────
# 10. NOTIFICATIONS
# ──────────────────────────────────────────

PUSH_NOTIFICATIONS: fcm
# FCM token stored in profiles.fcm_token, refreshed on app launch
# Dispatch only via Supabase Edge Functions (Firebase Admin SDK)
# Never dispatch directly from Flutter

NOTIFICATION_TYPES:
  booking_confirmed, booking_reminder, booking_cancelled,
  payment_success, payment_failed, score_update, vendor_approval, promo


# ──────────────────────────────────────────
# 11. DEPLOYMENT
# ──────────────────────────────────────────

DEPLOY_TARGET:
  user_app:   App Store + Google Play
  vendor_app: App Store + Google Play
  admin_app:  Vercel (Flutter Web)

CI_CD: github-actions
BUILD_TOOL: fastlane

ENVIRONMENTS:
  local:      supabase start (local Docker) + --flavor development
  staging:    fieldup-dev Supabase + Razorpay test keys + TestFlight internal + Play internal
  production: fieldup-prod Supabase + Razorpay live keys + App Store + Play Store

FLUTTER_BUILD_FLAVORS:
  development: fieldup-dev + rzp_test_xxx
  production:  fieldup-prod + rzp_live_xxx

REQUIRED_GITHUB_SECRETS:
  SUPABASE_DEV_URL, SUPABASE_DEV_ANON_KEY
  SUPABASE_PROD_URL, SUPABASE_PROD_ANON_KEY
  RAZORPAY_TEST_KEY_ID, RAZORPAY_LIVE_KEY_ID
  MATCH_PASSWORD, APP_STORE_CONNECT_API_KEY
  PLAY_STORE_SERVICE_ACCOUNT


# ──────────────────────────────────────────
# 12. SECURITY & COMPLIANCE
# ──────────────────────────────────────────

SENSITIVE_DATA: yes
COMPLIANCE: pci-dss, india-it-act

SECURITY_RULES:
  - RLS on every Supabase table — no exceptions ever
  - Supabase service role key: Edge Functions only
  - Razorpay key_secret: Edge Functions only
  - Webhooks: always verify HMAC before processing
  - Vendor KYC docs: private bucket + signed URLs only
  - No PII (phone, location) in logs or analytics events
  - Apple Sign-In mandatory on iOS when Google login is offered
  - Data region: Supabase ap-south-1 (Mumbai) for India data residency


# ──────────────────────────────────────────
# 13. TESTING
# ──────────────────────────────────────────

TEST_RUNNER: flutter-test + integration_test
UNIT_COVERAGE: 70%
E2E_COVERAGE: critical-paths-only

CRITICAL_TEST_PATHS:
  1. OTP login → create account → interests
  2. Court discovery → slot selection → payment → booking confirmed
  3. Coach browse → interest/booking
  4. Live score entry
  5. Vendor: publish court (vendor_app)

TESTING_RULES:
  - Integration tests use real fieldup-dev Supabase — never mock Supabase
  - Unit test all Riverpod providers via ProviderContainer
  - Widget tests for every loading/error/data state (not just happy path)


# ──────────────────────────────────────────
# 14. FOLDER STRUCTURE
# ──────────────────────────────────────────

REPO_STRUCTURE:
  fieldup/
  ├── apps/
  │   ├── user_app/
  │   ├── vendor_app/
  │   └── admin_app/
  ├── packages/
  │   ├── core/              # Shared Dart: models, utils, extensions, errors
  │   ├── supabase_client/   # Supabase init + shared repositories
  │   └── design_system/     # Shared Flutter: AppTheme, AppColors, widgets
  ├── backend/
  │   └── supabase/
  │       ├── migrations/    # SQL files — numbered sequentially
  │       ├── functions/     # Edge Functions (Deno/TypeScript)
  │       └── seed/
  ├── designs/
  │   ├── user_app/          # Figma screen exports (PNG)
  │   ├── vendor_app/
  │   └── admin_app/
  └── .github/
      ├── workflows/
      └── copilot-instructions/

FLUTTER_FEATURE_STRUCTURE: (per feature inside lib/features/)
  feature_name/
  ├── data/
  │   ├── feature_repository.dart
  │   └── feature_repository_impl.dart
  ├── domain/
  │   └── feature_model.dart         # freezed model
  └── presentation/
      ├── feature_screen.dart
      ├── feature_provider.dart      # @riverpod
      └── widgets/


# ──────────────────────────────────────────
# 15. CODING CONVENTIONS
# ──────────────────────────────────────────

DART_STYLE:
  - dart format enforced in CI (--set-exit-if-changed)
  - const constructors everywhere possible
  - Named parameters for constructors with 2+ parameters
  - freezed for all domain models (copyWith, toJson, fromJson, sealed unions)

NAMING:
  Screens:      CourtDetailScreen, BookingScreen      (suffix: Screen)
  Widgets:      CourtCard, SlotChip, PriceTag          (descriptive noun)
  Skeletons:    CourtCardSkeleton                      (suffix: Skeleton)
  Providers:    courtsProvider, bookingDetailProvider  (camelCase + Provider)
  Repositories: CourtRepository, BookingRepository    (suffix: Repository)
  Models:       Court, Booking, CourtSlot              (plain noun)
  Services:     PaymentService, NotificationService   (suffix: Service)

CRITICAL_CONVENTIONS:
  - All amounts in paise (int) — format via formatRupees() for display
  - CachedNetworkImage everywhere — never Image.network
  - context.go() / context.push() — never Navigator.push()
  - Supabase calls only in Repositories — never directly in providers or widgets
  - AsyncValue.when() always handles all 3 states: loading / error / data


# ──────────────────────────────────────────
# 16. CURRENT STATE
# ──────────────────────────────────────────

CURRENT_FOCUS: Scaffolding Flutter monorepo + building user_app screens from Figma

DESIGNS_AVAILABLE:
  user_app:   YES — Figma Hi-Fidelity (file: kIBysfIfh8sucmvVa6PGPW, page: 126:106)
  vendor_app: NOT YET DESIGNED
  admin_app:  NOT YET DESIGNED

ALREADY_BUILT:
  - [x] .github/copilot-instructions/ (6 agent files)
  - [x] copilot-instructions.md
  - [ ] Flutter monorepo scaffold (apps/, packages/, backend/)
  - [ ] packages/design_system (AppTheme, AppColors, AppTextStyles)
  - [ ] packages/core (models, utils, extensions)
  - [ ] user_app scaffold (main.dart, app_router.dart, folder structure)
  - [ ] Supabase migrations (schema)
  - [ ] Supabase RLS policies
  - [ ] Edge Function: create-payment-order
  - [ ] Edge Function: razorpay-webhook
  - [ ] Auth flow (onboarding + OTP + create account + interests)
  - [ ] Home screen
  - [ ] Venues list + detail + booking flow
  - [ ] Coaches list + detail
  - [ ] Scoring screens
  - [ ] Games screens
  - [ ] Player profile
  - [ ] CI/CD pipeline
  - [ ] App Store + Play Store submission

CONSTRAINTS:
  - India-first: INR only, UPI primary, +91 phone numbers
  - Apple Sign-In mandatory (App Store rule — non-negotiable)
  - Razorpay key_secret never in Flutter
  - Supabase service role key never in Flutter
  - Supabase region: ap-south-1 (Mumbai)
  - iOS min: 13.0 | Android min: API 21
  - All amounts in paise — never raw numbers shown to users
  - Network: design for 3G/4G India conditions — offline cache, shimmer skeletons
