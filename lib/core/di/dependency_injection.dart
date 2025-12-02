import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/data/repos/auth_repository.dart';
import '../../features/home/data/repos/fault_repository.dart';
import '../helpers/shared_preferences_helper.dart';

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  // Firebase
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // Cache
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<CacheHelper>(
    () => CacheHelper(sharedPreferences),
  );

  // Auth Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      firebaseAuth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
      cacheHelper: getIt<CacheHelper>(),
    ),
  );

  // Fault Repository
  getIt.registerLazySingleton<FaultRepository>(
    () => FaultRepository(getIt<FirebaseFirestore>()),
  );
}
