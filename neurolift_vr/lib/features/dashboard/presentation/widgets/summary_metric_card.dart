import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/summary_metrics_entity.dart';
import '../../../../core/utils/formatters.dart';

/// Horizontal scrollable row of summary metric cards displayed
/// at the top of the dashboard.
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
      width: 145,
      margin: const EdgeInsets.symmetric(horizontal: 6),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: iconColor, size: 20),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
