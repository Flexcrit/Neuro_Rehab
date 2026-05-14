import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/patient_entity.dart';
import '../repositories/patients_repository.dart';

/// Fetches the full list of registered patients.
class GetAllPatients extends UseCase<List<PatientEntity>, NoParams> {
  final PatientsRepository repository;

  GetAllPatients(this.repository);

  @override
  Future<Either<Failure, List<PatientEntity>>> call(NoParams params) {
    return repository.getAllPatients();
  }
}
