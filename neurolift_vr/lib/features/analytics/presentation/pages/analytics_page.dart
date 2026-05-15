import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/widgets/animated_counter.dart';
import '../../../../core/widgets/pressable_card.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});
  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _dateRange = 'Week';
  final _ranges = ['Today', 'Week', 'Month'];

  List<MockSession> get _rangedSessions {
    final now = DateTime.now();
    return MockData.sessions.where((s) {
      final diff = now.difference(s.timestamp);
      if (_dateRange == 'Today') return diff.inDays == 0;
      if (_dateRange == 'Week') return diff.inDays <= 7;
      return diff.inDays <= 30;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _rangedSessions;
    final totalSessions = sessions.length;
    final scored = sessions.where((s) => s.score > 0).toList();
    final avgScore = scored.isEmpty ? 0.0 :
        scored.fold(0, (s, e) => s + e.score) / scored.length;
    final completed = sessions.where((s) => s.status == 'Completed').length;
    final completionRate = totalSessions == 0 ? 0.0 : completed / totalSessions * 100;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: AppSpacing.bottomSafe),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildKpiRow(totalSessions, avgScore, completionRate),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildScoreDistribution(sessions),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildWeeklyTrend(sessions),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildTopPerformers(),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Analytics', style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22, fontWeight: FontWeight.w700)),
                SizedBox(height: 2),
                Text('Recovery insights & trends',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: _ranges.map((r) {
                final active = r == _dateRange;
                return GestureDetector(
                  onTap: () => setState(() => _dateRange = r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primaryAccent : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(r, style: TextStyle(
                        color: active ? AppColors.background : AppColors.textSecondary,
                        fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiRow(int total, double avg, double completion) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _KpiCard(label: 'Sessions', value: total.toDouble(),
              icon: Icons.monitor_heart_outlined, color: AppColors.primaryAccent),
          const SizedBox(width: 10),
          _KpiCard(label: 'Avg Score', value: avg,
              icon: Icons.score_rounded, color: AppColors.secondaryAccent,
              formatter: (v) => v.toStringAsFixed(1)),
          const SizedBox(width: 10),
          _KpiCard(label: 'Completion', value: completion,
              icon: Icons.check_circle_outline_rounded, color: AppColors.success,
              formatter: (v) => '${v.toInt()}%'),
        ],
      ),
    );
  }

  Widget _buildScoreDistribution(List<MockSession> sessions) {
    final buckets = [0, 0, 0, 0, 0]; // 0-20,21-40,41-60,61-80,81-100
    for (final s in sessions) {
      if (s.score <= 20) buckets[0]++;
      else if (s.score <= 40) buckets[1]++;
      else if (s.score <= 60) buckets[2]++;
      else if (s.score <= 80) buckets[3]++;
      else buckets[4]++;
    }
    final labels = ['0–20', '21–40', '41–60', '61–80', '81–100'];
    final colors = [AppColors.error, AppColors.warning, AppColors.warning,
                    AppColors.primaryAccent, AppColors.success];
    final maxVal = buckets.reduce((a, b) => a > b ? a : b).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Score Distribution', style: TextStyle(
              color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: List.generate(5, (i) => _AnimatedBarRow(
                label: labels[i],
                value: maxVal == 0 ? 0 : buckets[i] / maxVal,
                count: buckets[i],
                color: colors[i],
                delay: Duration(milliseconds: i * 100),
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrend(List<MockSession> sessions) {
    // Build 7-day score points
    final now = DateTime.now();
    final points = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final daySessions = sessions.where((s) =>
          s.timestamp.year == day.year &&
          s.timestamp.month == day.month &&
          s.timestamp.day == day.day &&
          s.score > 0).toList();
      final avg = daySessions.isEmpty ? 0.0 :
          daySessions.fold(0, (s, e) => s + e.score) / daySessions.length;
      return FlSpot(i.toDouble(), avg);
    });

    final dayLabels = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return ['M','T','W','T','F','S','S'][d.weekday % 7];
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Score Trend', style: TextStyle(
              color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Container(
            height: 200,
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: LineChart(
              LineChartData(
                minY: 0, maxY: 100,
                gridData: FlGridData(
                  show: true, drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (_) => FlLine(
                      color: AppColors.surfaceVariant, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true, interval: 25, reservedSize: 32,
                    getTitlesWidget: (v, _) => Text('${v.toInt()}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                  )),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true, reservedSize: 24,
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i >= 0 && i < dayLabels.length) {
                        return Padding(padding: const EdgeInsets.only(top: 6),
                          child: Text(dayLabels[i], style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 10)));
                      }
                      return const SizedBox.shrink();
                    },
                  )),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: points,
                    isCurved: true, curveSmoothness: 0.3,
                    color: AppColors.primaryAccent, barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true,
                        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                            radius: 4, color: AppColors.primaryAccent,
                            strokeWidth: 2, strokeColor: AppColors.surface)),
                    belowBarData: BarAreaData(show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [AppColors.primaryAccent.withValues(alpha: 0.25),
                                   AppColors.primaryAccent.withValues(alpha: 0.0)],
                        )),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformers() {
    final ranked = List.of(MockData.patients)
      ..sort((a, b) => b.scoreTrend.compareTo(a.scoreTrend));
    final top5 = ranked.take(5).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Performers', style: TextStyle(
              color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('By score improvement this period', style: TextStyle(
              color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 12),
          ...top5.asMap().entries.map((e) {
            final rank = e.key + 1;
            final p = e.value;
            final color = AppColors.conditionColor(p.condition);
            return PressableCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: rank == 1 ? AppColors.warning.withValues(alpha: 0.15)
                          : AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text('#$rank', style: TextStyle(
                        color: rank == 1 ? AppColors.warning : AppColors.textMuted,
                        fontSize: 11, fontWeight: FontWeight.w700))),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(radius: 16,
                      backgroundColor: color.withValues(alpha: 0.15),
                      child: Text(p.initials,
                          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700))),
                  const SizedBox(width: 10),
                  Expanded(child: Text(p.name, style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('↑ ${p.scoreTrend.abs().toStringAsFixed(0)} pts',
                        style: const TextStyle(color: AppColors.success,
                            fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final String Function(double)? formatter;
  const _KpiCard({required this.label, required this.value,
      required this.icon, required this.color, this.formatter});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 8),
        AnimatedCounter(target: value, formatter: formatter,
            style: TextStyle(color: AppColors.textPrimary,
                fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
      ]),
    ),
  );
}

class _AnimatedBarRow extends StatefulWidget {
  final String label;
  final double value;
  final int count;
  final Color color;
  final Duration delay;
  const _AnimatedBarRow({required this.label, required this.value,
      required this.count, required this.color, required this.delay});
  @override
  State<_AnimatedBarRow> createState() => _AnimatedBarRowState();
}

class _AnimatedBarRowState extends State<_AnimatedBarRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        SizedBox(width: 44,
            child: Text(widget.label, style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 11))),
        Expanded(child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: widget.value * _anim.value, minHeight: 8,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation(widget.color),
          ),
        )),
        const SizedBox(width: 8),
        Text('${widget.count}', style: TextStyle(
            color: widget.color, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}
