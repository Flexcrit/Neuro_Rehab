import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/summary_metrics_entity.dart';
import '../../../../core/utils/formatters.dart';

/// Horizontally scrollable row of high-density metric cards.
///
/// Height is capped at 100 px. Each [_MetricCard] is 140 × 80 px.
/// Consumes a [SummaryMetricsEntity] to avoid passing raw primitives
/// across widget boundaries.
class SummaryMetricsRow extends StatelessWidget {
  final SummaryMetricsEntity metrics;

  const SummaryMetricsRow({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        physics: const BouncingScrollPhysics(),
        children: [
          _MetricCard(
            icon: Icons.monitor_heart_outlined,
            iconColor: AppColors.primaryAccent,
            value: '${metrics.totalSessionsToday}',
            label: 'Sessions Today',
          ),
          _MetricCard(
            icon: Icons.speed_rounded,
            iconColor: AppColors.secondaryAccent,
            value: Formatters.formatDecimal(metrics.averageScore),
            label: 'Avg. Score',
          ),
          _MetricCard(
            icon: Icons.pending_actions_rounded,
            iconColor: AppColors.warning,
            value: '${metrics.pendingReviews}',
            label: 'Pending Reviews',
          ),
          _MetricCard(
            icon: Icons.vrpano_rounded,
            iconColor: AppColors.tertiaryAccent,
            value: '${metrics.activeVrHeadsets}',
            label: 'Active Headsets',
          ),
        ],
      ),
    );
  }
}

/// Individual 140 × 80 px metric card.
///
/// Layout (top → bottom, all left-aligned):
/// - Icon (top-left)
/// - Large bold number (24 sp, `#FFFFFF`)
/// - Tiny label (12 sp, `#8E92A4`)
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,                  // #11162D
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top-left icon
          Icon(icon, color: iconColor, size: 18),

          // Large bold number
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,          // #FFFFFF
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.0,
            ),
          ),

          // Tiny label
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,         // #8E92A4
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
