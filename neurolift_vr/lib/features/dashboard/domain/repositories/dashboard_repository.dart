import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/session_entity.dart';
import '../entities/summary_metrics_entity.dart';

/// Abstract contract for the dashboard data repository.
///
/// Follows the Dependency Inversion Principle — the domain layer defines
/// the interface, the data layer provides the implementation.
abstract class DashboardRepository {
  /// Fetches today's aggregated summary metrics.
  Future<Either<Failure, SummaryMetricsEntity>> getDailyMetrics();

  /// Fetches the list of recent VR rehabilitation sessions.
  Future<Either<Failure, List<SessionEntity>>> getRecentSessions();
}
