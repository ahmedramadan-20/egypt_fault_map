import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:egypt_fault_map/features/auth/data/models/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/helpers/shared_preferences_helper.dart';

class AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final CacheHelper cacheHelper;

  AuthRepository({
    required this.firebaseAuth,
    required this.firestore,
    required this.cacheHelper,
  });

  // -----------------------------
  // REGISTER USER
  // -----------------------------
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCred = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final appUser = AppUser(
        uid: userCred.user!.uid,
        name: name,
        email: email,
        profileImage: "assets/images/profile_pic.png",
      );

      await firestore.collection('users').doc(appUser.uid).set(appUser.toMap());

      // cache uid
      await cacheHelper.saveData(key: "uid", value: appUser.uid);

      return appUser;
    } on FirebaseAuthException catch (e, stackTrace) {
      throw AuthException(
        message: e.message ?? 'Sign up failed',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } on FirebaseException catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to create user profile: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to create user profile: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // -----------------------------
  // LOGIN
  // -----------------------------
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCred = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await firestore
          .collection('users')
          .doc(userCred.user!.uid)
          .get();

      if (!doc.exists) {
        throw DatabaseException.documentNotFound(userCred.user!.uid);
      }

      final appUser = AppUser.fromDoc(doc);

      await cacheHelper.saveData(key: "uid", value: appUser.uid);

      return appUser;
    } on FirebaseAuthException catch (e, stackTrace) {
      throw AuthException(
        message: e.message ?? 'Login failed',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } on DatabaseException {
      rethrow;
    } on FirebaseException catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to load user profile: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to load user profile: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // -----------------------------
  // GET CURRENT USER
  // -----------------------------
  Future<AppUser?> getCurrentUser() async {
    final uid = cacheHelper.getData("uid");

    if (uid == null) return null;

    final doc = await firestore.collection('users').doc(uid).get();

    if (!doc.exists) return null;

    return AppUser.fromDoc(doc);
  }

  // -----------------------------
  // LOGOUT
  // -----------------------------
  Future<void> logout() async {
    await firebaseAuth.signOut();
    await cacheHelper.remove("uid");
  }
}
