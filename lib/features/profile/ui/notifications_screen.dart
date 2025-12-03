import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theming/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _enableNotifications = true;
  bool _faultUpdates = true;
  bool _nearbyFaults = true;
  bool _communityUpdates = false;
  bool _systemAnnouncements = true;
  String _notificationFrequency = 'instant';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        children: [
          // Master Toggle
          Container(
            margin: EdgeInsets.all(16.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.white, size: 32.sp),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enable Notifications',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Turn on to receive updates',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _enableNotifications,
                  onChanged: (value) {
                    setState(() => _enableNotifications = value);
                  },
                  activeColor: Colors.white,
                  activeTrackColor: Colors.white.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),

          // Notification Types
          _buildSection(
            'Notification Types',
            [
              _buildSwitchTile(
                icon: Icons.update,
                title: 'Fault Updates',
                subtitle: 'Updates on faults you\'ve reported',
                value: _faultUpdates,
                enabled: _enableNotifications,
                onChanged: (value) => setState(() => _faultUpdates = value),
              ),
              _buildSwitchTile(
                icon: Icons.location_on,
                title: 'Nearby Faults',
                subtitle: 'New faults reported near your location',
                value: _nearbyFaults,
                enabled: _enableNotifications,
                onChanged: (value) => setState(() => _nearbyFaults = value),
              ),
              _buildSwitchTile(
                icon: Icons.people,
                title: 'Community Updates',
                subtitle: 'Updates from community members',
                value: _communityUpdates,
                enabled: _enableNotifications,
                onChanged: (value) => setState(() => _communityUpdates = value),
              ),
              _buildSwitchTile(
                icon: Icons.campaign,
                title: 'System Announcements',
                subtitle: 'Important app updates and news',
                value: _systemAnnouncements,
                enabled: _enableNotifications,
                onChanged: (value) => setState(() => _systemAnnouncements = value),
              ),
            ],
          ),

          // Frequency
          _buildSection(
            'Notification Frequency',
            [
              _buildRadioTile(
                icon: Icons.flash_on,
                title: 'Instant',
                subtitle: 'Get notified immediately',
                value: 'instant',
                groupValue: _notificationFrequency,
                enabled: _enableNotifications,
                onChanged: (value) => setState(() => _notificationFrequency = value!),
              ),
              _buildRadioTile(
                icon: Icons.schedule,
                title: 'Hourly Digest',
                subtitle: 'Receive a summary every hour',
                value: 'hourly',
                groupValue: _notificationFrequency,
                enabled: _enableNotifications,
                onChanged: (value) => setState(() => _notificationFrequency = value!),
              ),
              _buildRadioTile(
                icon: Icons.today,
                title: 'Daily Digest',
                subtitle: 'Receive a daily summary',
                value: 'daily',
                groupValue: _notificationFrequency,
                enabled: _enableNotifications,
                onChanged: (value) => setState(() => _notificationFrequency = value!),
              ),
            ],
          ),

          // Quick Actions
          _buildSection(
            'Quick Actions',
            [
              _buildActionTile(
                icon: Icons.clear_all,
                title: 'Clear All Notifications',
                subtitle: 'Remove all notification history',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All notifications cleared')),
                  );
                },
              ),
              _buildActionTile(
                icon: Icons.history,
                title: 'Notification History',
                subtitle: 'View past notifications',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification history coming soon')),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        ...children,
        Divider(height: 1.h),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      enabled: enabled,
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: enabled ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.primary : Colors.grey,
          size: 24.sp,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: enabled ? Colors.black : Colors.grey,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
      ),
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return null;
        }),
      ),
    );
  }

  Widget _buildRadioTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required bool enabled,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      enabled: enabled,
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: enabled ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.primary : Colors.grey,
          size: 24.sp,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: enabled ? Colors.black : Colors.grey,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
      ),
      trailing: Radio<String>(
        value: value,
        groupValue: groupValue,
        onChanged: enabled ? onChanged : null,
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return null;
        }),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24.sp),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
      ),
      trailing: Icon(Icons.chevron_right, size: 24.sp),
      onTap: onTap,
    );
  }
}
