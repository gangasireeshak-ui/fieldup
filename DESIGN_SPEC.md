# FieldUp — User App UI Design Specification

> **Purpose:** Complete screen-by-screen UI prompt for designing the FieldUp user-facing mobile application.
> **Platform:** Mobile-first (393 × 852 dp canvas). All screens scroll vertically unless noted.
> **Stack context:** Flutter. Every screen maps directly to a route in the app.

---

## 1. Design System

### 1.1 Colour Tokens

| Token | Hex | Usage |
|---|---|---|
| `brandGreen400` | `#CEF445` | Primary CTA buttons, active accents |
| `brandGreen100` | `#F1FCD3` | Selected chip backgrounds |
| `brandGreen700` | `#5F7D17` | Text on green backgrounds |
| `teal500` | `#4EAD8D` | Active indicators, checkboxes, links |
| `teal600` | `#3B8668` | Image placeholder backgrounds |
| `teal700` | `#2A5F48` | Group card backgrounds |
| `neutral900` | `#161B1D` | Primary body text |
| `neutral700` | `#59666C` | Secondary text |
| `neutral600` | `#7E8A90` | Placeholder / caption text |
| `neutral300` | `#DEE3E6` | Borders, dividers, inactive dots |
| `neutral200` | `#E9ECEE` | Card borders |
| `neutral100` | `#F2F4F5` | Read-only field fill |
| `neutral50` | `#F9FAFA` | Page background |
| `surface` | `#FFFFFF` | Card / sheet background |
| `red500` | `#E34B34` | Error states, destructive actions |
| `orange500` | `#F2AD25` | Warning, premium |
| `blue500` | `#3A7BEE` | Info, links |

### 1.2 Typography

| Style | Size | Weight | Usage |
|---|---|---|---|
| `headingLG` | 24 sp | SemiBold | Screen titles |
| `headingMD` | 20 sp | SemiBold | Section titles, OTP digits |
| `bodyLG` | 16 sp | Regular | Content text |
| `bodyMD` | 14 sp | Regular | Supporting text, form labels |
| `label` | 13 sp | Medium | Card labels, field labels |
| `caption` | 12 sp | Regular | Metadata, distance, timestamps |

Font family: **Inter**

### 1.3 Component Patterns

- **Primary button** — full width, 52 dp height, 12 dp radius, `brandGreen400` fill, `brandGreen700` bold text
- **Outlined button** — full width, 52 dp height, 12 dp radius, transparent fill, `neutral900` border + text
- **Dark filled button** — full width, 52 dp height, 12 dp radius, `neutral900` fill, white text (used for "Confirm")
- **Text field** — 48 dp height, 12 dp radius, `neutral200` border, `neutral500` hint text; focused border `teal500` 2 dp
- **Chip / filter pill** — 32 dp height, 20 dp horizontal padding, 20 dp radius; inactive: white + `neutral300` border; active: `brandGreen100` + `brandGreen400` border
- **Card** — `surface` background, 16 dp radius, `neutral200` border (1 dp)
- **Section header** — bold `bodyLG` title left + "See all ›" (`caption` + chevron) right
- **Bottom sheet** — `surface` background, `BorderRadius.vertical(top: 24)`, 40 dp handle pill (`neutral300`, 40 × 4 dp) centred at top
- **Image placeholder** — `teal600` or `neutral300` solid fill; always `ClipRRect` with matching radius

### 1.4 Global Layout Rules

- Safe-area padding on all screens
- Horizontal content padding: **24 dp** (auth) / **16 dp** (main app)
- Bottom navigation bar: 5 tabs — Home · Venues · Scoring · Games · Profile
- `AppColors.neutral50` background unless noted

---

## 2. Navigation Map

```
/ (Onboarding)
└── /auth/login
    ├── /auth/otp
    │   └── /auth/create-account
    │       └── /auth/interests
    │           └── /home  ←─────────────────────────┐
                                                      │
/home ──────────────────────────────────────── (tab 0)│
/venues ─────────────────────────────────────── tab 1 │
  /venues/:id                                         │
  /venues/:id/slots                                   │
  /venues/:id/booking-summary                         │
/scoring ────────────────────────────────────── tab 2 │
/games ──────────────────────────────────────── tab 3 │
  /games/:id                                          │
/profile ────────────────────────────────────── tab 4 │
/coaches  (no tab, reached from Home)                 │
  /coaches/:id ─────────────────────────────────────-─┘
```

