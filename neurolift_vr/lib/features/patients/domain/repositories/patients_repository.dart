import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/patient_entity.dart';

/// Abstract contract for the patients data repository.
abstract class PatientsRepository {
  Future<Either<Failure, List<PatientEntity>>> getAllPatients();
}
