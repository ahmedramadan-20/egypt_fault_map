import 'package:egypt_fault_map/core/di/dependency_injection.dart';
import 'package:egypt_fault_map/core/helpers/shared_preferences_helper.dart';
import 'package:egypt_fault_map/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../data/models/onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingModel> _pages = [
    OnboardingModel(
      image: 'assets/images/onboarding1.png',
      title: 'Report Problems in Seconds',
      subtitle:
          'Quickly submit any public issue around you — from road damage to water leaks — with just a few taps.',
    ),
    OnboardingModel(
      image: 'assets/images/onboarding2.png',
      title: 'Live Map of Nearby Issues',
      subtitle:
          'See all reported faults around you on an interactive map, updated instantly in real time.',
    ),
    OnboardingModel(
      image: 'assets/images/onboarding3.png',
      title: 'Track Progress Effortlessly',
      subtitle:
          'Follow your reports, check their status, and stay updated until the issue is fully fixed.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    _finishOnboarding(context);
                  },
                  child: Text(
                    'Skip',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Image.asset(
                            _pages[index].image,
                            //width: 300.w,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 30.h),
                        Text(
                          _pages[index].title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 15.h),
                        Text(
                          _pages[index].subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: _currentPage == index ? 20.w : 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.blue
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _pages.length - 1) {
                      _finishOnboarding(context);
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: TextStyle(fontSize: 18.sp, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _finishOnboarding(BuildContext context) {
    getIt<CacheHelper>().saveData(key: 'onBoarding', value: true);
    Navigator.pushReplacementNamed(context, Routes.loginScreen);
  }
}
