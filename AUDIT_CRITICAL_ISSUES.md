## 2. Critical Issues - Detailed Analysis

### Issue #1: LocationCubit Created at App Root - Memory Leak
**File:** `lib/app.dart` (lines 18-19)  
**Severity:** CRITICAL  
**Category:** Memory Management

#### Problem:
```dart
class EgyptFaultMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocationCubit()..getLocation(),  // ❌ Never disposed
      child: ScreenUtilInit(
        child: MaterialApp(...),
      ),
    );
  }
}
```

The LocationCubit is created at the root of the widget tree (above MaterialApp) and has a `StreamSubscription<Position>` that continuously listens to location updates. Since the app widget never gets disposed, this subscription runs forever, causing:
- Memory leak from unclosed stream
- Battery drain from continuous location tracking
- Unnecessary CPU usage

#### Fix:
```dart
class EgyptFaultMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      child: MaterialApp(
        title: 'Egypt Fault Map',
        debugShowCheckedModeBanner: false,
        initialRoute: initialRoute,
        onGenerateRoute: appRouter.generateRoute,
      ),
    );
  }
}
```

Move LocationCubit to HomeScreen:
```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

**Impact:** High - Fixes memory leak and reduces battery consumption

---

### Issue #2: TextEditingControllers Created in build() - Critical Memory Leak
**File:** `lib/features/auth/ui/widgets/login_form.dart` (lines 31, 44)  
**Severity:** CRITICAL  
**Category:** Memory Management

#### Problem:
```dart
class LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          AppTextFormField(
            controller: TextEditingController(),  // ❌ New instance on every rebuild
            // ...
          ),
          AppTextFormField(
            controller: TextEditingController(),  // ❌ Another leak
            // ...
          ),
        ],
      ),
    );
  }
}
```

Every time the widget rebuilds (which happens on every state change in BlocListener), new TextEditingController instances are created but never disposed. This causes:
- Memory leak accumulating with each rebuild
- Loss of user input on rebuild
- Performance degradation

#### Fix:
```dart
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();

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

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccessState) {
          context.pushReplacementNamed(Routes.homeScreen);
        } else if (state is LoginFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppTextFormField(
              hintText: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            AppTextFormField(
              hintText: 'Password',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              controller: _passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: BlocBuilder<LoginCubit, LoginState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state is LoginLoadingState
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<LoginCubit>().login(
                                    _emailController.text,
                                    _passwordController.text,
                                  );
                            }
                          },
                    child: state is LoginLoadingState
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Impact:** Critical - Prevents severe memory leaks and data loss

---

### Issue #3: PageController Never Disposed
**File:** `lib/features/on_boarding/ui/onboarding_screen.dart` (line 17)  
**Severity:** CRITICAL  
**Category:** Memory Management

#### Problem:
```dart
class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  // ... no dispose() method
}
```

PageController maintains animation resources and listeners that must be disposed. Not disposing causes memory leaks.

#### Fix:
```dart
class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ... existing code ...

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ... rest of the code
}
```

**Impact:** Medium-High - Memory leak on onboarding screen (only shown once per user)

---

### Issue #4: Logger Instance Per Cubit - Resource Waste
**File:** `lib/features/home/logic/home_cubit.dart` (line 36)  
**Severity:** CRITICAL  
**Category:** Memory Management / Performance

#### Problem:
```dart
class HomeCubit extends Cubit<HomeState> {
  final IFaultRepository _faultRepo;
  final Logger _logger = Logger();  // ❌ New instance per cubit

  HomeCubit(this._faultRepo) : super(HomeInitial());
}
```

Logger creates multiple internal buffers and formatting resources. Creating one per cubit instance wastes memory and resources.

#### Fix:
```dart
import 'package:logger/logger.dart';

// Create a global logger instance
final _logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: false,
  ),
);

class HomeCubit extends Cubit<HomeState> {
  final IFaultRepository _faultRepo;

  HomeCubit(this._faultRepo) : super(HomeInitial());

  Future<void> loadFaults({Position? userPosition}) async {
    _logger.d(
      "HomeCubit: loadFaults called. UserPosition: ${userPosition?.latitude}, ${userPosition?.longitude}",
    );
    // ... rest of code
  }
}
```

**Alternative:** Inject logger via DI:
```dart
// In dependency_injection.dart
getIt.registerLazySingleton<Logger>(() => Logger());

// In cubit
class HomeCubit extends Cubit<HomeState> {
  final IFaultRepository _faultRepo;
  final Logger _logger;

  HomeCubit(this._faultRepo, this._logger) : super(HomeInitial());
}
```

**Impact:** Medium - Reduces memory usage and improves performance

---

### Issue #5: Reading Cubit in Build Causing Excessive Rebuilds
**File:** `lib/features/home/ui/add_fault_screen.dart` (lines 104-114)  
**Severity:** CRITICAL  
**Category:** Performance

#### Problem:
```dart
builder: (context, state) {
  return Column(
    children: [
      Expanded(
        flex: 1,
        child: GoogleMap(
          // ...
          markers: context.read<AddFaultCubit>().selectedLocation != null  // ❌ Reading cubit in build
              ? {
                  Marker(
                    markerId: const MarkerId('selected'),
                    position: context.read<AddFaultCubit>().selectedLocation!,  // ❌ Again
                  ),
                }
              : {},
        ),
      ),
    ],
  );
}
```

Using `context.read<>()` to access state in the builder causes:
- GoogleMap widget rebuilt unnecessarily
- Markers recreated on every state emission
- Poor performance and jank

#### Fix:
Add selectedLocation to AddFaultState:
```dart
// add_fault_state.dart
abstract class AddFaultState {
  final LatLng? selectedLocation;
  const AddFaultState({this.selectedLocation});
}

class AddFaultInitial extends AddFaultState {
  const AddFaultInitial() : super(selectedLocation: null);
}

class AddFaultLoading extends AddFaultState {
  const AddFaultLoading({super.selectedLocation});
}

class AddFaultSuccess extends AddFaultState {
  const AddFaultSuccess() : super(selectedLocation: null);
}

class AddFaultError extends AddFaultState {
  final String message;
  const AddFaultError(this.message, {super.selectedLocation});
}

class AddFaultLocationSelected extends AddFaultState {
  const AddFaultLocationSelected(LatLng location) : super(selectedLocation: location);
}
```

Update cubit:
```dart
class AddFaultCubit extends Cubit<AddFaultState> {
  final IFaultRepository _faultRepo;
  final FirebaseAuth _firebaseAuth;

  AddFaultCubit(this._faultRepo, this._firebaseAuth) : super(const AddFaultInitial());

  void init(LatLng? initialLocation) {
    if (initialLocation != null) {
      emit(AddFaultLocationSelected(initialLocation));
    }
  }

  void selectLocation(LatLng location) {
    emit(AddFaultLocationSelected(location));
  }

  Future<void> addFault({
    required String type,
    required String description,
    required String severity,
  }) async {
    final selectedLocation = state.selectedLocation;
    if (selectedLocation == null) {
      emit(AddFaultError("Please select a location on the map."));
      return;
    }
    // ... rest of implementation
  }
}
```

Update UI:
```dart
builder: (context, state) {
  return Column(
    children: [
      Expanded(
        flex: 1,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _initialPosition,
            zoom: 15,
          ),
          onTap: (latLng) {
            context.read<AddFaultCubit>().selectLocation(latLng);
          },
          markers: state.selectedLocation != null
              ? {
                  Marker(
                    markerId: const MarkerId('selected'),
                    position: state.selectedLocation!,
                  ),
                }
              : {},
        ),
      ),
      // ... rest
    ],
  );
}
```

**Impact:** High - Significantly improves performance and reduces rebuilds

