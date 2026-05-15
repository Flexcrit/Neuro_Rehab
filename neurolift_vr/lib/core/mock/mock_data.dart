// NeuroLift VR — Central mock data store
// All data classes are defined inline below.

/// Central mock data store for all app features.
/// Pre-populated with realistic neurological rehabilitation data.
class MockData {
  MockData._();

  // ── Patients ──────────────────────────────────────────────────────────────
  static final List<MockPatient> patients = [
    MockPatient(
      id: 'p1',
      name: 'James Whitfield',
      initials: 'JW',
      dateOfBirth: DateTime(1978, 4, 12),
      condition: 'TBI',
      status: 'Active',
      enrollmentDate: DateTime(2024, 11, 3),
      therapistId: 'dr_rai',
      totalSessions: 18,
      averageScore: 72.3,
      recoveryPercent: 68,
      recentScores: [55, 61, 58, 67, 72],
      notes: ['Good improvement in hand-eye coordination.', 'Needs more work on reaction time.'],
    ),
    MockPatient(
      id: 'p2',
      name: 'Maria Santos',
      initials: 'MS',
      dateOfBirth: DateTime(1965, 9, 22),
      condition: 'Stroke',
      status: 'Active',
      enrollmentDate: DateTime(2024, 10, 14),
      therapistId: 'dr_rai',
      totalSessions: 24,
      averageScore: 58.7,
      recoveryPercent: 52,
      recentScores: [40, 45, 50, 55, 58],
      notes: ['Left-side weakness improving gradually.'],
    ),
    MockPatient(
      id: 'p3',
      name: 'Robert Chen',
      initials: 'RC',
      dateOfBirth: DateTime(1952, 2, 8),
      condition: "Parkinson's",
      status: 'Active',
      enrollmentDate: DateTime(2024, 9, 1),
      therapistId: 'dr_rai',
      totalSessions: 31,
      averageScore: 44.1,
      recoveryPercent: 41,
      recentScores: [38, 40, 42, 43, 44],
      notes: ['Tremor control exercises showing minimal improvement.'],
    ),
    MockPatient(
      id: 'p4',
      name: 'Amara Okonkwo',
      initials: 'AO',
      dateOfBirth: DateTime(1989, 6, 17),
      condition: 'TBI',
      status: 'Active',
      enrollmentDate: DateTime(2025, 1, 20),
      therapistId: 'dr_rai',
      totalSessions: 8,
      averageScore: 81.5,
      recoveryPercent: 79,
      recentScores: [72, 75, 78, 80, 81],
      notes: ['Exceptional progress — ahead of recovery curve.'],
    ),
    MockPatient(
      id: 'p5',
      name: 'Elena Vasquez',
      initials: 'EV',
      dateOfBirth: DateTime(1971, 11, 30),
      condition: 'Stroke',
      status: 'On Hold',
      enrollmentDate: DateTime(2024, 8, 5),
      therapistId: 'dr_rai',
      totalSessions: 15,
      averageScore: 33.8,
      recoveryPercent: 28,
      recentScores: [30, 32, 31, 34, 33],
      notes: ['Session paused — patient undergoing medication adjustment.'],
    ),
    MockPatient(
      id: 'p6',
      name: 'David Kim',
      initials: 'DK',
      dateOfBirth: DateTime(1960, 3, 5),
      condition: "Parkinson's",
      status: 'Discharged',
      enrollmentDate: DateTime(2024, 6, 12),
      therapistId: 'dr_rai',
      totalSessions: 42,
      averageScore: 65.2,
      recoveryPercent: 88,
      recentScores: [60, 63, 65, 66, 65],
      notes: ['Discharged — met all recovery milestones. Follow-up in 3 months.'],
    ),
    MockPatient(
      id: 'p7',
      name: 'Fatima Al-Hassan',
      initials: 'FA',
      dateOfBirth: DateTime(1983, 7, 14),
      condition: 'Other',
      status: 'Active',
      enrollmentDate: DateTime(2025, 2, 10),
      therapistId: 'dr_rai',
      totalSessions: 6,
      averageScore: 77.0,
      recoveryPercent: 62,
      recentScores: [65, 70, 74, 76, 77],
      notes: ['Vestibular rehabilitation — strong compliance.'],
    ),
    MockPatient(
      id: 'p8',
      name: 'Thomas Becker',
      initials: 'TB',
      dateOfBirth: DateTime(1945, 12, 25),
      condition: 'TBI',
      status: 'Active',
      enrollmentDate: DateTime(2024, 12, 1),
      therapistId: 'dr_rai',
      totalSessions: 12,
      averageScore: 29.4,
      recoveryPercent: 22,
      recentScores: [20, 25, 28, 29, 30],
      notes: ['Severe TBI. Slow but steady progress.'],
    ),
  ];

