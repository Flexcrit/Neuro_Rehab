import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/analytics_entity.dart';

/// Abstract contract for the analytics data repository.
abstract class AnalyticsRepository {
  Future<Either<Failure, AnalyticsEntity>> getRecoveryTrends();
}
