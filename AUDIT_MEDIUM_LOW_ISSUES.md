## 4. Medium & Low Priority Issues

### Issue #13: Simple String Hash for Cache Invalidation
**File:** `lib/features/home/logic/home_cubit.dart` (line 109)  
**Severity:** MEDIUM  
**Category:** Code Quality

#### Problem:
```dart
final currentHash = faults.map((e) => e.id).join(',');  // ❌ Inefficient for large lists
```

#### Fix:
```dart
// Add equatable package to pubspec.yaml
// Use Equatable or proper hash
import 'package:equatable/equatable.dart';

int _getFaultsHash(List<FaultModel> faults) {
  return Object.hashAll(faults.map((f) => f.id));
}

Set<Marker> _getMarkers(List<FaultModel> faults) {
  final currentHash = _getFaultsHash(faults);
  if (_cachedMarkers != null && _lastFaultsHash == currentHash) {
    return _cachedMarkers!;
  }
  
  _lastFaultsHash = currentHash;
  // ... rest of code
}
```

---

### Issue #14: Missing RepaintBoundary for Cached Images
**File:** `lib/features/home/ui/widgets/fault_card.dart` (lines 44-58)  
**Severity:** MEDIUM  
**Category:** Performance

#### Problem:
Images in list items cause unnecessary repaints of parent widgets.

#### Fix:
```dart
leading: fault.imageUrl.isNotEmpty
    ? RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: CachedNetworkImage(
            imageUrl: fault.imageUrl,
            width: 60.w,
            height: 60.h,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColors.grey300,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (_, __, ___) => Icon(
              Icons.broken_image,
              size: 60.sp,
              color: AppColors.grey,
            ),
          ),
        ),
      )
    : Container(/* ... */),
```

**Impact:** Medium - Reduces repaints, improves scroll performance

---

### Issue #15: Heavy Image Blur in build()
**File:** `lib/features/auth/ui/login_screen.dart` (lines 42-54)  
**Severity:** MEDIUM  
**Category:** Performance

#### Problem:
```dart
Positioned.fill(
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),  // ❌ Expensive operation in build
    child: Container(
      color: Colors.black.withValues(alpha: 0.4),
    ),
  ),
),
```

BackdropFilter is expensive and rebuilds on every frame.

#### Fix:
Use a pre-blurred image or wrap in RepaintBoundary:
```dart
Positioned.fill(
  child: RepaintBoundary(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
      ),
    ),
  ),
),
```

**Better:** Use a pre-processed blurred image:
```dart
Positioned.fill(
  child: Image.asset(
    'assets/images/login_map_bg_blurred.png',  // Pre-blurred in asset pipeline
    fit: BoxFit.cover,
    color: Colors.black.withOpacity(0.4),
    colorBlendMode: BlendMode.darken,
  ),
),
```

---

### Issue #16: Missing const Constructors
**Files:** Multiple  
**Severity:** MEDIUM  
**Category:** Performance

#### Locations:
- `lib/features/home/ui/widgets/fault_card.dart` - Line 37 (Card widget)
- `lib/features/home/ui/home_screen.dart` - Line 129 (Icon widget)
- `lib/features/auth/ui/login_screen.dart` - Multiple Text widgets
- Many other locations

#### Fix:
Add `const` where possible:
```dart
// Before
Icon(Icons.location_off, size: 80.sp, color: AppColors.grey)

// After
const Icon(Icons.location_off, size: 80, color: AppColors.grey)
// Note: Can't use .sp with const, consider using MediaQuery or avoiding const here
```

For text:
```dart
// Before
Text('Create Account', style: TextStyle(fontSize: 14.sp))

// After
const Text('Create Account')
// Or with theme
Text('Create Account', style: Theme.of(context).textTheme.bodyMedium)
```

**Impact:** Low-Medium - Reduces widget rebuilds and memory usage

---

### Issue #17: Mutable State in Cubit
**File:** `lib/features/home/logic/add_fault/add_fault_cubit.dart` (line 15)  
**Severity:** MEDIUM  
**Category:** Architecture

#### Problem:
```dart
class AddFaultCubit extends Cubit<AddFaultState> {
  final IFaultRepository _faultRepo;
  final FirebaseAuth _firebaseAuth;

  AddFaultCubit(this._faultRepo, this._firebaseAuth) : super(AddFaultInitial());

  LatLng? selectedLocation;  // ❌ Mutable state outside of State class
```

State should be immutable and contained in State classes, not as cubit properties.

#### Fix:
Already covered in Issue #5 - move selectedLocation to state class.

---

### Issue #18: States Not Using Equatable
**Files:** All state files  
**Severity:** MEDIUM  
**Category:** Architecture

#### Problem:
States don't implement Equatable, causing unnecessary rebuilds when the same state is emitted.

#### Fix:
```dart
// Add to pubspec.yaml
dependencies:
  equatable: ^2.0.5

// Update states
import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoadingState extends LoginState {}

class LoginSuccessState extends LoginState {}

class LoginFailureState extends LoginState {
  final String message;

  LoginFailureState({required this.message});

  @override
  List<Object?> get props => [message];
}
```

