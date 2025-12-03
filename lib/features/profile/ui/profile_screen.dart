import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:egypt_fault_map/core/helpers/extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/helpers/shared_preferences_helper.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theming/app_colors.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../home/data/repos/fault_repository.dart';
import '../logic/edit_profile/edit_profile_cubit.dart';
import '../logic/profile_cubit.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import 'my_reports_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(
        getIt<FirebaseAuth>(),
        getIt<FirebaseFirestore>(),
        getIt<IFaultRepository>(),
        getIt<CacheHelper>(),
      )..loadProfile(),
      child: const _ProfileScreenContent(),
    );
  }
}

class _ProfileScreenContent extends StatelessWidget {
  const _ProfileScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const ProfileSkeleton();
          } else if (state is ProfileLoaded) {
            return _buildProfileContent(context, state);
          } else if (state is ProfileError) {
            return _buildErrorState(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProfilePicture(ProfileLoaded state) {
    // Handle different image sources
    final profileImage = state.user.profileImage;

    // Default icon if null or empty
    if (profileImage == null || profileImage.isEmpty) {
      return CircleAvatar(
        radius: 60.r,
        backgroundColor: Colors.white,
        child: Icon(Icons.person, size: 60.sp, color: AppColors.primary),
      );
    }

    // Network URL (http:// or https://)
    if (profileImage.startsWith('http://') ||
        profileImage.startsWith('https://')) {
      return CircleAvatar(
        radius: 60.r,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 56.r,
          backgroundImage: NetworkImage(profileImage),
          onBackgroundImageError: (exception, stackTrace) {
            // If network image fails, show default
          },
          child: null,
        ),
      );
    }

    // Asset path (assets/images/...)
    return CircleAvatar(
      radius: 60.r,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: 56.r,
        backgroundImage: AssetImage(profileImage),
        onBackgroundImageError: (exception, stackTrace) {
          // If asset fails, show default
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, ProfileLoaded state) {
    return RefreshIndicator(
      onRefresh: () => context.read<ProfileCubit>().loadProfile(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: Column(
                children: [
                  // Profile Picture
                  _buildProfilePicture(state),
                  SizedBox(height: 16.h),
                  // User Name
                  Text(
                    state.user.name,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // User Email
                  Text(
                    state.user.email,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Statistics Cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.report_problem,
                      title: 'My Reports',
                      value: state.userFaults.toString(),
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.public,
                      title: 'Total Faults',
                      value: state.totalFaults.toString(),
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Profile Options
            _buildOptionsList(context, state),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40.sp, color: color),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsList(BuildContext context, ProfileLoaded state) {
    return Column(
      children: [
        _buildOptionTile(
          context,
          icon: Icons.person,
          title: 'Account Information',
          subtitle: 'View and edit your profile',
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => EditProfileCubit(
                    getIt<FirebaseFirestore>(),
                  ),
                  child: EditProfileScreen(user: state.user),
                ),
              ),
            );
            // Reload profile if changes were made
            if (result == true && context.mounted) {
              context.read<ProfileCubit>().loadProfile();
            }
          },
        ),
        _buildOptionTile(
          context,
          icon: Icons.history,
          title: 'My Reports History',
          subtitle: 'View all your reported faults',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyReportsScreen(userId: state.user.uid),
              ),
            );
          },
        ),
        _buildOptionTile(
          context,
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'Manage notification preferences',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          },
        ),
        _buildOptionTile(
          context,
          icon: Icons.settings,
          title: 'Settings',
          subtitle: 'App preferences and configuration',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
        ),
        _buildOptionTile(
          context,
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Get help or contact support',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HelpSupportScreen(),
              ),
            );
          },
        ),
        _buildOptionTile(
          context,
          icon: Icons.info_outline,
          title: 'About',
          subtitle: 'App version and information',
          onTap: () => _showAboutDialog(context),
        ),
        _buildOptionTile(
          context,
          icon: Icons.logout,
          title: 'Logout',
          subtitle: 'Sign out from your account',
          iconColor: Colors.red,
          onTap: () => _showLogoutDialog(context),
        ),
      ],
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
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

  Widget _buildErrorState(BuildContext context, ProfileError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            'Error Loading Profile',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              state.message,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => context.read<ProfileCubit>().loadProfile(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<ProfileCubit>().logout();
              if (context.mounted) {
                context.pushNamedAndRemoveUntil(
                  Routes.loginScreen,
                  predicate: (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Egypt Fault Map',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(Icons.map, size: 48.sp, color: AppColors.primary),
      children: [
        SizedBox(height: 16.h),
        const Text(
          'A community-driven application for reporting and tracking infrastructure faults across Egypt.',
        ),
        SizedBox(height: 16.h),
        const Text(
          'Report faults, view nearby issues, and help improve your community.',
        ),
      ],
    );
  }
}
