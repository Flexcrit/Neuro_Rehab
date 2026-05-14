import 'package:flutter/material.dart';

/// Enterprise Design System — Color Palette
/// Medical-grade dark theme optimized for clinical data review.
class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────────────────────────────
  static const Color background = Color(0xFF0A0E21);
  static const Color surface = Color(0xFF11162D);
  static const Color surfaceVariant = Color(0xFF1A2240);

  // ── Accents ──────────────────────────────────────────────────────────
  static const Color primaryAccent = Color(0xFF4A90E2);
  static const Color secondaryAccent = Color(0xFF50E3C2);
  static const Color tertiaryAccent = Color(0xFF7C4DFF);

  // ── Semantic ─────────────────────────────────────────────────────────
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFFF9800);
  static const Color success = Color(0xFF50E3C2);
  static const Color info = Color(0xFF4A90E2);

  // ── Text ─────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E92A4);
  static const Color textTertiary = Color(0xFF5A5F72);

  // ── Components ───────────────────────────────────────────────────────
  static const Color chipUnselected = Color(0xFF1A2240);
  static const Color chipSelected = Color(0xFF4A90E2);
  static const Color navBorder = Color(0xFF1A2240);
  static const Color statusGreenBg = Color(0xFF0A2A1E);
  static const Color statusAmberBg = Color(0xFF2A1F0A);
  static const Color statusRedBg = Color(0xFF2A0A0A);
  static const Color cardShadow = Color(0x1A000000);
  static const Color divider = Color(0xFF1E2545);

  // ── Gradients ────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4A90E2), Color(0xFF7C4DFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF50E3C2), Color(0xFF4A90E2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Returns a score-dependent color for circular indicators.
  static Color scoreColor(int score) {
    if (score >= 70) return secondaryAccent;
    if (score >= 50) return warning;
    return error;
  }
}
