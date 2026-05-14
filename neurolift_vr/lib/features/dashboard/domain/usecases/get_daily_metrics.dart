import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/summary_metrics_entity.dart';
import '../repositories/dashboard_repository.dart';

/// Fetches today's aggregated summary metrics from the repository.
class GetDailyMetrics extends UseCase<SummaryMetricsEntity, NoParams> {
  final DashboardRepository repository;

  GetDailyMetrics(this.repository);

  @override
  Future<Either<Failure, SummaryMetricsEntity>> call(NoParams params) {
    return repository.getDailyMetrics();
  }
}
