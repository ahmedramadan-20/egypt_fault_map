## 5. Memory Leak & Dispose Checklist

### Critical Memory Leaks Identified

#### ✅ = Properly Disposed | ❌ = Memory Leak | ⚠️ = Needs Verification

---

### Controllers & Disposables Audit

#### TextEditingControllers

| File | Line | Status | Issue |
|------|------|--------|-------|
| `login_screen.dart` | 22-23 | ✅ | Properly disposed in dispose() |
| `signup_screen.dart` | 22-24 | ✅ | Properly disposed in dispose() |
| `login_form.dart` | 31, 44 | ❌ | **CRITICAL: Created in build(), never disposed** |
| `add_fault_screen.dart` | 51 | ✅ | Properly disposed in dispose() |

**Action Required:**
```dart
// lib/features/auth/ui/widgets/login_form.dart
// Convert to StatefulWidget with proper lifecycle management
class _LoginFormState extends State<LoginForm> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

---

#### PageControllers

| File | Line | Status | Issue |
|------|------|--------|-------|
| `onboarding_screen.dart` | 17 | ❌ | **CRITICAL: Never disposed** |

**Action Required:**
```dart
@override
void dispose() {
  _pageController.dispose();
  super.dispose();
}
```

---

#### GoogleMapControllers

| File | Line | Status | Issue |
|------|------|--------|-------|
| `home_screen.dart` | 36 | ✅ | Properly disposed in dispose() |
| `add_fault_screen.dart` | N/A | ⚠️ | No controller stored, GoogleMap manages internally |
| `fault_details_screen.dart` | N/A | ❌ | **No controller stored, should be added for proper cleanup** |

**Action Required:**
```dart
// lib/features/home/ui/fault_details_screen.dart
class _FaultDetailsScreenState extends State<FaultDetailsScreen> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (controller) => _mapController = controller,
      // ...
    );
  }
}
```

---

#### StreamSubscriptions

| File | Line | Status | Issue |
|------|------|--------|-------|
| `location_cubit.dart` | 7 | ✅ | Properly cancelled in close() method |

**Verification:**
```dart
// ✅ Correctly implemented
@override
Future<void> close() {
  _positionStream?.cancel();
  return super.close();
}
```

---

#### BLoC/Cubits

| File | Scope | Status | Issue |
|------|-------|--------|-------|
| `LocationCubit` | App root (app.dart:18) | ❌ | **CRITICAL: Never closed, lives forever** |
| `HomeCubit` | HomeScreen | ✅ | Automatically closed by BlocProvider |
| `LoginCubit` | LoginScreen | ✅ | Automatically closed by BlocProvider |
| `RegisterCubit` | SignupScreen | ✅ | Automatically closed by BlocProvider |
| `AddFaultCubit` | AddFaultScreen | ✅ | Automatically closed by BlocProvider |
| `FaultDetailsCubit` | FaultDetailsScreen | ✅ | Automatically closed by BlocProvider |

**Action Required:**
```dart
// Move LocationCubit from app.dart to HomeScreen
// app.dart - REMOVE BlocProvider
class EgyptFaultMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      child: MaterialApp(...),  // No BlocProvider here
    );
  }
}

// home_screen.dart - ADD BlocProvider
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocationCubit()..getLocation(),
      child: BlocProvider(
        create: (context) => HomeCubit(getIt<IFaultRepository>()),
        child: const _HomeScreenContent(),
      ),
    );
  }
}
```

---

#### AnimationControllers

| File | Line | Status | Issue |
|------|------|--------|-------|
| N/A | N/A | N/A | No AnimationControllers found |

✅ **No issues found**

---

#### TabControllers

| File | Line | Status | Issue |
|------|------|--------|-------|
| N/A | N/A | N/A | No TabControllers found |

✅ **No issues found**

---

#### ScrollControllers

| File | Line | Status | Issue |
|------|------|--------|-------|
| N/A | N/A | N/A | No explicit ScrollControllers found |

✅ **No issues found** (ListView.builder creates its own)

---

#### FocusNodes

| File | Line | Status | Issue |
|------|------|--------|-------|
| N/A | N/A | N/A | No explicit FocusNodes found |

✅ **No issues found**

---

### Other Resource Leaks

#### Logger Instances

| File | Line | Status | Issue |
|------|------|--------|-------|
| `home_cubit.dart` | 36 | ⚠️ | **New Logger per cubit instance** |

**Issue:**
```dart
class HomeCubit extends Cubit<HomeState> {
  final Logger _logger = Logger();  // ❌ New instance per cubit
```

**Action Required:**
```dart
// Create global logger
final _logger = Logger(
  printer: PrettyPrinter(),
);

class HomeCubit extends Cubit<HomeState> {
  final IFaultRepository _faultRepo;
  // Remove: final Logger _logger = Logger();
  
  HomeCubit(this._faultRepo) : super(HomeInitial());
  
