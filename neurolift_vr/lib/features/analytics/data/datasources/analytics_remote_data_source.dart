import '../../domain/entities/analytics_entity.dart';

/// Remote data source for analytics with mock trend data.
abstract class AnalyticsRemoteDataSource {
  Future<AnalyticsEntity> getRecoveryTrends();
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  @override
  Future<AnalyticsEntity> getRecoveryTrends() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    return const AnalyticsEntity(
      weeklyScores: [
        DailyScorePoint(day: 'Mon', score: 55),
        DailyScorePoint(day: 'Tue', score: 62),
        DailyScorePoint(day: 'Wed', score: 58),
        DailyScorePoint(day: 'Thu', score: 71),
        DailyScorePoint(day: 'Fri', score: 68),
        DailyScorePoint(day: 'Sat', score: 79),
        DailyScorePoint(day: 'Sun', score: 73),
      ],
      sessionBreakdown: [
        SessionBreakdown(activityType: 'Fruit Picking', count: 12, averageScore: 72.5),
        SessionBreakdown(activityType: 'Scenario Switching', count: 8, averageScore: 68.0),
        SessionBreakdown(activityType: 'Balance Training', count: 6, averageScore: 85.3),
        SessionBreakdown(activityType: 'Cognitive Recall', count: 4, averageScore: 51.0),
      ],
      overallProgress: 0.73,
      totalSessionsThisWeek: 30,
      averageCognitiveLoad: 62.4,
      averageMotorScore: 71.8,
    );
  }
}
