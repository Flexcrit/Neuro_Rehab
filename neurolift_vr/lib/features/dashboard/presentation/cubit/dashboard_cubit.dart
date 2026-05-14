import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/entities/summary_metrics_entity.dart';
import '../../domain/usecases/get_daily_metrics.dart';
import '../../domain/usecases/get_recent_sessions.dart';

part 'dashboard_state.dart';

/// Cubit managing the state of the main Dashboard page.
///
/// Injects [GetDailyMetrics] and [GetRecentSessions] use cases
/// following Dependency Inversion. Handles loading, filtering,
/// and error states.
class DashboardCubit extends Cubit<DashboardState> {
  final GetDailyMetrics getDailyMetrics;
  final GetRecentSessions getRecentSessions;

  DashboardCubit({
    required this.getDailyMetrics,
    required this.getRecentSessions,
  }) : super(const DashboardInitial());

  /// Fetches both metrics and sessions concurrently.
  Future<void> loadDashboard() async {
    emit(const DashboardLoading());

    final results = await Future.wait([
      getDailyMetrics(const NoParams()),
      getRecentSessions(const NoParams()),
    ]);

    final metricsResult = results[0];
    final sessionsResult = results[1];

    // Check for failures
    SummaryMetricsEntity? metrics;
    List<SessionEntity>? sessions;

    metricsResult.fold(
      (failure) => null,
      (data) => metrics = data as SummaryMetricsEntity,
    );

    sessionsResult.fold(
      (failure) => null,
      (data) => sessions = data as List<SessionEntity>,
    );

    if (metrics != null && sessions != null) {
      emit(DashboardLoaded(
        metrics: metrics!,
        allSessions: sessions!,
        filteredSessions: sessions!,
        activeFilter: 'All',
      ));
    } else {
      // Return the first failure message found
      String errorMsg = 'An unknown error occurred.';
      metricsResult.fold(
        (failure) => errorMsg = failure.message,
        (_) {},
      );
      sessionsResult.fold(
        (failure) => errorMsg = failure.message,
        (_) {},
      );
      emit(DashboardError(message: errorMsg));
    }
  }

  /// Filters the in-memory session list based on the selected filter chip.
  void changeFilter(String filter) {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;

    List<SessionEntity> filtered;

    switch (filter) {
      case 'Fruit Picking':
        filtered = currentState.allSessions
            .where((s) => s.activityType == 'Fruit Picking')
            .toList();
        break;
      case 'High Score':
        filtered = currentState.allSessions
            .where((s) => s.score >= 70)
            .toList();
        break;
      case 'Completed':
        filtered = currentState.allSessions
            .where((s) => s.status == 'Completed')
            .toList();
        break;
      case 'In Progress':
        filtered = currentState.allSessions
            .where((s) => s.status == 'In Progress')
            .toList();
        break;
      case 'All':
      default:
        filtered = currentState.allSessions;
        break;
    }

    emit(currentState.copyWith(
      filteredSessions: filtered,
      activeFilter: filter,
    ));
  }

  /// Refreshes all dashboard data.
  Future<void> refresh() async => loadDashboard();
}