---

## 3. Screen Specifications

---

### 3.1 Onboarding Screen  `/`

**Layout:** Full-screen carousel. Top ~55% = scrollable image area. Bottom = fixed controls.

**Header row (top-right)**
- "Skip" text button — `teal500`, underline, `bodyMD` semibold

**Slide content (3 slides, left-to-right swipe)**

Each slide:
- Large rounded-corner image (24 dp radius) fills the top area — grey placeholder when no asset
- 32 dp gap below image
- Title — `headingLG`, left-aligned, 2 lines max
- 12 dp gap
- Body — `bodyMD`, `neutral600`, left-aligned

| Slide | Title | Body |
|---|---|---|
| 1 | Book & Join Sports Venues Instantly | Find and book arenas, join tournaments, and connect with players in your area |
| 2 | Train with coaches who know the game | Book trusted coaches across sports with flexible sessions and fair pricing. |
| 3 | Surround yourself with competition | Match with players at your level or higher to improve your game. |

**Bottom controls**
- Animated pill indicators — active: 24 × 8 dp `teal500` pill; inactive: 8 × 8 dp `neutral300` circle; 4 dp gap between
- 24 dp gap
- Primary button — "Next" on slides 1–2; "Get Started" on slide 3
- 40 dp bottom padding

**States:** Page index drives indicator width animation (250 ms ease).

---

### 3.2 Login Screen  `/auth/login`

**Layout:** Two-zone stack.
- **Zone A (top):** `neutral50` background. Image fills zone with 24 dp padding all sides, 24 dp radius clip. Shrinks naturally when keyboard appears.
- **Zone B (bottom sheet):** `surface` white, `BorderRadius.vertical(top: 24)`. Contains the form.

**Bottom sheet contents (top to bottom)**
1. Drag handle — 40 × 4 dp, `neutral300`, radius 2, centred, 12 dp vertical margin
2. 8 dp gap
3. Title — "Welcome!" — `headingLG`
4. 4 dp gap
5. Subtitle — "Let's get you started" — `bodyLG`, `neutral600`
6. 24 dp gap
7. Field label — "Mobile number" — `label`
8. 8 dp gap
9. Phone text field — `+91` prefix (inline text, not an icon), 10-digit max, numeric keyboard
10. 24 dp gap
11. **Primary button** — "Get OTP" → validates phone → sends OTP → navigate to `/auth/otp`
12. 20 dp gap
13. `or` divider — full-width `Divider` with "or" centred in `neutral500` caption text
14. 20 dp gap
15. **Outlined button** — "Sign Up" → navigate to `/auth/create-account`
16. 40 dp bottom padding

**States:**
- Button shows `CircularProgressIndicator` (20 dp) while loading
- Error: red `SnackBar` — "Failed to send OTP. Please try again."

---

### 3.3 OTP Screen  `/auth/otp`

**Layout:** Standard scaffold, `surface` background. AppBar (back button, `surface` background).

**Content (24 dp horizontal padding)**
- 16 dp top gap
- Title — "Enter OTP" — `headingLG`
- 8 dp gap
- Subtitle — "Sent to **+91XXXXXX12**" — `bodyMD`, `neutral600`; phone number is bold `neutral900`
- 40 dp gap
- **6-digit OTP input row** — 6 equal boxes, `spaceBetween`
  - Each box: 48 × 56 dp, 12 dp radius border
  - Inactive border: `neutral300`; focused border: `brandGreen400` 2 dp; error border: `red500`
  - Single digit, numeric keyboard, auto-advance focus on input, auto-retreat on delete
  - Auto-submits when all 6 filled
- 16 dp gap
- **Error message** — "Entered OTP is incorrect" — `bodyMD`, `red500` (shown on failed attempt)
- **Success message** — ✓ icon (`teal500`) + "You're in. Let's play." — `bodyMD`, `teal500`, semibold
- **Lockout message** — "Too many attempts. Please wait 15 minutes." — `bodyMD`, `red500`
- 24 dp gap
- **Resend row** — "Haven't received? " + either:
  - Countdown: "Retry in 0:45" — `neutral500`
  - Active link: "Resend OTP" — `brandGreen400`, semibold (tappable after 60 s)
