import 'package:flutter/material.dart';

/// NeuroLift VR Design System — Color Palette
/// Medical-grade dark/light themes for clinical data review.
class AppColors {
  AppColors._();

  // ── Dark Mode Backgrounds ────────────────────────────────────────────────
  static const Color background = Color(0xFF080D1A);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceVariant = Color(0xFF1C2537);

  // ── Light Mode Backgrounds ───────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF0F4FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFE8EDF8);

  // ── Accent Colors ────────────────────────────────────────────────────────
  static const Color primaryAccent = Color(0xFF00E5C7);     // teal
  static const Color primaryAccentLight = Color(0xFF00B4A0); // teal light mode
  static const Color secondaryAccent = Color(0xFF3B82F6);   // blue
  static const Color tertiaryAccent = Color(0xFF7C4DFF);    // purple

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color info = Color(0xFF3B82F6);

  // ── Text — Dark ──────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF0F4FF);
  static const Color textSecondary = Color(0xFF8B9CC8);
  static const Color textMuted = Color(0xFF4A5880);

  // ── Text — Light ─────────────────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF0A0F1E);
  static const Color textSecondaryLight = Color(0xFF4A5880);
  static const Color textMutedLight = Color(0xFF8B9CC8);

  // ── Borders & Dividers ───────────────────────────────────────────────────
  static const Color borderSubtle = Color(0x12FFFFFF);
  static const Color borderMedium = Color(0x3300E5C7);
  static const Color navBorder = Color(0x12FFFFFF);
  static const Color divider = Color(0x12FFFFFF);

  // ── Component Colors ─────────────────────────────────────────────────────
  static const Color chipUnselected = Color(0xFF1C2537);
  static const Color chipSelected = Color(0xFF00E5C7);
  static const Color cardShadow = Color(0x26000000);
  static const Color statusGreenBg = Color(0x1A10B981);
  static const Color statusAmberBg = Color(0x1AF59E0B);
  static const Color statusRedBg = Color(0x1AEF4444);
  static const Color statusBlueBg = Color(0x1A3B82F6);

  // ── Aliases (backward compat) ────────────────────────────────────────────
  static const Color textTertiary = textMuted;

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00E5C7), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF7C4DFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF080D1A), Color(0xFF111827)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Condition Colors ─────────────────────────────────────────────────────
  static const Color conditionTBI = Color(0xFF3B82F6);
  static const Color conditionStroke = Color(0xFFF97316);
  static const Color conditionParkinsons = Color(0xFF7C4DFF);
  static const Color conditionOther = Color(0xFF00E5C7);

  // ── Helpers ──────────────────────────────────────────────────────────────
  /// Returns a score-dependent ring/text color.
  static Color scoreColor(int score) {
    if (score >= 60) return primaryAccent;
    if (score >= 30) return warning;
    return error;
  }

  /// Returns bg color for a condition string.
  static Color conditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'tbi':
        return conditionTBI;
      case 'stroke':
        return conditionStroke;
      case "parkinson's":
      case 'parkinsons':
        return conditionParkinsons;
      default:
        return conditionOther;
    }
  }
}
