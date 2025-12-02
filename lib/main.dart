import 'package:egypt_fault_map/app.dart';
import 'package:egypt_fault_map/core/di/dependency_injection.dart';
import 'package:egypt_fault_map/core/helpers/shared_preferences_helper.dart';
import 'package:egypt_fault_map/core/routing/app_router.dart';
import 'package:egypt_fault_map/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await setupGetIt();
  await ScreenUtil.ensureScreenSize();

  final cache = getIt<CacheHelper>();

  String initialRoute = Routes.onBoardingScreen;
  bool? onBoarding = cache.getData('onBoarding');
  String? uid = cache.getData('uid');

  if (onBoarding != null && onBoarding) {
    if (uid != null && uid.isNotEmpty) {
      initialRoute = Routes.homeScreen;
    } else {
      initialRoute = Routes.loginScreen;
    }
  }

  runApp(EgyptFaultMap(appRouter: AppRouter(), initialRoute: initialRoute));
}