- Spacer
- Centered `CircularProgressIndicator` while verifying

**States:** 3 failed attempts triggers lockout (hides resend row).

---

### 3.4 Create Account Screen  `/auth/create-account`

**Layout:** Same two-zone stack as Login Screen (hero image top + bottom sheet form).

**Bottom sheet contents**
1. Drag handle (same as login)
2. 8 dp gap
3. Title — "Create Account" — `headingLG`
4. 24 dp gap
5. **Name** field label + input (hint: "eg: John Doe", title-case keyboard)
6. 16 dp gap
7. **Mobile Number** field label + read-only input (pre-filled, `+91` prefix, `neutral100` fill)
8. 16 dp gap
9. **E-mail (Optional)** field label + input (hint: "eg: john@example.com", email keyboard)
10. 16 dp gap
11. **Referral Code** field label + input (hint: "eg: FIELD123", all-caps keyboard)
12. 20 dp gap
13. **Consent row 1** — checkbox (`teal500` active) + RichText: "I agree to the **Terms of Service** and **Privacy Policy**" — linked words in `teal500` + underline, tappable
14. 12 dp gap
15. **Consent row 2** — checkbox + "I agree to receive emails and notifications related to my account"
16. 32 dp gap
17. **Primary button** — "Get OTP" → validate → `createProfile()` → navigate to `/auth/interests`
18. 40 dp bottom padding

**States:** Terms checkbox must be ticked or a `SnackBar` appears. Loading spinner in button.

---

### 3.5 Interests Screen  `/auth/interests`

**Layout:** Standard scaffold, `neutral50` background. No AppBar.

**Content (24 dp padding)**
- 16 dp top gap
- **FieldUp logo** — `Image.asset` 32 dp height (fallback: "FieldUp" text in `brandGreen600` bold)
- 32 dp gap
- Title — "Interests" — `headingLG`
- 20 dp gap
- **Search field** — search icon prefix, hint "Search", live-filters the list below
- 16 dp gap
- **Sports checklist** — `ListView`, each row:
  - `InkWell` tap target, 4 dp vertical padding
  - `Checkbox` (4 dp radius, `teal500` active, `shrinkWrap`) + 8 dp gap + sport name (`bodyLG`)
  - Sports: Basketball · Box Cricket · Badminton · Cricket · Football · Shooting · Boxing · Tennis · Volleyball · Swimming · Kabaddi · Table Tennis
- 16 dp gap
- **Bottom button row** — two equal buttons side by side, 12 dp gap:
  - Left — **Outlined button** "Skip" → navigate to `/home`
  - Right — **Dark filled button** "Confirm" (`neutral900` bg, white text) → `saveInterests()` → navigate to `/home`; if nothing selected, behaves like Skip
- 32 dp bottom padding

**States:** Search filters list in real time. Loading spinner inside Confirm while saving.

---

### 3.6 Home Screen  `/home`

**Layout:** `CustomScrollView` with `SliverAppBar` + `SliverToBoxAdapter`.

#### AppBar (floating, snap, teal `#2D6A6A`)
- **Left:** `CircleAvatar` (36 dp, `teal400` fill, person icon) + 10 dp gap + column:
  - Username — white `label` semibold
  - Row: location pin icon (white70, 12 dp) + location name (white70 `caption`) + `expand_more` chevron (white70, 14 dp)
- **Right:** notification bell icon (white) + circular avatar (36 dp, `neutral300` fill, person icon)

#### Scrollable body (16 dp horizontal padding)

**1 — Search bar** (48 dp, 12 dp radius, `surface` fill, `neutral200` border)
- Search icon (`neutral500`) + "Search" hint text (`neutral500 bodyMD`)
- Tappable (no active input on home)

**2 — Ad banner** (120 dp height, 16 dp radius)
- Full-width image clip; fallback: teal gradient (`#1E6B5E` → `#2D6A6A`) + centred `campaign_outlined` icon (36 dp, white54)

**3 — Feature grid** (2 × 2, 12 dp gaps, `childAspectRatio: 1.6`)

