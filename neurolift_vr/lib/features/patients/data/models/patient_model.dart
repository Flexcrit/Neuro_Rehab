import '../../domain/entities/patient_entity.dart';

/// Data model for [PatientEntity] with JSON serialization.
class PatientModel extends PatientEntity {
  const PatientModel({
    required super.id,
    required super.name,
    required super.age,
    required super.condition,
    required super.totalSessions,
    required super.averageScore,
    required super.lastSessionDate,
    required super.status,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      age: json['age'] as int? ?? 0,
      condition: json['condition'] as String? ?? '',
      totalSessions: json['total_sessions'] as int? ?? 0,
      averageScore: (json['average_score'] as num?)?.toDouble() ?? 0.0,
      lastSessionDate: json['last_session_date'] != null
          ? DateTime.parse(json['last_session_date'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? 'Active',
    );
  }
}
