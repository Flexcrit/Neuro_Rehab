import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/widgets/animated_counter.dart';
import '../../../../core/widgets/score_ring.dart';
import '../../../../core/widgets/pressable_card.dart';
import '../../../sessions/presentation/pages/session_detail_page.dart';

/// Full Patient Profile screen.
class PatientProfilePage extends StatefulWidget {
  final String patientId;
  const PatientProfilePage({super.key, required this.patientId});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage>
    with TickerProviderStateMixin {
  late MockPatient _patient;
  late List<MockSession> _sessions;
  String _activeFilter = 'All';
  bool _editMode = false;
  late AnimationController _entryCtrl;
  late Animation<double> _fadeAnim;

  static const _filters = ['All', 'This Week', 'High Score'];

  final exercises = ['Fruit Picking', 'Balance Beam', 'Reach & Grasp', 'Precision Tasks'];

  @override
  void initState() {
    super.initState();
    _patient = MockData.patientById(widget.patientId) ?? MockData.patients.first;
    _sessions = MockData.sessionsForPatient(_patient.id);
    _entryCtrl =
        AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  List<MockSession> get _filteredSessions {
    final now = DateTime.now();
    switch (_activeFilter) {
      case 'This Week':
        return _sessions.where((s) =>
            now.difference(s.timestamp).inDays <= 7).toList();
      case 'High Score':
        return _sessions.where((s) => s.score >= 70).toList();
      default:
        return _sessions;
    }
  }

  Color _conditionColor() => AppColors.conditionColor(_patient.condition);

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: AppSpacing.bottomSafe),
                child: Column(
                  children: [
                    _buildProfileHero(),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _buildQuickStats(),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _buildRecoveryProgress(),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _buildExerciseBreakdown(),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _buildSessionHistory(context),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary, size: 20),
            ),
            const Expanded(
              child: Text('Patient Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textPrimary,
                      fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            IconButton(
              onPressed: () => setState(() => _editMode = !_editMode),
              icon: Icon(_editMode ? Icons.close_rounded : Icons.edit_outlined,
                  color: AppColors.textSecondary, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHero() {
    final cond = _conditionColor();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: cond.withValues(alpha: 0.15),
            child: Text(
              _patient.initials,
              style: TextStyle(
                  color: cond, fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          Text(_patient.name,
              style: const TextStyle(color: AppColors.textPrimary,
                  fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Chip(label: _patient.condition, color: cond),
              const SizedBox(width: 8),
              _Chip(label: 'Age ${_patient.age}', color: AppColors.textMuted),
              const SizedBox(width: 8),
              _Chip(label: _patient.status, color: _statusColor(_patient.status)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Row(
        children: [
          _QuickStat(label: 'Sessions', value: _patient.totalSessions.toDouble(),
              icon: Icons.monitor_heart_outlined, color: AppColors.primaryAccent),
          const SizedBox(width: 10),
          _QuickStat(label: 'Avg Score', value: _patient.averageScore,
              icon: Icons.score_rounded, color: AppColors.secondaryAccent,
              formatter: (v) => v.toStringAsFixed(1)),
          const SizedBox(width: 10),
          _QuickStat(label: 'Recovery', value: _patient.recoveryPercent.toDouble(),
              icon: Icons.trending_up_rounded, color: AppColors.success,
              formatter: (v) => '${v.toInt()}%'),
        ],
      ),
    );
  }

  Widget _buildRecoveryProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recovery Progress',
                    style: TextStyle(color: AppColors.textPrimary,
                        fontSize: 15, fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '↑ ${(_patient.scoreTrend >= 0 ? '+' : '')}${_patient.scoreTrend.toStringAsFixed(0)} pts',
                    style: const TextStyle(
                        color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text('vs. admission baseline',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _patient.recoveryPercent / 100),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOut,
              builder: (_, value, __) => Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${(value * 100).toInt()}%',
                          style: const TextStyle(
                              color: AppColors.primaryAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      const Text('100%',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primaryAccent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseBreakdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Exercise Breakdown',
              style: TextStyle(color: AppColors.textPrimary,
                  fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...exercises.asMap().entries.map((entry) {
            final idx = entry.key;
            final exercise = entry.value;
            final exerciseSessions =
                _sessions.where((s) => s.exerciseType == exercise).toList();
            if (exerciseSessions.isEmpty) return const SizedBox.shrink();
            final avg = exerciseSessions.fold(0, (s, e) => s + e.score) /
                exerciseSessions.length;
            return _AnimatedBar(
              label: exercise,
              value: avg / 100,
              count: exerciseSessions.length,
              color: [AppColors.primaryAccent, AppColors.secondaryAccent,
                      AppColors.success, AppColors.tertiaryAccent][idx % 4],
              delay: Duration(milliseconds: idx * 100),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSessionHistory(BuildContext context) {
    final filtered = _filteredSessions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Session History',
                  style: TextStyle(color: AppColors.textPrimary,
                      fontSize: 15, fontWeight: FontWeight.w600)),
              Text('${filtered.length} sessions',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Filter chips
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
            itemCount: _filters.length,
            itemBuilder: (_, i) {
              final f = _filters[i];
              final active = f == _activeFilter;
              return GestureDetector(
                onTap: () => setState(() => _activeFilter = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primaryAccent : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
                  ),
                  child: Text(f,
                      style: TextStyle(
                          color: active ? AppColors.background : AppColors.textSecondary,
                          fontSize: 12, fontWeight: FontWeight.w500)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        ...filtered.map((s) => _ProfileSessionCard(
              session: s,
              relativeTime: _relativeTime(s.timestamp),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => SessionDetailPage(sessionId: s.id))),
            )),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Active': return AppColors.success;
      case 'Discharged': return AppColors.primaryAccent;
      case 'On Hold': return AppColors.warning;
      default: return AppColors.textSecondary;
    }
  }
}

// ── Support widgets ───────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );
}

class _QuickStat extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final String Function(double)? formatter;
  const _QuickStat({
    required this.label, required this.value, required this.icon,
    required this.color, this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.borderSubtle)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            AnimatedCounter(
              target: value,
              formatter: formatter,
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _AnimatedBar extends StatefulWidget {
  final String label;
  final double value;
  final int count;
  final Color color;
  final Duration delay;
  const _AnimatedBar({
    required this.label, required this.value,
    required this.count, required this.color, required this.delay,
  });

  @override
  State<_AnimatedBar> createState() => _AnimatedBarState();
}

class _AnimatedBarState extends State<_AnimatedBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.label,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13, fontWeight: FontWeight.w500)),
                Text('${widget.count} sessions • ${(widget.value * 100).toInt()}%',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: widget.value * _anim.value,
                minHeight: 6,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation(widget.color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSessionCard extends StatelessWidget {
  final MockSession session;
  final String relativeTime;
  final VoidCallback onTap;
  const _ProfileSessionCard({
    required this.session, required this.relativeTime, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          ScoreRing(score: session.score, size: 44, strokeWidth: 3.5),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.exerciseType,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(relativeTime,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          _StatusBadge(status: session.status),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (status) {
      case 'Completed':
        bg = AppColors.statusGreenBg; fg = AppColors.success; break;
      case 'In Progress':
        bg = AppColors.statusAmberBg; fg = AppColors.warning; break;
      case 'Failed':
        bg = AppColors.statusRedBg; fg = AppColors.error; break;
      default:
        bg = const Color(0x1AF59E0B); fg = const Color(0xFFF59E0B); break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status,
          style: TextStyle(
              color: fg, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}