Each card: 16 dp radius, solid colour fill, 14 dp padding, text at bottom-left:
- Title — white bold `label`
- Subtitle — white70 `caption` (1 line, ellipsis)
- Tap navigates to respective screen

| Card | Colour | Title | Subtitle | Route |
|---|---|---|---|---|
| Join Games | `#1A5C50` | Join Games | Find & join games near you | `/games` |
| Trainers | `#1B3E6B` | Trainers | Book certified coaches | `/coaches` |
| Venues | `#3D1A6B` | Venues | Explore nearby arenas | `/venues` |
| Scoring | `#6B1A1A` | Scoring | Track live game scores | `/scoring` |

**4 — Games Near you section**
- Section header → `/games`
- Horizontal scroll list (108 dp height, 12 dp card gap), each card 280 dp wide:
  - Top row: "TIME  •  DATE" bold `label` (left) + level badge (right) — `teal50` bg, `teal600` text, 6 dp radius
  - Middle row: pin icon + venue name `caption neutral600` (ellipsis)
  - Bottom row: people icon + "X/Y participants" `caption neutral600` + Spacer + distance `caption neutral600`

**5 — Venues Near you section**
- Section header → `/venues`
- Horizontal scroll list (200 dp height, 12 dp gap), each card 220 dp wide:
  - Top: 110 dp image area (`teal600` placeholder), Verified badge overlay top-right (`teal500` bg, white text + verified icon, 6 dp radius)
  - Bottom 90 dp: name + distance (right) / sports tags / location row

**6 — Certified Trainers near you section**
- Section header → `/coaches`
- Horizontal scroll list (180 dp height, 12 dp gap), each card 160 dp wide:
  - Top: 100 dp image (`neutral300` placeholder, person icon centred)
  - Bottom: name bold `label` / specialty `caption neutral600` 2 lines / location row (pin + `caption neutral500` 1 line)

**7 — Join Groups section**
- Section header (no-op see all)
- 2 equal cards side by side, 12 dp gap, 110 dp height, 16 dp radius
- Each: dark green gradient bg (`#2A5F48` → `#1A3D30`) + gradient overlay (transparent → black54 top-to-bottom) + text pinned bottom-left:
  - Group name — white bold `label`
  - Member count — white70 `caption`

---

### 3.7 Venues Screen  `/venues`

**Layout:** Standard scaffold. AppBar shows location selector right side ("Phase 5, JP Nagar ▼").

**Content**
1. **Search field** — 48 dp, hint "Search"
2. 12 dp gap
3. **Filter chips row** (horizontal scroll, no clip):
   - "Filter" chip with `tune` icon, outlined style
   - Sport chips: Football · Cricket · Badminton · Basketball · Tennis
   - Active chip: `brandGreen100` fill + `brandGreen400` 2 dp border
4. 16 dp gap
5. **Venue list** (vertical, 12 dp gap between cards)

Each venue card (`surface`, 16 dp radius, `neutral200` border):
- Image area (130 dp, `teal600` placeholder), `BorderRadius.vertical(top: 16)`
  - **Verified badge** top-right if verified: `teal500` bg + `verified` icon + "Verified" white caption
  - **Photo count indicator** bottom-right: dark pill "● ●●●●" dots
- Info section (12 dp padding):
  - Row: venue name bold `label` (flex) + distance `caption neutral600`
  - Sports tags: `caption neutral600`
  - Location row: pin icon + address `caption neutral500`

---

### 3.8 Venue Detail Screen  `/venues/:venueId`

**Layout:** `CustomScrollView` with `SliverAppBar` (expandedHeight 260 dp).

#### Expanded header
- Full-width sports image (`teal600` placeholder)
- Bottom: dot indicators (photo count)
- Top-left: circular back button (white, 36 dp, slight shadow)
- Top-right: circular share button (white, 36 dp)
- Top-right: **Verified badge** — `teal500` pill, white text + icon

#### Sticky collapsed AppBar
- Venue name as title, same back + share actions

#### Body sections (16 dp horizontal padding, cards separated by 16 dp)

**Venue info**
- Name — `headingLG`
- Hours row: clock icon + "5:00 AM - 12:00 AM" `bodyMD neutral600`
- Location row: pin icon + address `bodyMD neutral600`
- Stats row: ⭐ 4.5 · 321 reviews · 245 Total Games — `caption neutral600`

