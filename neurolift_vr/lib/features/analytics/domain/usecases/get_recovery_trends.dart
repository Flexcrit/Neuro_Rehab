import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/analytics_entity.dart';
import '../repositories/analytics_repository.dart';

/// Fetches recovery trend data for the analytics dashboard.
class GetRecoveryTrends extends UseCase<AnalyticsEntity, NoParams> {
  final AnalyticsRepository repository;

  GetRecoveryTrends(this.repository);

  @override
  Future<Either<Failure, AnalyticsEntity>> call(NoParams params) {
    return repository.getRecoveryTrends();
  }
}
