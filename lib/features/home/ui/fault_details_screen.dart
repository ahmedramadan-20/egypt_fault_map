import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/theming/app_colors.dart';
import '../data/models/fault_model.dart';
import '../logic/fault_details/fault_details_cubit.dart';
import '../logic/fault_details/fault_details_state.dart';

class FaultDetailsScreen extends StatelessWidget {
  final FaultModel fault;
  final double? distance;

  const FaultDetailsScreen({super.key, required this.fault, this.distance});

  Color _getStatusColor() {
    switch (fault.status.toLowerCase()) {
      case 'pending':
        return AppColors.statusPending;
      case 'in-progress':
        return AppColors.statusInProgress;
      case 'done':
        return AppColors.statusDone;
      default:
        return AppColors.statusUnknown;
    }
  }

  Color _getSeverityColor() {
    switch (fault.severity.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      case 'low':
        return AppColors.success;
      default:
        return AppColors.grey;
    }
  }

  String _getDistanceText() {
    if (distance == null) return "Unknown distance";
    if (distance! < 1000) {
      return "${distance!.toStringAsFixed(0)} m away";
    }
    return "${(distance! / 1000).toStringAsFixed(1)} km away";
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FaultDetailsCubit(getIt<FirebaseFirestore>())
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
    return Hero(
      tag: 'fault_${fault.id}',
      child: Material(
        child: Column(
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
                          position: LatLng(
                            fault.location.lat,
                            fault.location.lng,
                          ),
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
            // Details Section
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type & Status Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            fault.type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            fault.status.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    // Severity
                    Row(
                      children: [
                        Icon(
                          Icons.warning,
                          size: 20.sp,
                          color: _getSeverityColor(),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "Severity: ${fault.severity}",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: _getSeverityColor(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Divider(),
                    SizedBox(height: 16.h),
                    // Description
                    Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(fault.description, style: TextStyle(fontSize: 14.sp)),
                    SizedBox(height: 16.h),
                    Divider(),
                    SizedBox(height: 16.h),
                    // Reporter Info with Picture
                    _buildReporterInfo(state),
                    SizedBox(height: 12.h),
                    // Location Info
                    _buildInfoRow(
                      Icons.location_on,
                      "Location",
                      "${fault.location.lat.toStringAsFixed(6)}, ${fault.location.lng.toStringAsFixed(6)}",
                    ),
                    if (distance != null) ...[
                      SizedBox(height: 12.h),
                      _buildInfoRow(
                        Icons.straighten,
                        "Distance",
                        _getDistanceText(),
                      ),
                    ],
                    SizedBox(height: 12.h),
                    _buildInfoRow(
                      Icons.calendar_today,
                      "Reported",
                      DateFormat(
                        'MMM dd, yyyy • hh:mm a',
                      ).format(fault.createdAt.toDate()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReporterInfo(FaultDetailsLoaded state) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey300),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          // Profile Picture
          _buildProfilePicture(state),
          SizedBox(width: 12.w),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Reported by",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  state.reporterName,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (state.reporterEmail.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    state.reporterEmail,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicture(FaultDetailsLoaded state) {
    final profileImage = state.profileImage;

    // Default icon if null or empty
    if (profileImage == null || profileImage.isEmpty) {
      return CircleAvatar(
        radius: 28.r,
        backgroundColor: Colors.grey[300],
        child: Icon(Icons.person, size: 28.sp, color: Colors.grey[600]),
      );
    }

    // Network URL (http:// or https://)
    if (profileImage.startsWith('http://') ||
        profileImage.startsWith('https://')) {
      return CircleAvatar(
        radius: 28.r,
        backgroundColor: Colors.grey[300],
        backgroundImage: NetworkImage(profileImage),
        onBackgroundImageError: (exception, stackTrace) {
          // If network image fails, widget will show backgroundColor
        },
      );
    }

    // Asset path (assets/images/...)
    return CircleAvatar(
      radius: 28.r,
      backgroundColor: Colors.grey[300],
      backgroundImage: AssetImage(profileImage),
      onBackgroundImageError: (exception, stackTrace) {
        // If asset fails, widget will show backgroundColor
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.sp, color: Colors.grey[600]),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