**Action buttons row** (equal width, 12 dp gap)
- Outlined button "Show on Maps"
- Outlined button "Rate Venue"

**Sports Available card** (`surface`, 16 dp radius, `neutral200` border)
- Title "SPORTS AVAILABLE" bold `label`
- Subtitle "Click on your sport to view pricing" `caption neutral600`
- Wrap of sport chips (tappable → `/venues/:id/slots`): Cricket · Badminton · Basketball · Football

**Amenities card**
- Title "AMENITIES" bold `label`
- Subtitle "Facilities available for a comfortable playing experience."
- Bullet list `bodyMD`: Floodlights · Changing rooms · Parking · Drinking water · First aid · Cafeteria

**Primary CTA button** — "CREATE GAME" (`brandGreen400`)

**Nearby game card** (`surface`, 16 dp radius, `neutral200` border)
- Game title + date bold
- Location `caption neutral600`
- Distance + level badge row
- Tappable → `/games/:id`

**About Venue section**
- "ABOUT VENUE" bold `label`
- Description `bodyMD neutral700`

#### Sticky bottom bar
- Full-width **primary button** "BOOK COURT" → `/venues/:id/slots`

---

### 3.9 Slot Picker Screen  `/venues/:venueId/slots`

**AppBar:** "Choose Slot" with back button.

**Content (16 dp padding)**

**Venue title row**
- Venue name — `headingMD`
- "Earn 5 points every booking" — `caption teal500`

**Date picker card** (`surface`, 16 dp radius, `neutral200` border, 16 dp padding)
- Month header "January" + expand icon (top row)
- Horizontal scroll of 10 day columns (each ~52 dp wide):
  - Day abbrev — `caption neutral600`
  - Day number — `label` bold
  - Selected: `brandGreen400` circular background, dark text
  - Today: `teal500` border circle

**Duration card** (`surface`, 16 dp radius, `neutral200` border)
- "Duration" label
- Row: `—` icon button (left, `teal500`) + "60 min" centred bold `bodyLG` + `+` icon button (right, `teal500`)
- Range 30–180 min in 30 min steps

**Slot time card**
- "Slot" label
- Time markers row: 8:00 am → 2:00 pm (7 labels evenly spaced)
- Custom `Slider` with red-to-green gradient track + thumb showing selected time
- Duration pill below thumb: "60 mins"

**Court grid** (2 columns, 12 dp gap)
- "Court" label above
- Each court tile (`surface`, 16 dp radius, `neutral200` border, 16 dp padding):
  - Sport field icon (48 dp, `neutral400`)
  - Court name bold `label` centred
  - Price "INR XXX" `caption neutral600` centred
  - Selected state: `brandGreen100` bg + `brandGreen400` 2 dp border

**Unavailable Slots section**
- "Unavailable Slots" label
- Same tile grid but greyed out (50% opacity)
- **Outlined button** "Notify Me" below

**Similar Venues Near you**
- Single venue summary card with name, sports, distance, location

#### Sticky bottom bar
- **Primary button** "PROCEED TO PAY" (disabled/grey when no court selected)

---

### 3.10 Booking Summary Screen  `/venues/:venueId/booking-summary`

**AppBar:** "Booking Summary" with back button.

**Content (16 dp padding)**

**Venue card** (`surface`, 16 dp radius, `neutral200` border)
- Venue name bold + location `caption`

**Booking Details card** (16 dp padding, 16 dp radius)
- Title "BOOKING DETAILS" bold `label`
- Rows: Date / Time / Duration / Court / Sport — each as label + value pair

**Price Breakdown card**
- "PRICE BREAKDOWN" bold `label`
- Line items: Court fee + Platform fee + GST (18%)
- `Divider`
- Total row — **bold, larger** — `headingMD` with `brandGreen400` highlight or neutral900

#### Sticky bottom bar
- **Primary button** "PAY ₹XXX" — triggers Razorpay payment

---

### 3.11 Coaches Screen  `/coaches`

**AppBar:** "Coaches" + location selector right.

**Content**

