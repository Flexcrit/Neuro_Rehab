import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/session_entity.dart';
import '../repositories/dashboard_repository.dart';

/// Fetches the list of recent VR rehabilitation sessions from the repository.
class GetRecentSessions extends UseCase<List<SessionEntity>, NoParams> {
  final DashboardRepository repository;

  GetRecentSessions(this.repository);

  @override
  Future<Either<Failure, List<SessionEntity>>> call(NoParams params) {
    return repository.getRecentSessions();
  }
}
