import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/widgets/pressable_card.dart';
import '../../../../core/widgets/score_ring.dart';
import '../../../../core/widgets/animated_counter.dart';

/// Full Session Detail screen.
class SessionDetailPage extends StatefulWidget {
  final String sessionId;

  const SessionDetailPage({super.key, required this.sessionId});

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage>
    with TickerProviderStateMixin {
  late MockSession _session;
  bool _noteEditing = false;
  final _noteController = TextEditingController();
  bool _reviewed = false;
  late AnimationController _entryCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _session = MockData.sessions.firstWhere(
      (s) => s.id == widget.sessionId,
      orElse: () => MockData.sessions.first,
    );
    _reviewed = _session.reviewed;
    _noteController.text = _session.aiInsight ?? '';
    _entryCtrl = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _fadeAnim =
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final now = DateTime.now();
    final diff = now.difference(dt);
    String dayLabel;
    if (diff.inDays == 0) {
      dayLabel = 'Today';
    } else if (diff.inDays == 1) {
      dayLabel = 'Yesterday';
    } else {
      dayLabel = '${dt.day}/${dt.month}/${dt.year}';
    }
    return '$dayLabel at $hour:$min $period';
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
                    _buildHeroCard(),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _buildMetricsGrid(),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _buildScoreHistory(),
                    const SizedBox(height: AppSpacing.sectionGap),
                    if (_session.hasAiInsights) _buildAiInsightCard(),
                    if (_session.hasAiInsights) const SizedBox(height: AppSpacing.sectionGap),
                    _buildNotesSection(),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _buildActionButtons(context),
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
        padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary, size: 20),
            ),
            const Expanded(
              child: Text(
                'Session Detail',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              onPressed: () => _shareSession(context),
              icon: const Icon(Icons.share_rounded,
                  color: AppColors.textSecondary, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF1C2537)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.borderMedium),
      ),
      child: Column(
        children: [
          ScoreRing(
            score: _session.score,
            size: 120,
            strokeWidth: 8,
            duration: const Duration(milliseconds: 1200),
            textStyle: TextStyle(
              color: AppColors.scoreColor(_session.score),
              fontSize: 40,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _session.exerciseType,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(_session.timestamp),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Duration: ${_session.duration} min',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildStatusBadge(_session.status),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(status,
          style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildMetricsGrid() {
    final items = [
      _MetricItem(icon: Icons.gps_fixed_rounded, label: 'Accuracy',
          value: _session.accuracy.toDouble(), suffix: '%', color: AppColors.primaryAccent),
      _MetricItem(icon: Icons.timer_outlined, label: 'Reaction Time',
          value: _session.reactionTimeMs.toDouble(), suffix: ' ms', color: AppColors.secondaryAccent),
      _MetricItem(icon: Icons.catching_pokemon_rounded, label: 'Objects Caught',
          value: _session.objectsCaught.toDouble(), suffix: '', color: AppColors.success),
      _MetricItem(icon: Icons.close_rounded, label: 'Missed',
          value: _session.missedObjects.toDouble(), suffix: '', color: AppColors.error),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Performance Metrics',
              style: TextStyle(color: AppColors.textPrimary,
                  fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: items.map((m) => _MetricCard(item: m)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreHistory() {
    final patientSessions = MockData.sessionsForPatient(_session.patientId)
        .take(10)
        .toList()
        .reversed
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Score History',
                  style: TextStyle(color: AppColors.textPrimary,
                      fontSize: 16, fontWeight: FontWeight.w600)),
              Text('Last ${patientSessions.length} sessions',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: patientSessions.map((s) {
                  final pct = (s.score / 100).clamp(0.0, 1.0);
                  final isSelected = s.id == _session.id;
                  final col = AppColors.scoreColor(s.score);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 50 * pct + 4,
                            decoration: BoxDecoration(
                              color: isSelected ? col : col.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('${s.score}',
                              style: TextStyle(
                                color: isSelected ? col : AppColors.textMuted,
                                fontSize: 9,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              )),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsightCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.borderMedium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Recovery Plan',
                        style: TextStyle(color: AppColors.textPrimary,
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    Text('Gemini 2.0 Flash',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _session.aiInsight ?? '',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Therapist Notes',
                  style: TextStyle(color: AppColors.textPrimary,
                      fontSize: 16, fontWeight: FontWeight.w600)),
              GestureDetector(
                onTap: () => setState(() => _noteEditing = !_noteEditing),
                child: Text(
                  _noteEditing ? 'Cancel' : 'Edit',
                  style: const TextStyle(
                      color: AppColors.primaryAccent, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _noteEditing
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Text(
                _noteController.text.isEmpty
                    ? 'No notes yet. Tap Edit to add a note.'
                    : _noteController.text,
                style: TextStyle(
                  color: _noteController.text.isEmpty
                      ? AppColors.textMuted
                      : AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ),
            secondChild: Column(
              children: [
                TextField(
                  controller: _noteController,
                  maxLines: 4,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Add your clinical notes here…',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.borderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _noteEditing = false);
                      _showToast(context, 'Note saved');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Note',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => _reviewed = true);
                _showToast(context, 'Session marked as reviewed');
              },
              icon: Icon(
                _reviewed ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                size: 18,
              ),
              label: Text(_reviewed ? 'Reviewed ✓' : 'Mark as Reviewed'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _reviewed
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.primaryAccent,
                foregroundColor:
                    _reviewed ? AppColors.success : AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showToast(context, 'Report exported'),
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                  label: const Text('Export'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.borderSubtle),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showScheduleSheet(context),
                  icon: const Icon(Icons.calendar_today_rounded, size: 16),
                  label: const Text('Schedule'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.borderSubtle),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
        const SizedBox(width: 8),
        Text(message),
      ]),
      backgroundColor: AppColors.surfaceVariant,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _shareSession(BuildContext context) {
    _showToast(context, 'Session summary shared');
  }

  void _showScheduleSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.textMuted,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Schedule Follow-up',
                style: TextStyle(color: AppColors.textPrimary,
                    fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Text('Follow-up for ${_session.patientName}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showToast(context, 'Follow-up scheduled');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Schedule', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _MetricItem {
  final IconData icon;
  final String label;
  final double value;
  final String suffix;
  final Color color;
  const _MetricItem({
    required this.icon, required this.label,
    required this.value, required this.suffix, required this.color,
  });
}

class _MetricCard extends StatelessWidget {
  final _MetricItem item;
  const _MetricCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return PressableCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: item.color, size: 18),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedCounter(
                target: item.value,
                style: TextStyle(
                    color: item.color,
                    fontSize: 22,
                    fontWeight: FontWeight.w700),
              ),
              if (item.suffix.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(item.suffix,
                      style: TextStyle(
                          color: item.color.withValues(alpha: 0.7),
                          fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(item.label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
