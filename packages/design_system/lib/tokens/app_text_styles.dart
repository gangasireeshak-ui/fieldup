import 'package:flutter/material.dart';
import 'app_colors.dart';

/// FieldUp text styles — dark sporty theme
/// Headings: Barlow Condensed (bold, condensed, athletic)
/// Body/Label/Caption: Inter (clean, readable)
abstract final class AppTextStyles {
  static const _heading = 'Barlow Condensed';
  static const _body    = 'Inter';

  // ── Display (Barlow Condensed — hero numbers, big titles) ─────────────────
  static const displayLG = TextStyle(
    fontFamily: _heading,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
    letterSpacing: -1.0,
    color: AppColors.neutral900,
    height: 1.08,
  );

  // ── Headings (Barlow Condensed) ────────────────────────────────────────────
  static const headingXL = TextStyle(
    fontFamily: _heading,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.neutral900,
    height: 1.12,
  );

  static const headingLG = TextStyle(
    fontFamily: _heading,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.neutral900,
    height: 1.14,
  );

  static const headingMD = TextStyle(
    fontFamily: _heading,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.neutral900,
    height: 1.2,
  );

  // ── Body (Inter) ───────────────────────────────────────────────────────────
  static const bodyLG = TextStyle(
    fontFamily: _body,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral900,
    height: 1.5,
  );

  static const bodyMD = TextStyle(
    fontFamily: _body,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral700,
    height: 1.5,
  );

  static const label = TextStyle(
    fontFamily: _body,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.neutral900,
    height: 1.4,
  );

  static const caption = TextStyle(
    fontFamily: _body,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral600,
    height: 1.4,
  );
}
