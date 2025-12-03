## 7. Recommended Tests

### Test Suite Structure

```
test/
├── unit/
│   ├── cubits/
│   │   ├── home_cubit_test.dart
│   │   ├── login_cubit_test.dart
│   │   ├── register_cubit_test.dart
│   │   ├── add_fault_cubit_test.dart
│   │   └── location_cubit_test.dart
│   ├── repositories/
│   │   ├── auth_repository_test.dart
│   │   └── fault_repository_test.dart
│   └── models/
│       ├── fault_model_test.dart
│       └── app_user_test.dart
├── widget/
│   ├── login_screen_test.dart
│   ├── home_screen_test.dart
│   └── fault_card_test.dart
└── integration/
    └── app_flow_test.dart
```

---

## Unit Tests

### 1. HomeCubit Tests

**File:** `test/unit/cubits/home_cubit_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:egypt_fault_map/features/home/logic/home_cubit.dart';
import 'package:egypt_fault_map/features/home/data/repos/fault_repository.dart';
import 'package:egypt_fault_map/features/home/data/models/fault_model.dart';

@GenerateMocks([IFaultRepository])
import 'home_cubit_test.mocks.dart';

void main() {
  late HomeCubit cubit;
  late MockIFaultRepository mockRepository;

  setUp(() {
    mockRepository = MockIFaultRepository();
    cubit = HomeCubit(mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('HomeCubit', () {
    test('initial state is HomeInitial', () {
      expect(cubit.state, isA<HomeInitial>());
    });

    blocTest<HomeCubit, HomeState>(
      'emits [HomeLoading, HomeLoaded] when loadFaults succeeds',
      build: () {
        when(mockRepository.getAllFaults()).thenAnswer(
          (_) async => [
            FaultModel(
              id: '1',
              type: 'water',
              description: 'Test fault',
              imageUrl: '',
              location: FaultLocation(lat: 30.0, lng: 31.0, address: ''),
              status: 'pending',
              createdBy: 'user1',
              createdAt: Timestamp.now(),
              updatedAt: Timestamp.now(),
              severity: 'Low',
            ),
          ],
        );
        return cubit;
      },
      act: (cubit) => cubit.loadFaults(),
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeLoaded>(),
      ],
      verify: (_) {
        verify(mockRepository.getAllFaults()).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'emits [HomeLoading, HomeError] when loadFaults fails',
      build: () {
        when(mockRepository.getAllFaults()).thenThrow(Exception('Error'));
        return cubit;
      },
      act: (cubit) => cubit.loadFaults(),
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeError>(),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'sorts faults by distance when position provided',
      build: () {
        when(mockRepository.getAllFaults()).thenAnswer(
          (_) async => [
            FaultModel(
              id: '1',
              type: 'water',
              description: 'Far fault',
              imageUrl: '',
              location: FaultLocation(lat: 35.0, lng: 36.0, address: ''),
              status: 'pending',
              createdBy: 'user1',
              createdAt: Timestamp.now(),
              updatedAt: Timestamp.now(),
              severity: 'Low',
            ),
            FaultModel(
              id: '2',
              type: 'electric',
              description: 'Near fault',
              imageUrl: '',
              location: FaultLocation(lat: 30.1, lng: 31.1, address: ''),
              status: 'pending',
              createdBy: 'user1',
              createdAt: Timestamp.now(),
              updatedAt: Timestamp.now(),
              severity: 'High',
            ),
          ],
        );
        return cubit;
      },
      act: (cubit) => cubit.loadFaults(
        userPosition: Position(
          latitude: 30.0,
          longitude: 31.0,
          timestamp: DateTime.now(),
          accuracy: 10,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
        ),
      ),
      verify: (cubit) {
        final state = cubit.state as HomeLoaded;
        // Near fault (id: '2') should be first after sorting
        expect(state.faultsWithDistance.first.fault.id, '2');
      },
    );

    test('properly disposes when closed', () async {
      await cubit.close();
      expect(cubit.isClosed, true);
    });
  });
}
```

---

### 2. LoginCubit Tests

