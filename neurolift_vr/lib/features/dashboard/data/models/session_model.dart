import '../../domain/entities/session_entity.dart';

/// Data model for [SessionEntity] with JSON serialization.
///
/// This model sits in the data layer and handles the mapping between
/// raw JSON (from Firestore or REST API) and the domain entity.
class SessionModel extends SessionEntity {
  const SessionModel({
    required super.id,
    required super.patientId,
    required super.patientName,
    required super.activityType,
    required super.score,
    required super.timestamp,
    required super.status,
    required super.hasAiInsights,
    super.aiRecommendation,
    super.rawMetrics,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    // Robust score parsing to handle both int, double, and String from Firestore
    int parsedScore = 0;
    final rawScore = json['hand_tracking_score'] ?? json['score'] ?? 0;
    if (rawScore is num) {
      parsedScore = rawScore.toInt();
    } else if (rawScore is String) {
      parsedScore = int.tryParse(rawScore) ?? 0;
    }

    // Robust timestamp parsing
    DateTime parsedTimestamp;
    final rawTimestamp = json['timestamp'];
    if (rawTimestamp is DateTime) {
      parsedTimestamp = rawTimestamp;
    } else if (rawTimestamp != null && rawTimestamp.runtimeType.toString().contains('Timestamp')) {
      // Firestore Timestamp — call toDate()
      parsedTimestamp = (rawTimestamp as dynamic).toDate();
    } else if (rawTimestamp is String) {
      parsedTimestamp = DateTime.tryParse(rawTimestamp) ?? DateTime.now();
    } else {
      parsedTimestamp = DateTime.now();
    }

    final status = json['status'] as String? ?? 'Unknown';
    final recommendation = json['ai_recommendation'] as String?;

    return SessionModel(
      id: docId ?? json['id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? json['patientId'] as String? ?? '',
      patientName: json['patient_name'] as String? ?? json['patientName'] as String? ?? 'Unknown',
      activityType: json['activity_type'] as String? ?? json['scenario'] as String? ?? 'N/A',
      score: parsedScore,
      timestamp: parsedTimestamp,
      status: status,
      hasAiInsights: recommendation != null && recommendation.isNotEmpty,
      aiRecommendation: recommendation,
      rawMetrics: json['raw_metrics'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'patient_name': patientName,
      'activity_type': activityType,
      'score': score,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'ai_recommendation': aiRecommendation,
      'raw_metrics': rawMetrics,
    };
  }

  /// Creates a copy with overridden fields.
  SessionModel copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? activityType,
    int? score,
    DateTime? timestamp,
    String? status,
    bool? hasAiInsights,
    String? aiRecommendation,
    String? rawMetrics,
  }) {
    return SessionModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      activityType: activityType ?? this.activityType,
      score: score ?? this.score,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      hasAiInsights: hasAiInsights ?? this.hasAiInsights,
      aiRecommendation: aiRecommendation ?? this.aiRecommendation,
      rawMetrics: rawMetrics ?? this.rawMetrics,
    );
  }
}
