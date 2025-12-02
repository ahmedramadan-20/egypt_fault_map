import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/di/dependency_injection.dart';
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
        return Colors.orange;
      case 'in-progress':
        return Colors.blue;
      case 'done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getSeverityColor() {
    switch (fault.severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getDistanceText() {
    if (distance == null) return "Unknown distance";
    if (distance! < 1000) {
      return "${distance!.toStringAsFixed(0)} m away";
    }
    return "${(distance! / 1000).toStringAsFixed(1)} km away";
  }

  Future<BitmapDescriptor> _getCustomMarker() async {
    String assetPath;
    switch (fault.severity.toLowerCase()) {
      case 'high':
        assetPath = 'assets/images/high_severtity_marker.png';
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
    return BitmapDescriptor.fromBytes(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FaultDetailsCubit(getIt<FirebaseFirestore>())
            ..loadReporterInfo(fault.createdBy),
      child: Scaffold(
        appBar: AppBar(title: const Text("Fault Details")),
        body: Column(
          children: [
            // Map Section
            SizedBox(
              height: 250.h,
              child: FutureBuilder<BitmapDescriptor>(
                future: _getCustomMarker(),
                builder: (context, snapshot) {
                  return GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(fault.location.lat, fault.location.lng),
                      zoom: 16,
                    ),
                    markers: snapshot.hasData
                        ? {
                            Marker(
                              markerId: MarkerId(fault.id),
                              position: LatLng(
                                fault.location.lat,
                                fault.location.lng,
                              ),
                              icon: snapshot.data!,
                              infoWindow: InfoWindow(
                                title: fault.type.toUpperCase(),
                                snippet: fault.description,
                              ),
                            ),
                          }
                        : {},
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  );
                },
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
                    BlocBuilder<FaultDetailsCubit, FaultDetailsState>(
                      builder: (context, state) {
                        return _buildReporterInfo(state);
                      },
                    ),
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

  Widget _buildReporterInfo(FaultDetailsState state) {
    String displayName = "Loading...";
    Widget profilePic = Icon(Icons.person, size: 20.sp);

    if (state is FaultDetailsLoaded) {
      displayName = state.reporterName;

      if (state.profilePicUrl != null) {
        if (state.isDefaultPic) {
          // Use asset image path (saved from user creation)
          profilePic = CircleAvatar(
            radius: 20.r,
            backgroundImage: AssetImage(state.profilePicUrl!),
            onBackgroundImageError: (_, __) {},
          );
        } else {
          // Use network URL
          profilePic = CircleAvatar(
            radius: 20.r,
            backgroundImage: NetworkImage(state.profilePicUrl!),
            onBackgroundImageError: (_, __) {},
          );
        }
      } else {
        // Fallback to icon if no profile pic at all
        profilePic = CircleAvatar(
          radius: 20.r,
          child: Icon(Icons.person, size: 20.sp),
        );
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.person, size: 20.sp, color: Colors.grey[600]),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Reported by",
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  profilePic,
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
