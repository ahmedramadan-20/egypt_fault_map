import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theming/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        children: [
          // Contact Card
          Container(
            margin: EdgeInsets.all(16.w),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Icon(Icons.support_agent, size: 48.sp, color: Colors.white),
                SizedBox(height: 12.h),
                Text(
                  'We\'re Here to Help',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Get in touch with our support team',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // FAQ Section
          _buildSection(
            context,
            'Frequently Asked Questions',
            [
              _buildFAQTile(
                context,
                question: 'How do I report a fault?',
                answer: 'Tap the "Report Fault" button on the home screen, fill in the details, add photos, and mark the location on the map.',
              ),
              _buildFAQTile(
                context,
                question: 'Can I edit my reported faults?',
                answer: 'Yes, you can view your reports in "My Reports History" and make updates to them.',
              ),
              _buildFAQTile(
                context,
                question: 'How do I update my profile?',
                answer: 'Go to your profile, tap on "Account Information", and update your details.',
              ),
              _buildFAQTile(
                context,
                question: 'What types of faults can I report?',
                answer: 'You can report infrastructure issues like potholes, broken lights, water leaks, and more.',
              ),
            ],
          ),

          // Contact Options
          _buildSection(
            context,
            'Contact Us',
            [
              _buildContactTile(
                icon: Icons.email,
                title: 'Email Support',
                subtitle: 'support@egyptfaultmap.com',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening email app...')),
                  );
                },
              ),
              _buildContactTile(
                icon: Icons.phone,
                title: 'Phone Support',
                subtitle: '+20 123 456 7890',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening phone app...')),
                  );
                },
              ),
              _buildContactTile(
                icon: Icons.chat,
                title: 'Live Chat',
                subtitle: 'Chat with our support team',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Live chat coming soon')),
                  );
                },
              ),
            ],
          ),

          // Resources
          _buildSection(
            context,
            'Resources',
            [
              _buildResourceTile(
                icon: Icons.book,
                title: 'User Guide',
                subtitle: 'Learn how to use the app',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User guide coming soon')),
                  );
                },
              ),
              _buildResourceTile(
                icon: Icons.video_library,
                title: 'Video Tutorials',
                subtitle: 'Watch helpful videos',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Video tutorials coming soon')),
                  );
                },
              ),
              _buildResourceTile(
                icon: Icons.bug_report,
                title: 'Report a Bug',
                subtitle: 'Found an issue? Let us know',
                onTap: () => _showBugReportDialog(context),
              ),
            ],
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildFAQTile(BuildContext context, {required String question, required String answer}) {
    return ExpansionTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(Icons.help_outline, color: AppColors.primary, size: 24.sp),
      ),
      title: Text(
        question,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(72.w, 0, 16.w, 16.h),
          child: Text(
            answer,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildContactTile({
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

  Widget _buildResourceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: Colors.orange, size: 24.sp),
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

  void _showBugReportDialog(BuildContext context) {
    final TextEditingController bugController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Report a Bug'),
        content: TextField(
          controller: bugController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Describe the bug you encountered...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bug report submitted. Thank you!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
