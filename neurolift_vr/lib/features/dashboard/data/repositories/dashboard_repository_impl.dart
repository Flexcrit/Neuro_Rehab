import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/entities/summary_metrics_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_data_source.dart';
import '../datasources/dashboard_remote_data_source.dart';

/// Concrete implementation of [DashboardRepository].
///
/// Orchestrates between remote and local data sources with
/// network-aware fallback logic.
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final DashboardLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, SummaryMetricsEntity>> getDailyMetrics() async {
    if (await networkInfo.isConnected) {
      try {
        final metrics = await remoteDataSource.getDailyMetrics();
        await localDataSource.cacheMetrics(metrics);
        return Right(metrics);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      try {
        final cached = await localDataSource.getCachedMetrics();
        if (cached != null) {
          return Right(cached);
        }
        return const Left(CacheFailure());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> getRecentSessions() async {
    if (await networkInfo.isConnected) {
      try {
        final sessions = await remoteDataSource.getRecentSessions();
        await localDataSource.cacheSessions(sessions);
        return Right(sessions);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      try {
        final cached = await localDataSource.getCachedSessions();
        if (cached != null) {
          return Right(cached);
        }
        return const Left(CacheFailure());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }
}
