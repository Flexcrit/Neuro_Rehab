import 'package:equatable/equatable.dart';

/// Domain entity representing a single VR rehabilitation session.
///
/// This is the pure business object — no JSON serialization or framework
/// dependencies belong here.
class SessionEntity extends Equatable {
  final String id;
  final String patientId;
  final String patientName;
  final String activityType;
  final int score;
  final DateTime timestamp;
  final String status;
  final bool hasAiInsights;
  final String? aiRecommendation;
  final String? rawMetrics;

  const SessionEntity({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.activityType,
    required this.score,
    required this.timestamp,
    required this.status,
    required this.hasAiInsights,
    this.aiRecommendation,
    this.rawMetrics,
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        patientName,
        activityType,
        score,
        timestamp,
        status,
        hasAiInsights,
        aiRecommendation,
        rawMetrics,
      ];
}
