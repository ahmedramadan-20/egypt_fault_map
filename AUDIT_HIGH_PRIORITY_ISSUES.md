## 3. High Priority Issues - Detailed Analysis

### Issue #6: Distance Calculated in build() - Performance Issue
**File:** `lib/features/home/ui/home_screen.dart` (lines 146-162)  
**Severity:** HIGH  
**Category:** Performance

#### Problem:
```dart
Widget _buildListView(HomeLoaded state) {
  return ListView.builder(
    padding: EdgeInsets.all(16.w),
    itemCount: state.faults.length,
    itemBuilder: (context, index) {
      final fault = state.faults[index];
      double? distance;
      if (state.userPosition != null) {
        distance = Geolocator.distanceBetween(  // ❌ Calculated on every build
          state.userPosition!.latitude,
          state.userPosition!.longitude,
          fault.location.lat,
          fault.location.lng,
        );
      }
      return FaultCard(fault: fault, distance: distance);
    },
  );
}
```

Distance calculation happens every time the list scrolls or rebuilds. This is inefficient.

#### Fix:
Create a FaultWithDistance model:
```dart
// In home_state.dart
class FaultWithDistance {
  final FaultModel fault;
  final double? distance;
  
  const FaultWithDistance(this.fault, this.distance);
}

class HomeLoaded extends HomeState {
  final List<FaultWithDistance> faultsWithDistance;
  final Set<Marker> markers;
  final Position? userPosition;

  HomeLoaded(this.faultsWithDistance, this.markers, this.userPosition);
}
```

Update cubit to pre-calculate:
```dart
Future<void> loadFaults({Position? userPosition}) async {
  _logger.d("HomeCubit: loadFaults called.");
  emit(HomeLoading());
  try {
    await _loadCustomMarkers();
    var faults = await _faultRepo.getAllFaults();

    // Calculate distances and sort if user position is available
    List<FaultWithDistance> faultsWithDistance;
    if (userPosition != null) {
      _logger.d("HomeCubit: Sorting faults by distance in background...");
      faultsWithDistance = await compute(_calculateDistances, {
        'faults': faults,
        'pos': userPosition,
      });
    } else {
      faultsWithDistance = faults.map((f) => FaultWithDistance(f, null)).toList();
    }

    final markers = _getMarkers(faults);
    _logger.d("HomeCubit: Emitting HomeLoaded with ${faults.length} faults");
    emit(HomeLoaded(faultsWithDistance, markers, userPosition));
  } catch (e) {
    _logger.e("HomeCubit: Error loading faults", error: e);
    emit(HomeError(e.toString()));
  }
}

// Top-level function
List<FaultWithDistance> _calculateDistances(Map<String, dynamic> data) {
  final faults = data['faults'] as List<FaultModel>;
  final userPos = data['pos'] as Position;
  
  final faultsWithDistance = faults.map((fault) {
    final distance = Geolocator.distanceBetween(
      userPos.latitude,
      userPos.longitude,
      fault.location.lat,
      fault.location.lng,
    );
    return FaultWithDistance(fault, distance);
  }).toList();
  
  faultsWithDistance.sort((a, b) => a.distance!.compareTo(b.distance!));
  return faultsWithDistance;
}
```

Update UI:
```dart
Widget _buildListView(HomeLoaded state) {
  return ListView.builder(
    padding: EdgeInsets.all(16.w),
    itemCount: state.faultsWithDistance.length,
    itemBuilder: (context, index) {
      final item = state.faultsWithDistance[index];
      return FaultCard(fault: item.fault, distance: item.distance);
    },
  );
}
```

**Impact:** High - Eliminates redundant calculations, improves scroll performance

---

### Issue #7: GoogleMap Recreated on Every State Change
**File:** `lib/features/home/ui/add_fault_screen.dart` (lines 96-115)  
**Severity:** HIGH  
**Category:** Performance

#### Problem:
```dart
builder: (context, state) {
  return Column(
    children: [
      Expanded(
        flex: 1,
        child: GoogleMap(  // ❌ Recreated on every state emission
          initialCameraPosition: CameraPosition(
            target: _initialPosition,
            zoom: 15,
          ),
          onTap: (latLng) {
            context.read<AddFaultCubit>().selectLocation(latLng);
          },
          markers: /* ... */,
        ),
      ),
      // ... form
    ],
  );
}
```

GoogleMap is an expensive widget to create. Rebuilding it on every state change causes jank.

#### Fix:
Extract map to a separate widget:
```dart
class _MapSelector extends StatelessWidget {
  final LatLng initialPosition;
  final LatLng? selectedLocation;
  final Function(LatLng) onLocationSelected;

  const _MapSelector({
    required this.initialPosition,
    required this.selectedLocation,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 15,
      ),
      onTap: onLocationSelected,
      markers: selectedLocation != null
          ? {
              Marker(
                markerId: const MarkerId('selected'),
                position: selectedLocation!,
              ),
            }
          : {},
    );
  }
}
```