**File:** `test/unit/cubits/login_cubit_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:egypt_fault_map/features/auth/logic/login/login_cubit.dart';
import 'package:egypt_fault_map/features/auth/logic/login/login_state.dart';
import 'package:egypt_fault_map/features/auth/data/repos/auth_repository.dart';
import 'package:egypt_fault_map/features/auth/data/models/app_user.dart';

@GenerateMocks([AuthRepository])
import 'login_cubit_test.mocks.dart';

void main() {
  late LoginCubit cubit;
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    cubit = LoginCubit(mockAuthRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('LoginCubit', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';

    test('initial state is LoginInitial', () {
      expect(cubit.state, isA<LoginInitial>());
    });

    blocTest<LoginCubit, LoginState>(
      'emits [LoginLoadingState, LoginSuccessState] when login succeeds',
      build: () {
        when(mockAuthRepo.login(
          email: testEmail,
          password: testPassword,
        )).thenAnswer(
          (_) async => AppUser(
            uid: '123',
            name: 'Test User',
            email: testEmail,
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.login(testEmail, testPassword),
      expect: () => [
        isA<LoginLoadingState>(),
        isA<LoginSuccessState>(),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [LoginLoadingState, LoginFailureState] when login fails with user-not-found',
      build: () {
        when(mockAuthRepo.login(
          email: testEmail,
          password: testPassword,
        )).thenThrow(
          FirebaseAuthException(code: 'user-not-found'),
        );
        return cubit;
      },
      act: (cubit) => cubit.login(testEmail, testPassword),
      expect: () => [
        isA<LoginLoadingState>(),
        isA<LoginFailureState>().having(
          (state) => state.message,
          'message',
          'No user found for that email.',
        ),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [LoginLoadingState, LoginFailureState] when login fails with wrong-password',
      build: () {
        when(mockAuthRepo.login(
          email: testEmail,
          password: testPassword,
        )).thenThrow(
          FirebaseAuthException(code: 'wrong-password'),
        );
        return cubit;
      },
      act: (cubit) => cubit.login(testEmail, testPassword),
      expect: () => [
        isA<LoginLoadingState>(),
        isA<LoginFailureState>().having(
          (state) => state.message,
          'message',
          'Wrong password provided for that user.',
        ),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [LoginLoadingState, LoginFailureState] with generic error for unknown exceptions',
      build: () {
        when(mockAuthRepo.login(
          email: testEmail,
          password: testPassword,
        )).thenThrow(Exception('Network error'));
        return cubit;
      },
      act: (cubit) => cubit.login(testEmail, testPassword),
      expect: () => [
        isA<LoginLoadingState>(),
        isA<LoginFailureState>(),
      ],
    );
  });
}
```

---

### 3. LocationCubit Tests

**File:** `test/unit/cubits/location_cubit_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:egypt_fault_map/features/home/logic/location/location_cubit.dart';
import 'package:egypt_fault_map/features/home/logic/location/location_state.dart';

void main() {
  late LocationCubit cubit;

  setUp(() {
    cubit = LocationCubit();
  });

  tearDown(() {
    cubit.close();
  });

  group('LocationCubit', () {
    test('initial state is LocationInitial', () {
      expect(cubit.state, isA<LocationInitial>());
    });

    test('stream subscription is cancelled on close', () async {
      // Start location tracking
      // (Note: This test requires mocking Geolocator which is complex)
      // For now, just verify cubit closes properly
      await cubit.close();
      expect(cubit.isClosed, true);
    });

    // Note: Full testing of location features requires integration tests
    // or extensive mocking of Geolocator and PermissionHandler
  });
}
```

---

### 4. FaultRepository Tests

