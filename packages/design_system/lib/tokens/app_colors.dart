import 'package:flutter/material.dart';

/// FieldUp brand color tokens — Neon Punch dark-first theme
abstract final class AppColors {
  // ── Neutral scale (dark-first: 50 = darkest bg, 900 = lightest text) ────────
  static const neutral50  = Color(0xFF0A0A0A); // true black scaffold
  static const neutral100 = Color(0xFF111111); // surface
  static const neutral200 = Color(0xFF1A1A1A); // surface variant / card bg
  static const neutral300 = Color(0xFF242424); // surface container / border
  static const neutral400 = Color(0xFF2E2E2E); // heavy border
  static const neutral500 = Color(0xFF3D3D3D); // outline
  static const neutral600 = Color(0xFF6B6B6B); // tertiary hint / muted text
  static const neutral700 = Color(0xFF9E9E9E); // on-surface-variant label
  static const neutral800 = Color(0xFFCCCCCC); // dim text
  static const neutral900 = Color(0xFFF5F5F5); // primary text (light on dark)

  // ── Backgrounds ────────────────────────────────────────────────────────────
  static const background        = Color(0xFF000000); // Night Pitch
  static const surface           = Color(0xFF111111); // elevated surface
  static const surfaceVariant    = Color(0xFF1A1A1A); // cards / containers

  // ── Electric Lime — Primary Accent ────────────────────────────────────────
  static const brandGreen50  = Color(0xFF0D1500);
  static const brandGreen100 = Color(0xFF1D2900); // selected chip / tinted bg
  static const brandGreen200 = Color(0xFF2E4200);
  static const brandGreen300 = Color(0xFF5C7A00);
  static const brandGreen400 = Color(0xFFC8F23A); // PRIMARY — Electric Lime
  static const brandGreen500 = Color(0xFFB0D630); // pressed state
  static const brandGreen600 = Color(0xFF91B500);
  static const brandGreen700 = Color(0xFF1A2800); // dark text on lime
  static const brandGreen800 = Color(0xFF111B00);
  static const brandGreen900 = Color(0xFF090E00);

  // ── Pro Green — Secondary ─────────────────────────────────────────────────
  static const teal50  = Color(0xFF0A1F18);
  static const teal100 = Color(0xFF122E22);
  static const teal400 = Color(0xFF58B48F); // Pro Green — secondary
  static const teal500 = Color(0xFF4A9B79); // active / success
  static const teal600 = Color(0xFF3A7A60);
  static const teal700 = Color(0xFF285544);

  // ── Turf Blue — Accent ────────────────────────────────────────────────────
  static const blue50  = Color(0xFF071525);
  static const blue100 = Color(0xFF0D2040);
  static const blue400 = Color(0xFF3A8DCC); // Turf Blue — accent
  static const blue500 = Color(0xFF2D76B3); // links / info
  static const blue600 = Color(0xFF1F5990);

  // ── Red ───────────────────────────────────────────────────────────────────
  static const red50  = Color(0xFF200A07);
  static const red100 = Color(0xFF3A1210);
  static const red400 = Color(0xFFE75D4A);
  static const red500 = Color(0xFFE34B34); // error / destructive
  static const red600 = Color(0xFFC64534);

  // ── Orange ────────────────────────────────────────────────────────────────
  static const orange50  = Color(0xFF1F1100);
  static const orange100 = Color(0xFF331C00);
  static const orange400 = Color(0xFFF7BC45);
  static const orange500 = Color(0xFFF2AD25); // warning / premium
  static const orange600 = Color(0xFFC98D26);

  // ── Semantic aliases ──────────────────────────────────────────────────────
  static const primary   = brandGreen400; // Electric Lime CTA
  static const onPrimary = brandGreen700; // dark text on lime
  static const secondary = teal400;       // Pro Green
  static const accent    = blue400;       // Turf Blue
  static const error     = red500;
  static const success   = teal500;
  static const warning   = orange500;
  static const info      = blue500;
}