Use in parent:
```dart
builder: (context, state) {
  return Column(
    children: [
      Expanded(
        flex: 1,
        child: _MapSelector(
          initialPosition: _initialPosition,
          selectedLocation: state.selectedLocation,
          onLocationSelected: (latLng) {
            context.read<AddFaultCubit>().selectLocation(latLng);
          },
        ),
      ),
      Expanded(
        flex: 1,
        child: _buildForm(context, state),
      ),
    ],
  );
}
```

**Impact:** High - Reduces rebuilds and improves map interaction performance

---

### Issue #8: Marker Loaded in FutureBuilder - Performance Issue
**File:** `lib/features/home/ui/fault_details_screen.dart` (lines 53-78, 93-121)  
**Severity:** HIGH  
**Category:** Performance

#### Problem:
```dart
SizedBox(
  height: 250.h,
  child: FutureBuilder<BitmapDescriptor>(  // ❌ Marker loaded every build
    future: _getCustomMarker(),
    builder: (context, snapshot) {
      return GoogleMap(
        // ...
        markers: snapshot.hasData ? { /* marker */ } : {},
      );
    },
  ),
)
```

The marker is loaded from assets every time the widget builds. This is inefficient.

#### Fix:
Load marker in cubit:
```dart
// fault_details_state.dart
abstract class FaultDetailsState {}

class FaultDetailsInitial extends FaultDetailsState {}

class FaultDetailsLoading extends FaultDetailsState {}

class FaultDetailsLoaded extends FaultDetailsState {
  final String reporterName;
  final String? profilePicUrl;
  final bool isDefaultPic;
  final BitmapDescriptor? markerIcon;

  FaultDetailsLoaded({
    required this.reporterName,
    this.profilePicUrl,
    this.isDefaultPic = false,
    this.markerIcon,
  });
}

class FaultDetailsError extends FaultDetailsState {
  final String message;
  FaultDetailsError(this.message);
}
```

Update cubit:
```dart
class FaultDetailsCubit extends Cubit<FaultDetailsState> {
  final FirebaseFirestore _firestore;

  FaultDetailsCubit(this._firestore) : super(FaultDetailsInitial());

  Future<void> loadReporterInfo(String userId, String severity) async {
    emit(FaultDetailsLoading());

    try {
      // Load marker and user data in parallel
      final results = await Future.wait([
        _getCustomMarker(severity),
        _firestore.collection('users').doc(userId).get(),
      ]);

      final markerIcon = results[0] as BitmapDescriptor;
      final userDoc = results[1] as DocumentSnapshot;

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        final userName = userData?['name'] ?? 'Unknown User';
        final profilePic = userData?['profilePic'];

        final isUrl = profilePic != null &&
            (profilePic.startsWith('http://') || profilePic.startsWith('https://'));

        emit(FaultDetailsLoaded(
          reporterName: userName,
          profilePicUrl: profilePic,
          isDefaultPic: !isUrl,
          markerIcon: markerIcon,
        ));
      } else {
        emit(FaultDetailsLoaded(
          reporterName: 'Unknown User',
          profilePicUrl: null,
          isDefaultPic: true,
          markerIcon: markerIcon,
        ));
      }
    } catch (e) {
      emit(FaultDetailsError(e.toString()));
    }
  }

  Future<BitmapDescriptor> _getCustomMarker(String severity) async {
    String assetPath;
    switch (severity.toLowerCase()) {
      case 'high':
        assetPath = 'assets/images/high_severity_marker.png';
        break;
      case 'medium':
        assetPath = 'assets/images/medium_severity_marker.png';
        break;
      case 'low':
      default:
        assetPath = 'assets/images/low_severity_marker.png';
        break;
    }

    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 100,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final bytes = (await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
    return BitmapDescriptor.bytes(bytes);  // Use new API
  }
}
```

Update screen:
```dart
@override
Widget build(BuildContext context) {
  return BlocProvider(
    create: (context) => FaultDetailsCubit(getIt<FirebaseFirestore>())
      ..loadReporterInfo(fault.createdBy, fault.severity),
    child: Scaffold(
      appBar: AppBar(title: const Text("Fault Details")),
      body: BlocBuilder<FaultDetailsCubit, FaultDetailsState>(
        builder: (context, state) {
          if (state is FaultDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is FaultDetailsError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          
          if (state is FaultDetailsLoaded) {
            return _buildContent(state);
          }
          
          return const SizedBox.shrink();
        },
      ),
    ),
  );
}

Widget _buildContent(FaultDetailsLoaded state) {
  return Column(
    children: [
      // Map Section
      SizedBox(
        height: 250.h,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(fault.location.lat, fault.location.lng),
            zoom: 16,
          ),
          markers: state.markerIcon != null
              ? {
                  Marker(
                    markerId: MarkerId(fault.id),
                    position: LatLng(fault.location.lat, fault.location.lng),
                    icon: state.markerIcon!,
                    infoWindow: InfoWindow(
                      title: fault.type.toUpperCase(),
                      snippet: fault.description,
                    ),
                  ),
                }
              : {},
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        ),
      ),
      // Rest of content...
    ],
  );
}
```

