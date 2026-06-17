# Home Screen: Top Bar & Card Size Redesign

**Date:** 2026-05-12  
**Status:** Approved  
**Scope:** `apps/user_app/lib/features/home/presentation/home_screen.dart`

---

## Context

The existing home screen layout is well-liked but two areas need improvement:

1. **Top bar** — the current 2-row layout de-emphasises the FieldUp brand; the greeting/location/live-count information competes for hierarchy.
2. **Cards** — the horizontal scroll cards (Games, Venues, Trainers) are compact and dense; they don't give content enough room to breathe.

No sections are being removed or reordered. This is a targeted visual upgrade to two parts of the existing screen.

---

## Decision: Top Bar → Logo-First (Option C)

### What changes

Replace the current 2-row `_AppBar` with a **2-row Logo-First** layout:

**Row 1 — Identity bar** (~52px tall with padding):
- Left: user avatar (34×34px, lime border ring, online dot) + user name (14px Inter 600)
- Centre: `FieldUp` logo (28px Barlow Condensed italic, lime `#c3f400`)
- Right: notification bell icon (34×34px circle button, lime dot badge)

**Row 2 — Context strip** (~30px tall):
- Left: location pin icon + "JP Nagar, Bangalore" + chevron (tappable, 11px Inter)
- Right: pulse dot + "142 players active" (11px Inter 600, lime)

Both rows share the same blurred glass background (`AppColors.background` at 0.9 opacity, `sigmaX/Y: 24`), separated by a single subtle border between row 2 and the content below.

### What stays the same

- Glass blur backdrop filter
- Notification dot badge
- Online dot on avatar
- Location + live count information — just repositioned to the sub-row
- Total height is similar (~82px vs current ~72px) — the `SliverToBoxAdapter` spacer at the top of the `CustomScrollView` should be adjusted to `topInset + 88`

---

## Decision: Horizontal Scroll Cards → Cinematic (Option C)

All three horizontal scroll rows — Games, Venues, and Trainers — adopt the new cinematic card proportions. Each row gets its own card dimensions tuned to its content.

### Games row (`_GameCard`, `_GamesRow`)

| Property | Current | New |
|---|---|---|
| Card width | 240px | 270px |
| Row height | 185px | 230px |
| Image area | full card | 170px tall |
| Content area | overlay on image | separate body below image |

**New card structure:**
- Image/gradient area (170px): sport gradient background, sport icon watermark (opacity 0.06), price badge top-right, availability badge top-left
- Body area (below image, ~60px): title (24px Barlow Condensed 700), time row (12px, lime), venue/distance meta (11px, neutral)
- Footer (inside body, separated by divider): avatar stack (24px overlapping circles, -6px margin) + count label left; action button right (`Join →` lime or `View →` glass)

### Venues row (`_VenueCard`, `_VenuesRow`)

| Property | Current | New |
|---|---|---|
| Card width | 210px | 250px |
| Row height | 236px | 250px |
| Image area | 110px | 155px |

**New card structure:**
- Image area (155px): gradient or photo, verified badge top-right (teal pill)
- Body (below): name 19px Barlow Condensed, sports tags 11px, location 10px
- Footer (divider): star rating left; `Book →` glass button right

### Trainers row (`_TrainerCard`, `_TrainersRow`)

| Property | Current | New |
|---|---|---|
| Card width | 145px | 200px |
| Row height | 205px | 225px |
| Image area | 105px | 160px |

**New card structure:**
- Image area (160px, portrait): gradient background, `Trainer` badge top-left (teal), rating badge top-right (dark glass); name (20px Barlow Condensed 700) and specialty (10px) overlaid at bottom of image
- Body (below, compact ~55px): location left; `Book →` lime button right

---

## Flutter Implementation Notes

### `_AppBar` widget

- Split the current single `Column` into two named containers: `_TopBarIdentityRow` and `_TopBarContextStrip`
- Total measured height changes from ~72px to ~82px — update the `SliverToBoxAdapter` spacer constant `appBarH` from `72.0` to `88.0`
- No state changes needed; remains a `StatelessWidget`

### Card widgets

- `_GameCard`: add `cardBody` section below the image stack; move title/time/venue out of the `Positioned` overlay. Add `_AvatarStack` + action button as a `Row` footer.
- `_VenueCard`: increase `width` to 250, image height to 155; add footer row with rating + Book button.
- `_TrainerCard`: increase `width` to 200, image height to 160; name/specialty stay as image overlay (already positioned); add minimal body with location + Book button.

### Row heights

Update the `SizedBox` height wrappers:
- `_GamesRow`: `185` → `230`
- `_VenuesRow`: `236` → `250`
- `_TrainersRow`: `205` → `225`

---

## Out of Scope

- No changes to section order, section count, or content data
- No changes to the Featured Banner, Quick Actions, Stats Strip, Search Bar, Tournaments, Groups, Browse by Sport, or Coach Banner
- No changes to any other screen
