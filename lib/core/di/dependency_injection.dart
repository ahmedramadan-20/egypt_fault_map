import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/shared_preferences_helper.dart';

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  // SharedPreferences instance
  final prefs = await SharedPreferences.getInstance();

  // Register SharedPreferences
  getIt.registerLazySingleton<SharedPreferences>(() => prefs);

  // Register our CacheHelper (converted to instance-based)
  getIt.registerLazySingleton<CacheHelper>(() => CacheHelper(prefs));
}
