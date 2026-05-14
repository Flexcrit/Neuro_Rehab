import 'package:equatable/equatable.dart';

/// Domain entity representing a patient in the system.
class PatientEntity extends Equatable {
  final String id;
  final String name;
  final int age;
  final String condition;
  final int totalSessions;
  final double averageScore;
  final DateTime lastSessionDate;
  final String status; // 'Active', 'Discharged', 'On Hold'

  const PatientEntity({
    required this.id,
    required this.name,
    required this.age,
    required this.condition,
    required this.totalSessions,
    required this.averageScore,
    required this.lastSessionDate,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id, name, age, condition,
        totalSessions, averageScore, lastSessionDate, status,
      ];
}