**Impact:** High - Eliminates async work in build, improves performance

---

### Issue #9: MaterialApp Rebuilt When LocationCubit Emits
**File:** `lib/app.dart` (lines 18-29)  
**Severity:** HIGH  
**Category:** Performance

#### Problem:
```dart
return BlocProvider(
  create: (context) => LocationCubit()..getLocation(),
  child: ScreenUtilInit(
    child: MaterialApp(  // ❌ Rebuilt on every location update
      title: 'Egypt Fault Map',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      onGenerateRoute: appRouter.generateRoute,
    ),
  ),
);
```

When LocationCubit emits new states (which happens continuously as user moves), the entire MaterialApp gets rebuilt unnecessarily.

#### Fix:
Move BlocProvider inside MaterialApp or to specific screens:
```dart
class EgyptFaultMap extends StatelessWidget {
  final AppRouter appRouter;
  final String initialRoute;

  const EgyptFaultMap({
    super.key,
    required this.appRouter,
    required this.initialRoute,
  });

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

**Impact:** High - Prevents unnecessary rebuilds of entire app

---

### Issue #10: Generic Exception Wrapping Loses Error Info
**File:** `lib/features/auth/data/repos/auth_repository.dart` (lines 46, 80)  
**Severity:** HIGH  
**Category:** Error Handling

#### Problem:
```dart
} catch (e) {
  throw Exception(e.toString());  // ❌ Loses stack trace and error type
}
```

Wrapping exceptions in generic Exception loses:
- Original stack trace
- Error type information
- Debugging context

#### Fix:
Create custom exceptions:
```dart
// lib/core/errors/exceptions.dart
class AuthException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AuthException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AuthException: $message${code != null ? ' (code: $code)' : ''}';
}

class DatabaseException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  DatabaseException({
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'DatabaseException: $message';
}
```

Update repository:
```dart
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
    await cacheHelper.saveData(key: "uid", value: appUser.uid);

    return appUser;
  } on FirebaseAuthException catch (e, stackTrace) {
    throw AuthException(
      message: e.message ?? 'Authentication failed',
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
```

**Impact:** High - Improves debugging and error handling

---

### Issue #11: No Pagination - Performance Issue
**File:** `lib/features/home/data/repos/fault_repository.dart` (lines 19-21)  
**Severity:** HIGH  
**Category:** Performance / Scalability

#### Problem:
```dart
@override
Future<List<FaultModel>> getAllFaults() async {
  final snapshot = await firestore.collection('faults').get();  // ❌ Fetches ALL documents
  return snapshot.docs.map((doc) => FaultModel.fromDoc(doc)).toList();
}
```

As the app grows, this will:
- Fetch thousands of documents
- Consume excessive bandwidth
- Cause memory issues
- Slow down the app significantly

#### Fix:
```dart
abstract class IFaultRepository {
  Future<void> addFault(FaultModel fault);
  Future<List<FaultModel>> getFaults({
    int limit = 50,
    DocumentSnapshot? startAfter,
  });
  Stream<List<FaultModel>> watchFaults({int limit = 50});
}

class FaultRepository implements IFaultRepository {
  final FirebaseFirestore firestore;

  FaultRepository(this.firestore);

  @override
  Future<void> addFault(FaultModel fault) async {
    await firestore.collection('faults').doc(fault.id).set(fault.toMap());
  }

  @override
  Future<List<FaultModel>> getFaults({
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = firestore
        .collection('faults')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => FaultModel.fromDoc(doc)).toList();
  }

  @override
  Stream<List<FaultModel>> watchFaults({int limit = 50}) {
    return firestore
        .collection('faults')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => FaultModel.fromDoc(doc)).toList());
  }

  // For location-based queries
  Future<List<FaultModel>> getFaultsNearLocation({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int limit = 50,
  }) async {
    // Implement geohash or bounds-based query
    // For simplicity, fetch and filter (in production, use geofirestore package)
    final snapshot = await firestore
        .collection('faults')
        .limit(limit)
        .get();
    
    return snapshot.docs
        .map((doc) => FaultModel.fromDoc(doc))
        .where((fault) {
          final distance = Geolocator.distanceBetween(
            latitude,
            longitude,
            fault.location.lat,
            fault.location.lng,
          );
          return distance <= radiusInKm * 1000;
        })
        .toList();
  }
}
```

**Impact:** Critical for scalability - Prevents app from breaking as data grows

---

### Issue #12: Unnecessary ScreenUtil.ensureScreenSize() Call
**File:** `lib/main.dart` (line 15)  
**Severity:** HIGH  
**Category:** Performance

#### Problem:
```dart
await ScreenUtil.ensureScreenSize();  // ❌ Unnecessary, ScreenUtilInit handles this
```

This call is redundant because `ScreenUtilInit` already initializes the screen size properly.

#### Fix:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await setupGetIt();
  // Remove: await ScreenUtil.ensureScreenSize();

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
```

**Impact:** Low-Medium - Removes unnecessary initialization overhead

