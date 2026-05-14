import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/repositories/patients_repository.dart';
import '../datasources/patients_remote_data_source.dart';

/// Concrete implementation of [PatientsRepository].
class PatientsRepositoryImpl implements PatientsRepository {
  final PatientsRemoteDataSource remoteDataSource;

  PatientsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PatientEntity>>> getAllPatients() async {
    try {
      final patients = await remoteDataSource.getAllPatients();
      return Right(patients);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
