import 'dart:ui';

import 'package:egypt_fault_map/core/routing/routes.dart';
import 'package:egypt_fault_map/features/auth/logic/login/login_cubit.dart';
import 'package:egypt_fault_map/features/auth/logic/login/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/widgets/text_field.dart';
import '../data/repos/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(getIt<AuthRepository>()),
      child: Scaffold(
        body: Stack(
          children: [
            // 1. Blurred Map Background
            Positioned.fill(
              child: Image.asset(
                'assets/images/login_map_bg.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.4), // Dark overlay
                ),
              ),
            ),

            // 2. Center Card
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        elevation: 8,
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: BlocConsumer<LoginCubit, LoginState>(
                            listener: (context, state) {
                              if (state is LoginSuccessState) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  Routes.homeScreen,
                                );
                              } else if (state is LoginFailureState) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(state.message)),
                                );
                              }
                            },
                            builder: (context, state) {
                              return Form(
                                key: formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // App Logo
                                    Image.asset(
                                      'assets/images/app_logo.png',
                                      width: 120.w,
                                    ),
                                    SizedBox(height: 24.h),

                                    // Email Field
                                    AppTextFormField(
                                      hintText: 'Email',
                                      prefixIcon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      controller: emailController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16.h),

                                    // Password Field
                                    AppTextFormField(
                                      hintText: 'Password',
                                      prefixIcon: Icons.lock_outline,
                                      obscureText: true,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      controller: passwordController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 24.h),

                                    // Login Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50.h,
                                      child: ElevatedButton(
                                        onPressed: state is LoginLoadingState
                                            ? null
                                            : () {
                                                if (formKey.currentState!
                                                    .validate()) {
                                                  context
                                                      .read<LoginCubit>()
                                                      .login(
                                                        emailController.text,
                                                        passwordController.text,
                                                      );
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                          ),
                                        ),
                                        child: state is LoginLoadingState
                                            ? const CircularProgressIndicator(
                                                color: Colors.white,
                                              )
                                            : Text(
                                                'Login',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),
                                    SizedBox(height: 16.h),

                                    // Create Account
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          Routes.signupScreen,
                                        );
                                      },
                                      child: Text(
                                        'Create Account',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),

                                    // Continue as Guest
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          Routes.homeScreen,
                                        );
                                      },
                                      child: Text(
                                        'Continue as Guest',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Bottom Text
            Positioned(
              bottom: 30.h,
              left: 0,
              right: 0,
              child: Text(
                'Troubleshooting the country starts with you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
