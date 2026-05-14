part of 'patients_cubit.dart';

abstract class PatientsState extends Equatable {
  const PatientsState();
  @override
  List<Object?> get props => [];
}

class PatientsInitial extends PatientsState {
  const PatientsInitial();
}

class PatientsLoading extends PatientsState {
  const PatientsLoading();
}

class PatientsLoaded extends PatientsState {
  final List<PatientEntity> patients;
  const PatientsLoaded({required this.patients});
  @override
  List<Object?> get props => [patients];
}

class PatientsError extends PatientsState {
  final String message;
  const PatientsError({required this.message});
  @override
  List<Object?> get props => [message];
}
