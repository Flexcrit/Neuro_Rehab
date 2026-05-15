import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/widgets/score_ring.dart';
import '../../../../core/widgets/animated_counter.dart';
import '../../../../core/widgets/pressable_card.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../sessions/presentation/pages/session_detail_page.dart';
import '../../../notifications/presentation/pages/notifications_sheet.dart';
import '../../../ai/presentation/pages/ai_live_overlay.dart';

/// Main dashboard page — now powered by mock data with full animations.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  String _activeFilter = 'All';
  bool _isLoading = false;
  List<MockSession> _sessions = [];
  int _visibleCount = 10;

  static const _filters = [
    'All', 'Fruit Picking', 'High Score', 'Completed', 'In Progress', 'Failed',
  ];

  late AnimationController _bellCtrl;

  @override
  void initState() {
    super.initState();
    _bellCtrl = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _bellCtrl.dispose();
    super.dispose();
  }

  void _loadData({bool refresh = false}) async {
    if (refresh) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
    }
    setState(() {
      _sessions = MockData.sessions;
      _isLoading = false;
      _visibleCount = 10;
    });
  }

  List<MockSession> get _filteredSessions {
    List<MockSession> list;
    switch (_activeFilter) {
      case 'Fruit Picking':
        list = _sessions.where((s) => s.exerciseType == 'Fruit Picking').toList();
        break;
      case 'High Score':
        list = _sessions.where((s) => s.score >= 70).toList();
        break;
      case 'Completed':
        list = _sessions.where((s) => s.status == 'Completed').toList();
        break;
      case 'In Progress':
        list = _sessions.where((s) => s.status == 'In Progress').toList();
        break;
      case 'Failed':
        list = _sessions.where((s) => s.status == 'Failed' || s.score == 0).toList();
        break;
      default:
        list = _sessions;
    }
    return list.take(_visibleCount).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredSessions;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primaryAccent,
          backgroundColor: AppColors.surfaceVariant,
          onRefresh: () async => _loadData(refresh: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            slivers: [
              // ── Header ─────────────────────────────────────────────
              SliverToBoxAdapter(child: _buildHeader(context)),

              // ── Stat Cards ──────────────────────────────────────────
              SliverToBoxAdapter(child: _buildStatCards(context)),

              // ── Section header ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent Sessions',
                          style: TextStyle(color: AppColors.textPrimary,
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      GestureDetector(
                        onTap: () => _scrollToBottom(),
                        child: Text(
                          '${filtered.length} sessions',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Filter chips ────────────────────────────────────────
              SliverToBoxAdapter(child: _buildFilterChips()),

              // ── Session list ────────────────────────────────────────
              if (_isLoading)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => const SessionItemSkeleton(),
                    childCount: 5,
                  ),
                )
              else if (filtered.isEmpty)
                const SliverFillRemaining(
                    hasScrollBody: false, child: _EmptyView())
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _SessionCard(
                      session: filtered[i],
                      index: i,
                      onTap: () => Navigator.push(
                        context,
                        _slideRoute(SessionDetailPage(
                            sessionId: filtered[i].id)),
                      ),
                      onDelete: () => setState(
                          () => _sessions.removeWhere(
                              (s) => s.id == filtered[i].id)),
                    ),
                    childCount: filtered.length,
                  ),
                ),

              // Load more button
              if (!_isLoading &&
                  _visibleCount < _getFilteredTotal())
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _visibleCount += 10);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryAccent,
                        side: const BorderSide(
                            color: AppColors.borderMedium),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Load More'),
                    ),
                  ),
                ),

              const SliverPadding(
                  padding: EdgeInsets.only(bottom: AppSpacing.bottomSafe)),
            ],
          ),
        ),
      ),
    );
  }

  int _getFilteredTotal() {
    switch (_activeFilter) {
      case 'Fruit Picking':
        return _sessions.where((s) => s.exerciseType == 'Fruit Picking').length;
      case 'High Score': return _sessions.where((s) => s.score >= 70).length;
      case 'Completed': return _sessions.where((s) => s.status == 'Completed').length;
      case 'In Progress': return _sessions.where((s) => s.status == 'In Progress').length;
      case 'Failed': return _sessions.where((s) => s.status == 'Failed' || s.score == 0).length;
      default: return _sessions.length;
    }
  }

  void _scrollToBottom() {}

  Widget _buildHeader(BuildContext context) {
    final unreadCount = MockData.notifications.where((n) => !n.read).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome, Dr. Rai Rian',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                Text('NeuroLift VR Analytics',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontSize: 22, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          // AI Live button
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const AiLiveOverlay(),
                opaque: false,
                barrierColor: Colors.black54,
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
              ),
            ),
            child: _PulsingAiBadge(),
          ),
          const SizedBox(width: 8),
          // Notification bell
          GestureDetector(
            onTap: () {
              _bellCtrl.forward().then((_) => _bellCtrl.reverse());
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => const NotificationsSheet(),
              );
            },
            child: AnimatedBuilder(
              animation: _bellCtrl,
              builder: (_, child) => Transform.rotate(
                angle: _bellCtrl.value * 0.3 *
                    ((_bellCtrl.status == AnimationStatus.forward) ? 1 : -1),
                child: child,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_outlined,
                      color: AppColors.textSecondary, size: 26),
                  if (unreadCount > 0)
                    Positioned(
                      right: -2, top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                            color: AppColors.error, shape: BoxShape.circle),
                        child: Text('$unreadCount',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 8,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildStatCards(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _StatCard(
            icon: Icons.monitor_heart_outlined,
            label: 'Sessions Today',
            value: MockData.totalSessionsToday.toDouble(),
            color: AppColors.primaryAccent,
            onTap: () {},
          ),
          _StatCard(
            icon: Icons.score_rounded,
            label: 'Avg. Score',
            value: MockData.averageScore,
            color: AppColors.secondaryAccent,
            formatter: (v) => v.toStringAsFixed(1),
            onTap: () {},
          ),
          _StatCard(
            icon: Icons.pending_actions_rounded,
            label: 'Pending Review',
            value: MockData.pendingReviewCount.toDouble(),
            color: AppColors.warning,
            onTap: () {},
          ),
          _StatCard(
            icon: Icons.people_alt_rounded,
            label: 'Active Patients',
            value: MockData.activePatientsCount.toDouble(),
            color: AppColors.success,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (_, i) {
          final f = _filters[i];
          final active = f == _activeFilter;
          return GestureDetector(
            onTap: () => setState(() {
              _activeFilter = f;
              _visibleCount = 10;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primaryAccent
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
                boxShadow: active
                    ? [BoxShadow(
                        color: AppColors.primaryAccent.withValues(alpha: 0.3),
                        blurRadius: 8,
                      )]
                    : null,
              ),
              child: Text(f,
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
}

// ── Pulsing AI Badge ──────────────────────────────────────────────────────────
class _PulsingAiBadge extends StatefulWidget {
  @override
  State<_PulsingAiBadge> createState() => _PulsingAiBadgeState();
}

class _PulsingAiBadgeState extends State<_PulsingAiBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(seconds: 2), vsync: this)
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.4)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => Transform.scale(
              scale: _pulse.value,
              child: Container(
                width: 7, height: 7,
                decoration: const BoxDecoration(
                    color: AppColors.success, shape: BoxShape.circle),
              ),
            ),
          ),
          const SizedBox(width: 5),
          const Text('AI Live',
              style: TextStyle(
                  color: AppColors.success,
                  fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final Color color;
  final String Function(double)? formatter;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon, required this.label, required this.value,
    required this.color, this.formatter, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            AnimatedCounter(
              target: value,
              formatter: formatter,
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24, fontWeight: FontWeight.w700),
            ),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ── Session Card ──────────────────────────────────────────────────────────────
class _SessionCard extends StatefulWidget {
  final MockSession session;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SessionCard({
    required this.session, required this.index,
    required this.onTap, required this.onDelete,
  });

  @override
  State<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<_SessionCard>
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
            begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  String _relTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday, ${_formatHM(dt)}';
    return '${diff.inDays}d ago';
  }

  String _formatHM(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $p';
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Dismissible(
          key: Key(s.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => widget.onDelete(),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_rounded, color: AppColors.error),
          ),
          child: PressableCard(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            padding: const EdgeInsets.all(14),
            onTap: widget.onTap,
            child: Row(
              children: [
                ScoreRing(
                    score: s.score,
                    size: 50,
                    strokeWidth: 3.5),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.patientName,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Text(s.exerciseType,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(_relTime(s.timestamp),
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
                _StatusBadge(status: s.status),
              ],
            ),
          ),
        ),
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
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status,
          style: TextStyle(
              color: fg, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.filter_list_off_rounded,
                color: AppColors.textMuted, size: 48),
            SizedBox(height: 12),
            Text('No sessions match this filter',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
      );
}

Route _slideRoute(Widget page) => PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position:
            Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
        child: child,
      ),
    );
