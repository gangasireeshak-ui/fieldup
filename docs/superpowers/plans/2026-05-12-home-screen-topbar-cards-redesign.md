# Home Screen: Top Bar & Card Size Redesign — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update `home_screen.dart` to use a Logo-First top bar (FieldUp centred, user left, notification right, context sub-strip below) and cinematic-proportioned horizontal scroll cards for Games, Venues, and Trainers.

**Architecture:** All changes are confined to a single file — `apps/user_app/lib/features/home/presentation/home_screen.dart`. No new files, no data model changes, no routing changes. The existing widget structure (`_AppBar`, `_GameCard`, `_VenueCard`, `_TrainerCard`, and their row wrappers) is updated in place.

**Tech Stack:** Flutter 3.32, Dart 3.8, `dart:ui` (BackdropFilter), `AppColors` / `AppTextStyles` from `fieldup_design_system`

---

## File Map

| Action | File |
|---|---|
| Modify | `apps/user_app/lib/features/home/presentation/home_screen.dart` |
| Test | `apps/user_app/test/features/home/home_screen_test.dart` |

---

## Task 1: Update `appBarH` constant and `_AppBar` to Logo-First layout

**Files:**
- Modify: `apps/user_app/lib/features/home/presentation/home_screen.dart` — `HomeScreen.build` and `_AppBar`

The current `_AppBar` has one `Column` with a greeting row + location row. Replace it with two distinct sections: an identity row (avatar + name left, logo centre, notification right) and a context strip (location left, live count right). Update the `appBarH` constant so the `CustomScrollView` spacer gives the new bar enough clearance.

- [ ] **Step 1: Write the failing widget test**

