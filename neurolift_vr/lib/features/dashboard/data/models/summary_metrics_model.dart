import '../../domain/entities/summary_metrics_entity.dart';

/// Data model for [SummaryMetricsEntity] with JSON serialization.
class SummaryMetricsModel extends SummaryMetricsEntity {
  const SummaryMetricsModel({
    required super.totalSessionsToday,
    required super.averageScore,
    required super.pendingReviews,
    required super.activeVrHeadsets,
  });

  factory SummaryMetricsModel.fromJson(Map<String, dynamic> json) {
    return SummaryMetricsModel(
      totalSessionsToday: json['total_sessions_today'] as int? ?? 0,
      averageScore: (json['average_score'] as num?)?.toDouble() ?? 0.0,
      pendingReviews: json['pending_reviews'] as int? ?? 0,
      activeVrHeadsets: json['active_vr_headsets'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_sessions_today': totalSessionsToday,
      'average_score': averageScore,
      'pending_reviews': pendingReviews,
      'active_vr_headsets': activeVrHeadsets,
    };
  }
}
