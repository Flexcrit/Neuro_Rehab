import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/usecases/get_all_patients.dart';

part 'patients_state.dart';

/// Cubit managing the state of the Patients Directory page.
class PatientsCubit extends Cubit<PatientsState> {
  final GetAllPatients getAllPatients;

  PatientsCubit({required this.getAllPatients}) : super(const PatientsInitial());

  Future<void> loadPatients() async {
    emit(const PatientsLoading());

    final result = await getAllPatients(const NoParams());

    result.fold(
      (failure) => emit(PatientsError(message: failure.message)),
      (patients) => emit(PatientsLoaded(patients: patients)),
    );
  }
}
