import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theming/app_colors.dart';
import '../../auth/data/models/app_user.dart';
import '../logic/edit_profile/edit_profile_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  final AppUser user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          BlocBuilder<EditProfileCubit, EditProfileState>(
            builder: (context, state) {
              if (state is EditProfileLoading) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              return TextButton(
                onPressed: () => _saveProfile(context),
                child: const Text('Save'),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<EditProfileCubit, EditProfileState>(
        listener: (context, state) {
          if (state is EditProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true); // Return true to indicate success
          } else if (state is EditProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 16.h),
                  // Profile Picture (Read-only)
                  _buildProfilePictureSection(context, state),
                  SizedBox(height: 8.h),
                  Text(
                    'Profile picture cannot be changed',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.trim().length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  // Email Field (Read-only)
                  TextFormField(
                    controller: TextEditingController(text: widget.user.email),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      suffixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    enabled: false,
                  ),
                  SizedBox(height: 16.h),
                  // Phone Field
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      hintText: 'Phone Number (Optional)',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (value.length < 10) {
                          return 'Please enter a valid phone number';
                        }
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32.h),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: state is EditProfileLoading
                          ? null
                          : () => _saveProfile(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: state is EditProfileLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfilePictureSection(BuildContext context, EditProfileState state) {
    final currentImage = widget.user.profileImage;

    return CircleAvatar(
      radius: 60.r,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      backgroundImage: currentImage != null && currentImage.isNotEmpty
          ? (currentImage.startsWith('http')
              ? NetworkImage(currentImage)
              : AssetImage(currentImage)) as ImageProvider
          : null,
      child: currentImage == null || currentImage.isEmpty
          ? Icon(Icons.person, size: 60.sp, color: AppColors.primary)
          : null,
    );
  }

  void _saveProfile(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<EditProfileCubit>().updateProfile(
            userId: widget.user.uid,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim().isEmpty 
                ? null 
                : _phoneController.text.trim(),
          );
    }
  }
}
