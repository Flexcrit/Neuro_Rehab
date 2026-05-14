part of 'dashboard_cubit.dart';

/// Sealed state hierarchy for the Dashboard feature.
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state — no data loaded yet.
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Loading state — data is being fetched.
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Loaded state — data is available for rendering.
class DashboardLoaded extends DashboardState {
  final SummaryMetricsEntity metrics;
  final List<SessionEntity> allSessions;
  final List<SessionEntity> filteredSessions;
  final String activeFilter;

  const DashboardLoaded({
    required this.metrics,
    required this.allSessions,
    required this.filteredSessions,
    this.activeFilter = 'All',
  });

  @override
  List<Object?> get props => [metrics, allSessions, filteredSessions, activeFilter];

  DashboardLoaded copyWith({
    SummaryMetricsEntity? metrics,
    List<SessionEntity>? allSessions,
    List<SessionEntity>? filteredSessions,
    String? activeFilter,
  }) {
    return DashboardLoaded(
      metrics: metrics ?? this.metrics,
      allSessions: allSessions ?? this.allSessions,
      filteredSessions: filteredSessions ?? this.filteredSessions,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }
}

/// Error state — an error occurred during data fetching.
class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
