import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/mock/mock_data.dart';

/// AI Live full-screen overlay.
class AiLiveOverlay extends StatefulWidget {
  const AiLiveOverlay({super.key});

  @override
  State<AiLiveOverlay> createState() => _AiLiveOverlayState();
}

class _AiLiveOverlayState extends State<AiLiveOverlay>
    with TickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late Animation<double> _scaleAnim, _fadeAnim;
  late AnimationController _waveCtrl;
  late AnimationController _pulseCtrl;

  final _queryCtrl = TextEditingController();
  String? _aiResponse;
  bool _typingIndicator = false;
  final List<_AiMessage> _messages = [];
  int _displayedResponseLength = 0;
  Timer? _typewriterTimer;

  // Live score updates simulation
  final Map<String, int> _liveScores = {'s17': 42, 's20': 35};
  Timer? _liveUpdateTimer;

  final _suggestedQuestions = [
    'Who needs review today?',
    'Summarize today\'s sessions',
    'Flag any anomalies',
    'Top performers this week?',
  ];

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);

    _waveCtrl = AnimationController(
        duration: const Duration(seconds: 2), vsync: this)
      ..repeat();
    _pulseCtrl = AnimationController(
        duration: const Duration(seconds: 2), vsync: this)
      ..repeat(reverse: true);

    _entryCtrl.forward();

    // Simulate live score updates
    _liveUpdateTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() {
          _liveScores['s17'] =
              (_liveScores['s17']! + math.Random().nextInt(5) - 1).clamp(0, 100);
          _liveScores['s20'] =
              (_liveScores['s20']! + math.Random().nextInt(4)).clamp(0, 100);
        });
      }
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _waveCtrl.dispose();
    _pulseCtrl.dispose();
    _queryCtrl.dispose();
    _typewriterTimer?.cancel();
    _liveUpdateTimer?.cancel();
    super.dispose();
  }

  void _close() {
    _entryCtrl.reverse().then((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _sendQuery(String query) async {
    if (query.trim().isEmpty) return;
    _queryCtrl.clear();
    setState(() {
      _messages.add(_AiMessage(text: query, isUser: true));
      _typingIndicator = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final response = _generateResponse(query);
    setState(() {
      _typingIndicator = false;
      _messages.add(_AiMessage(text: response, isUser: false));
    });
    _startTypewriter(response);
  }

  String _generateResponse(String query) {
    final q = query.toLowerCase();
    if (q.contains('review')) {
      return 'Based on current session data, 5 sessions require review: Robert Chen (Precision Tasks, score 44), Thomas Becker (Fruit Picking, score 0), and 3 others. Thomas Becker\'s session is flagged as critical — recommend immediate follow-up.';
    } else if (q.contains('summar')) {
      return 'Today\'s summary: 24 sessions completed across 8 patients. Average score: 58.2 (↑4% vs yesterday). Top performer: Amara Okonkwo (82). Requires attention: Thomas Becker, Elena Vasquez.';
    } else if (q.contains('anomal')) {
      return 'Detected 2 anomalies: (1) Thomas Becker terminated session early citing dizziness — potential vestibular complication. (2) Amara Okonkwo\'s session s10 scored 0 due to connectivity failure — no clinical concern.';
    } else if (q.contains('top') || q.contains('perform')) {
      return 'Top performers this week: 1. Amara Okonkwo (avg 81.5) 2. James Whitfield (avg 72.3) 3. Fatima Al-Hassan (avg 76.5) 4. David Kim (avg 65.2) 5. Maria Santos (avg 58.7).';
    }
    return 'Analyzing your query across all active patient sessions… Based on current data, all systems are nominal. Amara Okonkwo continues to lead recovery metrics. Would you like a more detailed breakdown?';
  }

  void _startTypewriter(String text) {
    _displayedResponseLength = 0;
    _typewriterTimer?.cancel();
    _typewriterTimer = Timer.periodic(
      const Duration(milliseconds: 20),
      (_) {
        if (_displayedResponseLength < text.length) {
          setState(() => _displayedResponseLength++);
        } else {
          _typewriterTimer?.cancel();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: GestureDetector(
        onTap: () {},
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 12, right: 12, bottom: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderMedium),
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  _buildStatusBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                          bottom: AppSpacing.sm),
                      child: Column(
                        children: [
                          _buildLiveFeed(),
                          const SizedBox(height: 16),
                          _buildInsightsFeed(),
                          const SizedBox(height: 16),
                          _buildConversation(),
                        ],
                      ),
                    ),
                  ),
                  _buildAskAi(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
      child: Row(
        children: [
          // Pulsing badge
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success
                    .withValues(alpha: 0.1 + 0.05 * _pulseCtrl.value),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(
                        alpha: 0.2 + 0.1 * _pulseCtrl.value),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                        color: AppColors.success, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  const Text('AI Live',
                      style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text('NeuroLift AI',
              style: TextStyle(color: AppColors.textPrimary,
                  fontSize: 16, fontWeight: FontWeight.w700)),
          const Spacer(),
          GestureDetector(
            onTap: _close,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.close_rounded,
                  color: AppColors.textSecondary, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.headset_rounded,
              color: AppColors.primaryAccent, size: 16),
          const SizedBox(width: 8),
          const Text('Connected to Meta Quest — 3 sessions active',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const Spacer(),
          // Wave animation
          AnimatedBuilder(
            animation: _waveCtrl,
            builder: (_, __) => CustomPaint(
              size: const Size(32, 14),
              painter: _WavePainter(phase: _waveCtrl.value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveFeed() {
    final activeSessions = MockData.sessions
        .where((s) => s.status == 'In Progress')
        .toList();
    if (activeSessions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Live Sessions',
              style: TextStyle(color: AppColors.textPrimary,
                  fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...activeSessions.map((s) {
            final liveScore =
                _liveScores[s.id] ?? s.score;
            final scoreColor = AppColors.scoreColor(liveScore);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                        color: AppColors.success, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.patientName,
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12, fontWeight: FontWeight.w600)),
                        Text(s.exerciseType,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: scoreColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$liveScore',
                        style: TextStyle(
                            color: scoreColor,
                            fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInsightsFeed() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AI Insights',
              style: TextStyle(color: AppColors.textPrimary,
                  fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...MockData.aiInsights.map((insight) {
            final isPositive = insight.severity == 'positive';
            final color =
                isPositive ? AppColors.success : AppColors.error;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: color.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          color: color, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(insight.patientName,
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                      Text(_relTime(insight.timestamp),
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(insight.text,
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11, height: 1.5)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildConversation() {
    if (_messages.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Conversation',
              style: TextStyle(color: AppColors.textPrimary,
                  fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ..._messages.asMap().entries.map((entry) {
            final i = entry.key;
            final m = entry.value;
            final isLast = i == _messages.length - 1;
            final displayText = (!m.isUser && isLast)
                ? m.text.substring(
                    0, _displayedResponseLength.clamp(0, m.text.length))
                : m.text;
            return Align(
              alignment:
                  m.isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                constraints: BoxConstraints(
                    maxWidth:
                        MediaQuery.of(context).size.width * 0.75),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: m.isUser
                      ? AppColors.primaryAccent.withValues(alpha: 0.15)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  displayText,
                  style: TextStyle(
                    color: m.isUser
                        ? AppColors.primaryAccent
                        : AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            );
          }),
          if (_typingIndicator)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14)),
                child: const _TypingDots(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAskAi(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(24)),
        border: const Border(
            top: BorderSide(color: AppColors.borderSubtle)),
      ),
      padding: EdgeInsets.only(
          left: 16, right: 16, top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Suggested questions
          if (_messages.isEmpty)
            SizedBox(
              height: 32,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _suggestedQuestions.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _sendQuery(_suggestedQuestions[i]),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Text(_suggestedQuestions[i],
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11)),
                  ),
                ),
              ),
            ),
          if (_messages.isEmpty) const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _queryCtrl,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Ask about your patients…',
                    hintStyle: const TextStyle(
                        color: AppColors.textMuted, fontSize: 13),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                  onSubmitted: _sendQuery,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _sendQuery(_queryCtrl.text),
                child: Container(
                  width: 40, height: 40,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _relTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

class _AiMessage {
  final String text;
  final bool isUser;
  const _AiMessage({required this.text, required this.isUser});
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 900), vsync: this)
      ..repeat();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final delay = i * 0.33;
          final t = (_ctrl.value - delay).clamp(0.0, 1.0);
          final scale = 0.8 + 0.4 * math.sin(t * math.pi);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 6, height: 6,
            transform: Matrix4.identity()..scale(scale),
            decoration: BoxDecoration(
                color: AppColors.textMuted, shape: BoxShape.circle),
          );
        }),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double phase;
  const _WavePainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryAccent
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 +
          math.sin((x / size.width * 2 * math.pi) + phase * 2 * math.pi) *
              (size.height / 3);
      if (x == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter o) => o.phase != phase;
}