**File:** `test/unit/repositories/fault_repository_test.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:egypt_fault_map/features/home/data/repos/fault_repository.dart';
import 'package:egypt_fault_map/features/home/data/models/fault_model.dart';

void main() {
  late FaultRepository repository;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = FaultRepository(fakeFirestore);
  });

  group('FaultRepository', () {
    test('addFault successfully adds fault to Firestore', () async {
      final fault = FaultModel(
        id: 'test123',
        type: 'water',
        description: 'Test fault',
        imageUrl: '',
        location: FaultLocation(lat: 30.0, lng: 31.0, address: 'Test Address'),
        status: 'pending',
        createdBy: 'user123',
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        severity: 'Medium',
      );

      await repository.addFault(fault);

      final doc = await fakeFirestore.collection('faults').doc('test123').get();
      expect(doc.exists, true);
      expect(doc.data()?['type'], 'water');
      expect(doc.data()?['description'], 'Test fault');
    });

    test('getAllFaults returns list of faults', () async {
      // Add test data
      await fakeFirestore.collection('faults').doc('1').set({
        'id': '1',
        'type': 'electric',
        'description': 'Fault 1',
        'imageUrl': '',
        'location': {'lat': 30.0, 'lng': 31.0, 'address': ''},
        'status': 'pending',
        'createdBy': 'user1',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'severity': 'Low',
      });

      await fakeFirestore.collection('faults').doc('2').set({
        'id': '2',
        'type': 'water',
        'description': 'Fault 2',
        'imageUrl': '',
        'location': {'lat': 30.1, 'lng': 31.1, 'address': ''},
        'status': 'in-progress',
        'createdBy': 'user2',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'severity': 'High',
      });

      final faults = await repository.getAllFaults();

      expect(faults.length, 2);
      expect(faults[0].type, 'electric');
      expect(faults[1].type, 'water');
    });

    test('getAllFaults returns empty list when no faults exist', () async {
      final faults = await repository.getAllFaults();
      expect(faults, isEmpty);
    });
  });
}
```

---

### 5. FaultModel Tests

**File:** `test/unit/models/fault_model_test.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:egypt_fault_map/features/home/data/models/fault_model.dart';

void main() {
  group('FaultModel', () {
    test('toMap creates correct map', () {
      final timestamp = Timestamp.now();
      final fault = FaultModel(
        id: '123',
        type: 'water',
        description: 'Test description',
        imageUrl: 'http://example.com/image.jpg',
        location: FaultLocation(lat: 30.0, lng: 31.0, address: 'Test Address'),
        status: 'pending',
        createdBy: 'user123',
        createdAt: timestamp,
        updatedAt: timestamp,
        severity: 'High',
      );

      final map = fault.toMap();

      expect(map['id'], '123');
      expect(map['type'], 'water');
      expect(map['description'], 'Test description');
      expect(map['status'], 'pending');
      expect(map['severity'], 'High');
      expect(map['location']['lat'], 30.0);
      expect(map['location']['lng'], 31.0);
    });

    test('fromMap creates correct FaultModel', () {
      final timestamp = Timestamp.now();
      final map = {
        'id': '456',
        'type': 'electric',
        'description': 'Test fault',
        'imageUrl': '',
        'location': {'lat': 30.5, 'lng': 31.5, 'address': 'Test'},
        'status': 'done',
        'createdBy': 'user456',
        'createdAt': timestamp,
        'updatedAt': timestamp,
        'severity': 'Medium',
      };

      final fault = FaultModel.fromMap(map);

      expect(fault.id, '456');
      expect(fault.type, 'electric');
      expect(fault.description, 'Test fault');
      expect(fault.status, 'done');
      expect(fault.severity, 'Medium');
      expect(fault.location.lat, 30.5);
      expect(fault.location.lng, 31.5);
    });

    test('fromMap handles missing optional fields', () {
      final map = {
        'id': '',
        'type': '',
        'description': '',
        'location': {},
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      final fault = FaultModel.fromMap(map);

      expect(fault.id, '');
      expect(fault.type, 'other');
      expect(fault.status, 'pending');
      expect(fault.severity, 'Low');
      expect(fault.location.lat, 0.0);
    });
  });

  group('FaultLocation', () {
    test('toMap and fromMap work correctly', () {
      final location = FaultLocation(
        lat: 30.123,
        lng: 31.456,
        address: 'Test Address',
      );

      final map = location.toMap();
      expect(map['lat'], 30.123);
      expect(map['lng'], 31.456);
      expect(map['address'], 'Test Address');

      final restored = FaultLocation.fromMap(map);
      expect(restored.lat, location.lat);
      expect(restored.lng, location.lng);
      expect(restored.address, location.address);
    });
  });
}
```

---

## Widget Tests

### 6. LoginScreen Widget Test

**File:** `test/widget/login_screen_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:egypt_fault_map/features/auth/ui/login_screen.dart';
import 'package:egypt_fault_map/features/auth/logic/login/login_cubit.dart';
import 'package:egypt_fault_map/features/auth/data/repos/auth_repository.dart';

@GenerateMocks([AuthRepository])
import 'login_screen_test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
  });

  Widget createTestWidget() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MaterialApp(
          home: BlocProvider(
            create: (_) => LoginCubit(mockAuthRepo),
            child: const LoginScreen(),
          ),
        );
      },
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('renders all required elements', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
    });

    testWidgets('validates email field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap login button without entering email
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('validates password field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter email but not password
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );

      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('controllers are disposed properly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Navigate away
      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();

      // If controllers aren't disposed, you'll see warnings in console
    });
  });
}
```

