import 'package:equatable/equatable.dart';

/// Domain entity for analytics trend data points.
class AnalyticsEntity extends Equatable {
  final List<DailyScorePoint> weeklyScores;
  final List<SessionBreakdown> sessionBreakdown;
  final double overallProgress; // 0.0 to 1.0
  final int totalSessionsThisWeek;
  final double averageCognitiveLoad;
  final double averageMotorScore;

  const AnalyticsEntity({
    required this.weeklyScores,
    required this.sessionBreakdown,
    required this.overallProgress,
    required this.totalSessionsThisWeek,
    required this.averageCognitiveLoad,
    required this.averageMotorScore,
  });

  @override
  List<Object?> get props => [
        weeklyScores, sessionBreakdown, overallProgress,
        totalSessionsThisWeek, averageCognitiveLoad, averageMotorScore,
      ];
}

class DailyScorePoint extends Equatable {
  final String day; // 'Mon', 'Tue', etc.
  final double score;

  const DailyScorePoint({required this.day, required this.score});

  @override
  List<Object?> get props => [day, score];
}

class SessionBreakdown extends Equatable {
  final String activityType;
  final int count;
  final double averageScore;

  const SessionBreakdown({
    required this.activityType,
    required this.count,
    required this.averageScore,
  });

  @override
  List<Object?> get props => [activityType, count, averageScore];
}
