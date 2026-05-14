import 'package:equatable/equatable.dart';

/// Domain entity for top-level dashboard summary metrics.
///
/// Aggregated statistics displayed in the metrics row at the top
/// of the dashboard page.
class SummaryMetricsEntity extends Equatable {
  final int totalSessionsToday;
  final double averageScore;
  final int pendingReviews;
  final int activeVrHeadsets;

  const SummaryMetricsEntity({
    required this.totalSessionsToday,
    required this.averageScore,
    required this.pendingReviews,
    required this.activeVrHeadsets,
  });

  @override
  List<Object?> get props => [
        totalSessionsToday,
        averageScore,
        pendingReviews,
        activeVrHeadsets,
      ];
}