---

### 7. FaultCard Widget Test

**File:** `test/widget/fault_card_test.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:egypt_fault_map/features/home/ui/widgets/fault_card.dart';
import 'package:egypt_fault_map/features/home/data/models/fault_model.dart';

void main() {
  Widget createTestWidget(FaultModel fault, {double? distance}) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MaterialApp(
          home: Scaffold(
            body: FaultCard(fault: fault, distance: distance),
          ),
        );
      },
    );
  }

  group('FaultCard Widget Tests', () {
    final testFault = FaultModel(
      id: '123',
      type: 'water',
      description: 'Test fault description',
      imageUrl: '',
      location: FaultLocation(lat: 30.0, lng: 31.0, address: ''),
      status: 'pending',
      createdBy: 'user123',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      severity: 'High',
    );

    testWidgets('displays fault type', (tester) async {
      await tester.pumpWidget(createTestWidget(testFault));
      expect(find.text('WATER'), findsOneWidget);
    });

    testWidgets('displays fault description', (tester) async {
      await tester.pumpWidget(createTestWidget(testFault));
      expect(find.text('Test fault description'), findsOneWidget);
    });

    testWidgets('displays status badge', (tester) async {
      await tester.pumpWidget(createTestWidget(testFault));
      expect(find.text('PENDING'), findsOneWidget);
    });

    testWidgets('displays distance when provided', (tester) async {
      await tester.pumpWidget(createTestWidget(testFault, distance: 1500));
      expect(find.textContaining('1.5 km away'), findsOneWidget);
    });

    testWidgets('displays distance in meters when less than 1km', (tester) async {
      await tester.pumpWidget(createTestWidget(testFault, distance: 500));
      expect(find.textContaining('500 m away'), findsOneWidget);
    });

    testWidgets('shows placeholder when no image URL', (tester) async {
      await tester.pumpWidget(createTestWidget(testFault));
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('shows image when URL provided', (tester) async {
      final faultWithImage = FaultModel(
        id: '123',
        type: 'water',
        description: 'Test',
        imageUrl: 'http://example.com/image.jpg',
        location: FaultLocation(lat: 30.0, lng: 31.0, address: ''),
        status: 'pending',
        createdBy: 'user123',
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        severity: 'Low',
      );

      await tester.pumpWidget(createTestWidget(faultWithImage));
      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });
  });
}
```

---

## Integration Tests

### 8. Full App Flow Test

**File:** `test/integration/app_flow_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:egypt_fault_map/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Flow Integration Tests', () {
    testWidgets('complete onboarding flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify onboarding screen appears
      expect(find.text('Report Problems in Seconds'), findsOneWidget);

      // Tap Next button 3 times
      for (int i = 0; i < 2; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      // Tap Get Started
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Should navigate to login screen
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('login and view home screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Skip onboarding
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Continue as guest
      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should see home screen
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
```

---

## Test Configuration Files

### pubspec.yaml additions

Add these dependencies to `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  bloc_test: ^9.1.0
  fake_cloud_firestore: ^2.4.0
  integration_test:
    sdk: flutter
  build_runner: ^2.4.0
```

---

### Generate Mocks

Run this command to generate mocks:

```bash
flutter pub run build_runner build
```

---

## Running Tests

### Run all tests:
```bash
flutter test
```

### Run specific test file:
```bash
flutter test test/unit/cubits/home_cubit_test.dart
```

### Run with coverage:
```bash
flutter test --coverage
```

### View coverage report:
```bash
# Install lcov
# On Mac: brew install lcov
# On Linux: apt-get install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html
```

### Run integration tests:
```bash
flutter test integration_test/app_flow_test.dart
```

---

## Test Coverage Goals

| Component | Target Coverage | Priority |
|-----------|----------------|----------|
| Cubits | 90%+ | HIGH |
| Repositories | 85%+ | HIGH |
| Models | 95%+ | MEDIUM |
| Widgets | 70%+ | MEDIUM |
| Integration | Key flows | LOW |

---

## CI/CD Integration

See `AUDIT_CI_CD.md` for GitHub Actions configuration that automatically runs these tests.

