part of 'dashboard_cubit.dart';

/// Sealed state hierarchy for the Dashboard feature.
///
/// Uses [Equatable] for value-based equality comparisons so
/// [BlocBuilder] only rebuilds when the state actually changes.
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state — no data loaded yet.
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Loading state — data is being fetched or the stream is connecting.
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Loaded state — live data is available for rendering.
///
/// Contains both the raw session list and the derived aggregate metrics
/// (`totalToday`, `avgScore`, `pendingCount`) so the UI never has to
/// compute them on the render thread.
class DashboardLoaded extends DashboardState {
  /// All sessions from the current stream snapshot (newest first).
  final List<SessionEntity> sessions;

  /// Full unfiltered session list — retained for filter resets.
  final List<SessionEntity> allSessions;

  /// Subset of [allSessions] that matches the active filter chip.
  final List<SessionEntity> filteredSessions;

  /// Currently active filter label ("All", "Completed", etc.).
  final String activeFilter;

  /// Summary metrics — used by [SummaryMetricsRow].
  final SummaryMetricsEntity metrics;

  /// Number of sessions whose timestamp falls on today (local time).
  final int totalToday;

  /// Mean score across all sessions with a non-zero score.
  final double avgScore;

  /// Count of sessions awaiting AI analysis pipeline completion.
  final int pendingCount;

  const DashboardLoaded({
    required this.sessions,
    required this.allSessions,
    required this.filteredSessions,
    this.activeFilter = 'All',
    required this.metrics,
    required this.totalToday,
    required this.avgScore,
    required this.pendingCount,
  });

  @override
  List<Object?> get props => [
        sessions,
        allSessions,
        filteredSessions,
        activeFilter,
        metrics,
        totalToday,
        avgScore,
        pendingCount,
      ];

  DashboardLoaded copyWith({
    List<SessionEntity>? sessions,
    List<SessionEntity>? allSessions,
    List<SessionEntity>? filteredSessions,
    String? activeFilter,
    SummaryMetricsEntity? metrics,
    int? totalToday,
    double? avgScore,
    int? pendingCount,
  }) {
    return DashboardLoaded(
      sessions: sessions ?? this.sessions,
      allSessions: allSessions ?? this.allSessions,
      filteredSessions: filteredSessions ?? this.filteredSessions,
      activeFilter: activeFilter ?? this.activeFilter,
      metrics: metrics ?? this.metrics,
      totalToday: totalToday ?? this.totalToday,
      avgScore: avgScore ?? this.avgScore,
      pendingCount: pendingCount ?? this.pendingCount,
    );
  }
}

/// Error state — an error occurred during data fetching or stream failure.
class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
