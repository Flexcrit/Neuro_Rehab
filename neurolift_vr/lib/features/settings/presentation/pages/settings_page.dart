import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

/// Settings page with app configuration options.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Text(
                  'Settings',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Text(
                  'App configuration & preferences',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

              // Profile Card
              _SettingsCard(
                children: [
                  _ProfileTile(),
                ],
              ),
              const SizedBox(height: 12),

              // Preferences Section
              _SectionLabel('Preferences'),
              _SettingsCard(
                children: [
                  _ToggleTile(
                    icon: Icons.notifications_outlined,
                    title: 'Push Notifications',
                    subtitle: 'Receive alerts for session updates',
                    value: true,
                  ),
                  const Divider(color: AppColors.divider, height: 1),
                  _ToggleTile(
                    icon: Icons.auto_awesome_outlined,
                    title: 'AI Auto-Analysis',
                    subtitle: 'Automatically generate recovery plans',
                    value: true,
                  ),
                  const Divider(color: AppColors.divider, height: 1),
                  _ToggleTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    subtitle: 'Medical-grade dark interface',
                    value: true,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // System Section
              _SectionLabel('System'),
              _SettingsCard(
                children: [
                  _InfoTile(
                    icon: Icons.info_outline_rounded,
                    title: 'App Version',
                    trailing: '1.0.0',
                  ),
                  const Divider(color: AppColors.divider, height: 1),
                  _InfoTile(
                    icon: Icons.cloud_done_outlined,
                    title: 'Firebase Status',
                    trailing: 'Connected',
                    trailingColor: AppColors.secondaryAccent,
                  ),
                  const Divider(color: AppColors.divider, height: 1),
                  _InfoTile(
                    icon: Icons.memory_rounded,
                    title: 'AI Engine',
                    trailing: 'Gemini 2.0 Flash',
                    trailingColor: AppColors.tertiaryAccent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textTertiary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryAccent.withOpacity(0.15),
            child: const Text(
              'RR',
              style: TextStyle(
                color: AppColors.primaryAccent,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. Rai Rian',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 2),
                const Text(
                  'Neurologist • Lead Researcher',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            onChanged: (_) {},
            activeColor: AppColors.primaryAccent,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String trailing;
  final Color? trailingColor;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.trailing,
    this.trailingColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          Text(
            trailing,
            style: TextStyle(
              color: trailingColor ?? AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