**Registration banner** (`brandGreen400` background, 16 dp radius, 16 dp padding)
- "Are you a coach or trainer?" — bold `label` dark text
- "Register with us and grow your business" — `caption` dark text
- "+ Register with Us" — dark outlined small button (right-aligned)

**Filter chips row** (horizontal scroll)
- Filter icon chip + categories: Yoga · Dance · Workout · Dietician · Cricket · Football

**Coach grid** (2 columns, 12 dp gaps)

Each coach card (`surface`, 16 dp radius, `neutral200` border):
- Photo area (130 dp, `neutral300` placeholder, person icon)
  - "Trainer" badge — top-left pill, `teal500` bg, white caption
- Info (10 dp padding):
  - Name — bold `label`
  - Sport tags — `caption neutral600` (category + specialty keyword)
  - Location row — pin icon + address `caption neutral500` (1 line, ellipsis)

---

### 3.12 Coach Detail Screen  `/coaches/:coachId`

**Layout:** `CustomScrollView` with `SliverAppBar` (expandedHeight 280 dp).

#### Expanded header
- Large portrait photo (`neutral800` / dark brown placeholder)
- Dot indicators bottom
- Top-left: circular back button
- Top-right: favourite (♡) + share icons (circular white buttons)
- **Verified badge** top-right corner

#### Collapsed AppBar: coach name

#### Body (16 dp padding, 16 dp gap between sections)

**Identity card**
- Name — `headingLG`
- Subtitle — `bodyMD neutral600` — e.g. "Certified Cricket Coach | 10+ Years | Batting & Strategy"

**Sessions card** (`surface`, 16 dp radius, `neutral200` border, 16 dp padding)
- Calendar icon + days: "Monday – Sunday"
- Person icon + group: "Adult"
- Pin icon + full location address

**Expandable sections** (each with top divider, chevron toggle):

1. **About** — long bio `bodyMD neutral700`; pull quote in italic
2. **Testimonials** — quoted card with attribution `caption neutral500`
3. **Training Formats Offered** — bulleted list `bodyMD`
4. **Coaching Focus** — bulleted list `bodyMD`
5. **Experience & Background** — bulleted list `bodyMD`

#### Sticky bottom section
- **Primary button** "BOOK"
- Pricing lines: "• Bowling Training ~ ₹X/hour", etc. — `bodyMD neutral700`
- Footnote `caption neutral500`

---

### 3.13 Games Screen  `/games`

**AppBar:** "Games" + location selector right.

**Content**

**Create New Game card** (dashed `neutral300` border, 16 dp radius, 16 dp padding, centred)
- "+ Create New Game" — `teal500` semibold `bodyMD`
- Tap → opens **Add Players bottom sheet**

**Filter chips row** (horizontal scroll) — Filter icon + Football · Cricket · Badminton · Basketball · Tennis

**Games list** (vertical, 12 dp gap)

Each game card (`surface`, 16 dp radius, `neutral200` border, 16 dp padding):
- **Top row:**
  - Stacked avatars (up to 3 overlapping circles, 28 dp each, `neutral300` bg)
  - Status badge — "X going" (`teal50` bg, `teal600` text) OR "Sold out" (`red50` bg, `red500` text)
  - Distance `caption neutral600` right
- **Title** — game name bold `label`
- **Time** — `bodyMD neutral700`
- **Location row** — pin icon + venue name `caption neutral600`
- **Bottom row** — price per person `caption teal600` semibold (left) + level badge (`teal50` bg, `teal600` text) right

---

### 3.14 Add Players Bottom Sheet

**Triggered from:** Create New Game card on Games screen.

**Sheet header:** "ADD PLAYERS" bold centred + ✕ close button (top-right)

**Tab bar** (2 tabs, `teal500` indicator)
- Tab 1: "Add player"
- Tab 2: "My Playpals"

**Tab 1 — Add Player**
- Name input field (hint "Player Name")
- WhatsApp Number input (hint "Mobile Number")
- Helper text: "FieldUp will send an invitation link on this number" — `caption neutral500`
- "Select Skill level" label
- Skill level chips row (single-select): Rookie · Contender · Playmaker · Competitive · Elite
  - Active: `brandGreen100` + `brandGreen400` border
