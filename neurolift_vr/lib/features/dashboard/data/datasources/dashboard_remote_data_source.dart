import '../models/session_model.dart';
import '../models/summary_metrics_model.dart';

/// Contract for fetching dashboard data from a remote source (API or Firestore).
abstract class DashboardRemoteDataSource {
  Future<SummaryMetricsModel> getDailyMetrics();
  Future<List<SessionModel>> getRecentSessions();
}

/// Mock implementation simulating network latency and returning
/// hardcoded VR telemetry data for development and demo purposes.
///
/// Includes a variety of scores (0, 45, 72, 88, 100) to demonstrate
/// the dynamic color coding of the SessionCard score indicators.
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  @override
  Future<SummaryMetricsModel> getDailyMetrics() async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 800));

    return const SummaryMetricsModel(
      totalSessionsToday: 24,
      averageScore: 73.5,
      pendingReviews: 5,
      activeVrHeadsets: 3,
    );
  }

  @override
  Future<List<SessionModel>> getRecentSessions() async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 1200));

    final now = DateTime.now();

    return [
      SessionModel(
        id: 'session_001',
        patientId: 'patient_001',
        patientName: 'Rai Rian',
        activityType: 'Fruit Picking',
        score: 72,
        timestamp: now.subtract(const Duration(minutes: 15)),
        status: 'Completed',
        hasAiInsights: true,
        aiRecommendation:
            'Step 1: Increase grip strength exercises to 3x daily.\n'
            'Step 2: Introduce bilateral coordination drills.\n'
            'Step 3: Progress to fine motor precision tasks.',
        rawMetrics: 'Tremor: High, Grip: 2/10',
      ),
      SessionModel(
        id: 'session_002',
        patientId: 'patient_002',
        patientName: 'Dr. Amara Shah',
        activityType: 'Scenario Switching',
        score: 88,
        timestamp: now.subtract(const Duration(hours: 1)),
        status: 'Completed',
        hasAiInsights: true,
        aiRecommendation:
            'Step 1: Maintain current cognitive flexibility exercises.\n'
            'Step 2: Introduce dual-task paradigm challenges.\n'
            'Step 3: Gradually reduce visual cues for self-directed switching.',
      ),
      SessionModel(
        id: 'session_003',
        patientId: 'patient_003',
        patientName: 'James O\'Brien',
        activityType: 'Fruit Picking',
        score: 45,
        timestamp: now.subtract(const Duration(hours: 2)),
        status: 'In Progress',
        hasAiInsights: false,
      ),
      SessionModel(
        id: 'session_004',
        patientId: 'patient_004',
        patientName: 'Fatima Al-Rashid',
        activityType: 'Balance Training',
        score: 100,
        timestamp: now.subtract(const Duration(hours: 3)),
        status: 'Completed',
        hasAiInsights: true,
        aiRecommendation:
            'Step 1: Outstanding progress — advance to dynamic perturbation training.\n'
            'Step 2: Integrate VR locomotion with obstacle avoidance.\n'
            'Step 3: Schedule follow-up assessment in 48 hours.',
      ),
      SessionModel(
        id: 'session_005',
        patientId: 'patient_005',
        patientName: 'Marcus Chen',
        activityType: 'Cognitive Recall',
        score: 0,
        timestamp: now.subtract(const Duration(hours: 4)),
        status: 'Failed',
        hasAiInsights: false,
        rawMetrics: 'Session terminated early due to calibration error.',
      ),
      SessionModel(
        id: 'session_006',
        patientId: 'patient_001',
        patientName: 'Rai Rian',
        activityType: 'Scenario Switching',
        score: 65,
        timestamp: now.subtract(const Duration(hours: 5)),
        status: 'Completed',
        hasAiInsights: true,
        aiRecommendation:
            'Step 1: Focus on reaction time improvement drills.\n'
            'Step 2: Implement graded exposure to rapid scene changes.\n'
            'Step 3: Monitor for fatigue-related performance drops.',
      ),
      SessionModel(
        id: 'session_007',
        patientId: 'patient_006',
        patientName: 'Sarah Williams',
        activityType: 'Fruit Picking',
        score: 91,
        timestamp: now.subtract(const Duration(hours: 6)),
        status: 'Completed',
        hasAiInsights: true,
        aiRecommendation:
            'Step 1: Excellent hand-eye coordination — introduce weighted objects.\n'
            'Step 2: Transition to timed precision challenges.\n'
            'Step 3: Recommend discharge assessment within 1 week.',
      ),
    ];
  }
}
