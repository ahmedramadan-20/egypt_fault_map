import 'package:egypt_fault_map/core/routing/routes.dart';
import 'package:flutter/material.dart';

import '../../features/home/ui/home_screen.dart';
import '../../features/login/ui/login_screen.dart';
import '../../features/on_boarding/ui/onboarding_screen.dart';
import '../../features/signup/ui/signup_screen.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    final arguments = settings.arguments;
    switch (settings.name) {
      case Routes.homeScreen:
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      case Routes.onBoardingScreen:
        return MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        );
      case Routes.loginScreen:
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      case Routes.signupScreen:
        return MaterialPageRoute(builder: (context) => const SignupScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No Route Found for ${settings.name}')),
          ),
        );
    }
  }
}
