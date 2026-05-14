import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/session_entity.dart';

/// High-density session card. Total height is strictly capped at 85 px
/// (14 px vertical padding × 2 + 57 px content).
///
/// Row layout:
/// - Left   : 50×50 [_ScoreRing] with dynamic score colour.
/// - Middle : Expanded [Column] — name / activity type / timestamp.
/// - Right  : [_StatusToken] — pulsing amber chip or green "Completed" chip.
///
/// The [isPendingAi] flag drives both the score colour and the status token.
class SessionCard extends StatelessWidget {
  final String patientName;
  final String activityType;
  final int score;
  final DateTime timestamp;
  final bool isPendingAi;
  final VoidCallback? onTap;

  const SessionCard({
    super.key,
    required this.patientName,
    required this.activityType,
    required this.score,
    required this.timestamp,
    required this.isPendingAi,
    this.onTap,
  });

  /// Factory constructor from a [SessionEntity] so callers don't need to
  /// manually destructure the entity.
  factory SessionCard.fromEntity(SessionEntity entity, {VoidCallback? onTap}) {
    return SessionCard(
      patientName: entity.patientName,
      activityType: entity.activityType,
      score: entity.score,
      timestamp: entity.timestamp,
      isPendingAi: entity.status == 'Analysis Pending',
      onTap: onTap,
    );
  }

  // ── Score colour logic ────────────────────────────────────────────────────
  Color get _ringColor {
    if (isPendingAi) return AppColors.textTertiary;
    if (score >= 70) return AppColors.secondaryAccent;  // #50E3C2
    if (score < 50) return AppColors.error;             // #E74C3C
    return AppColors.warning;                            // amber/yellow
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        // Strict 85 px total: 14 top + 57 content + 14 bottom
        height: 85,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,                       // #11162D
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Left: 50×50 score ring ──────────────────────────────────
            _ScoreRing(score: score, color: _ringColor),
            const SizedBox(width: 12),

            // ── Middle: data column ─────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Patient name — 16 sp Bold White
                  Text(
                    patientName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,       // #FFFFFF
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Activity type — 14 sp Secondary
                  Text(
                    activityType,
                    style: const TextStyle(
                      color: AppColors.textSecondary,     // #8E92A4
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Timestamp — 12 sp Secondary via intl Formatters
                  Text(
                    Formatters.formatSessionTime(timestamp),
                    style: const TextStyle(
                      color: AppColors.textSecondary,     // #8E92A4
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // ── Right: status token ─────────────────────────────────────
            _StatusToken(isPendingAi: isPendingAi),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ScoreRing
// 50×50 SizedBox with a CircularProgressIndicator (strokeWidth 4) and the
// score value centred inside via a Stack.
// ─────────────────────────────────────────────────────────────────────────────
class _ScoreRing extends StatelessWidget {
  final int score;
  final Color color;

  const _ScoreRing({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    final progress = (score / 100).clamp(0.0, 1.0);
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Text(
            '$score',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatusToken
// When [isPendingAi] is true  → pulsing amber pill "Crunching Telemetry".
// When [isPendingAi] is false → static dark-green pill "Completed" + tick.
// ─────────────────────────────────────────────────────────────────────────────
class _StatusToken extends StatefulWidget {
  final bool isPendingAi;
  const _StatusToken({required this.isPendingAi});

  @override
  State<_StatusToken> createState() => _StatusTokenState();
}

class _StatusTokenState extends State<_StatusToken>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPendingAi) {
      // Pulsing amber "Crunching Telemetry" pill
      return FadeTransition(
        opacity: _pulse,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.statusAmberBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'Crunching\nTelemetry',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.warning,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Static dark-green "Completed" pill — #0A2A1E bg, #50E3C2 text + tick
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.statusGreenBg,             // #0A2A1E
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 12,
            color: AppColors.secondaryAccent,       // #50E3C2
          ),
          SizedBox(width: 4),
          Text(
            'Completed',
            style: TextStyle(
              color: AppColors.secondaryAccent,     // #50E3C2
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Backward-compatible wrapper used by dashboard_page.dart / SliverList.
// Delegates to [SessionCard.fromEntity] so existing call-sites need no change.
// ─────────────────────────────────────────────────────────────────────────────

/// Thin wrapper around [SessionCard] that accepts a [SessionEntity] directly.
///
/// Keeps the existing [DashboardPage] sliver list call-site unchanged.
class SessionListItem extends StatelessWidget {
  final SessionEntity session;
  final VoidCallback? onTap;

  const SessionListItem({
    super.key,
    required this.session,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) =>
      SessionCard.fromEntity(session, onTap: onTap);
}