Apply to all state files:
- `login_state.dart`
- `register_state.dart`
- `home_state.dart`
- `location_state.dart`
- `add_fault_state.dart`
- `fault_details_state.dart`

**Impact:** Medium - Prevents unnecessary rebuilds

---

### Issue #19: Unsafe Cast Without Type Check
**File:** `lib/core/routing/app_router.dart` (line 27)  
**Severity:** MEDIUM  
**Category:** Error Handling

#### Problem:
```dart
case Routes.faultDetailsScreen:
  final args = settings.arguments as Map<String, dynamic>;  // ❌ Can crash if wrong type
  return MaterialPageRoute(
    builder: (context) => FaultDetailsScreen(
      fault: args['fault'],
      distance: args['distance'],
    ),
  );
```

#### Fix:
```dart
case Routes.faultDetailsScreen:
  if (settings.arguments is! Map<String, dynamic>) {
    return _errorRoute('Invalid arguments for FaultDetailsScreen');
  }
  final args = settings.arguments as Map<String, dynamic>;
  
  if (!args.containsKey('fault') || args['fault'] is! FaultModel) {
    return _errorRoute('Missing or invalid fault argument');
  }
  
  return MaterialPageRoute(
    builder: (context) => FaultDetailsScreen(
      fault: args['fault'] as FaultModel,
      distance: args['distance'] as double?,
    ),
  );

// Helper method
MaterialPageRoute _errorRoute(String message) {
  return MaterialPageRoute(
    builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('Navigation Error: $message'),
      ),
    ),
  );
}
```

---

### Issue #20: Typo in Asset Path
**File:** `lib/features/home/ui/fault_details_screen.dart` (line 57)  
**Severity:** LOW  
**Category:** Bug

#### Problem:
```dart
assetPath = 'assets/images/high_severtity_marker.png';  // ❌ Typo: "severtity"
```

#### Fix:
```dart
assetPath = 'assets/images/high_severity_marker.png';  // ✅ Correct spelling
```

