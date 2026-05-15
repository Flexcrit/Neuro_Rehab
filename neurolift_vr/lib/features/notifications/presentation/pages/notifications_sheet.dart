import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/widgets/animated_counter.dart';
import '../../../../core/widgets/pressable_card.dart';

/// Notifications panel displayed as a bottom sheet.
class NotificationsSheet extends StatefulWidget {
  const NotificationsSheet({super.key});

  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  String _filter = 'All';
  final _filters = ['All', 'Sessions', 'Patients', 'Alerts'];
  List<MockNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _notifications = List.from(MockData.notifications);
  }

  List<MockNotification> get _filtered {
    switch (_filter) {
      case 'Sessions': return _notifications.where((n) => n.type == 'session').toList();
      case 'Patients': return _notifications.where((n) => n.type == 'patient').toList();
      case 'Alerts': return _notifications.where((n) => n.type == 'alert' || n.type == 'ai').toList();
      default: return _notifications;
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.read).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) { n.read = true; }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Center(
            child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.textMuted,
                    borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 16),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('Notifications',
                    style: TextStyle(color: AppColors.textPrimary,
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                if (_unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('$_unreadCount',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                const Spacer(),
                GestureDetector(
                  onTap: _markAllRead,
                  child: const Text('Mark all read',
                      style: TextStyle(
                          color: AppColors.primaryAccent, fontSize: 13)),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.textSecondary, size: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Filter chips
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filters.length,
              itemBuilder: (_, i) {
                final f = _filters[i];
                final active = f == _filter;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primaryAccent
                          : AppColors.surfaceVariant,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusChip),
                    ),
                    child: Text(f,
                        style: TextStyle(
                            color: active
                                ? AppColors.background
                                : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.borderSubtle, height: 1),
          // List
          Expanded(
            child: filtered.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _NotificationTile(
                      notification: filtered[i],
                      onTap: () {
                        setState(() => filtered[i].read = true);
                        Navigator.pop(context);
                      },
                      onDismiss: () {
                        setState(() =>
                            _notifications.remove(filtered[i]));
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none_rounded,
              color: AppColors.textMuted, size: 56),
          const SizedBox(height: 12),
          const Text("You're all caught up!",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
          const SizedBox(height: 4),
          const Text('No notifications in this category',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}

// ── Notification Tile ─────────────────────────────────────────────────────────

class _NotificationTile extends StatefulWidget {
  final MockNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  const _NotificationTile({
    required this.notification, required this.onTap, required this.onDismiss,
  });

  @override
  State<_NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<_NotificationTile> {
  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Color _iconColor(String type) {
    switch (type) {
      case 'session': return AppColors.primaryAccent;
      case 'alert': return AppColors.error;
      case 'ai': return AppColors.tertiaryAccent;
      default: return AppColors.secondaryAccent;
    }
  }

  IconData _icon(String type) {
    switch (type) {
      case 'session': return Icons.sports_esports_rounded;
      case 'alert': return Icons.warning_amber_rounded;
      case 'ai': return Icons.auto_awesome_rounded;
      default: return Icons.person_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.notification;
    final color = _iconColor(n.type);

    return Dismissible(
      key: Key(n.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error.withValues(alpha: 0.15),
        child: const Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: n.read
                ? Colors.transparent
                : AppColors.primaryAccent.withValues(alpha: 0.04),
            border: Border(
              left: BorderSide(
                color: n.read
                    ? Colors.transparent
                    : AppColors.primaryAccent,
                width: 3,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_icon(n.type), color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.title,
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: n.read
                                  ? FontWeight.w500
                                  : FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(n.body,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12,
                              height: 1.4)),
                      const SizedBox(height: 5),
                      Text(_relativeTime(n.timestamp),
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