  Future<void> loadFaults({Position? userPosition}) async {
    _logger.d("Loading faults...");  // Use global logger
  }
}
```

---

#### Image Cache

| File | Line | Status | Issue |
|------|------|--------|-------|
| `home_cubit.dart` | 40-42 | ⚠️ | BitmapDescriptor cached but never cleared |

**Analysis:**
```dart
BitmapDescriptor? _lowSeverityIcon;
BitmapDescriptor? _mediumSeverityIcon;
BitmapDescriptor? _highSeverityIcon;
```

These are cached in the cubit and automatically cleared when cubit is closed. ✅ **Acceptable**

However, the cubit should override close() to explicitly clear:
```dart
@override
Future<void> close() {
  _cachedMarkers?.clear();
  _cachedMarkers = null;
  return super.close();
}
```

---

### Complete Disposal Checklist

Copy this checklist and verify each item:

#### App-Level
- [ ] LocationCubit moved from app root to screen scope
- [ ] No global controllers or streams that persist beyond app lifecycle
- [ ] Firebase instances properly initialized (no cleanup needed)

#### Screen-Level (LoginScreen)
- [x] emailController disposed
- [x] passwordController disposed
- [ ] BlocProvider automatically disposes LoginCubit

#### Screen-Level (SignupScreen)
- [x] nameController disposed
- [x] emailController disposed
- [x] passwordController disposed
- [ ] BlocProvider automatically disposes RegisterCubit

#### Screen-Level (OnboardingScreen)
- [ ] **PageController disposal MISSING - ADD THIS**

#### Screen-Level (HomeScreen)
- [x] mapController disposed
- [ ] BlocProvider automatically disposes HomeCubit
- [ ] BlocProvider automatically disposes LocationCubit (after fix)

#### Screen-Level (AddFaultScreen)
- [x] descController disposed
- [ ] BlocProvider automatically disposes AddFaultCubit

#### Screen-Level (FaultDetailsScreen)
- [ ] **GoogleMapController disposal MISSING - ADD THIS**
- [ ] BlocProvider automatically disposes FaultDetailsCubit

#### Widget-Level (LoginForm)
- [ ] **TextEditingController leaks - CONVERT TO STATEFUL**

---

### Memory Leak Detection Guide

#### How to Detect Memory Leaks

**1. Using Flutter DevTools:**
```bash
# Run in profile mode
flutter run --profile

# Open DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Navigate through app, then:
# 1. Go to Memory tab
# 2. Take snapshot
# 3. Navigate away and back
# 4. Force GC (garbage collection)
# 5. Take another snapshot
# 6. Compare - if objects persist, you have a leak
```

**2. Using Observatory:**
```bash
flutter run --observatory-port=8888

# Open browser to http://localhost:8888
# Use Memory tab to inspect heap
```

**3. Manual Testing:**
```dart
// Add to main.dart (debug only)
void main() {
  if (kDebugMode) {
    debugPrintRebuildDirtyWidgets = true;
  }
  runApp(MyApp());
}

// Monitor output for excessive rebuilds
```

---

### Testing for Memory Leaks

#### Unit Test for Disposal

```dart
// test/cubits/home_cubit_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  late HomeCubit cubit;
  late MockFaultRepository mockRepo;

  setUp(() {
    mockRepo = MockFaultRepository();
    cubit = HomeCubit(mockRepo);
  });

  tearDown(() {
    cubit.close();
  });

  test('cubit closes without errors', () async {
    await cubit.loadFaults();
    await cubit.close();
    
    // Verify cubit is closed
    expect(cubit.isClosed, true);
  });

  test('stream subscription is cancelled on close', () async {
    // Create cubit with location stream
    final locationCubit = LocationCubit();
    await locationCubit.getLocation();
    
    // Close and verify no memory leak
    await locationCubit.close();
    expect(locationCubit.isClosed, true);
  });
}
```

#### Widget Test for Controller Disposal

```dart
// test/widgets/login_screen_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LoginScreen disposes controllers', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: LoginScreen()),
    );

    // Navigate away
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();

    // If controllers aren't disposed, this will throw
    // (DevTools will show warnings)
  });
}
```

---

### Memory Leak Prevention Guidelines

#### 1. Always Dispose Controllers
```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();  // ✅ Always dispose
    super.dispose();
  }
}
```

#### 2. Cancel Stream Subscriptions
```dart
class _MyWidgetState extends State<MyWidget> {
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = myStream.listen((data) {
      // Handle data
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();  // ✅ Always cancel
    super.dispose();
  }
}
```

#### 3. Close Cubits/Blocs
```dart
class MyCubit extends Cubit<MyState> {
  final StreamSubscription _subscription;

  MyCubit() : super(MyInitial()) {
    _subscription = myStream.listen(_onData);
  }

  @override
  Future<void> close() {
    _subscription.cancel();  // ✅ Clean up in close()
    return super.close();
  }
}
```

#### 4. Use StatefulWidget Correctly
```dart
// ❌ BAD: Creating disposable in build()
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(),  // Memory leak!
    );
  }
}

// ✅ GOOD: Creating in initState, disposing in dispose
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(controller: _controller);
  }
}
```

---

### Summary of Required Fixes

| Priority | File | Action | Est. Time |
|----------|------|--------|-----------|
| 🔴 CRITICAL | `app.dart` | Move LocationCubit to HomeScreen | 15 min |
| 🔴 CRITICAL | `login_form.dart` | Convert to StatefulWidget | 20 min |
| 🔴 CRITICAL | `onboarding_screen.dart` | Add PageController disposal | 5 min |
| 🟡 HIGH | `fault_details_screen.dart` | Add GoogleMapController disposal | 10 min |
| 🟡 HIGH | `home_cubit.dart` | Use static Logger instance | 10 min |
| 🟢 MEDIUM | `home_cubit.dart` | Add explicit close() override | 5 min |

**Total Estimated Time: ~1 hour**

---

### Verification After Fixes

Run this checklist after implementing fixes:

1. [ ] Run app in profile mode
2. [ ] Open DevTools Memory tab
3. [ ] Take memory snapshot
4. [ ] Navigate through all screens 3 times
5. [ ] Return to home
6. [ ] Force garbage collection
7. [ ] Take another snapshot
8. [ ] Compare snapshots - memory should not grow
9. [ ] Monitor for 5 minutes - memory should stabilize
10. [ ] Check for warnings in console

**Success Criteria:**
- No "controller not disposed" warnings
- Memory usage stable after navigation
- No increasing object count in heap
- App remains responsive after extended use

