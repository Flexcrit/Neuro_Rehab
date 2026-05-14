import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session_model.dart';
import '../models/summary_metrics_model.dart';

/// Contract for caching dashboard data locally.
abstract class DashboardLocalDataSource {
  Future<SummaryMetricsModel?> getCachedMetrics();
  Future<void> cacheMetrics(SummaryMetricsModel metrics);
  Future<List<SessionModel>?> getCachedSessions();
  Future<void> cacheSessions(List<SessionModel> sessions);
}

/// Implementation using SharedPreferences for lightweight caching.
class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _metricsKey = 'CACHED_DASHBOARD_METRICS';
  static const String _sessionsKey = 'CACHED_DASHBOARD_SESSIONS';

  DashboardLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<SummaryMetricsModel?> getCachedMetrics() async {
    final jsonStr = sharedPreferences.getString(_metricsKey);
    if (jsonStr == null) return null;
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    return SummaryMetricsModel.fromJson(json);
  }

  @override
  Future<void> cacheMetrics(SummaryMetricsModel metrics) async {
    await sharedPreferences.setString(_metricsKey, jsonEncode(metrics.toJson()));
  }

  @override
  Future<List<SessionModel>?> getCachedSessions() async {
    final jsonStr = sharedPreferences.getString(_sessionsKey);
    if (jsonStr == null) return null;
    final jsonList = jsonDecode(jsonStr) as List<dynamic>;
    return jsonList
        .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheSessions(List<SessionModel> sessions) async {
    final jsonList = sessions.map((s) => s.toJson()).toList();
    await sharedPreferences.setString(_sessionsKey, jsonEncode(jsonList));
  }
}