**Impact:** High (if asset doesn't load) - Critical runtime error

---

### Issue #21: Inconsistent Error Message Formatting
**Files:** Multiple  
**Severity:** LOW  
**Category:** Code Quality

#### Problem:
Error messages are inconsistent:
- Some use "Check your email and password"
- Some use "An error occurred"
- Some use exception.toString() directly

#### Fix:
Create consistent error handling:
```dart
// lib/core/helpers/error_handler.dart
class ErrorHandler {
  static String getReadableError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found with this email address.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'weak-password':
          return 'Password must be at least 6 characters.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        default:
          return error.message ?? 'Authentication failed. Please try again.';
      }
    }
    
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'You don\'t have permission to perform this action.';
        case 'unavailable':
          return 'Service unavailable. Please try again later.';
        default:
          return 'An error occurred. Please try again.';
      }
    }
    
    return 'An unexpected error occurred.';
  }
}
```

Use in cubits:
```dart
} catch (e) {
  emit(LoginFailureState(message: ErrorHandler.getReadableError(e)));
}
```

---

### Issue #22: Direct GetIt Access in Widget
**File:** `lib/features/on_boarding/ui/onboarding_screen.dart` (line 158)  
**Severity:** LOW  
**Category:** Architecture

#### Problem:
```dart
void _finishOnboarding(BuildContext context) {
  getIt<CacheHelper>().saveData(key: 'onBoarding', value: true);  // ❌ Direct DI access
  context.pushReplacementNamed(Routes.loginScreen);
}
```

#### Fix:
```dart
class OnboardingScreen extends StatefulWidget {
  final CacheHelper? cacheHelper;  // Optional for DI
  
  const OnboardingScreen({super.key, this.cacheHelper});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final CacheHelper _cacheHelper;
  
  @override
  void initState() {
    super.initState();
    _cacheHelper = widget.cacheHelper ?? getIt<CacheHelper>();
  }

  void _finishOnboarding(BuildContext context) {
    _cacheHelper.saveData(key: 'onBoarding', value: true);
    context.pushReplacementNamed(Routes.loginScreen);
  }
}
```

**Impact:** Low - Improves testability

---

### Issue #23: Firebase Instances as LazySingleton
**File:** `lib/core/di/dependency_injection.dart` (lines 12-15)  
**Severity:** LOW  
**Category:** Architecture

#### Problem:
```dart
getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
```

Firebase instances are already singletons. Using `registerLazySingleton` is semantically incorrect (though functionally fine).

#### Fix:
```dart
// Register as factory since Firebase manages its own singleton
getIt.registerFactory<FirebaseAuth>(() => FirebaseAuth.instance);
getIt.registerFactory<FirebaseFirestore>(() => FirebaseFirestore.instance);

// Or just use directly without DI:
// In repositories, just use FirebaseAuth.instance directly
```

**Impact:** Very Low - Mostly semantic, no functional impact

---

### Issue #24: Deprecated BitmapDescriptor.fromBytes
**Files:** `lib/features/home/logic/home_cubit.dart`, `lib/features/home/ui/fault_details_screen.dart`  
**Severity:** LOW  
**Category:** Deprecation

#### Problem:
```dart
return BitmapDescriptor.fromBytes(bytes);  // ❌ Deprecated
```

#### Fix:
```dart
return BitmapDescriptor.bytes(bytes);  // ✅ New API
```

---

### Issue #25: No Loading State Handling in Fault Details
**File:** `lib/features/home/ui/fault_details_screen.dart`  
**Severity:** MEDIUM  
**Category:** UX

#### Problem:
The screen doesn't show loading state while fetching reporter info.

#### Fix:
Already addressed in Issue #8 with BlocBuilder implementation.

---

### Issue #26: No Error Boundary for Widget Errors
**Severity:** MEDIUM  
**Category:** Error Handling

#### Problem:
No global error handling for widget tree errors.

#### Fix:
```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Catch Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Log to Firebase Crashlytics or your logging service
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  // Catch async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Async Error: $error');
    debugPrint('Stack trace: $stack');
    return true;
  };

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupGetIt();

  // ... rest of main
}
```

---

### Issue #27: No Offline Support
**Severity:** MEDIUM  
**Category:** Feature Gap

#### Problem:
App doesn't handle offline scenarios gracefully.

#### Fix:
```dart
// Enable Firestore offline persistence in main.dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

// Enable offline persistence
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

Add connectivity check:
```dart
// Add connectivity_plus package
import 'package:connectivity_plus/connectivity_plus.dart';

// In HomeCubit
Future<void> loadFaults({Position? userPosition}) async {
  emit(HomeLoading());
  
  final connectivityResult = await Connectivity().checkConnectivity();
  final isOffline = connectivityResult == ConnectivityResult.none;
  
  try {
    var faults = await _faultRepo.getAllFaults();
    // ... rest of logic
    
    if (isOffline && faults.isEmpty) {
      emit(HomeError('No internet connection. Showing cached data.'));
    } else {
      emit(HomeLoaded(faults, markers, userPosition));
    }
  } catch (e) {
    emit(HomeError(isOffline 
        ? 'No internet connection and no cached data available.'
        : e.toString()));
  }
}
```

---

### Issue #28: No Form Validation in Add Fault
**File:** `lib/features/home/ui/add_fault_screen.dart`  
**Severity:** MEDIUM  
**Category:** Validation

#### Problem:
Form doesn't prevent submission with empty description.

#### Fix:
```dart
final _formKey = GlobalKey<FormState>();

// Wrap form in Form widget
Form(
  key: _formKey,
  child: Column(
    children: [
      // ... existing fields
    ],
  ),
)

// In button onPressed
onPressed: state is AddFaultLoading
    ? null
    : () {
        if (_formKey.currentState!.validate()) {
          context.read<AddFaultCubit>().addFault(
            type: _type,
            description: _descController.text,
            severity: _severity,
          );
        }
      },
```

---

### Issue #29: GoogleMap Controller Not Disposed in Fault Details
**File:** `lib/features/home/ui/fault_details_screen.dart`  
**Severity:** MEDIUM  
**Category:** Memory Management

#### Problem:
GoogleMap might create a controller internally that isn't disposed.

#### Fix:
```dart
class FaultDetailsScreen extends StatefulWidget {
  final FaultModel fault;
  final double? distance;

  const FaultDetailsScreen({super.key, required this.fault, this.distance});

  @override
  State<FaultDetailsScreen> createState() => _FaultDetailsScreenState();
}

class _FaultDetailsScreenState extends State<FaultDetailsScreen> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FaultDetailsCubit(getIt<FirebaseFirestore>())
        ..loadReporterInfo(widget.fault.createdBy, widget.fault.severity),
      child: Scaffold(
        // ... rest of build with onMapCreated callback
        onMapCreated: (controller) => _mapController = controller,
      ),
    );
  }
}
```

---

### Issue #30: No Input Sanitization
**Severity:** MEDIUM  
**Category:** Security

#### Problem:
User inputs aren't sanitized before storing in Firestore.

#### Fix:
```dart
// lib/core/helpers/input_sanitizer.dart
class InputSanitizer {
  static String sanitize(String input, {int maxLength = 500}) {
    // Remove excessive whitespace
    var sanitized = input.trim().replaceAll(RegExp(r'\s+'), ' ');
    
    // Limit length
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }
    
    // Remove potentially dangerous characters for XSS
    // (Though Firestore/Flutter doesn't render HTML, good practice)
    sanitized = sanitized
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('script', '');
    
    return sanitized;
  }
}

// Use in cubits
Future<void> addFault({
  required String type,
  required String description,
  required String severity,
}) async {
  final sanitizedDescription = InputSanitizer.sanitize(description);
  
  if (sanitizedDescription.isEmpty) {
    emit(AddFaultError("Description cannot be empty."));
    return;
  }
  
  // ... rest of method
}
```