- "Or" divider
- "Copy Invite link:" label
- Read-only text field showing "fieldup.co.in/players/add" + copy icon button
- "Scan the QR Code to Onboard Players:" label
- QR code image (placeholder 160 × 160 dp, `neutral200` bg)
- **Primary button** "SELECT" (disabled until name + number filled)

**Tab 2 — My Playpals**
- Empty state: "No playpals yet" `bodyMD neutral500` centred

---

### 3.15 Game Detail Screen  `/games/:gameId`

**AppBar:** Game name + share icon button.

**Content (16 dp padding)**

**Meta info card** (`surface`, 16 dp radius, `neutral200` border, 16 dp padding)
- Clock icon + "TIME – TIME • DATE"
- Globe icon + "Public • ₹XX / player"
- Pin icon + venue name + map icon button (right)

**Skill Level card**
- "SKILL LEVEL" label bold
- "Game Skill:" label + teal pill badge e.g. "Intermediate – Professional"

**Instructions card**
- "INSTRUCTIONS" label bold
- Icon rows: 🎒 BYOE · 💸 Cost Shared
- "Others" section — bulleted details (UPI, court pricing, cancellation policy)

**Players card** (with "SEE ALL ›" right link)
- "PLAYERS" label bold
- Player rows (each): circular avatar + name + skill badge (pill) + role badge if Host/Co-host
- Truncated to 4–5 rows, "SEE ALL" link below

**Locker-Room card** (`neutral900` border, 16 dp radius)
- Description `bodyMD neutral600`
- **Outlined button** "ASK DOUBT" (`brandGreen400` border + text)

**Trainers card**
- "TRAINERS" label bold + subtitle
- 2 × 2 trainer mini-grid (same trainer card style as Home)

#### Sticky bottom bar
- **Primary button** "JOIN GAME · ₹XX / person"

---

### 3.16 Scoring Screen  `/scoring`

**3-step flow** managed by an `IndexedStack` (no page transition between steps).

---

#### Step 0 — Select Sport

**AppBar:** Back button (goes to previous route), no title on this step

**Content (24 dp padding)**
- Title "Select Sport" — `headingLG`
- Subtitle "Choose the sport you want to score" — `bodyMD neutral600`
- 24 dp gap
- **Sport grid** (2 columns, 12 dp gaps, `childAspectRatio: 1.2`):
  - Badminton · Cricket · Football · Basketball · Tennis · Volleyball
  - Each tile (`surface`, 16 dp radius, `neutral200` border, 16 dp padding):
    - Sport icon (32 dp, `neutral500`) centred top
    - Sport name bold `label` centred bottom
  - Selected state: `brandGreen100` bg + `brandGreen400` 2 dp border + `brandGreen700` text

---

#### Step 1 — Create Teams (Assign Players)

**AppBar:** Selected sport name as title + back (step--)

**Content (16 dp padding)**

Section header: "CREATE TEAM" bold + chevron-up collapse icon (right)

**Team 1 block**
- "Team 1" label `bodyMD neutral600`
- Team Name text field (hint "Team Name")
- Player list (shown after players added): each row = circular photo (36 dp) + name + skill level `caption teal500` + checkbox (right)
- **Outlined button** "ADD PLAYERS" or "EDIT PLAYERS" (after players added)

16 dp gap

**Team 2 block** (identical structure)

#### Sticky bottom bar
- **Outlined button** "VIEW RULES" (left, 50% width)
- **Primary button** "START GAME" (right, 50% width) — disabled `neutral200` until both teams have ≥1 player each; active `brandGreen400` when ready

---

#### Step 2 — Live Scoring

**AppBar:** "Match 1" + back (shows confirm dialog before resetting)

**Full-screen split layout:**

- **Team 1 header bar** — lime green (`brandGreen400`) full-width pill at top, "Team 1" bold centred
- **Top half (Team 1 scoring zone)** — 2 columns of green (`teal200` / `brandGreen100`) cells; each empty cell shows "+ Assign Player" tappable card
- Thin white divider line
- **Bottom half (Team 2 scoring zone)** — mirrored layout
- **Team 2 header bar** — lime green full-width pill at bottom, "Team 2" bold centred

**Live score overlay** (centred over the divider, shown during active match):
- Team 1 score — `headingXL` (48 sp) bold + `—` / `+` circular buttons (48 dp, `neutral900` bg, white icon)
- "VS" label centred
- Team 2 score — same layout