Create `apps/user_app/test/features/home/home_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fieldup_user_app/features/home/presentation/home_screen.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(home: child),
    );

void main() {
  group('HomeScreen top bar', () {
    testWidgets('renders FieldUp logo text', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(find.text('FieldUp'), findsOneWidget);
    });

    testWidgets('renders user name in identity row', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(find.text('Pravir S.'), findsOneWidget);
    });

    testWidgets('renders location in context strip', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(find.text('JP Nagar, Bangalore'), findsOneWidget);
    });

    testWidgets('renders live player count', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(find.text('142 players active'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to confirm it fails**

```bash
cd apps/user_app && flutter test test/features/home/home_screen_test.dart -v
```

Expected: compile error or test failures (the widget structure doesn't match yet).

- [ ] **Step 3: Update `appBarH` constant in `HomeScreen.build`**

In `home_screen.dart`, find:
```dart
const appBarH = 72.0;
```
Replace with:
```dart
const appBarH = 88.0;
```

Also update the spacer sliver at the top of the `CustomScrollView`:
```dart
SliverToBoxAdapter(child: SizedBox(height: topInset + appBarH + 12)),
```
This line already uses `appBarH` dynamically so no further change is needed there.

- [ ] **Step 4: Replace the `_AppBar.build` method**

Locate the entire `_AppBar` class (starts at `class _AppBar extends StatelessWidget`) and replace its `build` method body with the Logo-First layout:

```dart
@override
Widget build(BuildContext context) {
  return ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.9),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Row 1: Identity ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20, topInset + 12, 20, 12),
              child: Row(
                children: [
                  // Avatar with online dot
                  Stack(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.brandGreen400.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            _kAvatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFF37485B),
                              child: const Icon(Icons.person,
                                  color: AppColors.neutral700, size: 18),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 1,
                        right: 1,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.teal500,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.background, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Pravir S.',
                    style: _label(
                        size: 14,
                        color: AppColors.neutral900,
                        weight: FontWeight.w600),
                  ),
                  const Spacer(),
                  // FieldUp logo — centred via two Spacers
                  const Text(
                    'FieldUp',
                    style: TextStyle(
                      fontFamily: 'Barlow Condensed',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: AppColors.brandGreen400,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  // Notification bell
                  Stack(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF201F1F).withValues(alpha: 0.8),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: const Icon(Icons.notifications_outlined,
                            color: AppColors.neutral700, size: 20),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.brandGreen400,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ── Row 2: Context strip ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 7, 20, 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
                  bottom:
                      BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on,
                      color: AppColors.brandGreen400, size: 13),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'JP Nagar, Bangalore',
                      style: _label(
                          size: 11,
                          color: AppColors.neutral700,
                          weight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.expand_more,
                      color: AppColors.neutral700, size: 13),
                  const Spacer(),
                  _PulseDot(),
                  const SizedBox(width: 6),
                  Text(
                    '142 players active',
                    style: _label(
                        size: 11,
                        color: AppColors.brandGreen400,
                        weight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
```

- [ ] **Step 5: Run tests**

```bash
cd apps/user_app && flutter test test/features/home/home_screen_test.dart -v
```

Expected: all 4 top bar tests pass.

- [ ] **Step 6: Visual check in Chrome**

The running Flutter app should hot-reload. Confirm:
- "FieldUp" italic lime text is centred in the bar
- Avatar + "Pravir S." appear on the left
- Notification bell on the right
- Below: location pill left, "142 players active" right

- [ ] **Step 7: Commit**

```bash
git add apps/user_app/lib/features/home/presentation/home_screen.dart \
        apps/user_app/test/features/home/home_screen_test.dart
git commit -m "feat(home): logo-first top bar layout"
```

---

## Task 2: Update `_GameCard` and `_GamesRow` to Cinematic proportions

**Files:**
- Modify: `apps/user_app/lib/features/home/presentation/home_screen.dart` — `_GameCard`, `_GamesRow`

Replace the full-stack overlay card with a two-section layout: a 170px image area on top, then a separate body container below with title, time, venue, and a footer row (avatar stack + action button).

- [ ] **Step 1: Add game card widget tests**

Append to `apps/user_app/test/features/home/home_screen_test.dart`:

```dart
  group('_GamesRow card', () {
    testWidgets('renders game title Downtown 5v5', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(find.text('Downtown 5v5'), findsOneWidget);
    });

    testWidgets('renders game time', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(find.text('Tonight, 8 PM'), findsOneWidget);
    });
  });
```

- [ ] **Step 2: Run to confirm tests currently pass (they should — title/time already exist)**

```bash
cd apps/user_app && flutter test test/features/home/home_screen_test.dart -v
```

Expected: all tests pass. These act as regression guards.

- [ ] **Step 3: Update `_GamesRow` — change `SizedBox` height and card width**

Find:
```dart
class _GamesRow extends StatelessWidget {
  const _GamesRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 185,
```

Replace with:
```dart
class _GamesRow extends StatelessWidget {
  const _GamesRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
```

- [ ] **Step 4: Replace `_GameCard.build` with Cinematic layout**

Find the entire `Widget build(BuildContext context)` method inside `_GameCard` and replace it:

```dart
@override
Widget build(BuildContext context) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: SizedBox(
      width: 270,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image area (170px) ─────────────────────────────────────
          SizedBox(
            height: 170,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl != null)
                  Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    color: Colors.black.withValues(alpha: 0.45),
                    colorBlendMode: BlendMode.darken,
                    errorBuilder: (_, __, ___) => _colorBg(),
                  )
                else
                  _colorBg(),
                // Bottom-up gradient so body seams cleanly
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.background.withValues(alpha: 0.6),
                      ],
                      stops: const [0.45, 1.0],
                    ),
                  ),
                ),
                // Price badge — top right
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: priceHighlight
                          ? AppColors.brandGreen400
                          : const Color(0xFF201F1F).withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(999),
                      border: priceHighlight
                          ? null
                          : Border.all(
                              color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      price,
                      style: _label(
                        size: 11,
                        color: priceHighlight
                            ? AppColors.brandGreen700
                            : AppColors.neutral900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Body ──────────────────────────────────────────────────
          Container(
            color: const Color(0xFF201F1F),
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Barlow Condensed',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.schedule,
                        color: AppColors.brandGreen400, size: 13),
                    const SizedBox(width: 4),
                    Text(time,
                        style: _label(size: 12, color: AppColors.brandGreen400)),
                    const Spacer(),
                    _TagPill(label: tag, red: tagRed),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: AppColors.neutral700, size: 12),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        '$venue · $distance',
                        style: _label(
                            size: 11,
                            color: AppColors.neutral700,
                            weight: FontWeight.w400),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(
                    color: Colors.white.withValues(alpha: 0.07), height: 1),
                const SizedBox(height: 10),
                // Footer: avatar stack + action button
                Row(
                  children: [
                    // Three placeholder avatars
                    SizedBox(
                      width: 56,
                      height: 22,
                      child: Stack(
                        children: List.generate(
                          3,
                          (i) => Positioned(
                            left: i * 14.0,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF37485B),
                                border: Border.all(
                                    color: const Color(0xFF201F1F), width: 2),
                              ),
                              child: const Icon(Icons.person,
                                  size: 12, color: AppColors.neutral700),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+5 playing',
                      style: _label(
                          size: 10,
                          color: AppColors.neutral700,
                          weight: FontWeight.w400),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: priceHighlight
                            ? AppColors.brandGreen400
                            : const Color(0xFF2D3E50).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: priceHighlight
                            ? [
                                BoxShadow(
                                  color: AppColors.brandGreen400
                                      .withValues(alpha: 0.3),
                                  blurRadius: 10,
                                ),
                              ]
                            : null,
                        border: priceHighlight
                            ? null
                            : Border.all(
                                color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Text(
                        priceHighlight ? 'Join →' : 'View →',
                        style: _label(
                          size: 11,
                          color: priceHighlight
                              ? AppColors.brandGreen700
                              : AppColors.neutral900,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 5: Run tests**

```bash
cd apps/user_app && flutter test test/features/home/home_screen_test.dart -v
```

Expected: all tests still pass.

- [ ] **Step 6: Visual check in Chrome**

Confirm games row cards are wider and taller, image area is clearly separate from the white body, footer row shows avatar circles + action button.

- [ ] **Step 7: Commit**

```bash
git add apps/user_app/lib/features/home/presentation/home_screen.dart \
        apps/user_app/test/features/home/home_screen_test.dart
git commit -m "feat(home): cinematic game cards"
```

---

## Task 3: Update `_VenueCard` and `_VenuesRow` to Cinematic proportions

**Files:**
- Modify: `apps/user_app/lib/features/home/presentation/home_screen.dart` — `_VenueCard`, `_VenuesRow`

Increase image height from 110px to 155px, card width from 210px to 250px, row height from 236px to 250px. Add a footer row (star rating left, Book button right) to the existing body section.

- [ ] **Step 1: Add venue card widget tests**

Append to `apps/user_app/test/features/home/home_screen_test.dart`:

```dart
  group('_VenuesRow card', () {
    testWidgets('renders venue name', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(find.text('Feather Touch Arena'), findsOneWidget);
    });

    testWidgets('renders Book button for venue', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(find.text('Book →'), findsWidgets);
    });
  });
```

- [ ] **Step 2: Run tests — `Book →` finder will fail since it doesn't exist yet**

```bash
cd apps/user_app && flutter test test/features/home/home_screen_test.dart -v
```

Expected: `renders Book button for venue` fails with "zero widgets found".

- [ ] **Step 3: Update `_VenuesRow` height**

Find:
```dart
    return SizedBox(
      height: 236,
```
Replace with:
```dart
    return SizedBox(
      height: 250,
```

- [ ] **Step 4: Update `_VenueCard` dimensions and add footer**

In `_VenueCard.build`, find the card's outer `Container`:
```dart
      child: Container(
        width: 210,
```
Replace `210` with `250`.

Find the image `SizedBox`:
```dart
            SizedBox(
              height: 110,
```
Replace `110` with `155`.

Find the bottom of the `Padding` inside the info section — after the `reviews` row — and add the footer. The current info section ends with:

```dart
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.orange400, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        rating,
                        style: _label(size: 12, color: AppColors.orange400),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '· $reviews reviews',
                        style: _label(size: 11, color: AppColors.neutral700, weight: FontWeight.w400),
                      ),
                    ],
                  ),
```

Replace that entire star/reviews `Row` with:

```dart
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: AppColors.orange400, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        rating,
                        style: _label(size: 12, color: AppColors.orange400),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '· $reviews reviews',
                          style: _label(
                              size: 11,
                              color: AppColors.neutral700,
                              weight: FontWeight.w400),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D3E50).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Text(
                          'Book →',
                          style: _label(
                              size: 10,
                              color: AppColors.neutral900,
                              weight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
```

- [ ] **Step 5: Run tests**

```bash
cd apps/user_app && flutter test test/features/home/home_screen_test.dart -v
```

Expected: all tests pass including `renders Book button for venue`.

- [ ] **Step 6: Visual check in Chrome**

Venue cards are wider, images are taller, "Book →" button appears in the footer row alongside the star rating.

- [ ] **Step 7: Commit**

```bash
git add apps/user_app/lib/features/home/presentation/home_screen.dart \
        apps/user_app/test/features/home/home_screen_test.dart
git commit -m "feat(home): cinematic venue cards"
```

---

## Task 4: Update `_TrainerCard` and `_TrainersRow` to Cinematic proportions

**Files:**
- Modify: `apps/user_app/lib/features/home/presentation/home_screen.dart` — `_TrainerCard`, `_TrainersRow`

Increase card width from 145px to 200px, image height from 105px to 160px, row height from 205px to 225px. Name and specialty stay as image overlays (already `Positioned`). Add a compact body row: location left, Book button right.

- [ ] **Step 1: Add trainer card widget tests**

Append to `apps/user_app/test/features/home/home_screen_test.dart`:

```dart
  group('_TrainersRow card', () {
    testWidgets('renders trainer name', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      expect(find.text('Suresh Phogat'), findsOneWidget);
    });

    testWidgets('renders Book button for trainer', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump();
      // Book → appears in both venues and trainers rows
      expect(find.text('Book →'), findsWidgets);
    });
  });
```

- [ ] **Step 2: Run tests — trainer name test will pass, Book already exists from Task 3**

```bash
cd apps/user_app && flutter test test/features/home/home_screen_test.dart -v
```

Expected: all tests pass (trainer name already rendered, Book → already exists).

- [ ] **Step 3: Update `_TrainersRow` height**

Find:
```dart
    return SizedBox(
      height: 205,
```
Replace with:
```dart
    return SizedBox(
      height: 225,
```

- [ ] **Step 4: Update `_TrainerCard` — width, image height, add body row**

In `_TrainerCard.build`, find the outer container:
```dart
      child: Container(
        width: 145,
```
Replace `145` with `200`.

Find the photo area `SizedBox`:
```dart
            SizedBox(
              height: 105,
```
Replace `105` with `160`.

Find the info `Padding` block (the one after the photo area). Currently it contains name, specialty, and location. Replace the entire `Padding` with:

```dart
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 11),
              child: Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on,
                          color: AppColors.neutral700, size: 11),
                      const SizedBox(width: 2),
                      Text(
                        location,
                        style: _label(
                            size: 10,
                            color: AppColors.neutral700,
                            weight: FontWeight.w400),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.brandGreen400,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brandGreen400.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      'Book →',
                      style: _label(
                          size: 10,
                          color: AppColors.brandGreen700,
                          weight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
```

- [ ] **Step 5: Run tests**

```bash
cd apps/user_app && flutter test test/features/home/home_screen_test.dart -v
```

Expected: all tests pass.

- [ ] **Step 6: Visual check in Chrome**

Trainer cards are wider and taller. Name/specialty stay overlaid on the image. Below the image: location on the left, lime "Book →" button on the right.

- [ ] **Step 7: Commit**

```bash
git add apps/user_app/lib/features/home/presentation/home_screen.dart \
        apps/user_app/test/features/home/home_screen_test.dart
git commit -m "feat(home): cinematic trainer cards"
```

---

## Self-Review

**Spec coverage:**
- ✅ Top bar: Logo-First, 2-row, identity row + context strip — Task 1
- ✅ `appBarH` 72 → 88 — Task 1 Step 3
- ✅ Games: width 240→270, row 185→230, image 170px, footer with avatars + action button — Task 2
- ✅ Venues: width 210→250, row 236→250, image 110→155, Book button footer — Task 3
- ✅ Trainers: width 145→200, row 205→225, image 105→160, compact body with Book button — Task 4

**Placeholder scan:** No TBDs or TODOs — all code is complete.

**Type consistency:** `_label()` helper used consistently across all tasks. `AppColors` tokens used by exact name throughout. `_TagPill`, `_PulseDot`, `_colorBg()` all referenced without redefinition — they remain unchanged in the file.
