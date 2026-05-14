import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/session_entity.dart';

/// Compact session card widget (max height ~80px) with:
/// - Left: Circular score indicator with dynamic color
/// - Middle: Patient name, activity type, timestamp
/// - Right: Status chip
class SessionListItem extends StatelessWidget {
  final SessionEntity session;
  final VoidCallback? onTap;

  const SessionListItem({
    super.key,
    required this.session,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scoreColor = AppColors.scoreColor(session.score);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Score Indicator ──────────────────────────────────────────
            _ScoreIndicator(score: session.score, color: scoreColor),
            const SizedBox(width: 14),

            // ── Details Column ──────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          session.patientName,
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (session.hasAiInsights) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: AppColors.tertiaryAccent,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.sports_esports_outlined,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        session.activityType,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    Formatters.formatSessionTime(session.timestamp),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // ── Status Chip ─────────────────────────────────────────────
            _StatusChip(status: session.status),
          ],
        ),
      ),
    );
  }
}

/// Circular score ring with a number centered inside.
class _ScoreIndicator extends StatelessWidget {
  final int score;
  final Color color;

  const _ScoreIndicator({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    final normalized = (score / 100).clamp(0.0, 1.0);

    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: normalized,
            strokeWidth: 3.5,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation(color),
          ),
          Text(
            '$score',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact status chip with color-coded background.
class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case 'Completed':
        bgColor = AppColors.statusGreenBg;
        textColor = AppColors.secondaryAccent;
        icon = Icons.check_circle_rounded;
        break;
      case 'In Progress':
        bgColor = AppColors.statusAmberBg;
        textColor = AppColors.warning;
        icon = Icons.hourglass_top_rounded;
        break;
      case 'Failed':
        bgColor = AppColors.statusRedBg;
        textColor = AppColors.error;
        icon = Icons.cancel_rounded;
        break;
      default:
        bgColor = AppColors.chipUnselected;
        textColor = AppColors.textSecondary;
        icon = Icons.help_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            status == 'In Progress' ? 'Active' : status,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