  // ── Sessions ──────────────────────────────────────────────────────────────
  static final List<MockSession> sessions = _buildSessions();

  static List<MockSession> _buildSessions() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final twoDaysAgo = now.subtract(const Duration(days: 2));

    return [
      // Today's sessions (24 total today, showing first few prominently)
      MockSession(id: 's1', patientId: 'p1', patientName: 'James Whitfield',
          exerciseType: 'Fruit Picking', score: 72, duration: 14,
          timestamp: now.subtract(const Duration(hours: 1)),
          status: 'Completed', reviewed: true,
          accuracy: 78, reactionTimeMs: 420, objectsCaught: 18, missedObjects: 5,
          aiInsight: 'Score improved 8% vs last session. Reaction time within normal range for TBI recovery stage 2. Recommend increasing difficulty to level 4.',
          hasAiInsights: true),
      MockSession(id: 's2', patientId: 'p4', patientName: 'Amara Okonkwo',
          exerciseType: 'Balance Beam', score: 81, duration: 18,
          timestamp: now.subtract(const Duration(hours: 2)),
          status: 'Completed', reviewed: false,
          accuracy: 88, reactionTimeMs: 310, objectsCaught: 22, missedObjects: 3,
          aiInsight: 'Exceptional performance. Patient is exceeding recovery benchmarks by 15%. Consider graduated difficulty progression.',
          hasAiInsights: true),
      MockSession(id: 's3', patientId: 'p7', patientName: 'Fatima Al-Hassan',
          exerciseType: 'Reach & Grasp', score: 77, duration: 12,
          timestamp: now.subtract(const Duration(hours: 3)),
          status: 'Completed', reviewed: false,
          accuracy: 82, reactionTimeMs: 380, objectsCaught: 19, missedObjects: 4,
          aiInsight: 'Vestibular coordination improving. Balance metrics 12% above baseline.',
          hasAiInsights: true),
      MockSession(id: 's4', patientId: 'p2', patientName: 'Maria Santos',
          exerciseType: 'Fruit Picking', score: 58, duration: 16,
          timestamp: now.subtract(const Duration(hours: 4)),
          status: 'Completed', reviewed: true,
          accuracy: 62, reactionTimeMs: 510, objectsCaught: 14, missedObjects: 10,
          aiInsight: null, hasAiInsights: false),
      MockSession(id: 's5', patientId: 'p3', patientName: 'Robert Chen',
          exerciseType: 'Precision Tasks', score: 44, duration: 20,
          timestamp: now.subtract(const Duration(hours: 5)),
          status: 'Pending Review', reviewed: false,
          accuracy: 48, reactionTimeMs: 680, objectsCaught: 11, missedObjects: 13,
          aiInsight: 'Motor tremor significantly impacting performance. Recommend occupational therapy consultation.',
          hasAiInsights: true),
      MockSession(id: 's6', patientId: 'p8', patientName: 'Thomas Becker',
          exerciseType: 'Fruit Picking', score: 0, duration: 5,
          timestamp: now.subtract(const Duration(hours: 6)),
          status: 'Failed', reviewed: false,
          accuracy: 12, reactionTimeMs: 0, objectsCaught: 0, missedObjects: 24,
          aiInsight: 'Session terminated early. Patient reported dizziness. Recommend clinical assessment before next session.',
          hasAiInsights: true),
      MockSession(id: 's7', patientId: 'p5', patientName: 'Elena Vasquez',
          exerciseType: 'Balance Beam', score: 33, duration: 10,
          timestamp: now.subtract(const Duration(hours: 7)),
          status: 'Completed', reviewed: false,
          accuracy: 36, reactionTimeMs: 720, objectsCaught: 8, missedObjects: 16,
          aiInsight: null, hasAiInsights: false),
      // Yesterday's sessions
      MockSession(id: 's8', patientId: 'p1', patientName: 'James Whitfield',
          exerciseType: 'Fruit Picking', score: 72, duration: 14,
          timestamp: yesterday.copyWith(hour: 23, minute: 19),
          status: 'Completed', reviewed: true,
          accuracy: 75, reactionTimeMs: 435, objectsCaught: 17, missedObjects: 6,
          aiInsight: null, hasAiInsights: false),
      MockSession(id: 's9', patientId: 'p1', patientName: 'James Whitfield',
          exerciseType: 'Fruit Picking', score: 72, duration: 14,
          timestamp: yesterday.copyWith(hour: 22, minute: 50),
          status: 'Completed', reviewed: true,
          accuracy: 74, reactionTimeMs: 440, objectsCaught: 17, missedObjects: 6,
          aiInsight: null, hasAiInsights: false),
      MockSession(id: 's10', patientId: 'p4', patientName: 'Amara Okonkwo',
          exerciseType: 'Fruit Picking', score: 0, duration: 3,
          timestamp: yesterday.copyWith(hour: 23, minute: 0),
          status: 'Failed', reviewed: false,
          accuracy: 8, reactionTimeMs: 0, objectsCaught: 0, missedObjects: 20,
          aiInsight: 'Connectivity issue detected. Session data incomplete.',
          hasAiInsights: true),
      MockSession(id: 's11', patientId: 'p2', patientName: 'Maria Santos',
          exerciseType: 'Balance Beam', score: 55, duration: 15,
          timestamp: yesterday.copyWith(hour: 21, minute: 30),
          status: 'Completed', reviewed: true,
          accuracy: 60, reactionTimeMs: 520, objectsCaught: 13, missedObjects: 10,
          aiInsight: null, hasAiInsights: false),
      MockSession(id: 's12', patientId: 'p7', patientName: 'Fatima Al-Hassan',
          exerciseType: 'Reach & Grasp', score: 76, duration: 11,
          timestamp: yesterday.copyWith(hour: 20, minute: 21),
          status: 'Completed', reviewed: true,
          accuracy: 80, reactionTimeMs: 392, objectsCaught: 18, missedObjects: 5,
          aiInsight: null, hasAiInsights: false),
      // 2 days ago
      MockSession(id: 's13', patientId: 'p3', patientName: 'Robert Chen',
          exerciseType: 'Precision Tasks', score: 42, duration: 18,
          timestamp: twoDaysAgo.copyWith(hour: 14, minute: 15),
          status: 'Completed', reviewed: true,
          accuracy: 45, reactionTimeMs: 695, objectsCaught: 10, missedObjects: 14,
          aiInsight: null, hasAiInsights: false),
      MockSession(id: 's14', patientId: 'p8', patientName: 'Thomas Becker',
          exerciseType: 'Fruit Picking', score: 29, duration: 12,
          timestamp: twoDaysAgo.copyWith(hour: 11, minute: 0),
          status: 'Pending Review', reviewed: false,
          accuracy: 32, reactionTimeMs: 890, objectsCaught: 7, missedObjects: 17,
          aiInsight: 'Below average performance. Cognitive fatigue pattern detected.',
          hasAiInsights: true),
      MockSession(id: 's15', patientId: 'p6', patientName: 'David Kim',
          exerciseType: 'Balance Beam', score: 65, duration: 17,
          timestamp: twoDaysAgo.copyWith(hour: 9, minute: 30),
          status: 'Completed', reviewed: true,
          accuracy: 70, reactionTimeMs: 460, objectsCaught: 15, missedObjects: 8,
          aiInsight: null, hasAiInsights: false),
      // Remaining today sessions (to reach 24)
      MockSession(id: 's16', patientId: 'p4', patientName: 'Amara Okonkwo',
          exerciseType: 'Reach & Grasp', score: 80, duration: 13,
          timestamp: now.subtract(const Duration(hours: 8)),
          status: 'Completed', reviewed: true,
          accuracy: 85, reactionTimeMs: 320, objectsCaught: 21, missedObjects: 4,
          aiInsight: null, hasAiInsights: false),
      MockSession(id: 's17', patientId: 'p2', patientName: 'Maria Santos',
          exerciseType: 'Precision Tasks', score: 60, duration: 14,
          timestamp: now.subtract(const Duration(hours: 9)),
          status: 'In Progress', reviewed: false,
          accuracy: 63, reactionTimeMs: 495, objectsCaught: 14, missedObjects: 9,
          aiInsight: null, hasAiInsights: false),
      MockSession(id: 's18', patientId: 'p1', patientName: 'James Whitfield',
          exerciseType: 'Balance Beam', score: 68, duration: 16,
          timestamp: now.subtract(const Duration(hours: 10)),
          status: 'Completed', reviewed: false,
          accuracy: 72, reactionTimeMs: 450, objectsCaught: 16, missedObjects: 7,
          aiInsight: null, hasAiInsights: false),
      MockSession(id: 's19', patientId: 'p7', patientName: 'Fatima Al-Hassan',
          exerciseType: 'Fruit Picking', score: 75, duration: 12,
          timestamp: now.subtract(const Duration(minutes: 30)),
          status: 'Completed', reviewed: false,
          accuracy: 79, reactionTimeMs: 405, objectsCaught: 18, missedObjects: 5,
          aiInsight: null, hasAiInsights: false),
      MockSession(id: 's20', patientId: 'p3', patientName: 'Robert Chen',
          exerciseType: 'Fruit Picking', score: 43, duration: 19,
          timestamp: now.subtract(const Duration(minutes: 45)),
          status: 'In Progress', reviewed: false,
          accuracy: 46, reactionTimeMs: 670, objectsCaught: 10, missedObjects: 13,
          aiInsight: null, hasAiInsights: false),
      MockSession(id: 's21', patientId: 'p8', patientName: 'Thomas Becker',
          exerciseType: 'Balance Beam', score: 28, duration: 11,
          timestamp: now.subtract(const Duration(hours: 11)),
          status: 'Pending Review', reviewed: false,
          accuracy: 30, reactionTimeMs: 900, objectsCaught: 6, missedObjects: 18,
          aiInsight: null, hasAiInsights: false),
      MockSession(id: 's22', patientId: 'p5', patientName: 'Elena Vasquez',
          exerciseType: 'Reach & Grasp', score: 34, duration: 9,
          timestamp: now.subtract(const Duration(hours: 12)),
          status: 'Completed', reviewed: true,
          accuracy: 37, reactionTimeMs: 710, objectsCaught: 8, missedObjects: 15,
          aiInsight: null, hasAiInsights: false),
      MockSession(id: 's23', patientId: 'p6', patientName: 'David Kim',
          exerciseType: 'Precision Tasks', score: 66, duration: 15,
          timestamp: now.subtract(const Duration(hours: 13)),
          status: 'Completed', reviewed: true,
          accuracy: 71, reactionTimeMs: 448, objectsCaught: 15, missedObjects: 8,
          aiInsight: null, hasAiInsights: false),
      MockSession(id: 's24', patientId: 'p4', patientName: 'Amara Okonkwo',
          exerciseType: 'Fruit Picking', score: 82, duration: 14,
          timestamp: now.subtract(const Duration(hours: 14)),
          status: 'Completed', reviewed: true,
          accuracy: 89, reactionTimeMs: 305, objectsCaught: 23, missedObjects: 2,
          aiInsight: 'Best session score recorded. Recovery trajectory remains excellent.',
          hasAiInsights: true),
    ];
  }

  // ── Notifications ─────────────────────────────────────────────────────────
  static final List<MockNotification> notifications = [
    MockNotification(
      id: 'n1',
      type: 'session',
      title: 'Session Completed',
      body: 'James Whitfield completed Fruit Picking — Score: 72',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      read: false,
      linkTo: '/sessions/s1',
    ),
    MockNotification(
      id: 'n2',
      type: 'alert',
      title: 'Session Failed — Attention Required',
      body: 'Thomas Becker\'s session was terminated early. Clinical review recommended.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      read: false,
      linkTo: '/sessions/s6',
    ),
    MockNotification(
      id: 'n3',
      type: 'ai',
      title: 'AI Insight Ready',
      body: 'New recovery plan generated for Amara Okonkwo based on latest session data.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      read: false,
      linkTo: '/patients/p4',
    ),
    MockNotification(
      id: 'n4',
      type: 'patient',
      title: 'Pending Review',
      body: 'Robert Chen has 2 sessions awaiting therapist review.',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      read: false,
      linkTo: '/patients/p3',
    ),
    MockNotification(
      id: 'n5',
      type: 'alert',
      title: 'Weekly Report Ready',
      body: 'Your weekly patient summary for May 2025 is available.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      read: true,
      linkTo: '/analytics',
    ),
  ];

  // ── AI Insights ───────────────────────────────────────────────────────────
  static final List<MockAiInsight> aiInsights = [
    MockAiInsight(
      id: 'ai1',
      sessionId: 's1',
      patientId: 'p1',
      patientName: 'James Whitfield',
      text: 'Score improved 8% vs last session. Reaction time within normal range for TBI recovery stage 2. Recommend increasing difficulty to level 4.',
      severity: 'positive',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    MockAiInsight(
      id: 'ai2',
      sessionId: 's6',
      patientId: 'p8',
      patientName: 'Thomas Becker',
      text: 'Session terminated early due to reported dizziness. Cognitive fatigue pattern consistent with severe TBI stage 1. Clinical assessment recommended before next session.',
      severity: 'critical',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    MockAiInsight(
      id: 'ai3',
      sessionId: 's2',
      patientId: 'p4',
      patientName: 'Amara Okonkwo',
      text: 'Exceptional performance exceeding recovery benchmarks by 15%. Balance and coordination metrics suggest readiness for advanced exercises. Consider graduated difficulty progression.',
      severity: 'positive',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  // ── Computed Stats ────────────────────────────────────────────────────────
  static int get totalSessionsToday {
    final now = DateTime.now();
    return sessions.where((s) =>
        s.timestamp.year == now.year &&
        s.timestamp.month == now.month &&
        s.timestamp.day == now.day).length;
  }

  static double get averageScore {
    final scored = sessions.where((s) => s.score > 0).toList();
    if (scored.isEmpty) return 0;
    return scored.fold(0.0, (sum, s) => sum + s.score) / scored.length;
  }

  static int get pendingReviewCount =>
      sessions.where((s) => s.status == 'Pending Review' || !s.reviewed).length;

  static int get activePatientsCount =>
      patients.where((p) => p.status == 'Active').length;

  // ── Helpers ───────────────────────────────────────────────────────────────
  static MockPatient? patientById(String id) =>
      patients.where((p) => p.id == id).firstOrNull;

  static List<MockSession> sessionsForPatient(String patientId) =>
      sessions.where((s) => s.patientId == patientId).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
}

// ── Data Classes ──────────────────────────────────────────────────────────────

class MockPatient {
  final String id;
  final String name;
  final String initials;
  final DateTime dateOfBirth;
  final String condition;
  final String status;
  final DateTime enrollmentDate;
  final String therapistId;
  final int totalSessions;
  final double averageScore;
  final int recoveryPercent;
  final List<double> recentScores;
  final List<String> notes;

  const MockPatient({
    required this.id,
    required this.name,
    required this.initials,
    required this.dateOfBirth,
    required this.condition,
    required this.status,
    required this.enrollmentDate,
    required this.therapistId,
    required this.totalSessions,
    required this.averageScore,
    required this.recoveryPercent,
    required this.recentScores,
    required this.notes,
  });

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  double get scoreTrend {
    if (recentScores.length < 2) return 0;
    return recentScores.last - recentScores.first;
  }
}

class MockSession {
  final String id;
  final String patientId;
  final String patientName;
  final String exerciseType;
  final int score;
  final int duration;
  final DateTime timestamp;
  final String status;
  final bool reviewed;
  final int accuracy;
  final int reactionTimeMs;
  final int objectsCaught;
  final int missedObjects;
  final String? aiInsight;
  final bool hasAiInsights;

  const MockSession({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.exerciseType,
    required this.score,
    required this.duration,
    required this.timestamp,
    required this.status,
    required this.reviewed,
    required this.accuracy,
    required this.reactionTimeMs,
    required this.objectsCaught,
    required this.missedObjects,
    this.aiInsight,
    required this.hasAiInsights,
  });
}

class MockNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime timestamp;
  bool read;
  final String linkTo;

  MockNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.read,
    required this.linkTo,
  });
}

class MockAiInsight {
  final String id;
  final String sessionId;
  final String patientId;
  final String patientName;
  final String text;
  final String severity;
  final DateTime timestamp;

  const MockAiInsight({
    required this.id,
    required this.sessionId,
    required this.patientId,
    required this.patientName,
    required this.text,
    required this.severity,
    required this.timestamp,
  });
}

extension DateTimeCopyWith on DateTime {
  DateTime copyWith({
    int? year, int? month, int? day,
    int? hour, int? minute, int? second,
  }) => DateTime(
    year ?? this.year, month ?? this.month, day ?? this.day,
    hour ?? this.hour, minute ?? this.minute, second ?? this.second,
  );
}