#### Sticky bottom bar (during live scoring)
- **Dark button** "END MATCH" (`neutral900` fill, white text, full width)

---

### 3.17 Profile Screen  `/profile`

**AppBar:** "Profile" title + settings icon (right).

**Content (16 dp padding)**

**Profile header row** (no card)
- Large `CircleAvatar` (72 dp, `neutral300` bg, person icon)
  - Edit overlay: pencil icon chip bottom-right (24 dp, `surface` bg, 12 dp radius)
- Right column:
  - Name — `headingMD`
  - Primary Sport — `bodyMD neutral600`
  - "Member Since | Last played" — `caption neutral500`
- Edit text button (top-right, `teal500`)

**Karma Points card** (`surface`, 16 dp radius, `neutral200` border, 12 dp padding)
- Bolt icon (`orange500`) + "Karma Points" label + score badge right

**Stats row** — 3 equal cards (side by side, 8 dp gaps):
- Games Played / Hours Played / Skill Level Overall
- Each: bold large number centred + label `caption neutral600` below

**Sport preferences row** — horizontal wrap of sport chips (`neutral100` bg, `neutral300` border, 20 dp radius)

**Stats detail card** (`surface`, 16 dp radius, `neutral200` border)
- Label-value rows: Games Played · Streak · Hours Played · Skill Level · Last Rating

**Leaderboard card**
- Title "Leaderboard" bold `label`
- Empty state: "Play more games to appear on the leaderboard!" `bodyMD neutral500` centred

**Groups & Communities card**
- Title "Groups & Communities" bold `label`
- Empty state: "Join groups to connect with players near you" `bodyMD neutral500` centred

**Sign Out button** (full width, red text `red500` + logout icon, no border/fill)

---

## 4. Empty & Error States

| Context | Empty state | Error state |
|---|---|---|
| Lists (venues, coaches, games) | Centred icon + "Nothing here yet" `bodyMD neutral500` | Red `SnackBar` with message |
| Profile stats | Show "0" or "--" placeholder values | — |
| Leaderboard | Motivational message | — |
| Groups | Encouraging message | — |
| My Playpals | "No playpals yet" | — |
| Image areas | Solid-colour placeholder (teal or neutral) | Same placeholder |
| OTP | Per-box red border + error message below | Lockout message after 3 attempts |
| Form fields | Grey hint text | Red helper text below field |

---

## 5. Bottom Navigation Bar

5 tabs, fixed, `surface` background, `neutral200` top border.

| Index | Label | Icon (inactive) | Icon (active) | Route |
|---|---|---|---|---|
| 0 | Home | `home_outlined` | `home` | `/home` |
| 1 | Venues | `location_on_outlined` | `location_on` | `/venues` |
| 2 | Scoring | `sports_outlined` | `sports` | `/scoring` |
| 3 | Games | `people_outline` | `people` | `/games` |
| 4 | Profile | `account_circle_outlined` | `account_circle` | `/profile` |

Active tab colour: `brandGreen400`. Inactive: `neutral500`. Label font: `caption`.

---

## 6. Key Interaction Patterns

- **Horizontal scroll sections** on Home — swipe left/right to see more cards; no pagination dots needed
- **Image error fallback** — always a solid colour (`teal600` for venue/group, `neutral300` for people), never broken-image icon
- **Bottom sheet drag handle** — 40 × 4 dp `neutral300` pill, centred, 12 dp top margin; sheet is non-draggable (static positioned)
- **Keyboard avoidance** — hero image zone uses `Flexible` and shrinks; form scrolls inside `SingleChildScrollView`
- **Animated tab indicator** — OTP boxes auto-focus; scoring step transitions use `IndexedStack` (no slide animation)
- **Verified badge** — small pill, `teal500` bg, `verified` icon + "Verified" white caption; always positioned top-right of image area with 8 dp inset
- **Level badges** — pill shape, `teal50` bg, `teal600` semibold caption text; e.g. "Med-Adv", "Beginner", "Advanced"
- **Distance display** — always `caption neutral600`, right-aligned in its row, format "X.X km"
- **Price display** — Indian Rupee symbol ₹, no decimal for whole numbers
