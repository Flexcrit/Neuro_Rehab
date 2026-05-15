import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/widgets/pressable_card.dart';
import '../../../../core/widgets/animated_counter.dart';
import '../../../../core/widgets/score_ring.dart';
import '../pages/patient_profile_page.dart';

/// Fully rebuilt Patients screen with search, filters, sparklines, and FAB.
class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage>
    with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  bool _searchOpen = false;
  String _activeCondition = 'All';
  String _activeStatus = 'All';
  String _searchQuery = '';

  final _conditions = ['All', 'TBI', 'Stroke', "Parkinson's", 'Other'];
  final _statuses = ['All', 'Active', 'On Hold', 'Discharged'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<MockPatient> get _filteredPatients {
    return MockData.patients.where((p) {
      final matchSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.condition.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCondition =
          _activeCondition == 'All' || p.condition == _activeCondition;
      final matchStatus =
          _activeStatus == 'All' || p.status == _activeStatus;
      return matchSearch && matchCondition && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final patients = _filteredPatients;
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _buildFab(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildStatsBar(patients),
            _buildFilterChips(),
            Expanded(
              child: patients.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.only(
                          bottom: AppSpacing.bottomSafe, top: 4),
                      physics: const BouncingScrollPhysics(),
                      itemCount: patients.length,
                      itemBuilder: (_, i) => _PatientCard(
                        patient: patients[i],
                        delay: Duration(milliseconds: i * 60),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PatientProfilePage(patientId: patients[i].id),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH, AppSpacing.screenV, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: _searchOpen
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const Text(
                'Patients',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700),
              ),
              secondChild: TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search patients…',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _searchOpen = !_searchOpen;
                if (!_searchOpen) {
                  _searchCtrl.clear();
                  _searchQuery = '';
                }
              });
            },
            icon: Icon(
              _searchOpen ? Icons.close_rounded : Icons.search_rounded,
              color: AppColors.textSecondary,
            ),
          ),
          IconButton(
            onPressed: () => _showFilterSheet(context),
            icon: Stack(
              children: [
                const Icon(Icons.tune_rounded, color: AppColors.textSecondary),
                if (_activeCondition != 'All' || _activeStatus != 'All')
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                          color: AppColors.primaryAccent,
                          shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(List<MockPatient> patients) {
    final active = patients.where((p) => p.status == 'Active').length;
    final avgRecovery = patients.isEmpty
        ? 0.0
        : patients.fold(0.0, (s, p) => s + p.recoveryPercent) / patients.length;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenH, vertical: 4),
      child: Row(
        children: [
          _MiniStat(
              label: 'Total', value: patients.length.toDouble(),
              color: AppColors.primaryAccent),
          const SizedBox(width: 10),
          _MiniStat(
              label: 'Active', value: active.toDouble(),
              color: AppColors.success),
          const SizedBox(width: 10),
          _MiniStat(
              label: 'Avg Recovery',
              value: avgRecovery,
              color: AppColors.secondaryAccent,
              formatter: (v) => '${v.toInt()}%'),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
        itemCount: _conditions.length,
        itemBuilder: (_, i) {
          final c = _conditions[i];
          final active = c == _activeCondition;
          return GestureDetector(
            onTap: () => setState(() => _activeCondition = c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: active ? AppColors.primaryAccent : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
              ),
              child: Text(c,
                  style: TextStyle(
                      color: active
                          ? AppColors.background
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_search_rounded,
              color: AppColors.textMuted, size: 56),
          const SizedBox(height: 12),
          const Text('No patients found',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 15)),
          const SizedBox(height: 4),
          const Text('Try adjusting your filters',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddPatientSheet(context),
      backgroundColor: AppColors.primaryAccent,
      foregroundColor: AppColors.background,
      elevation: 0,
      child: const Icon(Icons.person_add_rounded),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (_, setModalState) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.textMuted,
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              const Text('Filter Patients',
                  style: TextStyle(color: AppColors.textPrimary,
                      fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              const Text('Condition',
                  style: TextStyle(color: AppColors.textSecondary,
                      fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _conditions.map((c) {
                  final active = c == _activeCondition;
                  return GestureDetector(
                    onTap: () {
                      setModalState(() => _activeCondition = c);
                      setState(() => _activeCondition = c);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primaryAccent
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(c,
                          style: TextStyle(
                              color: active
                                  ? AppColors.background
                                  : AppColors.textSecondary,
                              fontSize: 12)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Status',
                  style: TextStyle(color: AppColors.textSecondary,
                      fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _statuses.map((s) {
                  final active = s == _activeStatus;
                  return GestureDetector(
                    onTap: () {
                      setModalState(() => _activeStatus = s);
                      setState(() => _activeStatus = s);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primaryAccent
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(s,
                          style: TextStyle(
                              color: active
                                  ? AppColors.background
                                  : AppColors.textSecondary,
                              fontSize: 12)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Apply Filters',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddPatientSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _AddPatientSheet(),
    );
  }
}

// ── Patient Card ──────────────────────────────────────────────────────────────

class _PatientCard extends StatefulWidget {
  final MockPatient patient;
  final Duration delay;
  final VoidCallback onTap;
  const _PatientCard({required this.patient, required this.delay, required this.onTap});

  @override
  State<_PatientCard> createState() => _PatientCardState();
}

class _PatientCardState extends State<_PatientCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 350), vsync: this);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Color get _conditionColor => AppColors.conditionColor(widget.patient.condition);
  String get _lastSessionTime {
    final sessions = MockData.sessionsForPatient(widget.patient.id);
    if (sessions.isEmpty) return 'No sessions yet';
    final diff = DateTime.now().difference(sessions.first.timestamp);
    if (diff.inMinutes < 60) return 'Last: ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Last: ${diff.inHours}h ago';
    return 'Last: ${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: PressableCard(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          padding: const EdgeInsets.all(16),
          onTap: widget.onTap,
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: _conditionColor.withValues(alpha: 0.15),
                child: Text(
                  patient.initials,
                  style: TextStyle(
                      color: _conditionColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(patient.name,
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                        _StatusBadge(status: patient.status),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: _conditionColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(patient.condition,
                              style: TextStyle(
                                  color: _conditionColor, fontSize: 10,
                                  fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 8),
                        Text(_lastSessionTime,
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Sparkline
                        _Sparkline(scores: patient.recentScores),
                        const SizedBox(width: 10),
                        // Recovery trend
                        _TrendBadge(trend: patient.scoreTrend),
                        const Spacer(),
                        // Avg score
                        ScoreRing(
                          score: patient.averageScore.round(),
                          size: 36,
                          strokeWidth: 3,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sparkline ─────────────────────────────────────────────────────────────────

class _Sparkline extends StatelessWidget {
  final List<double> scores;
  const _Sparkline({required this.scores});

  @override
  Widget build(BuildContext context) {
    if (scores.length < 2) return const SizedBox(width: 44);
    final trend = scores.last - scores.first;
    final color = trend >= 0 ? AppColors.success : AppColors.error;
    final min = scores.reduce((a, b) => a < b ? a : b);
    final max = scores.reduce((a, b) => a > b ? a : b);
    final range = (max - min).clamp(1.0, double.infinity);

    return CustomPaint(
      size: const Size(44, 22),
      painter: _SparklinePainter(scores: scores, min: min, range: range, color: color),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> scores;
  final double min, range;
  final Color color;
  const _SparklinePainter({
    required this.scores, required this.min,
    required this.range, required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < scores.length; i++) {
      final x = (i / (scores.length - 1)) * size.width;
      final y = size.height - ((scores[i] - min) / range) * size.height;
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklinePainter o) => o.scores != scores;
}

// ── Trend Badge ───────────────────────────────────────────────────────────────
class _TrendBadge extends StatelessWidget {
  final double trend;
  const _TrendBadge({required this.trend});

  @override
  Widget build(BuildContext context) {
    final positive = trend >= 0;
    final color = positive ? AppColors.success : AppColors.error;
    final icon = positive ? '↑' : '↓';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8)),
      child: Text(
        '$icon ${trend.abs().toStringAsFixed(0)} pts',
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Active': color = AppColors.success; break;
      case 'Discharged': color = AppColors.primaryAccent; break;
      case 'On Hold': color = AppColors.warning; break;
      default: color = AppColors.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20)),
      child: Text(status,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Mini Stat ─────────────────────────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final String Function(double)? formatter;
  const _MiniStat({
    required this.label, required this.value, required this.color, this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedCounter(
              target: value,
              formatter: formatter,
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 1),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// ── Add Patient Sheet ─────────────────────────────────────────────────────────
class _AddPatientSheet extends StatefulWidget {
  const _AddPatientSheet();

  @override
  State<_AddPatientSheet> createState() => _AddPatientSheetState();
}

class _AddPatientSheetState extends State<_AddPatientSheet> {
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _condition = 'TBI';
  bool _loading = false;
  final _conditions = ['TBI', 'Stroke', "Parkinson's", 'Other'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24, right: 24, top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.textMuted,
                    borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 20),
          const Text('Add New Patient',
              style: TextStyle(color: AppColors.textPrimary,
                  fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _TextField(ctrl: _firstCtrl, label: 'First Name')),
              const SizedBox(width: 10),
              Expanded(child: _TextField(ctrl: _lastCtrl, label: 'Last Name')),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Condition',
              style: TextStyle(color: AppColors.textSecondary,
                  fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: _conditions.map((c) {
              final active = c == _condition;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _condition = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primaryAccent
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(c,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: active
                                ? AppColors.background
                                : AppColors.textSecondary,
                            fontSize: 11, fontWeight: FontWeight.w500)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          _TextField(ctrl: _notesCtrl, label: 'Notes (optional)', maxLines: 2),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : () async {
                setState(() => _loading = true);
                await Future.delayed(const Duration(seconds: 1));
                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          color: AppColors.background, strokeWidth: 2))
                  : const Text('Create Patient',
                      style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final int maxLines;
  const _TextField({required this.ctrl, required this.label, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primaryAccent)),
      ),
    );
  }
}
