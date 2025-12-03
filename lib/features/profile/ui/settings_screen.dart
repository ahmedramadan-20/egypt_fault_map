import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theming/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _nearbyAlerts = true;
  String _mapStyle = 'standard';
  String _language = 'en';
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            'Notifications',
            [
              _buildSwitchTile(
                icon: Icons.notifications_active,
                title: 'Push Notifications',
                subtitle: 'Receive push notifications for updates',
                value: _pushNotifications,
                onChanged: (value) => setState(() => _pushNotifications = value),
              ),
              _buildSwitchTile(
                icon: Icons.email,
                title: 'Email Notifications',
                subtitle: 'Receive email updates',
                value: _emailNotifications,
                onChanged: (value) => setState(() => _emailNotifications = value),
              ),
              _buildSwitchTile(
                icon: Icons.location_on,
                title: 'Nearby Alerts',
                subtitle: 'Get notified about faults near you',
                value: _nearbyAlerts,
                onChanged: (value) => setState(() => _nearbyAlerts = value),
              ),
            ],
          ),
          _buildSection(
            'Appearance',
            [
              _buildSwitchTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: 'Use dark theme',
                value: _darkMode,
                onChanged: (value) => setState(() => _darkMode = value),
              ),
              _buildChoiceTile(
                icon: Icons.language,
                title: 'Language',
                subtitle: _language == 'en' ? 'English' : 'العربية',
                onTap: () => _showLanguageDialog(),
              ),
            ],
          ),
          _buildSection(
            'Map Settings',
            [
              _buildChoiceTile(
                icon: Icons.map,
                title: 'Map Style',
                subtitle: _getMapStyleLabel(_mapStyle),
                onTap: () => _showMapStyleDialog(),
              ),
            ],
          ),
          _buildSection(
            'Privacy & Security',
            [
              _buildOptionTile(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                subtitle: 'View our privacy policy',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Privacy Policy coming soon')),
                  );
                },
              ),
              _buildOptionTile(
                icon: Icons.security,
                title: 'Terms of Service',
                subtitle: 'View terms and conditions',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Terms of Service coming soon')),
                  );
                },
              ),
            ],
          ),
          _buildSection(
            'Data',
            [
              _buildOptionTile(
                icon: Icons.download,
                title: 'Download My Data',
                subtitle: 'Export your data',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data export coming soon')),
                  );
                },
              ),
              _buildOptionTile(
                icon: Icons.delete_forever,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                iconColor: Colors.red,
                onTap: () => _showDeleteAccountDialog(),
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
    required ValueChanged<bool> onChanged,
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
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildChoiceTile({
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

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 24.sp),
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

  String _getMapStyleLabel(String style) {
    switch (style) {
      case 'standard':
        return 'Standard';
      case 'satellite':
        return 'Satellite';
      case 'terrain':
        return 'Terrain';
      case 'hybrid':
        return 'Hybrid';
      default:
        return 'Standard';
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Language changed to English')),
                );
              },
            ),
            RadioListTile<String>(
              title: const Text('العربية'),
              value: 'ar',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تغيير اللغة إلى العربية')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMapStyleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Map Style'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Standard'),
              value: 'standard',
              groupValue: _mapStyle,
              onChanged: (value) {
                setState(() => _mapStyle = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Satellite'),
              value: 'satellite',
              groupValue: _mapStyle,
              onChanged: (value) {
                setState(() => _mapStyle = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Terrain'),
              value: 'terrain',
              groupValue: _mapStyle,
              onChanged: (value) {
                setState(() => _mapStyle = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Hybrid'),
              value: 'hybrid',
              groupValue: _mapStyle,
              onChanged: (value) {
                setState(() => _mapStyle = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion coming soon'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
