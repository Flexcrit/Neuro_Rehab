import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Fully rebuilt Settings screen.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifSessions = true;
  bool _notifAlerts = true;
  bool _notifWeekly = false;
  bool _notifAi = true;
  bool _aiAutoAnalysis = true;
  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: AppSpacing.bottomSafe),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Text('Settings',
                    style: TextStyle(color: AppColors.textPrimary,
                        fontSize: 22, fontWeight: FontWeight.w700)),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Text('App configuration & preferences',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ),

              // Profile card
              _buildProfileCard(context),
              const SizedBox(height: 20),

              // Appearance
              _SectionLabel('Appearance'),
              _SettingsCard(children: [
                _ToggleTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  subtitle: 'Medical-grade dark interface',
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                ),
                const _Divider(),
                _AccentColorTile(),
              ]),
              const SizedBox(height: 16),

              // Notifications
              _SectionLabel('Notifications'),
              _SettingsCard(children: [
                _ToggleTile(
                  icon: Icons.sports_esports_rounded,
                  title: 'Session Completed',
                  subtitle: 'Alert when a VR session finishes',
                  value: _notifSessions,
                  onChanged: (v) => setState(() => _notifSessions = v),
                ),
                const _Divider(),
                _ToggleTile(
                  icon: Icons.warning_amber_rounded,
                  title: 'Patient Alerts',
                  subtitle: 'Critical patient notifications',
                  value: _notifAlerts,
                  onChanged: (v) => setState(() => _notifAlerts = v),
                ),
                const _Divider(),
                _ToggleTile(
                  icon: Icons.calendar_month_rounded,
                  title: 'Weekly Reports',
                  subtitle: 'Receive weekly summary emails',
                  value: _notifWeekly,
                  onChanged: (v) => setState(() => _notifWeekly = v),
                ),
                const _Divider(),
                _ToggleTile(
                  icon: Icons.auto_awesome_rounded,
                  title: 'AI Insights',
                  subtitle: 'Receive AI-generated recovery plans',
                  value: _notifAi,
                  onChanged: (v) => setState(() => _notifAi = v),
                ),
              ]),
              const SizedBox(height: 16),

              // AI
              _SectionLabel('AI Engine'),
              _SettingsCard(children: [
                _ToggleTile(
                  icon: Icons.psychology_rounded,
                  title: 'AI Auto-Analysis',
                  subtitle: 'Automatically generate recovery plans',
                  value: _aiAutoAnalysis,
                  onChanged: (v) => setState(() => _aiAutoAnalysis = v),
                ),
                const _Divider(),
                const _InfoTile(
                  icon: Icons.memory_rounded,
                  title: 'AI Model',
                  trailing: 'Gemini 2.0 Flash',
                  trailingColor: AppColors.tertiaryAccent,
                ),
              ]),
              const SizedBox(height: 16),

              // Connected Devices
              _SectionLabel('Connected Devices'),
              _SettingsCard(children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.headset_rounded,
                            color: AppColors.secondaryAccent, size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Meta Quest 3',
                                style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14, fontWeight: FontWeight.w500)),
                            SizedBox(height: 2),
                            Row(
                              children: [
                                CircleAvatar(
                                    radius: 4,
                                    backgroundColor: AppColors.success),
                                SizedBox(width: 6),
                                Text('Connected',
                                    style: TextStyle(
                                        color: AppColors.success, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text('Headset 1',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
                const _Divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showScanSheet(context),
                      icon: const Icon(Icons.radar_rounded, size: 18),
                      label: const Text('Scan for Devices'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryAccent,
                        side: const BorderSide(color: AppColors.borderMedium),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 16),

              // System
              _SectionLabel('System'),
              _SettingsCard(children: const [
                _InfoTile(icon: Icons.info_outline_rounded,
                    title: 'App Version', trailing: '1.0.0+1'),
                _Divider(),
                _InfoTile(icon: Icons.cloud_done_outlined,
                    title: 'Firebase Status', trailing: 'Connected',
                    trailingColor: AppColors.success),
                _Divider(),
                _InfoTile(icon: Icons.shield_outlined,
                    title: 'Privacy Policy', trailing: ''),
                _Divider(),
                _InfoTile(icon: Icons.description_outlined,
                    title: 'Terms of Service', trailing: ''),
              ]),
              const SizedBox(height: 16),

              // Sign Out
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showSignOutSheet(context),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error.withValues(alpha: 0.12),
                      foregroundColor: AppColors.error,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showEditProfileSheet(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('RR',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dr. Rai Rian',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Neurologist · Lead Therapist',
                        style: TextStyle(
                            color: AppColors.primaryAccent, fontSize: 11,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined,
                color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24, right: 24, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.textMuted,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            const Text('Edit Profile',
                style: TextStyle(color: AppColors.textPrimary,
                    fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _editField('Full Name', 'Dr. Rai Rian'),
            const SizedBox(height: 10),
            _editField('Specialty', 'Neurologist'),
            const SizedBox(height: 10),
            _editField('Hospital', 'NeuroRehab Institute'),
            const SizedBox(height: 10),
            _editField('Email', 'dr.rai@neurorehab.med'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Changes',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _editField(String label, String initial) {
    return TextFormField(
      initialValue: initial,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            color: AppColors.textSecondary, fontSize: 12),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primaryAccent)),
      ),
    );
  }

  void _showScanSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _ScanDevicesSheet(),
    );
  }

  void _showSignOutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.textMuted,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.logout_rounded,
                color: AppColors.error, size: 40),
            const SizedBox(height: 12),
            const Text('Sign Out?',
                style: TextStyle(color: AppColors.textPrimary,
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'You will be returned to the login screen. Your data is saved securely.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.borderSubtle),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Sign Out',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared Settings Widgets ───────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
        child: Text(text.toUpperCase(),
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 11,
                fontWeight: FontWeight.w600, letterSpacing: 1.2)),
      );
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle)),
        child: Column(children: children),
      );
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(color: AppColors.borderSubtle, height: 1, indent: 16);
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon, required this.title,
    required this.subtitle, required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primaryAccent,
            ),
          ],
        ),
      );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String trailing;
  final Color? trailingColor;
  const _InfoTile({
    required this.icon, required this.title,
    required this.trailing, this.trailingColor,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14)),
            ),
            if (trailing.isNotEmpty)
              Text(trailing,
                  style: TextStyle(
                      color: trailingColor ?? AppColors.textSecondary,
                      fontSize: 13, fontWeight: FontWeight.w500)),
            if (trailing.isEmpty)
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 18),
          ],
        ),
      );
}

