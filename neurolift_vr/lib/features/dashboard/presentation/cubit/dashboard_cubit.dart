import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../data/models/session_model.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/entities/summary_metrics_entity.dart';
import '../../domain/usecases/get_daily_metrics.dart';
import '../../domain/usecases/get_recent_sessions.dart';

part 'dashboard_state.dart';

/// Cubit managing the state of the main Dashboard page.
///
/// Supports two operational modes:
///
/// 1. **One-shot fetch** via [loadDashboard] — invokes the injected
///    [GetDailyMetrics] and [GetRecentSessions] use cases for immediate
///    data retrieval. This preserves backward compatibility with the
///    Clean Architecture use-case pipeline.
///
/// 2. **Real-time stream** via [initDashboardStream] — subscribes to
///    a live Firestore `snapshots()` stream on `vr_session_logs`,
///    automatically deriving `totalToday`, `avgScore`, and `pendingCount`
///    from each incoming `QuerySnapshot`.
///
/// The stream subscription is stored in [_sessionSubscription] and
/// deterministically cancelled in [close] to prevent memory leaks.
class DashboardCubit extends Cubit<DashboardState> {
  final GetDailyMetrics getDailyMetrics;
  final GetRecentSessions getRecentSessions;
  final FirebaseFirestore _firestore;

  /// Active Firestore realtime subscription. Cancelled on [close].
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _sessionSubscription;

  DashboardCubit({
    required this.getDailyMetrics,
    required this.getRecentSessions,
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        super(const DashboardInitial());

  // ═══════════════════════════════════════════════════════════════════════════
  // MODE 1 — One-shot fetch (backward-compatible with use-case pipeline)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fetches both metrics and sessions concurrently via use cases.
  Future<void> loadDashboard() async {
    emit(const DashboardLoading());

    final results = await Future.wait([
      getDailyMetrics(const NoParams()),
      getRecentSessions(const NoParams()),
    ]);

    final metricsResult = results[0];
    final sessionsResult = results[1];

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
      final derived = _computeMetrics(sessions!);
      emit(DashboardLoaded(
        sessions: sessions!,
        allSessions: sessions!,
        filteredSessions: sessions!,
        activeFilter: 'All',
        metrics: metrics!,
        totalToday: derived.totalToday,
        avgScore: derived.avgScore,
        pendingCount: derived.pendingCount,
      ));
    } else {
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

  // ═══════════════════════════════════════════════════════════════════════════
  // MODE 2 — Real-time Firestore stream
  // ═══════════════════════════════════════════════════════════════════════════

  /// Subscribes to `vr_session_logs` via a real-time Firestore stream.
  ///
  /// Each incoming [QuerySnapshot] is mapped to [SessionModel] objects
  /// with per-document error isolation — a single malformed document
  /// never crashes the entire stream.
  ///
  /// Derived metrics (`totalToday`, `avgScore`, `pendingCount`) are
  /// computed server-side fresh on every snapshot.
  void initDashboardStream() {
    // Prevent duplicate subscriptions
    _sessionSubscription?.cancel();

    emit(const DashboardLoading());

    _sessionSubscription = _firestore
        .collection('vr_session_logs')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .listen(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        _handleSnapshot(snapshot);
      },
      onError: (Object error, StackTrace stackTrace) {
        developer.log(
          '[DashboardCubit] Stream error',
          error: error,
          stackTrace: stackTrace,
          name: 'neurolift.cubit',
        );
        emit(DashboardError(
          message: 'Live data stream interrupted. '
              'Check your network connection and retry.',
        ));
      },
      cancelOnError: false, // Keep subscription alive on transient drops
    );
  }

  /// Processes a single [QuerySnapshot] into a [DashboardLoaded] emission.
  void _handleSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final List<SessionEntity> sessions = [];

    for (final doc in snapshot.docs) {
      try {
        sessions.add(SessionModel.fromJson(doc.data(), docId: doc.id));
      } catch (e, st) {
        // Per-document error isolation — log but never crash the stream
        developer.log(
          '[DashboardCubit] Skipping malformed doc ${doc.id}',
          error: e,
          stackTrace: st,
          name: 'neurolift.cubit',
        );
      }
    }

    final derived = _computeMetrics(sessions);

    // Preserve filter state across stream updates
    final currentFilter =
        state is DashboardLoaded
            ? (state as DashboardLoaded).activeFilter
            : 'All';

    final filtered = _applyFilter(sessions, currentFilter);

    emit(DashboardLoaded(
      sessions: sessions,
      allSessions: sessions,
      filteredSessions: filtered,
      activeFilter: currentFilter,
      metrics: SummaryMetricsEntity(
        totalSessionsToday: derived.totalToday,
        averageScore: derived.avgScore,
        pendingReviews: derived.pendingCount,
        activeVrHeadsets: 3, // Static device count until headset API
      ),
      totalToday: derived.totalToday,
      avgScore: derived.avgScore,
      pendingCount: derived.pendingCount,
    ));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED — Filter + Metrics logic
  // ═══════════════════════════════════════════════════════════════════════════

  /// Filters the in-memory session list based on the selected filter chip.
  void changeFilter(String filter) {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;

    final filtered = _applyFilter(currentState.allSessions, filter);

    emit(currentState.copyWith(
      filteredSessions: filtered,
      activeFilter: filter,
    ));
  }

  /// Applies the named [filter] against a session list.
  List<SessionEntity> _applyFilter(
    List<SessionEntity> sessions,
    String filter,
  ) {
    switch (filter) {
      case 'Fruit Picking':
        return sessions
            .where((s) => s.activityType == 'Fruit Picking')
            .toList();
      case 'High Score':
        return sessions.where((s) => s.score >= 70).toList();
      case 'Completed':
        return sessions.where((s) => s.status == 'Completed').toList();
      case 'In Progress':
        return sessions
            .where((s) => s.status == 'In Progress')
            .toList();
      case 'All':
      default:
        return sessions;
    }
  }

  /// Computes derived aggregate metrics from a session list.
  _DerivedMetrics _computeMetrics(List<SessionEntity> sessions) {
    final now = DateTime.now();
    int totalToday = 0;
    double totalScore = 0;
    int scoredCount = 0;
    int pendingCount = 0;

    for (final s in sessions) {
      // Sessions from today
      if (s.timestamp.year == now.year &&
          s.timestamp.month == now.month &&
          s.timestamp.day == now.day) {
        totalToday++;
      }

      // Score aggregation (skip zeroes)
      if (s.score > 0) {
        totalScore += s.score;
        scoredCount++;
      }

      // Pending AI analysis detection
      if (s.status == 'Analysis Pending' || s.status == 'In Progress') {
        pendingCount++;
      }
    }

    return _DerivedMetrics(
      totalToday: totalToday > 0 ? totalToday : sessions.length,
      avgScore: scoredCount > 0 ? totalScore / scoredCount : 0.0,
      pendingCount: pendingCount,
    );
  }

  /// Refreshes all dashboard data (one-shot mode).
  Future<void> refresh() async => loadDashboard();

  // ═══════════════════════════════════════════════════════════════════════════
  // LIFECYCLE — Leak-safe cleanup
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> close() {
    _sessionSubscription?.cancel();
    _sessionSubscription = null;
    return super.close();
  }
}

/// Internal value type for computed aggregate metrics.
class _DerivedMetrics {
  final int totalToday;
  final double avgScore;
  final int pendingCount;

  const _DerivedMetrics({
    required this.totalToday,
    required this.avgScore,
    required this.pendingCount,
  });
}
