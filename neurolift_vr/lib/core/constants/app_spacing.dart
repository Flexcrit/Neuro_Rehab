/// NeuroLift VR Design System — Spacing & Radius Tokens
class AppSpacing {
  AppSpacing._();

  // ── Padding ───────────────────────────────────────────────────────────────
  static const double screenH = 20.0;
  static const double screenV = 20.0;
  static const double cardPad = 16.0;
  static const double cardPadSm = 12.0;
  static const double itemGap = 12.0;
  static const double sectionGap = 24.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;

  // ── Border Radius ─────────────────────────────────────────────────────────
  static const double radiusXs = 8.0;
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 24.0;
  static const double radiusChip = 24.0;
  static const double radiusPill = 100.0;

  // ── Nav ───────────────────────────────────────────────────────────────────
  static const double navHeight = 68.0;
  static const double bottomSafe = 100.0; // scroll clearance above nav

  // ── Animation Durations ───────────────────────────────────────────────────
  static const Duration durationFast = Duration(milliseconds: 120);
  static const Duration durationNormal = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 280);
  static const Duration durationSlow = Duration(milliseconds: 350);
  static const Duration durationCounter = Duration(milliseconds: 800);
  static const Duration durationRing = Duration(milliseconds: 1200);
  static const Duration durationBar = Duration(milliseconds: 600);
  static const Duration durationStagger = Duration(milliseconds: 60);
}