class _AccentColorTile extends StatefulWidget {
  @override
  State<_AccentColorTile> createState() => _AccentColorTileState();
}

class _AccentColorTileState extends State<_AccentColorTile> {
  int _selected = 0;
  final _colors = [
    AppColors.primaryAccent,
    AppColors.secondaryAccent,
    AppColors.tertiaryAccent,
    AppColors.success,
    AppColors.warning,
    AppColors.error,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.palette_outlined,
              color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 14),
          const Expanded(
            child: Text('Accent Color',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
          ),
          Row(
            children: _colors.asMap().entries.map((e) {
              final selected = e.key == _selected;
              return GestureDetector(
                onTap: () => setState(() => _selected = e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(left: 6),
                  width: selected ? 26 : 22,
                  height: selected ? 26 : 22,
                  decoration: BoxDecoration(
                    color: e.value,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ScanDevicesSheet extends StatefulWidget {
  const _ScanDevicesSheet();
  @override
  State<_ScanDevicesSheet> createState() => _ScanDevicesSheetState();
}

class _ScanDevicesSheetState extends State<_ScanDevicesSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(seconds: 2), vsync: this)..repeat();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.textMuted,
                    borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 20),
          const Text('Scan for Devices',
              style: TextStyle(color: AppColors.textPrimary,
                  fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => CustomPaint(
              size: const Size(80, 80),
              painter: _RadarPainter(phase: _ctrl.value),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Searching for VR headsets…',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.headset_rounded,
                    color: AppColors.success, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Meta Quest 3 — Connected',
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 13)),
                ),
                Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double phase;
  const _RadarPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < 3; i++) {
      final t = ((phase + i * 0.33) % 1.0);
      canvas.drawCircle(
        center,
        t * size.width / 2,
        Paint()
          ..color = AppColors.primaryAccent.withValues(alpha: (1 - t) * 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
    canvas.drawCircle(
      center, 6,
      Paint()..color = AppColors.primaryAccent,
    );
  }

  @override
  bool shouldRepaint(_RadarPainter o) => o.phase != phase;
}
