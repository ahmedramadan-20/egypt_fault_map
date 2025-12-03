import 'package:egypt_fault_map/core/helpers/extensions.dart';
import 'package:egypt_fault_map/features/home/data/repos/fault_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../logic/home_cubit.dart';
import '../logic/location/location_cubit.dart';
import '../logic/location/location_state.dart';
import 'widgets/fault_card.dart';

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

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  GoogleMapController? _mapController;
  LatLng _initialPosition = const LatLng(30.0444, 31.2357); // Cairo default
  bool _isMapView = false; // Toggle between list and map
  bool _isRealTimeEnabled = true; // Enable real-time updates by default

  @override
  void initState() {
    super.initState();
    _loadFaults();
    _setupLocationListener();
  }

  void _setupLocationListener() {
    // Listen to location changes and update HomeCubit
    context.read<LocationCubit>().stream.listen((locationState) {
      if (locationState is LocationSuccess && mounted) {
        setState(() {
          _initialPosition = LatLng(
            locationState.position.latitude,
            locationState.position.longitude,
          );
        });
        // Update HomeCubit with new position for distance recalculation
        context.read<HomeCubit>().updateUserPosition(locationState.position);
      }
    });
  }

  void _loadFaults() {
    final locationState = context.read<LocationCubit>().state;
    Position? userPosition;
    if (locationState is LocationSuccess) {
      userPosition = locationState.position;
      _initialPosition = LatLng(
        locationState.position.latitude,
        locationState.position.longitude,
      );
    }
    _loadFaultsWithPosition(userPosition);
  }

  void _loadFaultsWithPosition(Position? userPosition) {
    // Use real-time updates if enabled, otherwise one-time load
    if (_isRealTimeEnabled) {
      context.read<HomeCubit>().enableRealTimeUpdates(
        userPosition: userPosition,
        limit: 100,
      );
    } else {
      context.read<HomeCubit>().loadFaults(userPosition: userPosition);
    }
  }

  void _toggleRealTimeUpdates() {
    setState(() {
      _isRealTimeEnabled = !_isRealTimeEnabled;
    });

    if (_isRealTimeEnabled) {
      // Enable real-time
      final locationState = context.read<LocationCubit>().state;
      Position? userPosition;
      if (locationState is LocationSuccess) {
        userPosition = locationState.position;
      }
      context.read<HomeCubit>().enableRealTimeUpdates(
        userPosition: userPosition,
        limit: 100,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Real-time updates enabled'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Disable real-time
      context.read<HomeCubit>().disableRealTimeUpdates();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Real-time updates disabled'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Profile button on the left
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            context.pushNamed(Routes.profileScreen);
          },
          tooltip: "Profile",
        ),
        title: const Text(AppStrings.appName),
        actions: [
          // Notifications button
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              context.pushNamed(Routes.notificationsScreen);
            },
            tooltip: "Notifications",
          ),
          // Real-time updates toggle
          IconButton(
            icon: Icon(
              _isRealTimeEnabled ? Icons.sync : Icons.sync_disabled,
              color: _isRealTimeEnabled ? Colors.green : null,
            ),
            onPressed: _toggleRealTimeUpdates,
            tooltip: _isRealTimeEnabled
                ? "Real-time updates enabled"
                : "Real-time updates disabled",
          ),
          // Map/List view toggle
          IconButton(
            icon: Icon(_isMapView ? Icons.list : Icons.map),
            onPressed: () {
              setState(() {
                _isMapView = !_isMapView;
              });
            },
            tooltip: _isMapView ? "List View" : "Map View",
          ),
        ],
      ),
      body: BlocListener<LocationCubit, LocationState>(
        listener: (context, state) {
          if (state is LocationSuccess) {
            // Only update position if faults are already loaded, don't reload
            final homeCubit = context.read<HomeCubit>();
            if (homeCubit.state is HomeLoaded) {
              homeCubit.updateUserPosition(state.position);
            } else {
              // Only load faults if not already loaded
              _loadFaults();
            }
          }
        },
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return _buildLoadingSkeleton();
            } else if (state is HomeError) {
              return Center(
                child: Text("${AppStrings.errorPrefix}${state.message}"),
              );
            } else if (state is HomeLoaded) {
              if (state.faultsWithDistance.isEmpty) {
                return _buildEmptyState();
              }
              return _isMapView
                  ? _buildMapView(state)
                  : _isRealTimeEnabled
                  ? _buildListView(
                      state,
                    ) // No pull-to-refresh when real-time is on
                  : RefreshIndicator(
                      onRefresh: () async {
                        _loadFaults();
                      },
                      child: _buildListView(state),
                    );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed(Routes.addFaultScreen).then((_) {
            _loadFaults();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.report_problem_outlined,
      title: 'No Faults Reported Yet',
      message:
          'Be the first to report a fault in your area and help improve the community.',
      actionLabel: 'Report First Fault',
      onActionPressed: () {
        context.pushNamed(Routes.addFaultScreen).then((_) {
          _loadFaults();
        });
      },
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 5,
      itemBuilder: (context, index) => const FaultCardSkeleton(),
    );
  }

  Widget _buildListView(HomeLoaded state) {
    return Column(
      children: [
        // Location permission banner
        BlocBuilder<LocationCubit, LocationState>(
          builder: (context, locationState) {
            if (locationState is LocationPermissionDenied ||
                locationState is LocationError) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: AppColors.warningLight.withOpacity(0.2),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.warning.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 20.sp,
                      color: AppColors.warning,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location access needed',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Enable location to see distances',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<LocationCubit>().getLocation();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Enable',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        // Real-time indicator banner
        if (_isRealTimeEnabled)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withOpacity(0.1),
                  AppColors.successLight.withOpacity(0.1),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.success.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8.sp,
                  height: 8.sp,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Live updates active',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: state.faultsWithDistance.length,
            itemBuilder: (context, index) {
              final item = state.faultsWithDistance[index];
              return FaultCard(fault: item.fault, distance: item.distance);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMapView(HomeLoaded state) {
    return RepaintBoundary(
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 12,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
        },
        markers: state.markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
