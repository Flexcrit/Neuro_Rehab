import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/session_entity.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/neuro_app_bar.dart';
import '../widgets/neuro_bottom_nav.dart';
import '../widgets/summary_metric_card.dart';
import '../widgets/filter_chip_row.dart';
import '../widgets/session_list_item.dart';
import '../../../../core/constants/strings.dart';

/// Main dashboard page assembled using Clean Architecture widgets.
///
/// Uses [BlocBuilder] to reactively render based on [DashboardState].
/// Hosts [NeuroAppBar] in a [CustomScrollView] and delegates navigation
/// to [NeuroBottomNav].
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: NeuroBottomNav(
        currentIndex: _navIndex,
        onTap: (index) => setState(() => _navIndex = index),
      ),
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading || state is DashboardInitial) {
              return const _LoadingView();
            }

            if (state is DashboardError) {
              return _ErrorView(
                message: state.message,
                onRetry: () =>
                    context.read<DashboardCubit>().loadDashboard(),
              );
            }

            if (state is DashboardLoaded) {
              return RefreshIndicator(
                color: AppColors.primaryAccent,
                backgroundColor: AppColors.surface,
                onRefresh: () =>
                    context.read<DashboardCubit>().refresh(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // ── Pinned App Bar ──────────────────────────────────
                    const NeuroAppBar(),

                    // ── Summary Metrics Row ─────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 16, bottom: 12),
                        child: SummaryMetricsRow(metrics: state.metrics),
                      ),
                    ),

                    // ── Section Header ──────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 8, 20, 12),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.recentSessions,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall,
                            ),
                            Text(
                              '${state.filteredSessions.length} sessions',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Filter Chip Row ─────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: FilterChipRow(
                          activeFilter: state.activeFilter,
                          onFilterChanged: (filter) => context
                              .read<DashboardCubit>()
                              .changeFilter(filter),
                        ),
                      ),
                    ),

                    // ── Session Sliver List ─────────────────────────────
                    if (state.filteredSessions.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyFilterView(),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final session =
                                state.filteredSessions[index];
                            return SessionListItem(
                              session: session,
                              onTap: session.hasAiInsights
                                  ? () =>
                                      _showAiInsights(context, session)
                                  : null,
                            );
                          },
                          childCount: state.filteredSessions.length,
                        ),
                      ),

                    // Bottom padding for nav bar clearance
                    const SliverPadding(
                        padding: EdgeInsets.only(bottom: 100)),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // ── AI Insights Bottom Sheet ──────────────────────────────────────────────
  void _showAiInsights(BuildContext ctx, SessionEntity session) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ClipRRect(
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.6,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24)),
              border: const Border(
                top: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.fromLTRB(24, 14, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textTertiary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Header row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: AppColors.primaryGradient,
                        ),
                        child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AI Recovery Plan',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Generated by Gemini 2.0 Flash',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Recommendation body
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      session.aiRecommendation ??
                          'No recommendation available.',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Footer metadata
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          color: AppColors.textTertiary, size: 15),
                      const SizedBox(width: 5),
                      Text(
                        session.patientName,
                        style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12),
                      ),
                      const Spacer(),
                      Icon(Icons.score_rounded,
                          color: AppColors.scoreColor(session.score),
                          size: 15),
                      const SizedBox(width: 5),
                      Text(
                        'Score: ${session.score}',
                        style: TextStyle(
                          color: AppColors.scoreColor(session.score),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Private Support Widgets ───────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: AppColors.primaryAccent,
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Loading dashboard...',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFilterView extends StatelessWidget {
  const _EmptyFilterView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.filter_list_off_rounded,
              color: AppColors.textTertiary, size: 48),
          const SizedBox(height: 12),
          const Text(
            'No sessions match this filter.',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
