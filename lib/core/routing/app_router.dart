import 'package:flutter/material.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/auth/ui/signup_screen.dart';
import '../../features/home/ui/home_screen.dart';
import '../../features/home/ui/add_fault_screen.dart';
import '../../features/home/ui/fault_details_screen.dart';
import '../../features/notifications/ui/notifications_list_screen.dart';
import '../../features/on_boarding/ui/onboarding_screen.dart';
import '../../features/profile/ui/profile_screen.dart';
import 'routes.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    // final arguments = settings.arguments;
    switch (settings.name) {
      case '/':
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
      case Routes.addFaultScreen:
        return MaterialPageRoute(builder: (context) => const AddFaultScreen());
      case Routes.faultDetailsScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => FaultDetailsScreen(
            fault: args['fault'],
            distance: args['distance'],
          ),
        );
      case Routes.profileScreen:
        return MaterialPageRoute(builder: (context) => const ProfileScreen());
      case Routes.notificationsScreen:
        return MaterialPageRoute(builder: (context) => const NotificationsListScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No Route Found for ${settings.name}')),
          ),
        );
    }
  }
}
