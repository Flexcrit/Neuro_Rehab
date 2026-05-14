import '../models/patient_model.dart';

/// Remote data source for patient directory.
abstract class PatientsRemoteDataSource {
  Future<List<PatientModel>> getAllPatients();
}

/// Mock implementation with realistic patient data.
class PatientsRemoteDataSourceImpl implements PatientsRemoteDataSource {
  @override
  Future<List<PatientModel>> getAllPatients() async {
    await Future.delayed(const Duration(milliseconds: 900));
    final now = DateTime.now();

    return [
      PatientModel(
        id: 'patient_001',
        name: 'Rai Rian',
        age: 34,
        condition: 'Post-stroke motor deficit (R-hemisphere)',
        totalSessions: 18,
        averageScore: 68.5,
        lastSessionDate: now.subtract(const Duration(minutes: 15)),
        status: 'Active',
      ),
      PatientModel(
        id: 'patient_002',
        name: 'Dr. Amara Shah',
        age: 42,
        condition: 'Traumatic brain injury recovery',
        totalSessions: 24,
        averageScore: 82.3,
        lastSessionDate: now.subtract(const Duration(hours: 1)),
        status: 'Active',
      ),
      PatientModel(
        id: 'patient_003',
        name: 'James O\'Brien',
        age: 56,
        condition: 'Cervical myelopathy — fine motor impairment',
        totalSessions: 9,
        averageScore: 45.0,
        lastSessionDate: now.subtract(const Duration(hours: 2)),
        status: 'Active',
      ),
      PatientModel(
        id: 'patient_004',
        name: 'Fatima Al-Rashid',
        age: 29,
        condition: 'Multiple sclerosis — balance deficits',
        totalSessions: 31,
        averageScore: 91.2,
        lastSessionDate: now.subtract(const Duration(hours: 3)),
        status: 'Discharged',
      ),
      PatientModel(
        id: 'patient_005',
        name: 'Marcus Chen',
        age: 61,
        condition: 'Parkinson\'s disease — stage II',
        totalSessions: 5,
        averageScore: 32.0,
        lastSessionDate: now.subtract(const Duration(days: 2)),
        status: 'On Hold',
      ),
      PatientModel(
        id: 'patient_006',
        name: 'Sarah Williams',
        age: 38,
        condition: 'Spinal cord injury (T6) — upper extremity rehab',
        totalSessions: 22,
        averageScore: 78.8,
        lastSessionDate: now.subtract(const Duration(hours: 6)),
        status: 'Active',
      ),
    ];
  }
}
