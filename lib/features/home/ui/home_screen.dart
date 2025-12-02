import 'package:egypt_fault_map/features/home/data/repos/fault_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/routing/routes.dart';
import '../data/models/fault_model.dart';
import '../logic/home_cubit.dart';
import '../logic/location/location_cubit.dart';
import '../logic/location/location_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(getIt<FaultRepository>()),
      child: const _HomeScreenContent(),
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

  @override
  void initState() {
    super.initState();
    _loadFaults();
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
    context.read<HomeCubit>().loadFaults(userPosition: userPosition);
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
        title: const Text("Egypt Fault Map"),
        actions: [
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
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HomeError) {
            return Center(child: Text("Error: ${state.message}"));
          } else if (state is HomeLoaded) {
            if (state.faults.isEmpty) {
              return _buildEmptyState();
            }
            return _isMapView ? _buildMapView(state) : _buildListView(state);
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.addFaultScreen).then((_) {
            _loadFaults();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 80.sp, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            "No Faults Reported Yet",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            "Tap + to report a fault",
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(HomeLoaded state) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: state.faults.length,
      itemBuilder: (context, index) {
        final fault = state.faults[index];
        double? distance;
        if (state.userPosition != null) {
          distance = Geolocator.distanceBetween(
            state.userPosition!.latitude,
            state.userPosition!.longitude,
            fault.location.lat,
            fault.location.lng,
          );
        }
        return _FaultCard(fault: fault, distance: distance);
      },
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

class _FaultCard extends StatelessWidget {
  final FaultModel fault;
  final double? distance;

  const _FaultCard({required this.fault, this.distance});

  String _getDistanceText() {
    if (distance == null) return "";
    if (distance! < 1000) {
      return "${distance!.toStringAsFixed(0)} m away";
    }
    return "${(distance! / 1000).toStringAsFixed(1)} km away";
  }

  Color _getStatusColor() {
    switch (fault.status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in-progress':
        return Colors.blue;
      case 'done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        contentPadding: EdgeInsets.all(12.w),
        leading: fault.imageUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  fault.imageUrl,
                  width: 60.w,
                  height: 60.h,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.broken_image, size: 60.sp, color: Colors.grey),
                ),
              )
            : Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.location_on,
                  size: 30.sp,
                  color: Colors.grey[600],
                ),
              ),
        title: Text(
          fault.type.toUpperCase(),
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Text(
              fault.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    fault.status.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (distance != null) ...[
                  SizedBox(width: 8.w),
                  Icon(Icons.location_on, size: 14.sp, color: Colors.grey),
                  SizedBox(width: 2.w),
                  Text(
                    _getDistanceText(),
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.faultDetailsScreen,
            arguments: {'fault': fault, 'distance': distance},
          );
        },
      ),
    );
  }
}
